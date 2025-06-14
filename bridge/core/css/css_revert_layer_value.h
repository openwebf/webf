// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef THIRD_PARTY_BLINK_RENDERER_CORE_CSS_CSS_REVERT_LAYER_VALUE_H_
#define THIRD_PARTY_BLINK_RENDERER_CORE_CSS_CSS_REVERT_LAYER_VALUE_H_

#include "core/base/types/pass_key.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"
/*
namespace WTF {
class String;
}  // namespace WTF
*/
namespace webf {

class CSSValuePool;

namespace cssvalue {

class CSSRevertLayerValue : public CSSValue {
 public:
  static std::shared_ptr<const CSSRevertLayerValue> Create();

  explicit CSSRevertLayerValue(webf::PassKey<CSSValuePool>) : CSSValue(kRevertLayerClass) {}

  std::string CustomCSSText() const;

  bool Equals(const CSSRevertLayerValue&) const { return true; }

  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValue::TraceAfterDispatch(visitor); }
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSRevertLayerValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsRevertLayerValue(); }
};

}  // namespace webf

#endif  // THIRD_PARTY_BLINK_RENDERER_CORE_CSS_CSS_REVERT_LAYER_VALUE_H_
