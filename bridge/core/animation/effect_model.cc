// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/animation/effect_model.h"

//#include "third_party/blink/renderer/bindings/core/v8/v8_keyframe_effect_options.h"
#include "bindings/qjs/exception_state.h"

namespace webf {
std::optional<EffectModel::CompositeOperation>
EffectModel::StringToCompositeOperation(const std::string& composite_string) {
  assert(composite_string == "replace" || composite_string == "add" ||
         composite_string == "accumulate" || composite_string == "auto");
  if (composite_string == "auto")
    return std::nullopt;
  if (composite_string == "add")
    return kCompositeAdd;
  if (composite_string == "accumulate")
    return kCompositeAccumulate;
  return kCompositeReplace;
}

std::string EffectModel::CompositeOperationToString(
    std::optional<CompositeOperation> composite) {
  if (!composite)
    return "auto";
  switch (composite.value()) {
    case EffectModel::kCompositeAccumulate:
      return "accumulate";
    case EffectModel::kCompositeAdd:
      return "add";
    case EffectModel::kCompositeReplace:
      return "replace";
    default:
      assert_m(false, "EffectModel::CompositeOperationToString NOTREACHED_IN_MIGRATION");
      return "";
  }
}
}  // namespace webf