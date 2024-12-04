// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "font_size_adjust.h"
#include <cassert>
#include <format>

#include "core/base/strings/string_number_conversions.h"
#include "core/platform/hash_functions.h"
#include "foundation/macros.h"

namespace webf {

unsigned FontSizeAdjust::GetHash() const {
  unsigned computed_hash = 0;
  // Normalize negative zero.
  WTF::AddFloatToHash(computed_hash, value_ == 0.0 ? 0.0 : value_);
  WTF::AddIntToHash(computed_hash, static_cast<const unsigned>(metric_));
  WTF::AddIntToHash(computed_hash, static_cast<const unsigned>(type_));
  return computed_hash;
}

std::string FontSizeAdjust::ToString(Metric metric) const {
  switch (metric) {
    case Metric::kCapHeight:
      return "cap-height";
    case Metric::kChWidth:
      return "ch-width";
    case Metric::kIcWidth:
      return "ic-width";
    case Metric::kIcHeight:
      return "ic-height";
    case Metric::kExHeight:
      return "ex-height";
  }
  assert_m(false, "NOTREACHED_IN_MIGRATION");
}

std::string FontSizeAdjust::ToString() const {
  if (value_ == kFontSizeAdjustNone) {
    return "none";
  }

  if (metric_ == Metric::kExHeight) {
    return IsFromFont() ? "from-font" : std::format("{}", base::NumberToString(value_).c_str());
  }

  return IsFromFont() ? std::format("{} from-font", ToString(metric_).c_str())
                      : std::format("{} {}", ToString(metric_).c_str(), base::NumberToString(value_).c_str());
}
}  // namespace webf