/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "profiler.h"
#include "foundation/macros.h"
#include "core/executing_context.h"
#include "bindings/qjs/exception_state.h"

#include <utility>
#include "stop_watch.h"

namespace webf {

static int64_t unique_profile_step_id_ = 0;

ProfileStep::ProfileStep(ProfileOpItem* owner, std::string label)
    : owner_(owner), label_(std::move(label)), id_(unique_profile_step_id_++) {
  stopwatch_.Begin();
}

ScriptValue ProfileStep::ToJSON(JSContext* ctx, const std::string& path, bool should_link) {
  JSValue json = JS_NewObject(ctx);

  JSValue duration_string = JS_NewString(ctx, (std::to_string(stopwatch_.elapsed()) + " us").c_str());
  JSValue label_string = JS_NewString(ctx, label_.c_str());

  JSValue child_steps_array = JS_NewArray(ctx);

  for(int i = 0; i < child_steps_.size(); i ++) {
    ScriptValue child_step_json = child_steps_[i]->ToJSON(ctx, path + "/" + std::to_string(i));
    JS_SetPropertyUint32(ctx, child_steps_array, i, JS_DupValue(ctx, child_step_json.QJSValue()));
  }

  JS_SetPropertyStr(ctx, json, "duration", duration_string);
  JS_SetPropertyStr(ctx, json, "label", label_string);
  JS_SetPropertyStr(ctx, json, "childSteps", child_steps_array);

  ScriptValue result = ScriptValue(ctx, json);

  JS_FreeValue(ctx, json);
  return result;
}

void ProfileStep::AddChildSteps(std::shared_ptr<ProfileStep> step) {
  child_steps_.emplace_back(step);
}

int64_t ProfileStep::id() {
  return id_;
}

ScriptValue LinkProfileStep::ToJSON(JSContext* ctx, const std::string& path, bool should_link) {
  ScriptValue json = ProfileStep::ToJSON(ctx, path);

  if (should_link) {
    owner_->owner()->link_paths_[id()] = path;
    JS_SetPropertyStr(ctx, json.QJSValue(), "profileId", JS_NewInt64(ctx, id()));
  }

  return json;
}

LinkProfileStep::LinkProfileStep(ProfileOpItem* owner, std::string label) : ProfileStep(owner, label) {}

ProfileOpItem::ProfileOpItem(WebFProfiler* owner) : owner_(owner) {
  stopwatch_.Begin();
}

void ProfileOpItem::RecordStep(const std::string& label, const std::shared_ptr<ProfileStep>& step) {
  bool is_child_step = false;
  if (!step_stack_.empty()) {
    is_child_step = true;
  }

  if (is_child_step) {
    current_step()->AddChildSteps(step);
  } else {
    steps_.emplace_back(step);
  }

  step_stack_.emplace(step);
//  assert(step_map_.count(label) == 0);
//  step_map_[label] = step;
}

void ProfileOpItem::FinishStep() {
  auto current_step = step_stack_.top();
  current_step->stopwatch_.End();
  step_stack_.pop();
}

ScriptValue ProfileOpItem::ToJSON(JSContext* ctx, const std::string& path, bool should_link) {
  JSValue json = JS_NewObject(ctx);

  JSValue duration_string = JS_NewString(ctx, (std::to_string(stopwatch_.elapsed()) + " us").c_str());
  JSValue steps = JS_NewArray(ctx);

  for(int i = 0; i < steps_.size(); i ++) {
    ScriptValue child_step_json = steps_[i]->ToJSON(ctx, path + "/" + std::to_string(i));
    JS_SetPropertyUint32(ctx, steps, i, JS_DupValue(ctx, child_step_json.QJSValue()));
  }

  JS_SetPropertyStr(ctx, json, "duration", duration_string);
  JS_SetPropertyStr(ctx, json, "steps", steps);

  ScriptValue result = ScriptValue(ctx, json);

  JS_FreeValue(ctx, json);
  return result;
}

WebFProfiler::WebFProfiler(bool enable): enabled_(enable) {}

void WebFProfiler::StartTrackInitialize() {
  if (UNLIKELY(enabled_)) {
    std::shared_ptr<ProfileOpItem> profile_item = std::make_shared<ProfileOpItem>(this);
    profile_stacks_.emplace(profile_item);
    initialize_profile_items_.emplace_back(profile_item);
  }
}

void WebFProfiler::FinishTrackInitialize() {
  if (UNLIKELY(enabled_)) {
    auto&& profile_item = profile_stacks_.top();
    profile_item->stopwatch_.End();
    profile_stacks_.pop();
  }
}

void WebFProfiler::StartTrackEvaluation(int64_t evaluate_id) {
  if (UNLIKELY(enabled_)) {
    std::shared_ptr<ProfileOpItem> profile_item = std::make_shared<ProfileOpItem>(this);
    assert(evaluate_profile_items_.count(evaluate_id) == 0);
    evaluate_profile_items_[evaluate_id] = profile_item;
    profile_stacks_.emplace(profile_item);
  }
}

void WebFProfiler::FinishTrackEvaluation(int64_t evaluate_id) {
  if (UNLIKELY(enabled_)) {
    auto&& profile_item = evaluate_profile_items_[evaluate_id];
    profile_item->stopwatch_.End();
    profile_stacks_.pop();
  }
}

void WebFProfiler::StartTrackAsyncEvaluation() {
  if (UNLIKELY(enabled_)) {
    std::shared_ptr<ProfileOpItem> profile_item = std::make_shared<ProfileOpItem>(this);
    async_evaluate_profile_items.emplace_back(profile_item);
    profile_stacks_.emplace(profile_item);
  }
}

void WebFProfiler::FinishTrackAsyncEvaluation() {
  if (UNLIKELY(enabled_)) {
    auto&& profile_item = profile_stacks_.top();
    profile_item->stopwatch_.End();
    profile_stacks_.pop();
  }
}

void WebFProfiler::StartTrackSteps(const std::string& label) {
  if (UNLIKELY(enabled_)) {
    assert_m(!profile_stacks_.empty(), "Tracks not started");

    auto&& current_profile = profile_stacks_.top();

    auto step = std::make_shared<ProfileStep>(current_profile.get(), label);
    current_profile->RecordStep(label, step);
  }
}

void WebFProfiler::FinishTrackSteps() {
  if (UNLIKELY(enabled_)) {
    auto&& current_profile = profile_stacks_.top();
    current_profile->FinishStep();
  }
}

void WebFProfiler::StartTrackLinkSteps(const std::string& label) {
  if (UNLIKELY(enabled_)) {
    auto&& current_profile = profile_stacks_.top();

    assert(current_profile != nullptr);

    auto step = std::make_shared<LinkProfileStep>(current_profile.get(), label);
    current_profile->RecordStep(label, step);
  }
}

void WebFProfiler::FinishTrackLinkSteps() {
  if (UNLIKELY(enabled_)) {
    auto&& current_profile = profile_stacks_.top();
    current_profile->FinishStep();
  }
}

std::string WebFProfiler::ToJSON() {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);

  std::string result;
  {
    JSValue object = JS_NewObject(ctx);

    {
      JSValue array_object = JS_NewArray(ctx);
      for (int i = 0; i < initialize_profile_items_.size(); i++) {
        ScriptValue json_item = initialize_profile_items_[i]->ToJSON(ctx, "");
        JS_SetPropertyUint32(ctx, array_object, i, JS_DupValue(ctx, json_item.QJSValue()));
      }

      JS_SetPropertyStr(ctx, object, "initialize", array_object);
    }

    {
      JSValue evaluate_object = JS_NewObject(ctx);
      for(auto&& item : evaluate_profile_items_) {
        ScriptValue json_item = item.second->ToJSON(ctx, std::to_string(item.first), true);
        JS_SetPropertyStr(ctx, evaluate_object, std::to_string(item.first).c_str(), JS_DupValue(ctx, json_item.QJSValue()));
      }
      JS_SetPropertyStr(ctx, object, "evaluate", evaluate_object);
    }

    {
      JSValue array_object = JS_NewArray(ctx);
      for (int i = 0; i < async_evaluate_profile_items.size(); i++) {
        ScriptValue json_item = async_evaluate_profile_items[i]->ToJSON(ctx, "", false);
        JS_SetPropertyUint32(ctx, array_object, i, JS_DupValue(ctx, json_item.QJSValue()));
      }

      JS_SetPropertyStr(ctx, object, "async_evaluate", array_object);
    }

    {
      JSValue link_path_object = JS_NewObject(ctx);
      for (auto&& item : link_paths_) {
        JS_SetPropertyStr(ctx, link_path_object, std::to_string(item.first).c_str(),
                          JS_NewString(ctx, item.second.c_str()));
      }
      JS_SetPropertyStr(ctx, object, "link", link_path_object);
    }

    ExceptionState exception_state;
    ScriptValue result_value = ScriptValue(ctx, object).ToJSONStringify(ctx, &exception_state);

    JS_FreeValue(ctx, object);

    result = result_value.ToString(ctx).ToStdString(ctx);
  }

  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);

  return result;
}

}