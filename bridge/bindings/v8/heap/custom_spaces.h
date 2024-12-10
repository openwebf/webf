/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_PLATFORM_HEAP_CUSTOM_SPACES_H_
#define WEBF_PLATFORM_HEAP_CUSTOM_SPACES_H_

#include <v8/cppgc/custom-space.h>
#include <memory>
#include <vector>

namespace webf {

// The following defines custom spaces that are used to partition Oilpan's heap.
// Each custom space is assigned to a type partition using `cppgc::SpaceTrait`.
// It is expected that `kSpaceIndex` uniquely identifies a space and that the
// indices of all custom spaces form a sequence starting at 0. See
// `cppgc::CustomSpace` for details.

class CompactableHeapVectorBackingSpace : public cppgc::CustomSpace<CompactableHeapVectorBackingSpace> {
 public:
  static constexpr cppgc::CustomSpaceIndex kSpaceIndex = 0;
  static constexpr bool kSupportsCompaction = true;
};

class CompactableHeapHashTableBackingSpace : public cppgc::CustomSpace<CompactableHeapHashTableBackingSpace> {
 public:
  static constexpr cppgc::CustomSpaceIndex kSpaceIndex = 1;
  static constexpr bool kSupportsCompaction = true;
};

class NodeSpace : public cppgc::CustomSpace<NodeSpace> {
 public:
  static constexpr cppgc::CustomSpaceIndex kSpaceIndex = 2;
};

class CSSValueSpace : public cppgc::CustomSpace<CSSValueSpace> {
 public:
  static constexpr cppgc::CustomSpaceIndex kSpaceIndex = 3;
};

class LayoutObjectSpace : public cppgc::CustomSpace<LayoutObjectSpace> {
 public:
  static constexpr cppgc::CustomSpaceIndex kSpaceIndex = 4;
};

struct CustomSpaces final {
  static std::vector<std::unique_ptr<cppgc::CustomSpaceBase>> CreateCustomSpaces();
};

}  // namespace webf

#endif  // WEBF_PLATFORM_HEAP_CUSTOM_SPACES_H_
