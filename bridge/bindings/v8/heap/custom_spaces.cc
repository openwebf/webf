/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "custom_spaces.h"

namespace webf {

// static
constexpr cppgc::CustomSpaceIndex CompactableHeapVectorBackingSpace::kSpaceIndex;

// static
constexpr cppgc::CustomSpaceIndex CompactableHeapHashTableBackingSpace::kSpaceIndex;

// static
constexpr cppgc::CustomSpaceIndex NodeSpace::kSpaceIndex;

// static
constexpr cppgc::CustomSpaceIndex CSSValueSpace::kSpaceIndex;

// static
constexpr cppgc::CustomSpaceIndex LayoutObjectSpace::kSpaceIndex;

// static
std::vector<std::unique_ptr<cppgc::CustomSpaceBase>> CustomSpaces::CreateCustomSpaces() {
  std::vector<std::unique_ptr<cppgc::CustomSpaceBase>> spaces;
  spaces.emplace_back(std::make_unique<CompactableHeapVectorBackingSpace>());
  spaces.emplace_back(std::make_unique<CompactableHeapHashTableBackingSpace>());
  spaces.emplace_back(std::make_unique<NodeSpace>());
  spaces.emplace_back(std::make_unique<CSSValueSpace>());
  spaces.emplace_back(std::make_unique<LayoutObjectSpace>());
  return spaces;
}

}  // namespace webf