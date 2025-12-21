/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "metrics_registry.h"
#include <sstream>

namespace webf {

const char* MetricName(MetricsEnum metric) {
  switch (metric) {
    case MetricsEnum::kTotalGetPropertyValueWithHint:
      return "TotalGetPropertyValueWithHint";
    case MetricsEnum::kGetPropertyValueWithHintWithRawText:
      return "GetPropertyValueWithHintWithRawText";
    case MetricsEnum::kCount:
      return "<COUNT>";
  }
  return "<UNKNOWN_METRIC>";
}

void MetricsRegistry::Increment(const std::string& key, uint64_t delta) {
  std::lock_guard<std::mutex> lock(mutex_);
  auto& ref = counters_[key];
  ref += delta;
}

uint64_t MetricsRegistry::Get(const std::string& key) const {
  std::lock_guard<std::mutex> lock(mutex_);
  auto it = counters_.find(key);
  if (it == counters_.end()) return 0;
  return it->second;
}

void MetricsRegistry::Increment(MetricsEnum metric, uint64_t delta) {
  std::lock_guard<std::mutex> lock(mutex_);
  size_t idx = static_cast<size_t>(metric);
  if (idx < enum_counters_.size()) enum_counters_[idx] += delta;
}

uint64_t MetricsRegistry::Get(MetricsEnum metric) const {
  std::lock_guard<std::mutex> lock(mutex_);
  size_t idx = static_cast<size_t>(metric);
  if (idx < enum_counters_.size()) return enum_counters_[idx];
  return 0;
}

std::unordered_map<std::string, uint64_t> MetricsRegistry::Snapshot() const {
  std::lock_guard<std::mutex> lock(mutex_);
  return counters_;
}

std::vector<std::pair<MetricsEnum, uint64_t>> MetricsRegistry::SnapshotEnum() const {
  std::lock_guard<std::mutex> lock(mutex_);
  std::vector<std::pair<MetricsEnum, uint64_t>> out;
  out.reserve(enum_counters_.size());
  for (size_t i = 0; i < enum_counters_.size(); ++i) {
    out.emplace_back(static_cast<MetricsEnum>(i), enum_counters_[i]);
  }
  return out;
}

std::unordered_map<std::string, uint64_t> MetricsRegistry::SnapshotAllNamed() const {
  std::lock_guard<std::mutex> lock(mutex_);
  std::unordered_map<std::string, uint64_t> out = counters_;
  for (size_t i = 0; i < enum_counters_.size(); ++i) {
    auto name = MetricName(static_cast<MetricsEnum>(i));
    out[name] += enum_counters_[i];
  }
  return out;
}

void MetricsRegistry::Clear() {
  std::lock_guard<std::mutex> lock(mutex_);
  counters_.clear();
  std::fill(enum_counters_.begin(), enum_counters_.end(), 0);
}

}  // namespace webf
