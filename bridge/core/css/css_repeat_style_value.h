// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_REPEAT_STYLE_VALUE_H_
#define WEBF_CORE_CSS_CSS_REPEAT_STYLE_VALUE_H_

#include "core/css/css_identifier_value.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {

// This class represents a repeat-style value as specified in:
// https://drafts.csswg.org/css-backgrounds-3/#typedef-repeat-style
// <repeat-style> = repeat-x | repeat-y | [repeat | space | round |
// no-repeat]{1,2}
class  CSSRepeatStyleValue : public CSSValue {
 public:
  explicit CSSRepeatStyleValue(std::shared_ptr<const CSSIdentifierValue> id);
  CSSRepeatStyleValue(std::shared_ptr<const CSSIdentifierValue> x, std::shared_ptr<const CSSIdentifierValue> y);

  // It is expected that CSSRepeatStyleValue objects should always be created
  // with at least one non-null id value.
  CSSRepeatStyleValue() = delete;

  ~CSSRepeatStyleValue();

  AtomicString CustomCSSText() const;

  bool Equals(const CSSRepeatStyleValue& other) const;

  bool IsRepeat() const;

  const CSSIdentifierValue* x() const { return x_.get(); }
  const CSSIdentifierValue* y() const { return y_.get(); }

  void TraceAfterDispatch(GCVisitor* visitor) const;

 private:
  // Member<const CSSIdentifierValue> x_;
  // Member<const CSSIdentifierValue> y_;
  std::shared_ptr<const CSSIdentifierValue> x_;
  std::shared_ptr<const CSSIdentifierValue> y_;
};

template <>
struct DowncastTraits<CSSRepeatStyleValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsRepeatStyleValue();
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_REPEAT_STYLE_VALUE_H_
