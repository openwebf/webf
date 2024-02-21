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

ScriptValue ProfileStep::ToJSON(webf::ExecutingContext* context) {
  JSValue json = JS_NewObject(context->ctx());

  JSValue duration_string = JS_NewString(context->ctx(), (std::to_string(stopwatch_.elapsed()) + " us").c_str());
  JSValue label_string = JS_NewString(context->ctx(), label_.c_str());

  JSValue child_steps_array = JS_NewArray(context->ctx());

  for(int i = 0; i < child_steps_.size(); i ++) {
    ScriptValue child_step_json = child_steps_[i]->ToJSON(context);
    JS_SetPropertyUint32(context->ctx(), child_steps_array, i, JS_DupValue(context->ctx(), child_step_json.QJSValue()));
  }

  JS_SetPropertyStr(context->ctx(), json, "duration", duration_string);
  JS_SetPropertyStr(context->ctx(), json, "label", label_string);
  JS_SetPropertyStr(context->ctx(), json, "childSteps", child_steps_array);

  ScriptValue result = ScriptValue(context->ctx(), json);

  JS_FreeValue(context->ctx(), json);
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

ScriptValue ProfileOpItem::ToJSON(webf::ExecutingContext* context) {
  JSValue json = JS_NewObject(context->ctx());

  JSValue duration_string = JS_NewString(context->ctx(), (std::to_string(stopwatch_.elapsed()) + " us").c_str());
  JSValue steps = JS_NewArray(context->ctx());

  for(int i = 0; i < steps_.size(); i ++) {
    ScriptValue child_step_json = steps_[i]->ToJSON(context);
    JS_SetPropertyUint32(context->ctx(), steps, i, JS_DupValue(context->ctx(), child_step_json.QJSValue()));
  }

  JS_SetPropertyStr(context->ctx(), json, "duration", duration_string);
  JS_SetPropertyStr(context->ctx(), json, "steps", steps);

  ScriptValue result = ScriptValue(context->ctx(), json);

  JS_FreeValue(context->ctx(), json);
  return result;
}

WebFProfiler::WebFProfiler(bool enable): enabled_(enable) {}

void WebFProfiler::StartTrackInitialize() {
  if (UNLIKELY(enabled_)) {
    std::shared_ptr<ProfileOpItem> profile_item = std::make_shared<ProfileOpItem>();
    initialize_profile_stacks_.emplace(profile_item);
    initialize_profile_items_.emplace_back(profile_item);
  }
}

void WebFProfiler::FinishTrackInitialize() {
  if (UNLIKELY(enabled_)) {
    auto&& profile_item = initialize_profile_stacks_.top();
    profile_item->stopwatch_.End();
    initialize_profile_stacks_.pop();
  }
}

void WebFProfiler::StartTrackInitializeSteps(const std::string& label) {
  if (UNLIKELY(enabled_)) {
    auto&& current_profile = initialize_profile_stacks_.top();

    assert(current_profile != nullptr);

    auto step = std::make_shared<ProfileStep>(label);
    current_profile->RecordStep(label, step);
  }
}

void WebFProfiler::FinishTrackInitializeSteps() {
  if (UNLIKELY(enabled_)) {
    auto&& current_profile = initialize_profile_stacks_.top();
    current_profile->FinishStep();
  }
}

std::string WebFProfiler::ToJSON(ExecutingContext* context) {
  JSValue array_object = JS_NewArray(context->ctx());

  for(int i = 0; i < initialize_profile_items_.size(); i ++) {
    ScriptValue json_item = initialize_profile_items_[i]->ToJSON(context);
    JS_SetPropertyUint32(context->ctx(), array_object, i, JS_DupValue(context->ctx(), json_item.QJSValue()));
  }

  ExceptionState exception_state;
  ScriptValue array_value = ScriptValue(context->ctx(), array_object);

  ScriptValue result = array_value.ToJSONStringify(context->ctx(), &exception_state);

  JS_FreeValue(context->ctx(), array_object);

  return result.ToString(context->ctx()).ToStdString(context->ctx());
}

}