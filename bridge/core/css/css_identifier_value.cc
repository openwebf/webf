// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/css_identifier_value.h"

#include "core/css/css_markup.h"
#include "core/css/css_value_pool.h"
#include "core/platform/geometry/length.h"

namespace webf {

std::shared_ptr<CSSIdentifierValue> CSSIdentifierValue::Create(CSSValueID value_id) {
  std::shared_ptr<CSSIdentifierValue> css_value = CssValuePool().IdentifierCacheValue(value_id);
  if (!css_value) {
    css_value = CssValuePool().SetIdentifierCacheValue(
        value_id, std::make_shared<CSSIdentifierValue>(value_id));
  }
  return css_value;
}

std::string CSSIdentifierValue::CustomCSSText() const {
  return getValueName(value_id_);
}

CSSIdentifierValue::CSSIdentifierValue(CSSValueID value_id)
    : CSSValue(kIdentifierClass), value_id_(value_id) {
}

CSSIdentifierValue::CSSIdentifierValue(CSSValueID value_id, bool was_quirky)
    : CSSValue(kIdentifierClass), value_id_(value_id) {
  assert(value_id != CSSValueID::kInvalid);
  was_quirky_ = was_quirky;
}

CSSIdentifierValue::CSSIdentifierValue(const Length& length)
    : CSSValue(kIdentifierClass) {
  switch (length.GetType()) {
    case Length::kAuto:
      value_id_ = CSSValueID::kAuto;
      break;
    case Length::kMinContent:
      value_id_ = CSSValueID::kMinContent;
      break;
    case Length::kMaxContent:
      value_id_ = CSSValueID::kMaxContent;
      break;
    case Length::kFillAvailable:
      value_id_ = CSSValueID::kWebkitFillAvailable;
      break;
    case Length::kFitContent:
      value_id_ = CSSValueID::kFitContent;
      break;
    case Length::kContent:
      value_id_ = CSSValueID::kContent;
      break;
    case Length::kExtendToZoom:
      value_id_ = CSSValueID::kInternalExtendToZoom;
      break;
    case Length::kPercent:
    case Length::kFixed:
    case Length::kCalculated:
    case Length::kFlex:
    case Length::kDeviceWidth:
    case Length::kDeviceHeight:
    case Length::kMinIntrinsic:
    case Length::kNone:
      assert_m(false, "CSSIdentifierValue NOTREACHED_IN_MIGRATION");
      break;
  }
}

void CSSIdentifierValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf
