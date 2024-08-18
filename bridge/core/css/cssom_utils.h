// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSSOM_UTILS_H_
#define WEBF_CORE_CSS_CSSOM_UTILS_H_

#include "foundation/macros.h"
#include "core/css/css_value.h"
#include "core/css/css_value_list.h"

namespace webf {

class CSSOMUtils {
  WEBF_STATIC_ONLY(CSSOMUtils);

 public:
  static bool IncludeDependentGridLineEndValue(const std::shared_ptr<const CSSValue>& line_start,
                                               const std::shared_ptr<const CSSValue>& line_end);

  static bool IsAutoValue(const std::shared_ptr<const CSSValue>& value);

  static bool IsNoneValue(const std::shared_ptr<const CSSValue>& value);

  static bool IsAutoValueList(const std::shared_ptr<const CSSValue>& value);

  static bool IsEmptyValueList(const std::shared_ptr<const CSSValue>& value);

  // Returns the name of a grid area based on the position (`row`, `column`).
  // e.g. with the following grid definition:
  // grid-template-areas: "a a a"
  //                      "b b b";
  // grid-template-rows: [header-top] auto [header-bottom main-top] 1fr
  // [main-bottom]; grid-template-columns: auto 1fr auto;
  //
  // NamedGridAreaTextForPosition(grid_area_map, 0, 0) will return "a"
  // NamedGridAreaTextForPosition(grid_area_map, 1, 0) will return "b"
  //
  // Unlike the CSS indices, these are 0-based indices.
  // Out-of-range or not-found indices return ".", per spec.
//  static std::string NamedGridAreaTextForPosition(
//      const NamedGridAreaMap& grid_area_map,
//      wtf_size_t row,
//      wtf_size_t column);

  // Returns a `CSSValueList` containing the computed value for the
  // `grid-template` shorthand, based on provided `grid-template-rows`,
  // `grid-template-columns`, and `grid-template-areas`.
//  static std::shared_ptr<const CSSValueList> ComputedValueForGridTemplateShorthand(
//      const CSSValue* template_row_values,
//      const CSSValue* template_column_values,
//      const CSSValue* template_area_values);
};

}

#endif  // WEBF_CORE_CSS_CSSOM_UTILS_H_
