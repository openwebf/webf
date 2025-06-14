// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "cssom_utils.h"
#include "core/css/css_custom_ident_value.h"
#include "core/css/css_identifier_value.h"

namespace webf {

// static
bool CSSOMUtils::IncludeDependentGridLineEndValue(const std::shared_ptr<const CSSValue>& line_start,
                                                  const std::shared_ptr<const CSSValue>& line_end) {
  const bool line_end_is_initial_value = IsA<CSSIdentifierValue>(line_end.get()) &&
                                         To<CSSIdentifierValue>(line_end.get())->GetValueID() == CSSValueID::kAuto;

  // "When grid-column-start is omitted, if grid-row-start is a <custom-ident>,
  // all four longhands are set to that value. Otherwise, it is set to auto.
  // When grid-row-end is omitted, if grid-row-start is a <custom-ident>,
  // grid-row-end is set to that <custom-ident>; otherwise, it is set to auto.
  // When grid-column-end is omitted, if grid-column-start is a <custom-ident>,
  // grid-column-end is set to that <custom-ident>; otherwise, it is set to
  // auto."
  //
  // https://www.w3.org/TR/css-grid-2/#placement-shorthands
  //
  // In order to produce a shortest-possible-serialization, we need essentially
  // the converse of that statement, as parsing handles the
  // literal interpretation. In particular, `CSSValueList` values (integer
  // literals) are always included, duplicate `custom-ident` values get
  // dropped, as well as initial values if they match the equivalent
  // `line_start` value.
  return IsA<CSSValueList>(line_end.get()) ||
         ((*line_end != *line_start) && (IsA<CSSCustomIdentValue>(line_start.get()) || !line_end_is_initial_value));
}

// static
bool CSSOMUtils::IsAutoValue(const std::shared_ptr<const CSSValue>& value) {
  return IsA<CSSIdentifierValue>(value.get()) && To<CSSIdentifierValue>(value.get())->GetValueID() == CSSValueID::kAuto;
}

// static
bool CSSOMUtils::IsNoneValue(const std::shared_ptr<const CSSValue>& value) {
  return IsA<CSSIdentifierValue>(value.get()) && To<CSSIdentifierValue>(value.get())->GetValueID() == CSSValueID::kNone;
}

// static
bool CSSOMUtils::IsAutoValueList(const std::shared_ptr<const CSSValue>& value) {
  const CSSValueList* value_list = DynamicTo<CSSValueList>(value.get());
  return value_list && value_list->length() == 1 && IsAutoValue(value_list->Item(0));
}

// static
bool CSSOMUtils::IsEmptyValueList(const std::shared_ptr<const CSSValue>& value) {
  const CSSValueList* value_list = DynamicTo<CSSValueList>(value.get());
  return value_list && value_list->length() == 0;
}

}  // namespace webf
