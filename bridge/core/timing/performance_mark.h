/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_TIMING_PERFORMANCE_MARK_H_
#define WEBF_CORE_TIMING_PERFORMANCE_MARK_H_

#include "bindings/qjs/script_value.h"
#include "performance_entry.h"
#include "performance_entry_names.h"
#include "qjs_performance_mark_options.h"

namespace webf {

class PerformanceMark : public PerformanceEntry {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static PerformanceMark* Create(ExecutingContext* context,
                                 const AtomicString& name,
                                 const std::shared_ptr<PerformanceMarkOptions>& mark_options,
                                 ExceptionState& exception_state);

  explicit PerformanceMark(ExecutingContext* context,
                           const AtomicString& name,
                           int64_t start_time,
                           const ScriptValue& detail);

  AtomicString entryType() const override;
  ScriptValue detail() const;

  void Trace(GCVisitor* visitor) const override;

 private:
  ScriptValue detail_;
};

}  // namespace webf

#endif  // WEBF_CORE_TIMING_PERFORMANCE_MARK_H_
