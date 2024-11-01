// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/css_repeat_style_value.h"
#include "foundation/string_builder.h"
#include "core/base/memory/values_equivalent.h"

namespace webf {

CSSRepeatStyleValue::CSSRepeatStyleValue(std::shared_ptr<const CSSIdentifierValue> id)
    : CSSValue(kRepeatStyleClass) {
  switch (id->GetValueID()) {
    case CSSValueID::kRepeatX:
      x_ = CSSIdentifierValue::Create(CSSValueID::kRepeat);
      y_ = CSSIdentifierValue::Create(CSSValueID::kNoRepeat);
      break;

    case CSSValueID::kRepeatY:
      x_ = CSSIdentifierValue::Create(CSSValueID::kNoRepeat);
      y_ = CSSIdentifierValue::Create(CSSValueID::kRepeat);
      break;

    default:
      x_ = y_ = id;
      break;
  }
}

CSSRepeatStyleValue::CSSRepeatStyleValue(std::shared_ptr<const CSSIdentifierValue> x,
                                         std::shared_ptr<const CSSIdentifierValue> y)
    : CSSValue(kRepeatStyleClass), x_(x), y_(y) {}

CSSRepeatStyleValue::~CSSRepeatStyleValue() = default;

std::string CSSRepeatStyleValue::CustomCSSText() const {
  StringBuilder result;

  if (webf::ValuesEquivalent(x_, y_)) {
    result.Append(x_->CssText());
  } else if (x_->GetValueID() == CSSValueID::kRepeat &&
             y_->GetValueID() == CSSValueID::kNoRepeat) {
    result.Append(getValueName(CSSValueID::kRepeatX));
  } else if (x_->GetValueID() == CSSValueID::kNoRepeat &&
             y_->GetValueID() == CSSValueID::kRepeat) {
    result.Append(getValueName(CSSValueID::kRepeatY));
  } else {
    result.Append(x_->CssText());
    result.Append(' ');
    result.Append(y_->CssText());
  }

  return result.ReleaseString();
}

bool CSSRepeatStyleValue::Equals(const CSSRepeatStyleValue& other) const {
  return webf::ValuesEquivalent(x_, other.x_) &&
         webf::ValuesEquivalent(y_, other.y_);
}

bool CSSRepeatStyleValue::IsRepeat() const {
  return x_->GetValueID() == CSSValueID::kRepeat &&
         y_->GetValueID() == CSSValueID::kRepeat;
}

void CSSRepeatStyleValue::TraceAfterDispatch(GCVisitor* visitor) const {
  //visitor->Trace(x_);
  //visitor->Trace(y_);

  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf
