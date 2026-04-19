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

}  // namespace webf
