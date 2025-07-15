// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_STYLE_COMPUTED_STYLE_INITIAL_VALUES_H_
#define WEBF_CORE_STYLE_COMPUTED_STYLE_INITIAL_VALUES_H_

#include <vector>
#include "core/css/css_value_list.h"
#include "core/css/css_identifier_value.h"
#include "core/style/computed_style_constants.h"
#include "core/style/grid_enums.h"
#include "core/style/style_content_alignment_data.h"
#include "core/style/style_self_alignment_data.h"
#include "core/style/style_auto_color.h"
#include "core/style/style_aspect_ratio.h"
#include "core/style/text_size_adjust.h"
#include "core/style/style_stubs.h"
#include "core/style/filter_operations.h"
#include "core/platform/geometry/length_size.h"
#include "core/platform/geometry/length_box.h"
#include "core/platform/geometry/length_point.h"
#include "core/platform/geometry/path_types.h"
#include "core/platform/std_lib_extras.h"
#include "foundation/macros.h"

// Type aliases for compatibility with Blink
template<typename T>
using Vector = std::vector<T>;
<% includes.forEach(include => { %>
#include "<%= include %>"
<% }); %>

namespace webf {

class StyleImage;
<% forward_declarations.forEach(declaration => { %>
class <%= declaration %>;
<% }); %>

/**
 * A set of functions that return the initial value for each field on ComputedStyle.
 * This includes both properties defined in css_properties.json5 and the extra
 * fields defined in computed_style_extra_fields.json5.
 */
class ComputedStyleInitialValues {
  WEBF_STATIC_ONLY(ComputedStyleInitialValues);
 public:
  // Hand-written methods.

  static FilterOperations InitialBackdropFilter() {
    return FilterOperations();
  }
  
  static int InitialColumnRuleWidth() {
    return 3;
  }
  
  static FilterOperations InitialFilter() {
    return FilterOperations();
  }

  static StyleContentAlignmentData InitialContentAlignment() {
    return StyleContentAlignmentData(ContentPosition::kNormal,
                                     ContentDistributionType::kDefault,
                                     OverflowAlignment::kDefault);
  }
  static StyleSelfAlignmentData InitialDefaultAlignment() {
    return StyleSelfAlignmentData(ItemPosition::kNormal,
                                  OverflowAlignment::kDefault);
  }
  static StyleImage* InitialBorderImageSource() { return nullptr; }
  static float InitialBorderWidth() { return 3; }

  // Grid properties.
  static size_t InitialGridAutoRepeatInsertionPoint() { return 0; }
  static AutoRepeatType InitialGridAutoRepeatType() {
    return AutoRepeatType::kNoAutoRepeat;
  }
  static GridAxisType InitialGridAxisType() {
    return GridAxisType::kStandaloneAxis;
  }

  // FIXME: Remove letter-spacing/word-spacing and replace them with respective
  // FontBuilder calls.
  static float InitialWordSpacing() { return 0.0f; }
  static float InitialLetterSpacing() { return 0.0f; }

  static EVerticalAlign InitialVerticalAlign() {
    return EVerticalAlign::kBaseline;
  }

  // -webkit-perspective-origin-x
  static Length InitialPerspectiveOriginX() { return Length::Percent(50.0); }

  // -webkit-perspective-origin-y
  static Length InitialPerspectiveOriginY() { return Length::Percent(50.0); }

  // -webkit-transform-origin-x
  static Length InitialTransformOriginX() { return Length::Percent(50.0); }
  // -webkit-transform-origin-y
  static Length InitialTransformOriginY() { return Length::Percent(50.0); }
  // -webkit-transform-origin-z
  static float InitialTransformOriginZ() { return 0; }

  // Generated methods below.
<% properties.forEach(property => { %>
  <% if (!property.computed_style_custom_functions || !property.computed_style_custom_functions.includes('initial')) { %>
    <% if (property.field_template === "pointer") { %>

  static <%= property.type_name %>* <%= property.initial %>() {
    return <%= property.default_value %>;
  }
    <% } else if (property.field_template === "external") { %>
      <% if (property.wrapper_pointer_name) { %>

  static <%= property.unwrapped_type_name %>* <%= property.initial %>() {
    return <%= property.default_value %>;
  }
      <% } else { %>

  static <%= property.type_name %> <%= property.initial %>() {
    return <%= property.default_value %>;
  }
      <% } %>
    <% } else if (property.field_template === "keyword" || 
                  property.field_template === "multi_keyword" || 
                  property.field_template === "bitset_keyword" || 
                  property.field_template === "primitive") { %>

  static <%= property.type_name %> <%= property.initial %>() {
    return <%= property.default_value %>;
  }
    <% } %>
  <% } %>
<% }); %>

};

}  // namespace webf

#endif  // WEBF_CORE_STYLE_COMPUTED_STYLE_INITIAL_VALUES_H_