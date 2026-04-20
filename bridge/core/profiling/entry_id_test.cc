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

TEST(EntryId, DispatchOverrideTakesPrecedenceOverCurrent) {
  // The Dart→JS dispatch path sets a JS-thread-local override before
  // invoking a listener so the JS functions stamped during that scope
  // always carry the dispatching entry's id, even when the shared
  // `current_entry_id_` atomic has been overwritten by a concurrent
  // async entry that opened later on the Dart thread.
  auto& p = JSThreadProfiler::Instance();
  p.Enable(/*min_duration_us=*/0);

  // Dart thread: opened pode (id=36), then load (id=37) raced in and
  // overwrote the stamp before JS started running.
  p.SetCurrentEntryId(37);

  // JS thread enters pode's dispatch and activates the override guard.
  {
    JSThreadProfiler::ScopedDispatchEntryId scope(p, /*entry_id=*/36);
    int32_t idx = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
    ASSERT_GE(idx, 0);
    p.OnFunctionExit(idx);
  }  // guard destructor restores override to 0

  JSThreadSpan out[1];
  int32_t count = p.DrainSpans(out, 1);
  ASSERT_EQ(1, count);
  EXPECT_EQ(36u, out[0].entry_id)
      << "Override must win over current_entry_id_ during dispatch";

  // After the scope exits, OnFunctionEntry falls back to the shared atomic.
  int32_t idx2 = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(idx2, 0);
  p.OnFunctionExit(idx2);

  count = p.DrainSpans(out, 1);
  ASSERT_EQ(1, count);
  EXPECT_EQ(37u, out[0].entry_id)
      << "After scope, falls back to current_entry_id_";

  p.Disable();
}

TEST(EntryId, DispatchOverrideNestable) {
  // Nested dispatches (e.g. a JS listener synchronously fires another
  // dispatchEvent which re-enters HandleCallFromDartSide on the JS thread):
  // inner span should carry the inner dispatch's id, outer should restore.
  auto& p = JSThreadProfiler::Instance();
  p.Enable(/*min_duration_us=*/0);
  p.SetCurrentEntryId(0);

  JSThreadProfiler::ScopedDispatchEntryId outer(p, /*entry_id=*/10);
  int32_t outer_idx = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(outer_idx, 0);

  {
    JSThreadProfiler::ScopedDispatchEntryId inner(p, /*entry_id=*/20);
    int32_t inner_idx = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
    ASSERT_GE(inner_idx, 0);
    p.OnFunctionExit(inner_idx);
  }  // inner scope restores override to 10

  // After inner scope closes we should be back to the outer dispatch id.
  int32_t after = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
  ASSERT_GE(after, 0);
  p.OnFunctionExit(after);

  p.OnFunctionExit(outer_idx);

  JSThreadSpan out[3];
  int32_t count = p.DrainSpans(out, 3);
  ASSERT_EQ(3, count);
  // Drain is in exit order: inner, after, outer.
  EXPECT_EQ(20u, out[0].entry_id);
  EXPECT_EQ(10u, out[1].entry_id);
  EXPECT_EQ(10u, out[2].entry_id);

  p.Disable();
}

TEST(EntryId, ZeroDispatchOverrideIsNoop) {
  // A zero entry_id means "tracking disabled / caller has no id" — the
  // override must NOT mask current_entry_id_ in that case, otherwise every
  // disabled-tracker call site would accidentally erase the real stamp.
  auto& p = JSThreadProfiler::Instance();
  p.Enable(/*min_duration_us=*/0);
  p.SetCurrentEntryId(55);

  {
    JSThreadProfiler::ScopedDispatchEntryId scope(p, /*entry_id=*/0);
    int32_t idx = p.OnFunctionEntry(/*category=*/0, /*func_name=*/0);
    ASSERT_GE(idx, 0);
    p.OnFunctionExit(idx);
  }

  JSThreadSpan out[1];
  int32_t count = p.DrainSpans(out, 1);
  ASSERT_EQ(1, count);
  EXPECT_EQ(55u, out[0].entry_id)
      << "entry_id=0 in guard must fall through to current_entry_id_";
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
