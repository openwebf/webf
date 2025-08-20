/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_PERFORMANCE_H
#define BRIDGE_PERFORMANCE_H

#include <vector>
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "performance_entry.h"
#include "plugin_api_gen/performance.h"
#include "qjs_performance_mark_options.h"

namespace webf {

class PerformanceEntry;

struct NativePerformanceEntry {
  int64_t name;
  int64_t startTime;
  int64_t uniqueId;
};

class Performance : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  Performance() = delete;
  explicit Performance(ExecutingContext* context);

  int64_t now(ExceptionState& exception_state) const;
  int64_t timeOrigin() const;
  ScriptValue toJSON(ExceptionState& exception_state) const;
  AtomicString ___webf_navigation_summary__(ExceptionState& exception_state) const;
  std::vector<Member<PerformanceEntry>> getEntries(ExceptionState& exception_state);
  std::vector<Member<PerformanceEntry>> getEntriesByType(const AtomicString& entry_type,
                                                         ExceptionState& exception_state);
  std::vector<Member<PerformanceEntry>> getEntriesByName(const AtomicString& name, ExceptionState& exception_state);
  std::vector<Member<PerformanceEntry>> getEntriesByName(const AtomicString& name,
                                                         const AtomicString& entry_type,
                                                         ExceptionState& exception_state);

  void mark(const AtomicString& name, ExceptionState& exception_state);
  void mark(const AtomicString& name,
            const std::shared_ptr<PerformanceMarkOptions>& options,
            ExceptionState& exception_state);
  void clearMarks(ExceptionState& exception_state);
  void clearMarks(const AtomicString& name, ExceptionState& exception_state);
  void clearMeasures(ExceptionState& exception_state);
  void clearMeasures(const AtomicString& name, ExceptionState& exception_state);

  void measure(const AtomicString& measure_name, ExceptionState& exception_state);
  void measure(const AtomicString& measure_name, const AtomicString& start_mark, ExceptionState& exception_state);
  void measure(const AtomicString& measure_name,
               const ScriptValue& start_mark_or_options,
               ExceptionState& exception_state);
  void measure(const AtomicString& measure_name,
               const ScriptValue& start_mark_or_options,
               const AtomicString& end_mark,
               ExceptionState& exception_state);

  void Trace(GCVisitor* visitor) const override;

  const PerformancePublicMethods* performancePublicMethods();

 private:
  void measure(const AtomicString& measure_name,
               const AtomicString& start_mark,
               const AtomicString& end_mark,
               ExceptionState& exception_state);

  std::vector<Member<PerformanceEntry>> entries_;
};

}  // namespace webf

#endif  // BRIDGE_PERFORMANCE_H
