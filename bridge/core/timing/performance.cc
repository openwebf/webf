/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "performance.h"
#include <algorithm>
#include <chrono>
#include "bindings/qjs/converter_impl.h"
#include "bindings/qjs/script_value.h"
#include "core/executing_context.h"
#include "performance_entry.h"
#include "performance_mark.h"
#include "performance_measure.h"
#include "qjs_performance_measure_options.h"

namespace webf {

using namespace std::chrono;

Performance::Performance(ExecutingContext* context) : ScriptWrappable(context->ctx()) {}

int64_t Performance::now(ExceptionState& exception_state) const {
  auto now = std::chrono::system_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::microseconds>(now - GetExecutingContext()->timeOrigin());
  auto reducedDuration = std::floor(duration / 1000us) * 1000us;
  return std::chrono::duration_cast<std::chrono::milliseconds>(reducedDuration).count();
}

int64_t Performance::timeOrigin() const {
  return std::chrono::duration_cast<std::chrono::milliseconds>(GetExecutingContext()->timeOrigin().time_since_epoch())
      .count();
}

ScriptValue Performance::toJSON(ExceptionState& exception_state) const {
  int64_t now_value = now(exception_state);
  int64_t time_origin_value = timeOrigin();

  JSValue object = JS_NewObject(ctx());
  JS_SetPropertyStr(ctx(), object, "now", Converter<IDLInt64>::ToValue(ctx(), now_value));
  JS_SetPropertyStr(ctx(), object, "timeOrigin", Converter<IDLInt64>::ToValue(ctx(), time_origin_value));
  ScriptValue result = ScriptValue(ctx(), object);
  JS_FreeValue(ctx(), object);
  return result;
}

AtomicString Performance::___webf_navigation_summary__(ExceptionState& exception_state) const {
  return AtomicString::Empty();
}

std::vector<Member<PerformanceEntry>> Performance::getEntries(ExceptionState& exception_state) {
  return entries_;
}

std::vector<Member<PerformanceEntry>> Performance::getEntriesByType(const AtomicString& entry_type,
                                                                    ExceptionState& exception_state) {
  std::vector<Member<PerformanceEntry>> result;
  for (auto& entry : entries_) {
    if (entry->entryType() == entry_type) {
      result.emplace_back(entry);
    };
  }

  return result;
}

std::vector<Member<PerformanceEntry>> Performance::getEntriesByName(const AtomicString& name,
                                                                    ExceptionState& exception_state) {
  std::vector<Member<PerformanceEntry>> result;
  for (auto& entry : entries_) {
    if (entry->name() == name) {
      result.emplace_back(entry);
    };
  }

  return result;
}

std::vector<Member<PerformanceEntry>> Performance::getEntriesByName(const AtomicString& name,
                                                                    const AtomicString& entry_type,
                                                                    ExceptionState& exception_state) {
  std::vector<Member<PerformanceEntry>> result;
  for (auto& entry : entries_) {
    if (entry->name() == name && entry->entryType() == entry_type) {
      result.emplace_back(entry);
    }
  }
  return result;
}

void Performance::mark(const AtomicString& name, ExceptionState& exception_state) {
  auto* mark = PerformanceMark::Create(GetExecutingContext(), name, nullptr, exception_state);
  entries_.emplace_back(mark);
}

void Performance::mark(const AtomicString& name,
                       const std::shared_ptr<PerformanceMarkOptions>& options,
                       ExceptionState& exception_state) {
  auto* mark = PerformanceMark::Create(GetExecutingContext(), name, options, exception_state);
  entries_.emplace_back(mark);
}

void Performance::clearMarks(ExceptionState& exception_state) {
  auto new_entries = std::vector<Member<PerformanceEntry>>();

  auto it = std::begin(entries_);

  while (it != entries_.end()) {
    if ((*it)->entryType() != performance_entry_names::kmark) {
      new_entries.emplace_back(*it);
    }
    it++;
  }
  std::swap(entries_, new_entries);
}

void Performance::clearMarks(const AtomicString& name, ExceptionState& exception_state) {
  auto new_entries = std::vector<Member<PerformanceEntry>>();

  auto it = std::begin(entries_);

  while (it != std::end(entries_)) {
    if (!((*it)->entryType() == performance_entry_names::kmark && (*it)->name() == name)) {
      new_entries.emplace_back(*it);
    }
    it++;
  }

  std::swap(entries_, new_entries);
}

void Performance::clearMeasures(ExceptionState& exception_state) {
  auto new_entries = std::vector<Member<PerformanceEntry>>();
  auto it = std::begin(entries_);

  while (it != std::end(entries_)) {
    if ((*it)->entryType() != performance_entry_names::kmeasure) {
      new_entries.emplace_back(*it);
    }
    it++;
  }

  std::swap(entries_, new_entries);
}

void Performance::clearMeasures(const AtomicString& name, ExceptionState& exception_state) {
  auto new_entries = std::vector<Member<PerformanceEntry>>();
  auto it = std::begin(entries_);

  while (it != std::end(entries_)) {
    if (!((*it)->entryType() == performance_entry_names::kmeasure && (*it)->name() == name)) {
      new_entries.emplace_back(*it);
    }
    it++;
  }

  std::swap(entries_, new_entries);
}

void Performance::Trace(GCVisitor* visitor) const {
  for (auto& entries : entries_) {
    visitor->TraceMember(entries);
  }
}

void Performance::measure(const AtomicString& measure_name, ExceptionState& exception_state) {
  measure(measure_name, AtomicString::Empty(), AtomicString::Empty(), exception_state);
}

void Performance::measure(const AtomicString& measure_name,
                          const AtomicString& start_mark,
                          ExceptionState& exception_state) {
  measure(measure_name, start_mark, AtomicString::Empty(), exception_state);
}

void Performance::measure(const AtomicString& measure_name,
                          const ScriptValue& start_mark_or_options,
                          ExceptionState& exception_state) {
  if (start_mark_or_options.IsString()) {
    measure(measure_name, start_mark_or_options.ToString(ctx()), exception_state);
  } else {
    auto&& options =
        Converter<PerformanceMeasureOptions>::FromValue(ctx(), start_mark_or_options.QJSValue(), exception_state);
    measure(measure_name, options->hasStart() ? options->start() : AtomicString::Empty(),
            options->hasEnd() ? options->end() : AtomicString::Empty(), exception_state);
  }
}

void Performance::measure(const AtomicString& measure_name,
                          const ScriptValue& start_mark_or_options,
                          const AtomicString& end_mark,
                          ExceptionState& exception_state) {
  if (start_mark_or_options.IsString()) {
    measure(measure_name, start_mark_or_options.ToString(ctx()), end_mark, exception_state);
  } else {
    auto&& options =
        Converter<PerformanceMeasureOptions>::FromValue(ctx(), start_mark_or_options.QJSValue(), exception_state);
    measure(measure_name, options->hasStart() ? options->start() : AtomicString::Empty(),
            options->hasEnd() ? options->end() : end_mark, exception_state);
  }
}

void Performance::measure(const AtomicString& measure_name,
                          const AtomicString& start_mark,
                          const AtomicString& end_mark,
                          ExceptionState& exception_state) {
  if (start_mark.IsEmpty()) {
    auto* measure = PerformanceMeasure::Create(GetExecutingContext(), measure_name, timeOrigin(), now(exception_state),
                                               ScriptValue::Empty(ctx()), exception_state);
    entries_.emplace_back(measure);
    return;
  }

  auto start_it = std::begin(entries_);
  auto end_it = std::begin(entries_);

  if (end_mark.IsEmpty()) {
    auto start_entry = std::find_if(start_it, entries_.end(),
                                    [&start_mark](auto&& entry) -> bool { return entry->name() == start_mark; });
    auto* measure = PerformanceMeasure::Create(GetExecutingContext(), measure_name, (*start_entry)->startTime(),
                                               now(exception_state), ScriptValue::Empty(ctx()), exception_state);
    entries_.emplace_back(measure);
    return;
  }

  size_t start_mark_count = std::count_if(entries_.begin(), entries_.end(),
                                          [&start_mark](auto&& entry) -> bool { return entry->name() == start_mark; });

  if (start_mark_count == 0) {
    exception_state.ThrowException(
        ctx(), ErrorType::TypeError,
        "Failed to execute 'measure' on 'Performance': The mark " + start_mark.ToStdString(ctx()) + " does not exist.");
    return;
  }

  size_t end_mark_count = std::count_if(entries_.begin(), entries_.end(),
                                        [end_mark](auto&& entry) -> bool { return entry->name() == end_mark; });

  if (end_mark_count == 0) {
    exception_state.ThrowException(
        ctx(), ErrorType::TypeError,
        "Failed to execute 'measure' on 'Performance': The mark " + end_mark.ToStdString(ctx()) + " does not exist.");
    return;
  }

  if (start_mark_count != end_mark_count) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "Failed to execute 'measure' on 'Performance': The mark " +
                                       start_mark.ToStdString(ctx()) + " and " + end_mark.ToStdString(ctx()) +
                                       " does not appear the same number of times");
    return;
  }

  for (size_t i = 0; i < start_mark_count; i++) {
    auto start_entry = std::find_if(start_it, entries_.end(),
                                    [&start_mark](auto&& entry) -> bool { return entry->name() == start_mark; });

    bool is_start_entry_has_unique_id = (*start_entry)->uniqueId() != PERFORMANCE_ENTRY_NONE_UNIQUE_ID;

    auto end_entry_comparator = [&end_mark, &start_entry, is_start_entry_has_unique_id](auto&& entry) -> bool {
      if (is_start_entry_has_unique_id) {
        return entry->uniqueId() == (*start_entry)->uniqueId() && entry->name() == end_mark;
      }
      return entry->name() == end_mark;
    };

    auto end_entry = std::find_if(start_entry, entries_.end(), end_entry_comparator);

    if (end_entry == entries_.end()) {
      size_t startIndex = start_entry - entries_.begin();
      assert_m(false, ("Can not get endEntry. startIndex: " + std::to_string(startIndex) +
                       " startMark: " + start_mark.ToStdString(ctx()) + " endMark: " + end_mark.ToStdString(ctx())));
    }

    int64_t duration = (*end_entry)->startTime() - (*start_entry)->startTime();
    int64_t start_time = std::chrono::duration_cast<microseconds>(system_clock::now().time_since_epoch()).count();
    auto* measure = PerformanceMeasure::Create(GetExecutingContext(), measure_name, start_time, start_time + duration,
                                               ScriptValue::Empty(ctx()), exception_state);
    entries_.emplace_back(measure);
    start_it = ++start_entry;
    end_it = ++end_entry;
  }
}

}  // namespace webf
