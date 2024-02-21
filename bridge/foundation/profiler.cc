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

ProfileStep::ProfileStep(std::string label): label_(std::move(label)) {
  stopwatch_.Begin();
}

ScriptValue ProfileStep::ToJSON(JSContext* ctx) {
  JSValue json = JS_NewObject(ctx);

  JSValue duration_string = JS_NewString(ctx, (std::to_string(stopwatch_.elapsed()) + " us").c_str());
  JSValue label_string = JS_NewString(ctx, label_.c_str());

  JSValue child_steps_array = JS_NewArray(ctx);

  for(int i = 0; i < child_steps_.size(); i ++) {
    ScriptValue child_step_json = child_steps_[i]->ToJSON(ctx);
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

ProfileOpItem::ProfileOpItem() {
  stopwatch_.Begin();
}

void ProfileOpItem::RecordStep(const std::string& label, const std::shared_ptr<ProfileStep>& step) {
  bool is_child_step = false;
  if (!step_stack_.empty()) {
    is_child_step = true;
  }

  if (is_child_step) {
    step_map_[step_stack_.top()]->AddChildSteps(step);
  } else {
    steps_.emplace_back(step);
  }

  step_stack_.emplace(label);
  assert(step_map_.count(label) == 0);
  step_map_[label] = step;
}

void ProfileOpItem::FinishStep() {
  auto current_step = step_map_[step_stack_.top()];
  current_step->stopwatch_.End();
  step_map_.erase(current_step->label_);
  step_stack_.pop();
}

ScriptValue ProfileOpItem::ToJSON(JSContext* ctx) {
  JSValue json = JS_NewObject(ctx);

  JSValue duration_string = JS_NewString(ctx, (std::to_string(stopwatch_.elapsed()) + " us").c_str());
  JSValue steps = JS_NewArray(ctx);

  for(int i = 0; i < steps_.size(); i ++) {
    ScriptValue child_step_json = steps_[i]->ToJSON(ctx);
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
    std::shared_ptr<ProfileOpItem> profile_item = std::make_shared<ProfileOpItem>();
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
    std::shared_ptr<ProfileOpItem> profile_item = std::make_shared<ProfileOpItem>();
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

void WebFProfiler::StartTrackSteps(const std::string& label) {
  if (UNLIKELY(enabled_)) {
    auto&& current_profile = profile_stacks_.top();

    assert(current_profile != nullptr);

    auto step = std::make_shared<ProfileStep>(label);
    current_profile->RecordStep(label, step);
  }
}

void WebFProfiler::FinishTrackSteps() {
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
        ScriptValue json_item = initialize_profile_items_[i]->ToJSON(ctx);
        JS_SetPropertyUint32(ctx, array_object, i, JS_DupValue(ctx, json_item.QJSValue()));
      }

      JS_SetPropertyStr(ctx, object, "initialize", array_object);
    }

    {
      JSValue evaluate_object = JS_NewObject(ctx);
      for(auto&& item : evaluate_profile_items_) {
        ScriptValue json_item = item.second->ToJSON(ctx);
        JS_SetPropertyStr(ctx, evaluate_object, std::to_string(item.first).c_str(), JS_DupValue(ctx, json_item.QJSValue()));
      }
      JS_SetPropertyStr(ctx, object, "evaluate", evaluate_object);
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