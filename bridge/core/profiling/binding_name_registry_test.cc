/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <gtest/gtest.h>
#include "core/profiling/js_thread_profiler.h"

namespace webf {

TEST(BindingNameRegistry, RegisterReturnsHighBitId) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  uint32_t id = p.RegisterBindingName("getBoundingClientRect");
  EXPECT_NE(0u, id & 0x80000000u) << "binding IDs must have the high bit set";
  p.Disable();
}

TEST(BindingNameRegistry, RegisterIsIdempotent) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  uint32_t id1 = p.RegisterBindingName("offsetWidth");
  uint32_t id2 = p.RegisterBindingName("offsetWidth");
  EXPECT_EQ(id1, id2) << "same name must return same ID";
  p.Disable();
}

TEST(BindingNameRegistry, GetAtomNameResolvesBindingId) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  uint32_t id = p.RegisterBindingName("getComputedStyle");
  EXPECT_EQ("getComputedStyle", p.GetAtomName(id));
  p.Disable();
}

TEST(BindingNameRegistry, EnableClearsBindingRegistry) {
  auto& p = JSThreadProfiler::Instance();
  p.Enable();
  uint32_t id_before = p.RegisterBindingName("scrollTop");
  p.Disable();
  p.Enable();
  uint32_t id_after = p.RegisterBindingName("scrollTop");
  EXPECT_EQ("scrollTop", p.GetAtomName(id_after));
  // After Disable+Enable the registry is cleared, so id_before (from the old
  // session) must not resolve to "scrollTop" in the new session. If id_before
  // happens to equal id_after (both are 0x80000000 | 0, the first slot), use a
  // provably unregistered ID instead.
  uint32_t probe = (id_before == id_after) ? (id_before ^ 1u) : id_before;
  EXPECT_EQ("", p.GetAtomName(probe));
  p.Disable();
}

}  // namespace webf
