/*
 * Copyright (C) 2026-present The OpenWebF authors. All rights reserved.
 */

#include <gtest/gtest.h>
#include "core/profiling/js_thread_profiler.h"

namespace webf {

TEST(EntryId, DefaultsToZero) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  EXPECT_EQ(0u, p.GetCurrentEntryId());
  p.Disable();
}

TEST(EntryId, SetAndGetRoundtrip) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  p.SetCurrentEntryId(42);
  EXPECT_EQ(42u, p.GetCurrentEntryId());
  p.SetCurrentEntryId(0);
  EXPECT_EQ(0u, p.GetCurrentEntryId());
  p.Disable();
}

TEST(EntryId, EnableResetsToZero) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  p.SetCurrentEntryId(99);
  p.Disable();
  p.Enable();
  EXPECT_EQ(0u, p.GetCurrentEntryId()) << "Enable must reset entry id";
  p.Disable();
}

TEST(EntryId, StampedIntoSpanOnExit) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable(/*min_duration_us=*/0);  // no filter so test span is recorded
  p.SetCurrentEntryId(7);
  int32_t idx = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(idx, 0);
  p.OnFunctionExit(idx);

  JSThreadSpan out[1];
  int32_t count = p.DrainSpans(out, 1);
  ASSERT_EQ(1, count);
  EXPECT_EQ(7u, out[0].entry_id);
  p.Disable();
}

TEST(EntryId, ZeroStampWhenNoEntryActive) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable(/*min_duration_us=*/0);
  // do not call SetCurrentEntryId — should default to 0
  int32_t idx = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(idx, 0);
  p.OnFunctionExit(idx);

  JSThreadSpan out[1];
  int32_t count = p.DrainSpans(out, 1);
  ASSERT_EQ(1, count);
  EXPECT_EQ(0u, out[0].entry_id);
  p.Disable();
}

TEST(EntryId, CapturedAtEntryNotExit) {
  // Simulates the asyncSpanning leak: Dart pushes entry X, JS span starts,
  // Dart pops X and pushes entry Y while JS is still running, JS span exits.
  // The span must attribute to X (the entry active when it started), not Y.
  auto& p = JSThreadProfiler::Instance();
  p.Enable(/*min_duration_us=*/0);

  p.SetCurrentEntryId(11);
  int32_t idx = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(idx, 0);

  // Dart-side churn while JS span is still open
  p.SetCurrentEntryId(22);
  p.SetCurrentEntryId(33);

  p.OnFunctionExit(idx);

  JSThreadSpan out[1];
  int32_t count = p.DrainSpans(out, 1);
  ASSERT_EQ(1, count);
  EXPECT_EQ(11u, out[0].entry_id) << "Span must attribute to entry active at entry-time, not exit-time";
  p.Disable();
}

TEST(EntryId, NestedSpansCaptureIndependently) {
  // Outer span starts under entry 100. Mid-flight, current entry switches to
  // 200; an inner span opens, closes, then outer closes. Inner should be 200,
  // outer should remain 100.
  auto& p = JSThreadProfiler::Instance();
  p.Enable(/*min_duration_us=*/0);

  p.SetCurrentEntryId(100);
  int32_t outer = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(outer, 0);

  p.SetCurrentEntryId(200);
  int32_t inner = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(inner, 0);
  p.OnFunctionExit(inner);

  // Switch again before outer exits
  p.SetCurrentEntryId(300);
  p.OnFunctionExit(outer);

  JSThreadSpan out[2];
  int32_t count = p.DrainSpans(out, 2);
  ASSERT_EQ(2, count);
  // Drain order matches exit order: inner first, outer second.
  EXPECT_EQ(200u, out[0].entry_id);
  EXPECT_EQ(100u, out[1].entry_id);
  p.Disable();
}

}  // namespace webf
