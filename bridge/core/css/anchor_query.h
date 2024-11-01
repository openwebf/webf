// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_ANCHOR_QUERY_H_
#define WEBF_CORE_CSS_ANCHOR_QUERY_H_

#include <cassert>
#include <variant>
#include "foundation/macros.h"
#include "core/css/css_anchor_query_enums.h"
#include "core/style/anchor_specifier_value.h"

namespace webf {

// The input to AnchorEvaluator::Evaluate.
//
// It represents either an anchor() function, or an anchor-size() function.
//
// https://drafts.csswg.org/css-anchor-position-1/#anchor-pos
// https://drafts.csswg.org/css-anchor-position-1/#anchor-size-fn
class AnchorQuery {
  WEBF_DISALLOW_NEW();

 public:
  AnchorQuery(CSSAnchorQueryType query_type,
              const AnchorSpecifierValue* anchor_specifier,
              float percentage,
              std::variant<CSSAnchorValue, CSSAnchorSizeValue> value)
      : query_type_(query_type),
        anchor_specifier_(anchor_specifier),
        percentage_(percentage),
        value_(value) {
    assert(anchor_specifier);
  }

  CSSAnchorQueryType Type() const { return query_type_; }
  const AnchorSpecifierValue& AnchorSpecifier() const {
    return *anchor_specifier_;
  }
  CSSAnchorValue AnchorSide() const {
    assert(query_type_ == CSSAnchorQueryType::kAnchor);
    return std::get<CSSAnchorValue>(value_);
  }
  float AnchorSidePercentage() const {
    assert(query_type_ == CSSAnchorQueryType::kAnchor);
    assert(AnchorSide() == CSSAnchorValue::kPercentage);
    return percentage_;
  }
  float AnchorSidePercentageOrZero() const {
    assert(query_type_ == CSSAnchorQueryType::kAnchor);
    return AnchorSide() == CSSAnchorValue::kPercentage ? percentage_ : 0;
  }
  CSSAnchorSizeValue AnchorSize() const {
    assert(query_type_ == CSSAnchorQueryType::kAnchorSize);
    return std::get<CSSAnchorSizeValue>(value_);
  }

  bool operator==(const AnchorQuery& other) const;
  bool operator!=(const AnchorQuery& other) const { return !operator==(other); }
  void Trace(GCVisitor*) const;

 private:
  CSSAnchorQueryType query_type_;
  std::shared_ptr<const AnchorSpecifierValue> anchor_specifier_;
  float percentage_;
  std::variant<CSSAnchorValue, CSSAnchorSizeValue> value_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_ANCHOR_QUERY_H_
