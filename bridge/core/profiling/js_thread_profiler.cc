/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "js_thread_profiler.h"

namespace webf {

const std::string JSThreadProfiler::kEmptyString;

JSThreadProfiler& JSThreadProfiler::Instance() {
  static JSThreadProfiler instance;
  return instance;
}

void JSThreadProfiler::Enable(int64_t min_duration_us) {
  min_duration_us_ = min_duration_us;
  write_pos_ = 0;
  read_pos_ = 0;
  stack_depth_ = 0;
  atom_to_id_.clear();
  unique_atoms_.clear();
  atom_names_.clear();
  binding_name_to_id_.clear();
  binding_names_.clear();
  current_entry_id_.store(0, std::memory_order_relaxed);
  for (int i = 0; i < kMaxDepth; i++) {
    pending_[i].valid = false;
  }
  session_start_ = std::chrono::steady_clock::now();
  enabled_.store(true, std::memory_order_release);
  InstallHooks();
}

void JSThreadProfiler::Disable() {
  enabled_.store(false, std::memory_order_release);
  UninstallHooks();
  stack_depth_ = 0;
}

int64_t JSThreadProfiler::NowUs() const {
  auto now = std::chrono::steady_clock::now();
  return std::chrono::duration_cast<std::chrono::microseconds>(now - session_start_).count();
}

int64_t JSThreadProfiler::SessionStartUs() const {
  return std::chrono::duration_cast<std::chrono::microseconds>(session_start_.time_since_epoch()).count();
}

int64_t JSThreadProfiler::SteadyClockNowUs() {
  auto now = std::chrono::steady_clock::now();
  return std::chrono::duration_cast<std::chrono::microseconds>(now.time_since_epoch()).count();
}

bool JSThreadProfiler::TrackAtom(JSAtom atom) {
  if (atom == 0) return false;
  if ((atom & kBindingIdFlag) != 0) return false;  // binding registry IDs — already resolved
  if (atom_to_id_.find(atom) == atom_to_id_.end()) {
    int32_t id = static_cast<int32_t>(unique_atoms_.size());
    atom_to_id_[atom] = id;
    unique_atoms_.push_back(atom);
    atom_names_.emplace_back();  // empty placeholder, resolved later
    return true;  // new atom
  }
  return false;  // already tracked
}

void JSThreadProfiler::RegisterAtomName(JSAtom atom, const std::string& name) {
  auto it = atom_to_id_.find(atom);
  if (it != atom_to_id_.end() && it->second < static_cast<int32_t>(atom_names_.size())) {
    atom_names_[it->second] = name;
  }
}

const std::string& JSThreadProfiler::GetAtomName(JSAtom atom) const {
  if ((atom & kBindingIdFlag) != 0) {
    uint32_t idx = atom & ~kBindingIdFlag;
    if (idx < binding_names_.size()) return binding_names_[idx];
    return kEmptyString;
  }
  auto it = atom_to_id_.find(atom);
  if (it != atom_to_id_.end() && it->second < static_cast<int32_t>(atom_names_.size())) {
    return atom_names_[it->second];
  }
  return kEmptyString;
}

uint32_t JSThreadProfiler::RegisterBindingName(const std::string& name) {
  auto it = binding_name_to_id_.find(name);
  if (it != binding_name_to_id_.end()) return it->second;
  uint32_t idx = static_cast<uint32_t>(binding_names_.size());
  uint32_t id = idx | kBindingIdFlag;
  binding_name_to_id_.emplace(name, id);
  binding_names_.push_back(name);
  return id;
}

bool JSThreadProfiler::IsAtomKnown(JSAtom atom) const {
  auto it = atom_to_id_.find(atom);
  if (it == atom_to_id_.end()) return false;
  // Known if the name has been registered (non-empty)
  return it->second < static_cast<int32_t>(atom_names_.size()) && !atom_names_[it->second].empty();
}

void JSThreadProfiler::SetCurrentEntryId(uint32_t entry_id) {
  current_entry_id_.store(entry_id, std::memory_order_relaxed);
}

uint32_t JSThreadProfiler::GetCurrentEntryId() const {
  return current_entry_id_.load(std::memory_order_relaxed);
}

int32_t JSThreadProfiler::OnFunctionEntry(uint8_t category, JSAtom func_name) {
  if (!enabled_.load(std::memory_order_relaxed)) return -1;
  if (stack_depth_ >= kMaxDepth) return -1;

  int32_t pending_idx = stack_depth_;
  auto& entry = pending_[pending_idx];
  entry.start_us = NowUs();
  entry.category = category;
  entry.func_name_atom = func_name;
  entry.entry_id = current_entry_id_.load(std::memory_order_relaxed);
  entry.depth = static_cast<uint8_t>(stack_depth_ < 255 ? stack_depth_ : 255);
  entry.valid = true;

  // Track this atom for later name resolution
  TrackAtom(func_name);

  stack_depth_++;
  return pending_idx;
}

void JSThreadProfiler::OnFunctionExit(int32_t entry_idx) {
  if (entry_idx < 0 || entry_idx >= kMaxDepth) return;
  if (!pending_[entry_idx].valid) return;

  auto& entry = pending_[entry_idx];
  int64_t end_us = NowUs();
  int64_t duration = end_us - entry.start_us;

  // Pop from stack
  if (stack_depth_ > 0) {
    stack_depth_--;
  }

  // Apply minimum duration filter
  if (duration < min_duration_us_) {
    entry.valid = false;
    return;
  }

  // Write to ring buffer
  int32_t buf_idx = write_pos_ % kMaxSpans;
  auto& span = buffer_[buf_idx];
  span.category = entry.category;
  span.start_us = entry.start_us;
  span.end_us = end_us;
  span.func_name_atom = entry.func_name_atom;
  span.depth = entry.depth;
  span.entry_id = entry.entry_id;

  write_pos_++;
  entry.valid = false;
}

int32_t JSThreadProfiler::DrainSpans(JSThreadSpan* out_spans, int32_t max_spans) {
  if (read_pos_ >= write_pos_) return 0;

  int32_t available = write_pos_ - read_pos_;
  // If buffer wrapped, skip lost spans
  if (available > kMaxSpans) {
    read_pos_ = write_pos_ - kMaxSpans;
    available = kMaxSpans;
  }

  int32_t count = available < max_spans ? available : max_spans;
  for (int32_t i = 0; i < count; i++) {
    int32_t buf_idx = (read_pos_ + i) % kMaxSpans;
    out_spans[i] = buffer_[buf_idx];
  }

  read_pos_ += count;
  return count;
}

// ScopedSpan implementation
JSThreadProfiler::ScopedSpan::ScopedSpan(JSThreadProfiler& p, uint8_t category, JSAtom name)
    : profiler(p), idx(p.OnFunctionEntry(category, name)) {}

JSThreadProfiler::ScopedSpan::~ScopedSpan() {
  if (idx >= 0) {
    profiler.OnFunctionExit(idx);
  }
}

// Install/uninstall hooks so that quickjs.dylib can reach our singleton.
void JSThreadProfiler::InstallHooks() {
  webf_js_profiler_enabled_hook = []() -> int {
    return JSThreadProfiler::Instance().enabled() ? 1 : 0;
  };
  webf_js_profiler_on_entry_hook = [](uint8_t category, uint32_t func_name_atom) -> int32_t {
    return JSThreadProfiler::Instance().OnFunctionEntry(category, static_cast<JSAtom>(func_name_atom));
  };
  webf_js_profiler_on_exit_hook = [](int32_t entry_idx) -> void {
    JSThreadProfiler::Instance().OnFunctionExit(entry_idx);
  };
  webf_js_profiler_register_atom_name_hook = [](uint32_t atom, const char* name) -> void {
    JSThreadProfiler::Instance().RegisterAtomName(static_cast<JSAtom>(atom), std::string(name));
  };
  webf_js_profiler_is_atom_known_hook = [](uint32_t atom) -> int {
    return JSThreadProfiler::Instance().IsAtomKnown(static_cast<JSAtom>(atom)) ? 1 : 0;
  };
}

void JSThreadProfiler::UninstallHooks() {
  webf_js_profiler_enabled_hook = nullptr;
  webf_js_profiler_on_entry_hook = nullptr;
  webf_js_profiler_on_exit_hook = nullptr;
  webf_js_profiler_register_atom_name_hook = nullptr;
  webf_js_profiler_is_atom_known_hook = nullptr;
}

}  // namespace webf
