/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_PROFILER_H_
#define WEBF_FOUNDATION_PROFILER_H_

#include <stack>
#include <string>
#include <unordered_map>
#include <memory>
#include "foundation/stop_watch.h"
#include "bindings/qjs/script_value.h"

namespace webf {

class WebFProfiler;
class ExecutingContext;
class ProfileOpItem;

class ProfileStep {
 public:
  explicit ProfileStep(std::string label);

  ScriptValue ToJSON(JSContext* ctx);
  void AddChildSteps(std::shared_ptr<ProfileStep> step);

 private:
  std::vector<std::shared_ptr<ProfileStep>> child_steps_;
  Stopwatch stopwatch_;
  std::string label_;
  friend ProfileOpItem;
};

class ProfileOpItem {
 public:
  explicit ProfileOpItem();

  void RecordStep(const std::string& label, const std::shared_ptr<ProfileStep>& step);
  void FinishStep();

  ScriptValue ToJSON(JSContext* ctx);

 private:
  Stopwatch stopwatch_;

  std::unordered_map<std::string, std::shared_ptr<ProfileStep>> step_map_;
  std::stack<std::string> step_stack_;
  std::vector<std::shared_ptr<ProfileStep>> steps_;
  friend WebFProfiler;
  friend ProfileStep;
};

class WebFProfiler {
 public:
  explicit WebFProfiler(bool enable);

  void StartTrackInitialize();
  void FinishTrackInitialize();

  void StartTrackEvaluation(int64_t evaluate_id);
  void FinishTrackEvaluation(int64_t evaluate_id);

  void StartTrackSteps(const std::string& label);
  void FinishTrackSteps();

  std::string ToJSON();

 private:
  bool enabled_{false};
  std::stack<std::shared_ptr<ProfileOpItem>> profile_stacks_;
  std::vector<std::shared_ptr<ProfileOpItem>> initialize_profile_items_;

  std::unordered_map<int64_t, std::shared_ptr<ProfileOpItem>> evaluate_profile_items_;

  friend ProfileOpItem;
};

}

#endif  // WEBF_FOUNDATION_PROFILER_H_
