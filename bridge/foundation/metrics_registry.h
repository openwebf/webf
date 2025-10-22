/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_METRICS_REGISTRY_H_
#define WEBF_FOUNDATION_METRICS_REGISTRY_H_

#include <cstdint>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

namespace webf {

// Optional enum-based metrics. Extend as needed and keep contiguous.
enum class MetricsEnum {
  kTotalGetPropertyValueWithHint = 0,
  kGetPropertyValueWithHintWithRawText = 1,

  kCount
};

// Convert a MetricsEnum to a stable, human-readable name.
const char* MetricName(MetricsEnum metric);

// A simple thread-safe key->counter registry that is shared per DartIsolateContext.
// - Keys are strings
// - Values are monotonically increasing counters
class MetricsRegistry {
 public:
  MetricsRegistry() : enum_counters_(static_cast<size_t>(MetricsEnum::kCount), 0) {}

  // Increment the counter for `key` by `delta` (default 1).
  void Increment(const std::string& key, uint64_t delta = 1);

  // Get the current value for `key`. Returns 0 if missing.
  uint64_t Get(const std::string& key) const;

  // Enum overloads.
  void Increment(MetricsEnum metric, uint64_t delta = 1);
  uint64_t Get(MetricsEnum metric) const;

  // Create a point-in-time copy of all counters.
  std::unordered_map<std::string, uint64_t> Snapshot() const;

  // Snapshot enum metrics as vector of pairs.
  std::vector<std::pair<MetricsEnum, uint64_t>> SnapshotEnum() const;

  // Merge string and enum snapshots into a single name->value map.
  std::unordered_map<std::string, uint64_t> SnapshotAllNamed() const;

  // Clear all counters.
  void Clear();

 private:
  mutable std::mutex mutex_;
  std::unordered_map<std::string, uint64_t> counters_;
  std::vector<uint64_t> enum_counters_;
};

}  // namespace webf

#endif  // WEBF_FOUNDATION_METRICS_REGISTRY_H_
