/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_PROFILING_JS_THREAD_PROFILER_H_
#define WEBF_CORE_PROFILING_JS_THREAD_PROFILER_H_

#include <atomic>
#include <chrono>
#include <cstdint>
#include <string>
#include <unordered_map>
#include <vector>

#include "js_profiler_hooks.h"

// Forward declare JSAtom (uint32_t in QuickJS)
typedef uint32_t JSAtom;

namespace webf {

enum JSSpanCategory : uint8_t {
  kJSFunction = 0,
  kJSCFunction = 1,
  kJSScriptEval = 2,
  kJSTimer = 3,
  kJSEvent = 4,
  kJSRAF = 5,
  kJSIdle = 6,
  kJSMicrotask = 7,
  kJSMutationObserver = 8,
  kJSFlushUICommand = 9,
  kJSBindingSyncCall = 10,
};

// Span stored in the ring buffer (completed spans only)
struct JSThreadSpan {
  uint8_t category;
  int64_t start_us;       // microseconds from profiler session start
  int64_t end_us;
  uint32_t func_name_atom; // JSAtom for function name (0 = anonymous)
  uint8_t depth;
};

class JSThreadProfiler {
 public:
  static JSThreadProfiler& Instance();

  void Enable(int64_t min_duration_us = 10);
  void Disable();
  bool enabled() const { return enabled_.load(std::memory_order_relaxed); }
  int64_t NowUs() const;
  int64_t SessionStartUs() const;

  // Absolute steady_clock time in microseconds (time_since_epoch).
  // Safe to call regardless of enabled state.
  static int64_t SteadyClockNowUs();

  // Called at JS function entry — returns pending stack index or -1 if disabled
  int32_t OnFunctionEntry(uint8_t category, JSAtom func_name);
  // Called at JS function exit
  void OnFunctionExit(int32_t entry_idx);

  // RAII guard for high-level categories
  struct ScopedSpan {
    JSThreadProfiler& profiler;
    int32_t idx;
    ScopedSpan(JSThreadProfiler& p, uint8_t category, JSAtom name = 0);
    ~ScopedSpan();
    ScopedSpan(const ScopedSpan&) = delete;
    ScopedSpan& operator=(const ScopedSpan&) = delete;
  };

  // Drain completed spans for Dart. Called during FlushUICommand (JS thread blocked).
  // Returns number of spans written to out_spans.
  int32_t DrainSpans(JSThreadSpan* out_spans, int32_t max_spans);

  // Collect unique atoms from drained spans for name resolution
  const std::unordered_map<JSAtom, int32_t>& GetAtomMap() const { return atom_to_id_; }
  const std::vector<JSAtom>& GetUniqueAtoms() const { return unique_atoms_; }

  // Register a resolved name for an atom (called from Dart side bridge after resolving)
  void RegisterAtomName(JSAtom atom, const std::string& name);
  const std::string& GetAtomName(JSAtom atom) const;
  bool IsAtomKnown(JSAtom atom) const;

  // Register a human-readable name for a C++-side span (e.g., binding method
  // names). Returns a stable ID with the high bit set so it does not collide
  // with QuickJS JSAtoms. Use the returned ID as the `name` argument of
  // ScopedSpan / OnFunctionEntry. GetAtomName() will resolve it.
  uint32_t RegisterBindingName(const std::string& name);

 private:
  JSThreadProfiler() = default;

  std::atomic<bool> enabled_{false};
  std::chrono::steady_clock::time_point session_start_;

  // Ring buffer for completed spans
  static constexpr int32_t kMaxSpans = 8192;
  JSThreadSpan buffer_[kMaxSpans];
  int32_t write_pos_ = 0;
  int32_t read_pos_ = 0;

  // Atom tracking for name resolution
  std::unordered_map<JSAtom, int32_t> atom_to_id_;
  std::vector<JSAtom> unique_atoms_;
  std::vector<std::string> atom_names_;
  static const std::string kEmptyString;

  // C++-side name registry (binding methods, internal spans). IDs use the high
  // bit to distinguish from QuickJS atoms. Cleared on Enable().
  static constexpr uint32_t kBindingIdFlag = 0x80000000u;
  std::unordered_map<std::string, uint32_t> binding_name_to_id_;
  std::vector<std::string> binding_names_;  // index = id & ~kBindingIdFlag

  // Open span stack for depth tracking
  static constexpr int32_t kMaxDepth = 128;
  struct PendingEntry {
    int64_t start_us;
    uint8_t category;
    uint32_t func_name_atom;
    uint8_t depth;
    bool valid;
  };
  PendingEntry pending_[kMaxDepth];
  int32_t stack_depth_ = 0;

  int64_t min_duration_us_ = 10;

  bool TrackAtom(JSAtom atom);

 public:
  // Install/uninstall function-pointer hooks in quickjs.dylib
  static void InstallHooks();
  static void UninstallHooks();
};

}  // namespace webf

#endif  // WEBF_CORE_PROFILING_JS_THREAD_PROFILER_H_
