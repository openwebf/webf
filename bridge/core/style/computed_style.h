/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2000 Lars Knoll (knoll@kde.org)
 *           (C) 2000 Antti Koivisto (koivisto@kde.org)
 *           (C) 2000 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2003, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Apple Inc. All rights reserved.
 * Copyright (C) 2006 Graham Dennis (graham.dennis@gmail.com)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_STYLE_COMPUTED_STYLE_H
#define WEBF_CORE_STYLE_COMPUTED_STYLE_H

#include <cmath>
#include <memory>
#include <optional>
#include "../../foundation/string/atomic_string.h"
#include "code_gen/css_property_names.h"
#include "core/animation/css/css_transition_data.h"
#include "core/css/style_color.h"
#include "core/css/white_space.h"
#include "core/platform/fonts/font.h"
#include "core/platform/fonts/font_description.h"
#include "core/platform/geometry/layout_unit.h"
#include "core/platform/geometry/length.h"
#include "core/platform/geometry/length_point.h"
#include "core/platform/geometry/length_size.h"
#include "core/platform/geometry/path_types.h"
#include "core/platform/graphics/color.h"
#include "core/platform/graphics/graphic_types.h"
#include "core/platform/graphics/touch_action.h"
#include "core/platform/text/text_direction.h"
#include "core/platform/text/writing_mode.h"
#include "core/style/computed_style_base_constants.h"
#include "core/style/computed_style_constants.h"
#include "core/style/filter_operations.h"
#include "core/style/nine_piece_image.h"
#include "core/style/scoped_css_name.h"
#include "core/style/style_aspect_ratio.h"
#include "core/style/style_auto_color.h"
#include "core/style/style_content_alignment_data.h"
#include "core/style/style_self_alignment_data.h"
#include "core/style/style_stubs.h"
#include "foundation/macros.h"

namespace webf {

class ComputedStyleBuilder;
class StyleImage;
class ShadowList;
class ClipPathOperation;
class QuotesData;
class RotateTransformOperation;
class ScaleTransformOperation;

// Typedef for TextDecoration which is a bitmask of TextDecorationLine values
using TextDecoration = uint8_t;

// Represents the computed style for an element
class ComputedStyle : public std::enable_shared_from_this<ComputedStyle> {

 public:
  ComputedStyle();
  ComputedStyle(const ComputedStyle& other) = default;
  ComputedStyle& operator=(const ComputedStyle& other) = default;
  
  // Create the initial style singleton
  static const ComputedStyle& GetInitialStyle();
  
  // Clone this style
  std::unique_ptr<ComputedStyle> Clone() const;
  
  // Clone for style builder
  std::unique_ptr<ComputedStyleBuilder> CloneAsBuilder() const;
  
  // Display property
  EDisplay Display() const { return display_; }
  void SetDisplay(EDisplay display) { display_ = display; }
  
  // Position property
  EPosition Position() const { return position_; }
  void SetPosition(EPosition position) { position_ = position; }
  
  // Overflow properties
  EOverflow OverflowX() const { return overflow_x_; }
  void SetOverflowX(EOverflow overflow) { overflow_x_ = overflow; }
  
  EOverflow OverflowY() const { return overflow_y_; }
  void SetOverflowY(EOverflow overflow) { overflow_y_ = overflow; }
  
  // Direction
  TextDirection GetDirection() const { return direction_; }
  void SetDirection(TextDirection direction) { direction_ = direction; }
  
  // Writing mode
  WritingMode GetWritingMode() const { return writing_mode_; }
  void SetWritingMode(WritingMode mode) { writing_mode_ = mode; }
  
  // Colors
  const Color& Color() const { return color_; }
  void SetColor(const ::webf::Color& color) { color_ = color; }
  
  const ::webf::Color& BackgroundColor() const { return background_color_; }
  void SetBackgroundColor(const ::webf::Color& color) { background_color_ = color; }
  void SetBackgroundColor(const StyleColor& color) { 
    // Convert StyleColor to Color - simplified conversion
    background_color_ = color.IsCurrentColor() ? ::webf::Color::kBlack : color.GetColor();
  }
  
  // Font
  const FontDescription& GetFontDescription() const { return font_description_; }
  void SetFontDescription(const FontDescription& desc) { font_description_ = desc; }
  
  float GetFontSize() const { return font_description_.ComputedSize(); }
  
  // Get Font object - returns by value since Font uses WEBF_DISALLOW_NEW
  Font GetFont() const { 
    return Font(font_description_);
  }
  
  // Opacity
  float Opacity() const { return opacity_; }
  void SetOpacity(float opacity) { opacity_ = opacity; }
  
  // Z-index
  int ZIndex() const { return z_index_; }
  void SetZIndex(int z_index) { z_index_ = z_index; }
  
  bool HasAutoZIndex() const { return has_auto_z_index_; }
  void SetHasAutoZIndex(bool has_auto) { has_auto_z_index_ = has_auto; }
  
  // Box model - dimensions
  const Length& Width() const { return width_; }
  void SetWidth(const Length& width) { width_ = width; }
  
  const Length& Height() const { return height_; }
  void SetHeight(const Length& height) { height_ = height; }
  
  const Length& MinWidth() const { return min_width_; }
  void SetMinWidth(const Length& width) { min_width_ = width; }
  
  const Length& MinHeight() const { return min_height_; }
  void SetMinHeight(const Length& height) { min_height_ = height; }
  
  const Length& MaxWidth() const { return max_width_; }
  void SetMaxWidth(const Length& width) { max_width_ = width; }
  
  const Length& MaxHeight() const { return max_height_; }
  void SetMaxHeight(const Length& height) { max_height_ = height; }
  
  // Box model - margins
  const Length& MarginTop() const { return margin_top_; }
  void SetMarginTop(const Length& margin) { margin_top_ = margin; }
  
  const Length& MarginRight() const { return margin_right_; }
  void SetMarginRight(const Length& margin) { margin_right_ = margin; }
  
  const Length& MarginBottom() const { return margin_bottom_; }
  void SetMarginBottom(const Length& margin) { margin_bottom_ = margin; }
  
  const Length& MarginLeft() const { return margin_left_; }
  void SetMarginLeft(const Length& margin) { margin_left_ = margin; }
  
  // Box model - padding
  const Length& PaddingTop() const { return padding_top_; }
  void SetPaddingTop(const Length& padding) { padding_top_ = padding; }
  
  const Length& PaddingRight() const { return padding_right_; }
  void SetPaddingRight(const Length& padding) { padding_right_ = padding; }
  
  const Length& PaddingBottom() const { return padding_bottom_; }
  void SetPaddingBottom(const Length& padding) { padding_bottom_ = padding; }
  
  const Length& PaddingLeft() const { return padding_left_; }
  void SetPaddingLeft(const Length& padding) { padding_left_ = padding; }
  
  // Border widths
  LayoutUnit BorderTopWidth() const { return border_top_width_; }
  void SetBorderTopWidth(LayoutUnit width) { border_top_width_ = width; }
  void SetBorderTopWidth(int width) { border_top_width_ = LayoutUnit(width); }
  
  LayoutUnit BorderRightWidth() const { return border_right_width_; }
  void SetBorderRightWidth(LayoutUnit width) { border_right_width_ = width; }
  void SetBorderRightWidth(int width) { border_right_width_ = LayoutUnit(width); }
  
  LayoutUnit BorderBottomWidth() const { return border_bottom_width_; }
  void SetBorderBottomWidth(LayoutUnit width) { border_bottom_width_ = width; }
  void SetBorderBottomWidth(int width) { border_bottom_width_ = LayoutUnit(width); }
  
  LayoutUnit BorderLeftWidth() const { return border_left_width_; }
  void SetBorderLeftWidth(LayoutUnit width) { border_left_width_ = width; }
  void SetBorderLeftWidth(int width) { border_left_width_ = LayoutUnit(width); }
  
  // Border styles
  EBorderStyle BorderTopStyle() const { return border_top_style_; }
  void SetBorderTopStyle(EBorderStyle style) { border_top_style_ = style; }
  
  EBorderStyle BorderRightStyle() const { return border_right_style_; }
  void SetBorderRightStyle(EBorderStyle style) { border_right_style_ = style; }
  
  EBorderStyle BorderBottomStyle() const { return border_bottom_style_; }
  void SetBorderBottomStyle(EBorderStyle style) { border_bottom_style_ = style; }
  
  EBorderStyle BorderLeftStyle() const { return border_left_style_; }
  void SetBorderLeftStyle(EBorderStyle style) { border_left_style_ = style; }
  
  // Border colors
  const ::webf::Color& BorderTopColor() const { return border_top_color_; }
  void SetBorderTopColor(const ::webf::Color& color) { border_top_color_ = color; }
  void SetBorderTopColor(const StyleColor& color) { 
    border_top_color_ = color.IsCurrentColor() ? ::webf::Color::kBlack : color.GetColor();
  }
  
  const ::webf::Color& BorderRightColor() const { return border_right_color_; }
  void SetBorderRightColor(const ::webf::Color& color) { border_right_color_ = color; }
  void SetBorderRightColor(const StyleColor& color) { 
    border_right_color_ = color.IsCurrentColor() ? ::webf::Color::kBlack : color.GetColor();
  }
  
  const ::webf::Color& BorderBottomColor() const { return border_bottom_color_; }
  void SetBorderBottomColor(const ::webf::Color& color) { border_bottom_color_ = color; }
  void SetBorderBottomColor(const StyleColor& color) { 
    border_bottom_color_ = color.IsCurrentColor() ? ::webf::Color::kBlack : color.GetColor();
  }
  
  const ::webf::Color& BorderLeftColor() const { return border_left_color_; }
  void SetBorderLeftColor(const ::webf::Color& color) { border_left_color_ = color; }
  void SetBorderLeftColor(const StyleColor& color) { 
    border_left_color_ = color.IsCurrentColor() ? ::webf::Color::kBlack : color.GetColor();
  }
  
  // Border radius
  const LengthSize& BorderTopLeftRadius() const { return border_top_left_radius_; }
  void SetBorderTopLeftRadius(const LengthSize& radius) { border_top_left_radius_ = radius; }
  
  const LengthSize& BorderTopRightRadius() const { return border_top_right_radius_; }
  void SetBorderTopRightRadius(const LengthSize& radius) { border_top_right_radius_ = radius; }
  
  const LengthSize& BorderBottomLeftRadius() const { return border_bottom_left_radius_; }
  void SetBorderBottomLeftRadius(const LengthSize& radius) { border_bottom_left_radius_ = radius; }
  
  const LengthSize& BorderBottomRightRadius() const { return border_bottom_right_radius_; }
  void SetBorderBottomRightRadius(const LengthSize& radius) { border_bottom_right_radius_ = radius; }
  
  // Accent color
  const StyleAutoColor& AccentColor() const { return accent_color_; }
  void SetAccentColor(const StyleAutoColor& color) { accent_color_ = color; }
  
  // Alignment baseline
  EAlignmentBaseline AlignmentBaseline() const { return alignment_baseline_; }
  void SetAlignmentBaseline(EAlignmentBaseline baseline) { alignment_baseline_ = baseline; }
  
  // Anchor name
  ScopedCSSNameList* AnchorName() const { return anchor_name_; }
  void SetAnchorName(ScopedCSSNameList* name) { anchor_name_ = name; }
  
  // Anchor scope
  ScopedCSSNameList* AnchorScope() const { return anchor_scope_; }
  void SetAnchorScope(ScopedCSSNameList* scope) { anchor_scope_ = scope; }
  
  // Aspect ratio
  const StyleAspectRatio& AspectRatio() const { return aspect_ratio_; }
  void SetAspectRatio(const StyleAspectRatio& ratio) { aspect_ratio_ = ratio; }
  
  // Backdrop filter
  const FilterOperations& BackdropFilter() const { return backdrop_filter_; }
  void SetBackdropFilter(const FilterOperations& filter) { backdrop_filter_ = filter; }
  
  // Backface visibility
  EBackfaceVisibility BackfaceVisibility() const { return backface_visibility_; }
  void SetBackfaceVisibility(EBackfaceVisibility visibility) { backface_visibility_ = visibility; }
  
  // Border collapse
  EBorderCollapse BorderCollapse() const { return border_collapse_; }
  void SetBorderCollapse(EBorderCollapse collapse) { border_collapse_ = collapse; }
  
  // Border image
  const NinePieceImage& BorderImage() const { return border_image_; }
  void SetBorderImage(const NinePieceImage& image) { border_image_ = image; }
  
  // Border image source
  StyleImage* BorderImageSource() const { return border_image_source_; }
  void SetBorderImageSource(StyleImage* source) { border_image_source_ = source; }
  
  // Box decoration break
  EBoxDecorationBreak BoxDecorationBreak() const { return box_decoration_break_; }
  void SetBoxDecorationBreak(EBoxDecorationBreak decoration_break) { box_decoration_break_ = decoration_break; }
  
  // Box shadow
  ShadowList* BoxShadow() const { return box_shadow_; }
  void SetBoxShadow(ShadowList* shadow) { box_shadow_ = shadow; }
  
  // Box sizing
  EBoxSizing BoxSizing() const { return box_sizing_; }
  void SetBoxSizing(EBoxSizing sizing) { box_sizing_ = sizing; }
  
  // Break properties
  EBreakBetween BreakAfter() const { return break_after_; }
  void SetBreakAfter(EBreakBetween break_value) { break_after_ = break_value; }
  
  EBreakBetween BreakBefore() const { return break_before_; }
  void SetBreakBefore(EBreakBetween break_value) { break_before_ = break_value; }
  
  EBreakInside BreakInside() const { return break_inside_; }
  void SetBreakInside(EBreakInside break_value) { break_inside_ = break_value; }
  
  // Rendering properties
  EBufferedRendering BufferedRendering() const { return buffered_rendering_; }
  void SetBufferedRendering(EBufferedRendering rendering) { buffered_rendering_ = rendering; }
  
  // Table properties
  ECaptionSide CaptionSide() const { return caption_side_; }
  void SetCaptionSide(ECaptionSide side) { caption_side_ = side; }
  
  // Caret color
  const StyleAutoColor& CaretColor() const { return caret_color_; }
  void SetCaretColor(const StyleAutoColor& color) { caret_color_ = color; }
  
  // Clipping properties
  const LengthBox& Clip() const { return clip_; }
  void SetClip(const LengthBox& clip) { clip_ = clip; }
  
  bool HasAutoClip() const { return has_auto_clip_; }
  void SetHasAutoClip() { has_auto_clip_ = true; }
  
  ClipPathOperation* ClipPath() const { return clip_path_; }
  void SetClipPath(ClipPathOperation* path) { clip_path_ = path; }
  
  WindRule ClipRule() const { return clip_rule_; }
  void SetClipRule(WindRule rule) { clip_rule_ = rule; }
  
  // Color interpolation
  EColorInterpolation ColorInterpolation() const { return color_interpolation_; }
  void SetColorInterpolation(EColorInterpolation interpolation) { color_interpolation_ = interpolation; }
  
  EColorInterpolation ColorInterpolationFilters() const { return color_interpolation_filters_; }
  void SetColorInterpolationFilters(EColorInterpolation interpolation) { color_interpolation_filters_ = interpolation; }
  
  // Color rendering
  EColorRendering ColorRendering() const { return color_rendering_; }
  void SetColorRendering(EColorRendering rendering) { color_rendering_ = rendering; }
  
  // Column properties
  unsigned short ColumnCount() const { return column_count_; }
  void SetColumnCount(unsigned short count) { column_count_ = count; }
  
  bool HasAutoColumnCount() const { return has_auto_column_count_; }
  void SetHasAutoColumnCount() { has_auto_column_count_ = true; }
  
  EColumnFill GetColumnFill() const { return column_fill_; }
  void SetColumnFill(EColumnFill fill) { column_fill_ = fill; }
  
  // Positioning offsets
  const Length& Top() const { return top_; }
  void SetTop(const Length& top) { top_ = top; }
  
  const Length& Right() const { return right_; }
  void SetRight(const Length& right) { right_ = right; }
  
  const Length& Bottom() const { return bottom_; }
  void SetBottom(const Length& bottom) { bottom_ = bottom; }
  
  const Length& Left() const { return left_; }
  void SetLeft(const Length& left) { left_ = left; }
  
  // Text properties
  ETextAlign TextAlign() const { return text_align_; }
  ETextAlign GetTextAlign() const { return text_align_; }  // For Blink compatibility
  void SetTextAlign(ETextAlign align) { text_align_ = align; }
  
  ::webf::TextDecoration GetTextDecoration() const { return text_decoration_; }
  void SetTextDecoration(::webf::TextDecoration decoration) { text_decoration_ = decoration; }
  
  ETextTransform TextTransform() const { return text_transform_; }
  void SetTextTransform(ETextTransform transform) { text_transform_ = transform; }
  
  const Length& LineHeight() const { return line_height_; }
  void SetLineHeight(const Length& height) { line_height_ = height; }
  
  // Layout properties
  EFloat Float() const { return float_; }
  void SetFloat(EFloat float_value) { float_ = float_value; }
  
  EClear Clear() const { return clear_; }
  void SetClear(EClear clear) { clear_ = clear; }
  
  EOverflow Overflow() const { return overflow_x_; } // For shorthand
  void SetOverflow(EOverflow overflow) { 
    overflow_x_ = overflow; 
    overflow_y_ = overflow; 
  }
  
  // Visibility
  EVisibility Visibility() const { return visibility_; }
  void SetVisibility(EVisibility visibility) { visibility_ = visibility; }
  
  // Flexbox properties
  EFlexDirection FlexDirection() const { return flex_direction_; }
  void SetFlexDirection(EFlexDirection direction) { flex_direction_ = direction; }
  
  EFlexWrap FlexWrap() const { return flex_wrap_; }
  void SetFlexWrap(EFlexWrap wrap) { flex_wrap_ = wrap; }
  
  const StyleContentAlignmentData& JustifyContent() const { return justify_content_; }
  void SetJustifyContent(const StyleContentAlignmentData& alignment) { justify_content_ = alignment; }
  
  const StyleSelfAlignmentData& AlignItems() const { return align_items_; }
  void SetAlignItems(const StyleSelfAlignmentData& alignment) { align_items_ = alignment; }
  
  const StyleContentAlignmentData& AlignContent() const { return align_content_; }
  void SetAlignContent(const StyleContentAlignmentData& alignment) { align_content_ = alignment; }
  
  // AlignSelf and JustifySelf (individual item alignment)
  const StyleSelfAlignmentData& AlignSelf() const { return align_self_; }
  void SetAlignSelf(const StyleSelfAlignmentData& alignment) { align_self_ = alignment; }
  
  const StyleSelfAlignmentData& JustifySelf() const { return justify_self_; }
  void SetJustifySelf(const StyleSelfAlignmentData& alignment) { justify_self_ = alignment; }
  
  const StyleSelfAlignmentData& JustifyItems() const { return justify_items_; }
  void SetJustifyItems(const StyleSelfAlignmentData& alignment) { justify_items_ = alignment; }
  
  float FlexGrow() const { return flex_grow_; }
  void SetFlexGrow(float grow) { flex_grow_ = grow; }
  
  float FlexShrink() const { return flex_shrink_; }
  void SetFlexShrink(float shrink) { flex_shrink_ = shrink; }
  
  const Length& FlexBasis() const { return flex_basis_; }
  void SetFlexBasis(const Length& basis) { flex_basis_ = basis; }
  
  // Writing direction
  TextDirection Direction() const { return direction_; }
  // WritingMode GetWritingMode() is already declared above
  
  // Locale
  const AtomicString& Locale() const { return locale_; }
  void SetLocale(const AtomicString& locale) { locale_ = locale; }
  
  // Quirks mode
  bool IsQuirksModeDocumentForView() const { return is_quirks_mode_document_; }
  void SetIsQuirksModeDocumentForView(bool quirks) { is_quirks_mode_document_ = quirks; }
  
  // Forced color adjust
  EForcedColorAdjust ForcedColorAdjust() const { return forced_color_adjust_; }
  void SetForcedColorAdjust(EForcedColorAdjust adjust) { forced_color_adjust_ = adjust; }
  
  // Column properties
  Length ColumnGap() const { return column_gap_; }
  void SetColumnGap(const Length& gap) { column_gap_ = gap; }
  
  StyleColor ColumnRuleColor() const { return column_rule_color_; }
  void SetColumnRuleColor(const StyleColor& color) { column_rule_color_ = color; }
  void SetColumnRuleColor(const ::webf::Color& color) { 
    column_rule_color_ = StyleColor(color);
  }
  
  EBorderStyle ColumnRuleStyle() const { return column_rule_style_; }
  void SetColumnRuleStyle(EBorderStyle style) { column_rule_style_ = style; }
  
  LayoutUnit ColumnRuleWidth() const { return column_rule_width_; }
  void SetColumnRuleWidth(const LayoutUnit& width) { column_rule_width_ = width; }
  void SetColumnRuleWidth(int width) { column_rule_width_ = LayoutUnit(width); }
  
  EColumnSpan GetColumnSpan() const { return column_span_; }
  void SetColumnSpan(EColumnSpan span) { column_span_ = span; }
  
  float ColumnWidth() const { return column_width_; }
  void SetColumnWidth(float width) { column_width_ = width; has_auto_column_width_ = false; }
  
  bool HasAutoColumnWidth() const { return has_auto_column_width_; }
  void SetHasAutoColumnWidth() { has_auto_column_width_ = true; }
  
  unsigned Contain() const { return contain_; }
  void SetContain(unsigned contain) { contain_ = contain; }
  
  StyleIntrinsicLength ContainIntrinsicHeight() const { return contain_intrinsic_height_; }
  void SetContainIntrinsicHeight(const StyleIntrinsicLength& height) { contain_intrinsic_height_ = height; }
  
  StyleIntrinsicLength ContainIntrinsicWidth() const { return contain_intrinsic_width_; }
  void SetContainIntrinsicWidth(const StyleIntrinsicLength& width) { contain_intrinsic_width_ = width; }
  
  // Container query properties
  ScopedCSSNameList* ContainerName() const { return container_name_; }
  void SetContainerName(ScopedCSSNameList* name) { container_name_ = name; }
  
  unsigned ContainerType() const { return container_type_; }
  void SetContainerType(unsigned type) { container_type_ = type; }
  
  // Content visibility
  EContentVisibility ContentVisibility() const { return content_visibility_; }
  void SetContentVisibility(EContentVisibility visibility) { content_visibility_ = visibility; }
  
  // Baseline properties
  EDominantBaseline DominantBaseline() const { return dominant_baseline_; }
  void SetDominantBaseline(EDominantBaseline baseline) { dominant_baseline_ = baseline; }
  
  // Table properties
  EEmptyCells EmptyCells() const { return empty_cells_; }
  void SetEmptyCells(EEmptyCells cells) { empty_cells_ = cells; }
  void SetEmptyCellsIsInherited(bool inherited) { empty_cells_is_inherited_ = inherited; }
  
  // Form field properties
  EFieldSizing FieldSizing() const { return field_sizing_; }
  void SetFieldSizing(EFieldSizing sizing) { field_sizing_ = sizing; }
  
  // SVG fill properties
  float FillOpacity() const { return fill_opacity_; }
  void SetFillOpacity(float opacity) { fill_opacity_ = opacity; }
  
  WindRule FillRule() const { return fill_rule_; }
  void SetFillRule(WindRule rule) { fill_rule_ = rule; }
  
  // Filter properties
  const FilterOperations& Filter() const { return filter_; }
  void SetFilter(const FilterOperations& filter) { filter_ = filter; }
  
  // Float properties (floating is alias for float)
  EFloat Floating() const { return Float(); }
  void SetFloating(EFloat float_value) { SetFloat(float_value); }
  
  // SVG flood properties
  StyleColor FloodColor() const { return flood_color_; }
  void SetFloodColor(const StyleColor& color) { flood_color_ = color; }
  
  float FloodOpacity() const { return flood_opacity_; }
  void SetFloodOpacity(float opacity) { flood_opacity_ = opacity; }
  
  // Grid layout properties
  const ComputedGridTrackList& GridAutoColumns() const { return grid_auto_columns_; }
  void SetGridAutoColumns(const ComputedGridTrackList& columns) { grid_auto_columns_ = columns; }
  
  GridAutoFlow GetGridAutoFlow() const { return grid_auto_flow_; }
  void SetGridAutoFlow(GridAutoFlow flow) { grid_auto_flow_ = flow; }
  
  const ComputedGridTrackList& GridAutoRows() const { return grid_auto_rows_; }
  void SetGridAutoRows(const ComputedGridTrackList& rows) { grid_auto_rows_ = rows; }
  
  const GridPosition& GridColumnEnd() const { return grid_column_end_; }
  void SetGridColumnEnd(const GridPosition& position) { grid_column_end_ = position; }
  
  const GridPosition& GridColumnStart() const { return grid_column_start_; }
  void SetGridColumnStart(const GridPosition& position) { grid_column_start_ = position; }
  
  const GridPosition& GridRowEnd() const { return grid_row_end_; }
  void SetGridRowEnd(const GridPosition& position) { grid_row_end_ = position; }
  
  const GridPosition& GridRowStart() const { return grid_row_start_; }
  void SetGridRowStart(const GridPosition& position) { grid_row_start_ = position; }
  
  ComputedGridTemplateAreas* GridTemplateAreas() const { return grid_template_areas_; }
  void SetGridTemplateAreas(ComputedGridTemplateAreas* areas) { grid_template_areas_ = areas; }
  
  const ComputedGridTrackList& GridTemplateColumns() const { return grid_template_columns_; }
  void SetGridTemplateColumns(const ComputedGridTrackList& columns) { grid_template_columns_ = columns; }
  
  const ComputedGridTrackList& GridTemplateRows() const { return grid_template_rows_; }
  void SetGridTemplateRows(const ComputedGridTrackList& rows) { grid_template_rows_ = rows; }
  
  // Image properties
  RespectImageOrientationEnum ImageOrientation() const { return image_orientation_; }
  void SetImageOrientation(RespectImageOrientationEnum orientation) { image_orientation_ = orientation; }
  
  EImageRendering ImageRendering() const { return image_rendering_; }
  void SetImageRendering(EImageRendering rendering) { image_rendering_ = rendering; }
  
  // Text properties
  const StyleInitialLetter& InitialLetter() const { return initial_letter_; }
  void SetInitialLetter(const StyleInitialLetter& letter) { initial_letter_ = letter; }
  
  // Isolation property
  EIsolation Isolation() const { return isolation_; }
  void SetIsolation(EIsolation isolation) { isolation_ = isolation; }
  
  // Letter spacing
  float LetterSpacing() const { return letter_spacing_; }
  void SetLetterSpacing(float spacing) { letter_spacing_ = spacing; }
  
  // Lighting color (SVG)
  const StyleColor& LightingColor() const { return lighting_color_; }
  void SetLightingColor(const StyleColor& color) { lighting_color_ = color; }
  void SetLightingColor(const ::webf::Color& color) { lighting_color_ = StyleColor(color); }
  
  // Line clamp properties
  bool HasAutoStandardLineClamp() const { return has_auto_standard_line_clamp_; }
  void SetHasAutoStandardLineClamp() { has_auto_standard_line_clamp_ = true; }
  
  int StandardLineClamp() const { return standard_line_clamp_; }
  void SetStandardLineClamp(int clamp) { standard_line_clamp_ = clamp; }
  
  // SVG marker resources
  StyleSVGResource* MarkerEndResource() const { return marker_end_resource_; }
  void SetMarkerEndResource(StyleSVGResource* resource) { marker_end_resource_ = resource; }
  
  StyleSVGResource* MarkerMidResource() const { return marker_mid_resource_; }
  void SetMarkerMidResource(StyleSVGResource* resource) { marker_mid_resource_ = resource; }
  
  StyleSVGResource* MarkerStartResource() const { return marker_start_resource_; }
  void SetMarkerStartResource(StyleSVGResource* resource) { marker_start_resource_ = resource; }
  
  // Math properties
  EMathShift MathShift() const { return math_shift_; }
  void SetMathShift(EMathShift shift) { math_shift_ = shift; }
  
  EMathStyle MathStyle() const { return math_style_; }
  void SetMathStyle(EMathStyle style) { math_style_ = style; }
  
  // Blend mode
  BlendMode GetBlendMode() const { return blend_mode_; }
  void SetBlendMode(BlendMode mode) { blend_mode_ = mode; }
  
  // Object fit
  EObjectFit GetObjectFit() const { return object_fit_; }
  void SetObjectFit(EObjectFit fit) { object_fit_ = fit; }
  
  // Object position
  const LengthPoint& ObjectPosition() const { return object_position_; }
  void SetObjectPosition(const LengthPoint& position) { object_position_ = position; }
  
  // Object view box
  BasicShape* ObjectViewBox() const { return object_view_box_; }
  void SetObjectViewBox(BasicShape* view_box) { object_view_box_ = view_box; }
  
  // Offset properties
  const LengthPoint& OffsetAnchor() const { return offset_anchor_; }
  void SetOffsetAnchor(const LengthPoint& anchor) { offset_anchor_ = anchor; }
  
  const Length& OffsetDistance() const { return offset_distance_; }
  void SetOffsetDistance(const Length& distance) { offset_distance_ = distance; }
  
  OffsetPathOperation* OffsetPath() const { return offset_path_; }
  void SetOffsetPath(OffsetPathOperation* path) { offset_path_ = path; }
  
  const LengthPoint& OffsetPosition() const { return offset_position_; }
  void SetOffsetPosition(const LengthPoint& position) { offset_position_ = position; }
  
  const StyleOffsetRotation& OffsetRotate() const { return offset_rotate_; }
  void SetOffsetRotate(const StyleOffsetRotation& rotate) { offset_rotate_ = rotate; }
  
  // Order (flexbox/grid)
  int Order() const { return order_; }
  void SetOrder(int order) { order_ = order; }
  
  // Outline properties
  const LayoutUnit& OutlineOffset() const { return outline_offset_; }
  void SetOutlineOffset(const LayoutUnit& offset) { outline_offset_ = offset; }
  
  int OutlineWidth() const { return outline_width_; }
  void SetOutlineWidth(int width) { outline_width_ = width; }
  
  // Overflow properties
  EOverflowAnchor OverflowAnchor() const { return overflow_anchor_; }
  void SetOverflowAnchor(EOverflowAnchor anchor) { overflow_anchor_ = anchor; }
  
  const std::optional<StyleOverflowClipMargin>& OverflowClipMargin() const { return overflow_clip_margin_; }
  void SetOverflowClipMargin(const std::optional<StyleOverflowClipMargin>& margin) { overflow_clip_margin_ = margin; }
  
  EOverflowWrap OverflowWrap() const { return overflow_wrap_; }
  void SetOverflowWrap(EOverflowWrap wrap) { overflow_wrap_ = wrap; }
  
  EOverlay Overlay() const { return overlay_; }
  void SetOverlay(EOverlay overlay) { overlay_ = overlay; }
  
  // Outline color
  const StyleColor& OutlineColor() const { return outline_color_; }
  void SetOutlineColor(const StyleColor& color) { outline_color_ = color; }
  void SetOutlineColor(const ::webf::Color& color) { outline_color_ = StyleColor(color); }
  
  // Page properties
  const AtomicString& Page() const { return page_; }
  void SetPage(const AtomicString& page) { page_ = page; }
  
  PageOrientation GetPageOrientation() const { return page_orientation_; }
  void SetPageOrientation(PageOrientation orientation) { page_orientation_ = orientation; }
  
  // Perspective
  float Perspective() const { return perspective_; }
  void SetPerspective(float perspective) { perspective_ = perspective; }
  
  const LengthPoint& PerspectiveOrigin() const { return perspective_origin_; }
  void SetPerspectiveOrigin(const LengthPoint& origin) { perspective_origin_ = origin; }
  
  // Pointer events
  EPointerEvents PointerEvents() const { return pointer_events_; }
  void SetPointerEvents(EPointerEvents events) { pointer_events_ = events; }
  bool PointerEventsIsInherited() const { return pointer_events_is_inherited_; }
  void SetPointerEventsIsInherited(bool inherited) { pointer_events_is_inherited_ = inherited; }
  
  // Orphans
  short Orphans() const { return orphans_; }
  void SetOrphans(short orphans) { orphans_ = orphans; }
  
  // Origin trial test property
  EOriginTrialTestProperty OriginTrialTestProperty() const { return origin_trial_test_property_; }
  void SetOriginTrialTestProperty(EOriginTrialTestProperty property) { origin_trial_test_property_ = property; }
  
  // Popover properties
  float PopoverHideDelay() const { return popover_hide_delay_; }
  void SetPopoverHideDelay(float delay) { popover_hide_delay_ = delay; }
  
  float PopoverShowDelay() const { return popover_show_delay_; }
  void SetPopoverShowDelay(float delay) { popover_show_delay_ = delay; }
  
  // Quotes
  QuotesData* Quotes() const { return quotes_; }
  void SetQuotes(QuotesData* quotes) { quotes_ = quotes; }
  
  // Resize
  EResize Resize() const { return resize_; }
  void SetResize(EResize resize) { resize_ = resize; }
  
  // Rotate transform
  RotateTransformOperation* Rotate() const { return rotate_; }
  void SetRotate(RotateTransformOperation* rotate) { rotate_ = rotate; }
  
  // Row gap
  const std::optional<Length>& RowGap() const { return row_gap_; }
  void SetRowGap(const std::optional<Length>& gap) { row_gap_ = gap; }
  
  // Scale transform
  ScaleTransformOperation* Scale() const { return scale_; }
  void SetScale(ScaleTransformOperation* scale) { scale_ = scale; }
  
  // Speak
  ESpeak Speak() const { return speak_; }
  void SetSpeak(ESpeak speak) { speak_ = speak; }
  
  // Table layout
  ETableLayout TableLayout() const { return table_layout_; }
  void SetTableLayout(ETableLayout layout) { table_layout_ = layout; }
  
  // Text align last
  ETextAlignLast TextAlignLast() const { return text_align_last_; }
  void SetTextAlignLast(ETextAlignLast align) { text_align_last_ = align; }
  
  // Text anchor
  ETextAnchor TextAnchor() const { return text_anchor_; }
  void SetTextAnchor(ETextAnchor anchor) { text_anchor_ = anchor; }
  
  // Stop opacity
  float StopOpacity() const { return stop_opacity_; }
  void SetStopOpacity(float opacity) { stop_opacity_ = opacity; }
  
  // Tab size
  const TabSize& GetTabSize() const { return tab_size_; }
  void SetTabSize(const TabSize& size) { tab_size_ = size; }
  
  // Text box edge
  const TextBoxEdge& GetTextBoxEdge() const { return text_box_edge_; }
  void SetTextBoxEdge(const TextBoxEdge& edge) { text_box_edge_ = edge; }
  
  // Text box trim
  ETextBoxTrim TextBoxTrim() const { return text_box_trim_; }
  void SetTextBoxTrim(ETextBoxTrim trim) { text_box_trim_ = trim; }
  
  // Text combine
  ETextCombine TextCombine() const { return text_combine_; }
  void SetTextCombine(ETextCombine combine) { text_combine_ = combine; }
  
  // Text decoration color
  const StyleColor& TextDecorationColor() const { return text_decoration_color_; }
  void SetTextDecorationColor(const StyleColor& color) { text_decoration_color_ = color; }
  void SetTextDecorationColor(const ::webf::Color& color) { text_decoration_color_ = StyleColor(color); }
  
  // Text decoration line
  TextDecorationLine GetTextDecorationLine() const { return text_decoration_line_; }
  void SetTextDecorationLine(TextDecorationLine line) { text_decoration_line_ = line; }
  
  // Text decoration skip ink
  ETextDecorationSkipInk TextDecorationSkipInk() const { return text_decoration_skip_ink_; }
  void SetTextDecorationSkipInk(ETextDecorationSkipInk skip) { text_decoration_skip_ink_ = skip; }
  
  // Text decoration style
  ETextDecorationStyle TextDecorationStyle() const { return text_decoration_style_; }
  void SetTextDecorationStyle(ETextDecorationStyle style) { text_decoration_style_ = style; }
  
  // Text decoration thickness
  const class TextDecorationThickness& GetTextDecorationThickness() const { return text_decoration_thickness_; }
  void SetTextDecorationThickness(const class TextDecorationThickness& thickness) { text_decoration_thickness_ = thickness; }
  
  // Text emphasis color
  const StyleColor& TextEmphasisColor() const { return text_emphasis_color_; }
  void SetTextEmphasisColor(const StyleColor& color) { text_emphasis_color_ = color; }
  void SetTextEmphasisColor(const ::webf::Color& color) { text_emphasis_color_ = StyleColor(color); }
  
  // Text emphasis position
  TextEmphasisPosition GetTextEmphasisPosition() const { return text_emphasis_position_; }
  void SetTextEmphasisPosition(TextEmphasisPosition position) { text_emphasis_position_ = position; }
  
  // Text indent
  const Length& TextIndent() const { return text_indent_; }
  void SetTextIndent(const Length& indent) { text_indent_ = indent; }
  
  // Text overflow
  ETextOverflow TextOverflow() const { return text_overflow_; }
  void SetTextOverflow(ETextOverflow overflow) { text_overflow_ = overflow; }
  
  // Text shadow
  ShadowList* TextShadow() const { return text_shadow_; }
  void SetTextShadow(ShadowList* shadow) { text_shadow_ = shadow; }
  
  // Text transform inherited flag
  bool TextTransformIsInherited() const { return text_transform_is_inherited_; }
  void SetTextTransformIsInherited(bool inherited) { text_transform_is_inherited_ = inherited; }
  
  // Text underline offset
  const Length& TextUnderlineOffset() const { return text_underline_offset_; }
  void SetTextUnderlineOffset(const Length& offset) { text_underline_offset_ = offset; }
  
  // Text underline position
  TextUnderlinePosition GetTextUnderlinePosition() const { return text_underline_position_; }
  void SetTextUnderlinePosition(TextUnderlinePosition position) { text_underline_position_ = position; }
  
  // Text wrap
  TextWrap GetTextWrap() const { return text_wrap_; }
  void SetTextWrap(TextWrap wrap) { text_wrap_ = wrap; }
  
  // Transitions
  const CSSTransitionData* Transitions() const { 
    // TODO: Implement transitions support
    return nullptr; 
  }
  CSSTransitionData& AccessTransitions() {
    // TODO: Implement transitions support
    static CSSTransitionData dummy;
    return dummy;
  }
  
  // Timeline scope
  ScopedCSSNameList* TimelineScope() const { return timeline_scope_; }
  void SetTimelineScope(ScopedCSSNameList* scope) { timeline_scope_ = scope; }
  
  // Touch action
  TouchAction GetTouchAction() const { return touch_action_; }
  void SetTouchAction(TouchAction action) { touch_action_ = action; }
  
  // Transform properties
  const TransformOperations& Transform() const { return transform_; }
  void SetTransform(const TransformOperations& transform) { transform_ = transform; }
  
  ETransformBox TransformBox() const { return transform_box_; }
  void SetTransformBox(ETransformBox box) { transform_box_ = box; }
  
  const TransformOrigin& GetTransformOrigin() const { return transform_origin_; }
  void SetTransformOrigin(const TransformOrigin& origin) { transform_origin_ = origin; }
  
  ETransformStyle3D TransformStyle3D() const { return transform_style_3d_; }
  void SetTransformStyle3D(ETransformStyle3D style) { transform_style_3d_ = style; }
  
  // User select
  EUserSelect UserSelect() const { return user_select_; }
  void SetUserSelect(EUserSelect select) { user_select_ = select; }
  
  // Vertical align
  const Length& VerticalAlign() const { return vertical_align_; }
  void SetVerticalAlign(const Length& align) { vertical_align_ = align; }
  
  // Line break
  LineBreak GetLineBreak() const { return line_break_; }
  void SetLineBreak(LineBreak line_break) { line_break_ = line_break; }

  // Word break
  EWordBreak WordBreak() const { return word_break_; }
  EWordBreak GetWordBreak() const { return word_break_; }
  void SetWordBreak(EWordBreak wb) { word_break_ = wb; }

  // Webkit line clamp
  int WebkitLineClamp() const { return webkit_line_clamp_; }
  void SetWebkitLineClamp(int clamp) { webkit_line_clamp_ = clamp; }
  
  // White space collapse
  WhiteSpaceCollapse GetWhiteSpaceCollapse() const { return white_space_collapse_; }
  void SetWhiteSpaceCollapse(WhiteSpaceCollapse collapse) { white_space_collapse_ = collapse; }
  
  // Widows
  short Widows() const { return widows_; }
  void SetWidows(short widows) { widows_ = widows; }
  
  // Word spacing
  float WordSpacing() const { return word_spacing_; }
  void SetWordSpacing(float spacing) { word_spacing_ = spacing; }
  
  // Zoom
  float EffectiveZoom() const { return effective_zoom_; }
  void SetEffectiveZoom(float zoom) { effective_zoom_ = zoom; }
  
  // Specified line height
  Length SpecifiedLineHeight() const { return line_height_; }
  
  // Inheritance checks
  bool InheritedEqual(const ComputedStyle& other) const;
  bool NonInheritedEqual(const ComputedStyle& other) const;

 private:
  // Non-inherited properties
  EDisplay display_ = EDisplay::kInline;
  EPosition position_ = EPosition::kStatic;
  EOverflow overflow_x_ = EOverflow::kVisible;
  EOverflow overflow_y_ = EOverflow::kVisible;
  float opacity_ = 1.0f;
  int z_index_ = 0;
  bool has_auto_z_index_ = true;
  ::webf::Color background_color_ = ::webf::Color::kTransparent;
  
  // Box model - dimensions
  Length width_ = Length::Auto();
  Length height_ = Length::Auto();
  Length min_width_ = Length::Auto();
  Length min_height_ = Length::Auto();
  Length max_width_ = Length::None();
  Length max_height_ = Length::None();
  
  // Box model - margins
  Length margin_top_ = Length::Fixed(0);
  Length margin_right_ = Length::Fixed(0);
  Length margin_bottom_ = Length::Fixed(0);
  Length margin_left_ = Length::Fixed(0);
  
  // Box model - padding
  Length padding_top_ = Length::Fixed(0);
  Length padding_right_ = Length::Fixed(0);
  Length padding_bottom_ = Length::Fixed(0);
  Length padding_left_ = Length::Fixed(0);
  
  // Border properties
  LayoutUnit border_top_width_ = LayoutUnit(0);
  LayoutUnit border_right_width_ = LayoutUnit(0);
  LayoutUnit border_bottom_width_ = LayoutUnit(0);
  LayoutUnit border_left_width_ = LayoutUnit(0);
  
  EBorderStyle border_top_style_ = EBorderStyle::kNone;
  EBorderStyle border_right_style_ = EBorderStyle::kNone;
  EBorderStyle border_bottom_style_ = EBorderStyle::kNone;
  EBorderStyle border_left_style_ = EBorderStyle::kNone;
  
  ::webf::Color border_top_color_ = ::webf::Color::kBlack;
  ::webf::Color border_right_color_ = ::webf::Color::kBlack;
  ::webf::Color border_bottom_color_ = ::webf::Color::kBlack;
  ::webf::Color border_left_color_ = ::webf::Color::kBlack;
  
  // Border radius
  LengthSize border_top_left_radius_ = LengthSize(Length::Fixed(0), Length::Fixed(0));
  LengthSize border_top_right_radius_ = LengthSize(Length::Fixed(0), Length::Fixed(0));
  LengthSize border_bottom_left_radius_ = LengthSize(Length::Fixed(0), Length::Fixed(0));
  LengthSize border_bottom_right_radius_ = LengthSize(Length::Fixed(0), Length::Fixed(0));
  
  // Positioning offsets
  Length top_ = Length::Auto();
  Length right_ = Length::Auto();
  Length bottom_ = Length::Auto();
  Length left_ = Length::Auto();
  
  // Layout properties
  EFloat float_ = EFloat::kNone;
  EClear clear_ = EClear::kNone;
  EVisibility visibility_ = EVisibility::kVisible;
  
  // Flexbox properties
  EFlexDirection flex_direction_ = EFlexDirection::kRow;
  EFlexWrap flex_wrap_ = EFlexWrap::kNowrap;
  StyleContentAlignmentData justify_content_ = StyleContentAlignmentData(ContentPosition::kNormal, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
  StyleSelfAlignmentData align_items_ = StyleSelfAlignmentData(ItemPosition::kNormal, OverflowAlignment::kDefault);
  StyleContentAlignmentData align_content_ = StyleContentAlignmentData(ContentPosition::kNormal, ContentDistributionType::kDefault, OverflowAlignment::kDefault);
  StyleSelfAlignmentData align_self_ = StyleSelfAlignmentData(ItemPosition::kAuto, OverflowAlignment::kDefault);
  StyleSelfAlignmentData justify_self_ = StyleSelfAlignmentData(ItemPosition::kAuto, OverflowAlignment::kDefault);
  StyleSelfAlignmentData justify_items_ = StyleSelfAlignmentData(ItemPosition::kLegacy, OverflowAlignment::kDefault);
  float flex_grow_ = 0.0f;
  float flex_shrink_ = 1.0f;
  Length flex_basis_ = Length::Auto();
  
  // Inherited properties
  TextDirection direction_ = TextDirection::kLtr;
  WritingMode writing_mode_ = WritingMode::kHorizontalTb;
  ::webf::Color color_ = ::webf::Color::kBlack;
  FontDescription font_description_;
  AtomicString locale_;
  bool is_quirks_mode_document_ = false;
  
  // Text properties (inherited)
  ETextAlign text_align_ = ETextAlign::kStart;
  uint8_t text_decoration_ = 0; // Will use TextDecorationLine values
  ETextTransform text_transform_ = ETextTransform::kNone;
  Length line_height_ = Length::Auto();
  
  // Color adjustment properties (inherited)
  EForcedColorAdjust forced_color_adjust_ = EForcedColorAdjust::kAuto;
  
  // Zoom
  float effective_zoom_ = 1.0f;
  
  // Accent color
  StyleAutoColor accent_color_ = StyleAutoColor::AutoColor();
  
  // Alignment baseline
  EAlignmentBaseline alignment_baseline_ = EAlignmentBaseline::kAuto;
  
  // Anchor name
  ScopedCSSNameList* anchor_name_ = nullptr;
  
  // Anchor scope
  ScopedCSSNameList* anchor_scope_ = nullptr;
  
  // Aspect ratio
  StyleAspectRatio aspect_ratio_ = StyleAspectRatio(EAspectRatioType::kAuto, gfx::SizeF());
  
  // Backdrop filter
  FilterOperations backdrop_filter_ = FilterOperations();
  
  // Backface visibility
  EBackfaceVisibility backface_visibility_ = EBackfaceVisibility::kVisible;
  
  // Border collapse
  EBorderCollapse border_collapse_ = EBorderCollapse::kSeparate;
  
  // Border image
  NinePieceImage border_image_;
  
  // Border image source
  StyleImage* border_image_source_ = nullptr;
  
  // Box properties
  EBoxDecorationBreak box_decoration_break_ = EBoxDecorationBreak::kSlice;
  ShadowList* box_shadow_ = nullptr;
  EBoxSizing box_sizing_ = EBoxSizing::kContentBox;
  
  // Break properties
  EBreakBetween break_after_ = EBreakBetween::kAuto;
  EBreakBetween break_before_ = EBreakBetween::kAuto;
  EBreakInside break_inside_ = EBreakInside::kAuto;
  
  // Rendering properties
  EBufferedRendering buffered_rendering_ = EBufferedRendering::kAuto;
  
  // Table properties
  ECaptionSide caption_side_ = ECaptionSide::kTop;
  
  // Caret color
  StyleAutoColor caret_color_ = StyleAutoColor::AutoColor();
  
  // Clipping properties
  LengthBox clip_;
  bool has_auto_clip_ = true;
  ClipPathOperation* clip_path_ = nullptr;
  WindRule clip_rule_ = RULE_NONZERO;
  
  // Color interpolation
  EColorInterpolation color_interpolation_ = EColorInterpolation::kSrgb;
  EColorInterpolation color_interpolation_filters_ = EColorInterpolation::kLinearrgb;
  
  // Color rendering
  EColorRendering color_rendering_ = EColorRendering::kAuto;
  
  // Column properties
  unsigned short column_count_ = 1;
  bool has_auto_column_count_ = false;
  EColumnFill column_fill_ = EColumnFill::kBalance;
  Length column_gap_ = Length::Normal();
  StyleColor column_rule_color_ = StyleColor::CurrentColor();
  EBorderStyle column_rule_style_ = EBorderStyle::kNone;
  LayoutUnit column_rule_width_ = LayoutUnit(3);
  EColumnSpan column_span_ = EColumnSpan::kNone;
  float column_width_ = 0.0f;
  bool has_auto_column_width_ = true;
  unsigned contain_ = 0;
  StyleIntrinsicLength contain_intrinsic_height_ = StyleIntrinsicLength::None();
  StyleIntrinsicLength contain_intrinsic_width_ = StyleIntrinsicLength::None();
  ScopedCSSNameList* container_name_ = nullptr;
  unsigned container_type_ = 0;
  EContentVisibility content_visibility_ = EContentVisibility::kVisible;
  EDominantBaseline dominant_baseline_ = EDominantBaseline::kAuto;
  EEmptyCells empty_cells_ = EEmptyCells::kShow;
  bool empty_cells_is_inherited_ = true;
  EFieldSizing field_sizing_ = EFieldSizing::kFixed;
  float fill_opacity_ = 1.0f;
  WindRule fill_rule_ = RULE_NONZERO;
  FilterOperations filter_;
  StyleColor flood_color_ = StyleColor(Color::kBlack);
  float flood_opacity_ = 1.0f;
  ComputedGridTrackList grid_auto_columns_ = ComputedGridTrackList::CreateDefault();
  GridAutoFlow grid_auto_flow_ = GridAutoFlow::kAutoFlowRow;
  ComputedGridTrackList grid_auto_rows_ = ComputedGridTrackList::CreateDefault();
  GridPosition grid_column_end_ = GridPosition::CreateAuto();
  GridPosition grid_column_start_ = GridPosition::CreateAuto();
  GridPosition grid_row_end_ = GridPosition::CreateAuto();
  GridPosition grid_row_start_ = GridPosition::CreateAuto();
  ComputedGridTemplateAreas* grid_template_areas_ = nullptr;
  ComputedGridTrackList grid_template_columns_ = ComputedGridTrackList::CreateDefault();
  ComputedGridTrackList grid_template_rows_ = ComputedGridTrackList::CreateDefault();
  RespectImageOrientationEnum image_orientation_ = kRespectImageOrientation;
  EImageRendering image_rendering_ = EImageRendering::kAuto;
  StyleInitialLetter initial_letter_ = StyleInitialLetter::None();
  EIsolation isolation_ = EIsolation::kAuto;
  float letter_spacing_ = 0.0f;
  StyleColor lighting_color_ = StyleColor(Color::kWhite);
  bool has_auto_standard_line_clamp_ = false;
  int standard_line_clamp_ = 0;
  StyleSVGResource* marker_end_resource_ = nullptr;
  StyleSVGResource* marker_mid_resource_ = nullptr;
  StyleSVGResource* marker_start_resource_ = nullptr;
  EMathShift math_shift_ = EMathShift::kNormal;
  EMathStyle math_style_ = EMathStyle::kNormal;
  BlendMode blend_mode_ = BlendMode::kNormal;
  EObjectFit object_fit_ = EObjectFit::kFill;
  LengthPoint object_position_ = LengthPoint(Length::Percent(50.0), Length::Percent(50.0));
  BasicShape* object_view_box_ = nullptr;
  LengthPoint offset_anchor_ = LengthPoint(Length::Auto(), Length::Auto());
  Length offset_distance_ = Length::Fixed(0);
  OffsetPathOperation* offset_path_ = nullptr;
  LengthPoint offset_position_ = LengthPoint(Length::None(), Length::None());
  StyleOffsetRotation offset_rotate_ = StyleOffsetRotation::Auto();
  int order_ = 0;
  LayoutUnit outline_offset_ = LayoutUnit();
  int outline_width_ = 3;
  EOverflowAnchor overflow_anchor_ = EOverflowAnchor::kAuto;
  std::optional<StyleOverflowClipMargin> overflow_clip_margin_ = std::nullopt;
  EOverflowWrap overflow_wrap_ = EOverflowWrap::kNormal;
  EWordBreak word_break_ = EWordBreak::kNormal;
  EOverlay overlay_ = EOverlay::kNone;
  StyleColor outline_color_ = StyleColor::CurrentColor();
  
  // Page properties
  AtomicString page_;
  PageOrientation page_orientation_ = PageOrientation::kUpright;
  
  // Perspective
  float perspective_ = -1.0f;
  LengthPoint perspective_origin_ = LengthPoint(Length::Percent(50.0), Length::Percent(50.0));
  
  // Pointer events
  EPointerEvents pointer_events_ = EPointerEvents::kAuto;
  bool pointer_events_is_inherited_ = false;
  
  // Orphans (for paged media)
  short orphans_ = 2;
  
  // Origin trial test property
  EOriginTrialTestProperty origin_trial_test_property_ = EOriginTrialTestProperty::kNormal;
  
  // Popover properties
  float popover_hide_delay_ = HUGE_VALF;
  float popover_show_delay_ = 0.5f;
  
  // Quotes
  QuotesData* quotes_ = nullptr;
  
  // Resize
  EResize resize_ = EResize::kNone;
  
  // Rotate transform
  RotateTransformOperation* rotate_ = nullptr;
  
  // Row gap
  std::optional<Length> row_gap_ = std::nullopt;
  
  // Scale transform
  ScaleTransformOperation* scale_ = nullptr;
  
  // Speak
  ESpeak speak_ = ESpeak::kNormal;
  
  // Table layout
  ETableLayout table_layout_ = ETableLayout::kAuto;
  
  // Text align last
  ETextAlignLast text_align_last_ = ETextAlignLast::kAuto;
  
  // Text anchor
  ETextAnchor text_anchor_ = ETextAnchor::kStart;
  
  // Stop opacity (SVG)
  float stop_opacity_ = 1.0f;
  
  // Tab size
  TabSize tab_size_ = TabSize(8);
  
  // Text box edge
  TextBoxEdge text_box_edge_;
  
  // Text box trim
  ETextBoxTrim text_box_trim_ = ETextBoxTrim::kNone;
  
  // Text combine
  ETextCombine text_combine_ = ETextCombine::kNone;
  
  // Text decoration color
  StyleColor text_decoration_color_ = StyleColor::CurrentColor();
  
  // Text decoration line
  TextDecorationLine text_decoration_line_ = TextDecorationLine::kNone;
  
  // Text decoration skip ink
  ETextDecorationSkipInk text_decoration_skip_ink_ = ETextDecorationSkipInk::kAuto;
  
  // Text decoration style
  ETextDecorationStyle text_decoration_style_ = ETextDecorationStyle::kSolid;
  
  // Text decoration thickness
  class TextDecorationThickness text_decoration_thickness_;
  
  // Text emphasis color
  StyleColor text_emphasis_color_ = StyleColor::CurrentColor();
  
  // Text emphasis position
  TextEmphasisPosition text_emphasis_position_ = TextEmphasisPosition::kOverRight;
  
  // Text indent
  Length text_indent_ = Length::Fixed(0);
  
  // Text overflow
  ETextOverflow text_overflow_ = ETextOverflow::kClip;
  
  // Text shadow
  ShadowList* text_shadow_ = nullptr;
  
  // Text transform inherited flag
  bool text_transform_is_inherited_ = true;
  
  // Text underline offset
  Length text_underline_offset_ = Length();
  
  // Text underline position
  TextUnderlinePosition text_underline_position_ = TextUnderlinePosition::kAuto;
  
  // Text wrap
  TextWrap text_wrap_ = TextWrap::kWrap;
  
  // Timeline scope
  ScopedCSSNameList* timeline_scope_ = nullptr;
  
  // Transitions
  // TODO: Implement transitions support properly
  // std::unique_ptr<CSSTransitionData> transitions_;
  
  // Touch action
  TouchAction touch_action_ = TouchAction::kAuto;
  
  // Transform properties
  TransformOperations transform_;
  ETransformBox transform_box_ = ETransformBox::kViewBox;
  TransformOrigin transform_origin_ = TransformOrigin(Length::Percent(50.0), Length::Percent(50.0), 0);
  ETransformStyle3D transform_style_3d_ = ETransformStyle3D::kFlat;
  
  // User select
  EUserSelect user_select_ = EUserSelect::kAuto;
  
  // Vertical align
  Length vertical_align_ = Length();
  
  // Line break
  LineBreak line_break_ = LineBreak::kAuto;
  
  // Webkit line clamp
  int webkit_line_clamp_ = 0;
  
  // Widows
  short widows_ = 2;
  
  // Word spacing
  float word_spacing_ = 0.0f;
  
  // White space collapse
  WhiteSpaceCollapse white_space_collapse_ = WhiteSpaceCollapse::kCollapse;
  
  friend class ComputedStyleBuilder;
};

// Builder pattern for ComputedStyle
class ComputedStyleBuilder {

 public:
  ComputedStyleBuilder();
  explicit ComputedStyleBuilder(const ComputedStyle& style);
  ~ComputedStyleBuilder();
  
  // Delete copy operations
  ComputedStyleBuilder(const ComputedStyleBuilder&) = delete;
  ComputedStyleBuilder& operator=(const ComputedStyleBuilder&) = delete;
  
  // Allow move operations
  ComputedStyleBuilder(ComputedStyleBuilder&&) = default;
  ComputedStyleBuilder& operator=(ComputedStyleBuilder&&) = default;
  
  // Take the built style
  std::shared_ptr<const ComputedStyle> TakeStyle();
  
  // Display
  ComputedStyleBuilder& SetDisplay(EDisplay display) {
    style_->SetDisplay(display);
    return *this;
  }
  
  // Position
  ComputedStyleBuilder& SetPosition(EPosition position) {
    style_->SetPosition(position);
    return *this;
  }
  
  // Overflow
  ComputedStyleBuilder& SetOverflowX(EOverflow overflow) {
    style_->SetOverflowX(overflow);
    return *this;
  }
  
  ComputedStyleBuilder& SetOverflowY(EOverflow overflow) {
    style_->SetOverflowY(overflow);
    return *this;
  }
  
  // Direction
  ComputedStyleBuilder& SetDirection(TextDirection direction) {
    style_->SetDirection(direction);
    return *this;
  }
  
  // Writing mode
  ComputedStyleBuilder& SetWritingMode(WritingMode mode) {
    style_->SetWritingMode(mode);
    return *this;
  }
  
  // Colors
  ComputedStyleBuilder& SetColor(const ::webf::Color& color) {
    style_->SetColor(color);
    return *this;
  }
  
  const ::webf::Color& Color() const {
    return style_->Color();
  }
  
  ComputedStyleBuilder& SetBackgroundColor(const ::webf::Color& color) {
    style_->SetBackgroundColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBackgroundColor(const StyleColor& color) {
    style_->SetBackgroundColor(color);
    return *this;
  }
  
  // Font
  ComputedStyleBuilder& SetFontDescription(const FontDescription& desc) {
    style_->SetFontDescription(desc);
    return *this;
  }
  
  ComputedStyleBuilder& SetFontSize(float size) {
    FontDescription desc = style_->GetFontDescription();
    desc.SetComputedSize(size);
    desc.SetSpecifiedSize(size);
    style_->SetFontDescription(desc);
    return *this;
  }
  
  // Opacity
  ComputedStyleBuilder& SetOpacity(float opacity) {
    style_->SetOpacity(opacity);
    return *this;
  }
  
  // Z-index
  ComputedStyleBuilder& SetZIndex(int z_index) {
    style_->SetZIndex(z_index);
    return *this;
  }
  
  ComputedStyleBuilder& SetHasAutoZIndex(bool has_auto) {
    style_->SetHasAutoZIndex(has_auto);
    return *this;
  }
  
  // Locale
  ComputedStyleBuilder& SetLocale(const AtomicString& locale) {
    style_->SetLocale(locale);
    return *this;
  }
  
  // Forced color adjust
  ComputedStyleBuilder& SetForcedColorAdjust(EForcedColorAdjust adjust) {
    style_->SetForcedColorAdjust(adjust);
    return *this;
  }
  
  // Border collapse
  ComputedStyleBuilder& SetBorderCollapse(EBorderCollapse collapse) {
    style_->SetBorderCollapse(collapse);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderCollapseIsInherited(bool inherited) {
    // TODO: Track inheritance state if needed
    return *this;
  }
  
  // Border image
  const NinePieceImage& BorderImage() const {
    return style_->BorderImage();
  }
  
  ComputedStyleBuilder& SetBorderImage(const NinePieceImage& image) {
    style_->SetBorderImage(image);
    return *this;
  }
  
  // Border image source
  ComputedStyleBuilder& SetBorderImageSource(StyleImage* source) {
    style_->SetBorderImageSource(source);
    return *this;
  }
  
  // Box decoration break
  ComputedStyleBuilder& SetBoxDecorationBreak(EBoxDecorationBreak decoration_break) {
    style_->SetBoxDecorationBreak(decoration_break);
    return *this;
  }
  
  // Box shadow
  ComputedStyleBuilder& SetBoxShadow(ShadowList* shadow) {
    style_->SetBoxShadow(shadow);
    return *this;
  }
  
  // Box sizing
  ComputedStyleBuilder& SetBoxSizing(EBoxSizing sizing) {
    style_->SetBoxSizing(sizing);
    return *this;
  }
  
  // Break properties
  ComputedStyleBuilder& SetBreakAfter(EBreakBetween break_value) {
    style_->SetBreakAfter(break_value);
    return *this;
  }
  
  ComputedStyleBuilder& SetBreakBefore(EBreakBetween break_value) {
    style_->SetBreakBefore(break_value);
    return *this;
  }
  
  ComputedStyleBuilder& SetBreakInside(EBreakInside break_value) {
    style_->SetBreakInside(break_value);
    return *this;
  }
  
  // Rendering properties
  ComputedStyleBuilder& SetBufferedRendering(EBufferedRendering rendering) {
    style_->SetBufferedRendering(rendering);
    return *this;
  }
  
  // Table properties
  ComputedStyleBuilder& SetCaptionSide(ECaptionSide side) {
    style_->SetCaptionSide(side);
    return *this;
  }
  
  ComputedStyleBuilder& SetCaptionSideIsInherited(bool inherited) {
    // TODO: Track inheritance state if needed
    return *this;
  }
  
  // Caret color
  ComputedStyleBuilder& SetCaretColor(const StyleAutoColor& color) {
    style_->SetCaretColor(color);
    return *this;
  }
  
  // Clipping properties
  ComputedStyleBuilder& SetClip(const LengthBox& clip) {
    style_->SetClip(clip);
    return *this;
  }
  
  ComputedStyleBuilder& SetHasAutoClip() {
    style_->SetHasAutoClip();
    return *this;
  }
  
  ComputedStyleBuilder& SetClipPath(ClipPathOperation* path) {
    style_->SetClipPath(path);
    return *this;
  }
  
  ComputedStyleBuilder& SetClipRule(WindRule rule) {
    style_->SetClipRule(rule);
    return *this;
  }
  
  // Color interpolation
  ComputedStyleBuilder& SetColorInterpolation(EColorInterpolation interpolation) {
    style_->SetColorInterpolation(interpolation);
    return *this;
  }
  
  ComputedStyleBuilder& SetColorInterpolationFilters(EColorInterpolation interpolation) {
    style_->SetColorInterpolationFilters(interpolation);
    return *this;
  }
  
  // Color rendering
  ComputedStyleBuilder& SetColorRendering(EColorRendering rendering) {
    style_->SetColorRendering(rendering);
    return *this;
  }
  
  // Column properties
  ComputedStyleBuilder& SetColumnCount(unsigned short count) {
    style_->SetColumnCount(count);
    return *this;
  }
  
  ComputedStyleBuilder& SetHasAutoColumnCount() {
    style_->SetHasAutoColumnCount();
    return *this;
  }
  
  ComputedStyleBuilder& SetColumnFill(EColumnFill fill) {
    style_->SetColumnFill(fill);
    return *this;
  }
  
  // Box model - dimensions
  ComputedStyleBuilder& SetWidth(const Length& width) {
    style_->SetWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetHeight(const Length& height) {
    style_->SetHeight(height);
    return *this;
  }
  
  ComputedStyleBuilder& SetMinWidth(const Length& width) {
    style_->SetMinWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetMinHeight(const Length& height) {
    style_->SetMinHeight(height);
    return *this;
  }
  
  ComputedStyleBuilder& SetMaxWidth(const Length& width) {
    style_->SetMaxWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetMaxHeight(const Length& height) {
    style_->SetMaxHeight(height);
    return *this;
  }
  
  // Box model - margins
  ComputedStyleBuilder& SetMarginTop(const Length& margin) {
    style_->SetMarginTop(margin);
    return *this;
  }
  
  ComputedStyleBuilder& SetMarginRight(const Length& margin) {
    style_->SetMarginRight(margin);
    return *this;
  }
  
  ComputedStyleBuilder& SetMarginBottom(const Length& margin) {
    style_->SetMarginBottom(margin);
    return *this;
  }
  
  ComputedStyleBuilder& SetMarginLeft(const Length& margin) {
    style_->SetMarginLeft(margin);
    return *this;
  }
  
  // Box model - padding
  ComputedStyleBuilder& SetPaddingTop(const Length& padding) {
    style_->SetPaddingTop(padding);
    return *this;
  }
  
  ComputedStyleBuilder& SetPaddingRight(const Length& padding) {
    style_->SetPaddingRight(padding);
    return *this;
  }
  
  ComputedStyleBuilder& SetPaddingBottom(const Length& padding) {
    style_->SetPaddingBottom(padding);
    return *this;
  }
  
  ComputedStyleBuilder& SetPaddingLeft(const Length& padding) {
    style_->SetPaddingLeft(padding);
    return *this;
  }
  
  // Border widths
  ComputedStyleBuilder& SetBorderTopWidth(LayoutUnit width) {
    style_->SetBorderTopWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderTopWidth(int width) {
    style_->SetBorderTopWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderRightWidth(LayoutUnit width) {
    style_->SetBorderRightWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderRightWidth(int width) {
    style_->SetBorderRightWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomWidth(LayoutUnit width) {
    style_->SetBorderBottomWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomWidth(int width) {
    style_->SetBorderBottomWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderLeftWidth(LayoutUnit width) {
    style_->SetBorderLeftWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderLeftWidth(int width) {
    style_->SetBorderLeftWidth(width);
    return *this;
  }
  
  // Border styles
  ComputedStyleBuilder& SetBorderTopStyle(EBorderStyle style) {
    style_->SetBorderTopStyle(style);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderRightStyle(EBorderStyle style) {
    style_->SetBorderRightStyle(style);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomStyle(EBorderStyle style) {
    style_->SetBorderBottomStyle(style);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderLeftStyle(EBorderStyle style) {
    style_->SetBorderLeftStyle(style);
    return *this;
  }
  
  // Border colors
  ComputedStyleBuilder& SetBorderTopColor(const ::webf::Color& color) {
    style_->SetBorderTopColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderTopColor(const StyleColor& color) {
    style_->SetBorderTopColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderRightColor(const ::webf::Color& color) {
    style_->SetBorderRightColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderRightColor(const StyleColor& color) {
    style_->SetBorderRightColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomColor(const ::webf::Color& color) {
    style_->SetBorderBottomColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomColor(const StyleColor& color) {
    style_->SetBorderBottomColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderLeftColor(const ::webf::Color& color) {
    style_->SetBorderLeftColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderLeftColor(const StyleColor& color) {
    style_->SetBorderLeftColor(color);
    return *this;
  }
  
  // Border radius
  ComputedStyleBuilder& SetBorderTopLeftRadius(const LengthSize& radius) {
    style_->SetBorderTopLeftRadius(radius);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderTopRightRadius(const LengthSize& radius) {
    style_->SetBorderTopRightRadius(radius);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomLeftRadius(const LengthSize& radius) {
    style_->SetBorderBottomLeftRadius(radius);
    return *this;
  }
  
  ComputedStyleBuilder& SetBorderBottomRightRadius(const LengthSize& radius) {
    style_->SetBorderBottomRightRadius(radius);
    return *this;
  }
  
  // Positioning offsets
  ComputedStyleBuilder& SetTop(const Length& top) {
    style_->SetTop(top);
    return *this;
  }
  
  ComputedStyleBuilder& SetRight(const Length& right) {
    style_->SetRight(right);
    return *this;
  }
  
  ComputedStyleBuilder& SetBottom(const Length& bottom) {
    style_->SetBottom(bottom);
    return *this;
  }
  
  ComputedStyleBuilder& SetLeft(const Length& left) {
    style_->SetLeft(left);
    return *this;
  }
  
  // Text properties
  ComputedStyleBuilder& SetTextAlign(ETextAlign align) {
    style_->SetTextAlign(align);
    return *this;
  }
  
  ComputedStyleBuilder& SetTextDecoration(::webf::TextDecoration decoration) {
    style_->SetTextDecoration(decoration);
    return *this;
  }
  
  ComputedStyleBuilder& SetTextTransform(ETextTransform transform) {
    style_->SetTextTransform(transform);
    return *this;
  }
  
  ComputedStyleBuilder& SetLineHeight(const Length& height) {
    style_->SetLineHeight(height);
    return *this;
  }
  
  // Layout properties
  ComputedStyleBuilder& SetFloat(EFloat float_value) {
    style_->SetFloat(float_value);
    return *this;
  }
  
  ComputedStyleBuilder& SetClear(EClear clear) {
    style_->SetClear(clear);
    return *this;
  }
  
  ComputedStyleBuilder& SetOverflow(EOverflow overflow) {
    style_->SetOverflow(overflow);
    return *this;
  }
  
  // Visibility
  ComputedStyleBuilder& SetVisibility(EVisibility visibility) {
    style_->SetVisibility(visibility);
    return *this;
  }
  
  // Flexbox properties
  ComputedStyleBuilder& SetFlexDirection(EFlexDirection direction) {
    style_->SetFlexDirection(direction);
    return *this;
  }
  
  ComputedStyleBuilder& SetFlexWrap(EFlexWrap wrap) {
    style_->SetFlexWrap(wrap);
    return *this;
  }
  
  ComputedStyleBuilder& SetJustifyContent(const StyleContentAlignmentData& alignment) {
    style_->SetJustifyContent(alignment);
    return *this;
  }
  
  ComputedStyleBuilder& SetAlignItems(const StyleSelfAlignmentData& alignment) {
    style_->SetAlignItems(alignment);
    return *this;
  }
  
  ComputedStyleBuilder& SetAlignContent(const StyleContentAlignmentData& alignment) {
    style_->SetAlignContent(alignment);
    return *this;
  }
  
  ComputedStyleBuilder& SetAlignSelf(const StyleSelfAlignmentData& alignment) {
    style_->SetAlignSelf(alignment);
    return *this;
  }
  
  ComputedStyleBuilder& SetJustifySelf(const StyleSelfAlignmentData& alignment) {
    style_->SetJustifySelf(alignment);
    return *this;
  }
  
  ComputedStyleBuilder& SetJustifyItems(const StyleSelfAlignmentData& alignment) {
    style_->SetJustifyItems(alignment);
    return *this;
  }
  
  ComputedStyleBuilder& SetFlexGrow(float grow) {
    style_->SetFlexGrow(grow);
    return *this;
  }
  
  ComputedStyleBuilder& SetFlexShrink(float shrink) {
    style_->SetFlexShrink(shrink);
    return *this;
  }
  
  ComputedStyleBuilder& SetFlexBasis(const Length& basis) {
    style_->SetFlexBasis(basis);
    return *this;
  }
  
  // Quirks mode
  ComputedStyleBuilder& SetIsQuirksModeDocumentForView(bool quirks) {
    style_->SetIsQuirksModeDocumentForView(quirks);
    return *this;
  }
  
  // Accent color
  ComputedStyleBuilder& SetAccentColor(const StyleAutoColor& color) {
    style_->SetAccentColor(color);
    return *this;
  }
  
  // Alignment baseline
  ComputedStyleBuilder& SetAlignmentBaseline(EAlignmentBaseline baseline) {
    style_->SetAlignmentBaseline(baseline);
    return *this;
  }
  
  // Anchor name
  ComputedStyleBuilder& SetAnchorName(ScopedCSSNameList* name) {
    style_->SetAnchorName(name);
    return *this;
  }
  
  // Anchor scope
  ComputedStyleBuilder& SetAnchorScope(ScopedCSSNameList* scope) {
    style_->SetAnchorScope(scope);
    return *this;
  }
  
  // Aspect ratio
  ComputedStyleBuilder& SetAspectRatio(const StyleAspectRatio& ratio) {
    style_->SetAspectRatio(ratio);
    return *this;
  }
  
  // Backdrop filter
  ComputedStyleBuilder& SetBackdropFilter(const FilterOperations& filter) {
    style_->SetBackdropFilter(filter);
    return *this;
  }
  
  // Backface visibility
  ComputedStyleBuilder& SetBackfaceVisibility(EBackfaceVisibility visibility) {
    style_->SetBackfaceVisibility(visibility);
    return *this;
  }
  
  // Column properties
  ComputedStyleBuilder& SetColumnGap(const Length& gap) {
    style_->SetColumnGap(gap);
    return *this;
  }
  
  ComputedStyleBuilder& SetColumnRuleColor(const StyleColor& color) {
    style_->SetColumnRuleColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetColumnRuleColor(const ::webf::Color& color) {
    style_->SetColumnRuleColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetColumnRuleStyle(EBorderStyle style) {
    style_->SetColumnRuleStyle(style);
    return *this;
  }
  
  ComputedStyleBuilder& SetColumnRuleWidth(const LayoutUnit& width) {
    style_->SetColumnRuleWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetColumnRuleWidth(int width) {
    style_->SetColumnRuleWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetColumnSpan(EColumnSpan span) {
    style_->SetColumnSpan(span);
    return *this;
  }
  
  ComputedStyleBuilder& SetColumnWidth(float width) {
    style_->SetColumnWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetHasAutoColumnWidth() {
    style_->SetHasAutoColumnWidth();
    return *this;
  }
  
  ComputedStyleBuilder& SetContain(unsigned contain) {
    style_->SetContain(contain);
    return *this;
  }
  
  ComputedStyleBuilder& SetContainIntrinsicHeight(const StyleIntrinsicLength& height) {
    style_->SetContainIntrinsicHeight(height);
    return *this;
  }
  
  ComputedStyleBuilder& SetContainIntrinsicWidth(const StyleIntrinsicLength& width) {
    style_->SetContainIntrinsicWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetContainerName(ScopedCSSNameList* name) {
    style_->SetContainerName(name);
    return *this;
  }
  
  ComputedStyleBuilder& SetContainerType(unsigned type) {
    style_->SetContainerType(type);
    return *this;
  }
  
  ComputedStyleBuilder& SetContentVisibility(EContentVisibility visibility) {
    style_->SetContentVisibility(visibility);
    return *this;
  }
  
  ComputedStyleBuilder& SetDominantBaseline(EDominantBaseline baseline) {
    style_->SetDominantBaseline(baseline);
    return *this;
  }
  
  ComputedStyleBuilder& SetEmptyCells(EEmptyCells cells) {
    style_->SetEmptyCells(cells);
    return *this;
  }
  
  ComputedStyleBuilder& SetEmptyCellsIsInherited(bool inherited) {
    style_->SetEmptyCellsIsInherited(inherited);
    return *this;
  }
  
  ComputedStyleBuilder& SetFieldSizing(EFieldSizing sizing) {
    style_->SetFieldSizing(sizing);
    return *this;
  }
  
  ComputedStyleBuilder& SetFillOpacity(float opacity) {
    style_->SetFillOpacity(opacity);
    return *this;
  }
  
  ComputedStyleBuilder& SetFillRule(WindRule rule) {
    style_->SetFillRule(rule);
    return *this;
  }
  
  ComputedStyleBuilder& SetFilter(const FilterOperations& filter) {
    style_->SetFilter(filter);
    return *this;
  }
  
  ComputedStyleBuilder& SetFloating(EFloat float_value) {
    style_->SetFloating(float_value);
    return *this;
  }
  
  ComputedStyleBuilder& SetFloodColor(const StyleColor& color) {
    style_->SetFloodColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetFloodOpacity(float opacity) {
    style_->SetFloodOpacity(opacity);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridAutoColumns(const ComputedGridTrackList& columns) {
    style_->SetGridAutoColumns(columns);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridAutoFlow(GridAutoFlow flow) {
    style_->SetGridAutoFlow(flow);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridAutoRows(const ComputedGridTrackList& rows) {
    style_->SetGridAutoRows(rows);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridColumnEnd(const GridPosition& position) {
    style_->SetGridColumnEnd(position);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridColumnStart(const GridPosition& position) {
    style_->SetGridColumnStart(position);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridRowEnd(const GridPosition& position) {
    style_->SetGridRowEnd(position);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridRowStart(const GridPosition& position) {
    style_->SetGridRowStart(position);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridTemplateAreas(ComputedGridTemplateAreas* areas) {
    style_->SetGridTemplateAreas(areas);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridTemplateColumns(const ComputedGridTrackList& columns) {
    style_->SetGridTemplateColumns(columns);
    return *this;
  }
  
  ComputedStyleBuilder& SetGridTemplateRows(const ComputedGridTrackList& rows) {
    style_->SetGridTemplateRows(rows);
    return *this;
  }
  
  ComputedStyleBuilder& SetImageOrientation(RespectImageOrientationEnum orientation) {
    style_->SetImageOrientation(orientation);
    return *this;
  }
  
  ComputedStyleBuilder& SetImageRendering(EImageRendering rendering) {
    style_->SetImageRendering(rendering);
    return *this;
  }
  
  ComputedStyleBuilder& SetInitialLetter(const StyleInitialLetter& letter) {
    style_->SetInitialLetter(letter);
    return *this;
  }
  
  ComputedStyleBuilder& SetIsolation(EIsolation isolation) {
    style_->SetIsolation(isolation);
    return *this;
  }
  
  ComputedStyleBuilder& SetLetterSpacing(float spacing) {
    style_->SetLetterSpacing(spacing);
    return *this;
  }
  
  ComputedStyleBuilder& SetLightingColor(const StyleColor& color) {
    style_->SetLightingColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetLightingColor(const ::webf::Color& color) {
    style_->SetLightingColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetHasAutoStandardLineClamp() {
    style_->SetHasAutoStandardLineClamp();
    return *this;
  }
  
  ComputedStyleBuilder& SetStandardLineClamp(int clamp) {
    style_->SetStandardLineClamp(clamp);
    return *this;
  }
  
  ComputedStyleBuilder& SetMarkerEndResource(StyleSVGResource* resource) {
    style_->SetMarkerEndResource(resource);
    return *this;
  }
  
  ComputedStyleBuilder& SetMarkerMidResource(StyleSVGResource* resource) {
    style_->SetMarkerMidResource(resource);
    return *this;
  }
  
  ComputedStyleBuilder& SetMarkerStartResource(StyleSVGResource* resource) {
    style_->SetMarkerStartResource(resource);
    return *this;
  }
  
  ComputedStyleBuilder& SetMathShift(EMathShift shift) {
    style_->SetMathShift(shift);
    return *this;
  }
  
  ComputedStyleBuilder& SetMathStyle(EMathStyle style) {
    style_->SetMathStyle(style);
    return *this;
  }
  
  ComputedStyleBuilder& SetBlendMode(BlendMode mode) {
    style_->SetBlendMode(mode);
    return *this;
  }
  
  ComputedStyleBuilder& SetObjectFit(EObjectFit fit) {
    style_->SetObjectFit(fit);
    return *this;
  }
  
  ComputedStyleBuilder& SetObjectPosition(const LengthPoint& position) {
    style_->SetObjectPosition(position);
    return *this;
  }
  
  ComputedStyleBuilder& SetObjectViewBox(BasicShape* view_box) {
    style_->SetObjectViewBox(view_box);
    return *this;
  }
  
  ComputedStyleBuilder& SetOffsetAnchor(const LengthPoint& anchor) {
    style_->SetOffsetAnchor(anchor);
    return *this;
  }
  
  ComputedStyleBuilder& SetOffsetDistance(const Length& distance) {
    style_->SetOffsetDistance(distance);
    return *this;
  }
  
  ComputedStyleBuilder& SetOffsetPath(OffsetPathOperation* path) {
    style_->SetOffsetPath(path);
    return *this;
  }
  
  ComputedStyleBuilder& SetOffsetPosition(const LengthPoint& position) {
    style_->SetOffsetPosition(position);
    return *this;
  }
  
  ComputedStyleBuilder& SetOffsetRotate(const StyleOffsetRotation& rotate) {
    style_->SetOffsetRotate(rotate);
    return *this;
  }
  
  ComputedStyleBuilder& SetOrder(int order) {
    style_->SetOrder(order);
    return *this;
  }
  
  ComputedStyleBuilder& SetOutlineOffset(const LayoutUnit& offset) {
    style_->SetOutlineOffset(offset);
    return *this;
  }
  
  ComputedStyleBuilder& SetOutlineWidth(int width) {
    style_->SetOutlineWidth(width);
    return *this;
  }
  
  ComputedStyleBuilder& SetOverflowAnchor(EOverflowAnchor anchor) {
    style_->SetOverflowAnchor(anchor);
    return *this;
  }
  
  ComputedStyleBuilder& SetOverflowClipMargin(const std::optional<StyleOverflowClipMargin>& margin) {
    style_->SetOverflowClipMargin(margin);
    return *this;
  }
  
  ComputedStyleBuilder& SetOverflowWrap(EOverflowWrap wrap) {
    style_->SetOverflowWrap(wrap);
    return *this;
  }

  ComputedStyleBuilder& SetWordBreak(EWordBreak wb) {
    style_->SetWordBreak(wb);
    return *this;
  }
  
  ComputedStyleBuilder& SetOverlay(EOverlay overlay) {
    style_->SetOverlay(overlay);
    return *this;
  }
  
  ComputedStyleBuilder& SetOutlineColor(const StyleColor& color) {
    style_->SetOutlineColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetOutlineColor(const ::webf::Color& color) {
    style_->SetOutlineColor(color);
    return *this;
  }
  
  // Page properties
  ComputedStyleBuilder& SetPage(const AtomicString& page) {
    style_->SetPage(page);
    return *this;
  }
  
  ComputedStyleBuilder& SetPageOrientation(PageOrientation orientation) {
    style_->SetPageOrientation(orientation);
    return *this;
  }
  
  // Perspective
  ComputedStyleBuilder& SetPerspective(float perspective) {
    style_->SetPerspective(perspective);
    return *this;
  }
  
  ComputedStyleBuilder& SetPerspectiveOrigin(const LengthPoint& origin) {
    style_->SetPerspectiveOrigin(origin);
    return *this;
  }
  
  // Pointer events
  ComputedStyleBuilder& SetPointerEvents(EPointerEvents events) {
    style_->SetPointerEvents(events);
    return *this;
  }
  
  ComputedStyleBuilder& SetPointerEventsIsInherited(bool inherited) {
    style_->SetPointerEventsIsInherited(inherited);
    return *this;
  }
  
  // Orphans
  ComputedStyleBuilder& SetOrphans(short orphans) {
    style_->SetOrphans(orphans);
    return *this;
  }
  
  // Origin trial test property
  ComputedStyleBuilder& SetOriginTrialTestProperty(EOriginTrialTestProperty property) {
    style_->SetOriginTrialTestProperty(property);
    return *this;
  }
  
  // Popover properties
  ComputedStyleBuilder& SetPopoverHideDelay(float delay) {
    style_->SetPopoverHideDelay(delay);
    return *this;
  }
  
  ComputedStyleBuilder& SetPopoverShowDelay(float delay) {
    style_->SetPopoverShowDelay(delay);
    return *this;
  }
  
  // Quotes
  ComputedStyleBuilder& SetQuotes(QuotesData* quotes) {
    style_->SetQuotes(quotes);
    return *this;
  }
  
  // Resize
  ComputedStyleBuilder& SetResize(EResize resize) {
    style_->SetResize(resize);
    return *this;
  }
  
  // Rotate transform
  ComputedStyleBuilder& SetRotate(RotateTransformOperation* rotate) {
    style_->SetRotate(rotate);
    return *this;
  }
  
  // Row gap
  ComputedStyleBuilder& SetRowGap(const std::optional<Length>& gap) {
    style_->SetRowGap(gap);
    return *this;
  }
  
  // Scale transform
  ComputedStyleBuilder& SetScale(ScaleTransformOperation* scale) {
    style_->SetScale(scale);
    return *this;
  }
  
  // Speak
  ComputedStyleBuilder& SetSpeak(ESpeak speak) {
    style_->SetSpeak(speak);
    return *this;
  }
  
  // Table layout
  ComputedStyleBuilder& SetTableLayout(ETableLayout layout) {
    style_->SetTableLayout(layout);
    return *this;
  }
  
  // Text align last
  ComputedStyleBuilder& SetTextAlignLast(ETextAlignLast align) {
    style_->SetTextAlignLast(align);
    return *this;
  }
  
  // Text anchor
  ComputedStyleBuilder& SetTextAnchor(ETextAnchor anchor) {
    style_->SetTextAnchor(anchor);
    return *this;
  }
  
  // Stop opacity
  ComputedStyleBuilder& SetStopOpacity(float opacity) {
    style_->SetStopOpacity(opacity);
    return *this;
  }
  
  // Tab size
  ComputedStyleBuilder& SetTabSize(const TabSize& size) {
    style_->SetTabSize(size);
    return *this;
  }
  
  // Text box edge
  ComputedStyleBuilder& SetTextBoxEdge(const TextBoxEdge& edge) {
    style_->SetTextBoxEdge(edge);
    return *this;
  }
  
  // Text box trim
  ComputedStyleBuilder& SetTextBoxTrim(ETextBoxTrim trim) {
    style_->SetTextBoxTrim(trim);
    return *this;
  }
  
  // Text combine
  ComputedStyleBuilder& SetTextCombine(ETextCombine combine) {
    style_->SetTextCombine(combine);
    return *this;
  }
  
  // Text decoration color
  ComputedStyleBuilder& SetTextDecorationColor(const StyleColor& color) {
    style_->SetTextDecorationColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetTextDecorationColor(const ::webf::Color& color) {
    style_->SetTextDecorationColor(color);
    return *this;
  }
  
  // Text decoration line
  ComputedStyleBuilder& SetTextDecorationLine(TextDecorationLine line) {
    style_->SetTextDecorationLine(line);
    return *this;
  }
  
  // Text decoration skip ink
  ComputedStyleBuilder& SetTextDecorationSkipInk(ETextDecorationSkipInk skip) {
    style_->SetTextDecorationSkipInk(skip);
    return *this;
  }
  
  // Text decoration style
  ComputedStyleBuilder& SetTextDecorationStyle(ETextDecorationStyle style) {
    style_->SetTextDecorationStyle(style);
    return *this;
  }
  
  // Text decoration thickness
  ComputedStyleBuilder& SetTextDecorationThickness(const class TextDecorationThickness& thickness) {
    style_->SetTextDecorationThickness(thickness);
    return *this;
  }
  
  // Text emphasis color
  ComputedStyleBuilder& SetTextEmphasisColor(const StyleColor& color) {
    style_->SetTextEmphasisColor(color);
    return *this;
  }
  
  ComputedStyleBuilder& SetTextEmphasisColor(const ::webf::Color& color) {
    style_->SetTextEmphasisColor(color);
    return *this;
  }
  
  // Text emphasis position
  ComputedStyleBuilder& SetTextEmphasisPosition(TextEmphasisPosition position) {
    style_->SetTextEmphasisPosition(position);
    return *this;
  }
  
  // Text indent
  ComputedStyleBuilder& SetTextIndent(const Length& indent) {
    style_->SetTextIndent(indent);
    return *this;
  }
  
  // Text overflow
  ComputedStyleBuilder& SetTextOverflow(ETextOverflow overflow) {
    style_->SetTextOverflow(overflow);
    return *this;
  }
  
  // Text shadow
  ComputedStyleBuilder& SetTextShadow(ShadowList* shadow) {
    style_->SetTextShadow(shadow);
    return *this;
  }
  
  // Text transform inherited flag
  ComputedStyleBuilder& SetTextTransformIsInherited(bool inherited) {
    style_->SetTextTransformIsInherited(inherited);
    return *this;
  }
  
  // Text underline offset
  ComputedStyleBuilder& SetTextUnderlineOffset(const Length& offset) {
    style_->SetTextUnderlineOffset(offset);
    return *this;
  }
  
  // Text underline position
  ComputedStyleBuilder& SetTextUnderlinePosition(TextUnderlinePosition position) {
    style_->SetTextUnderlinePosition(position);
    return *this;
  }
  
  // Text wrap
  ComputedStyleBuilder& SetTextWrap(TextWrap wrap) {
    style_->SetTextWrap(wrap);
    return *this;
  }
  
  // Transitions
  const CSSTransitionData* Transitions() const { 
    // TODO: Implement transitions support
    return nullptr; 
  }
  CSSTransitionData& AccessTransitions() { 
    // TODO: Implement transitions support
    static CSSTransitionData dummy;
    return dummy;
  }
  
  // Timeline scope
  ComputedStyleBuilder& SetTimelineScope(ScopedCSSNameList* scope) {
    style_->SetTimelineScope(scope);
    return *this;
  }
  
  // Touch action
  ComputedStyleBuilder& SetTouchAction(TouchAction action) {
    style_->SetTouchAction(action);
    return *this;
  }
  
  // Transform properties
  ComputedStyleBuilder& SetTransform(const TransformOperations& transform) {
    style_->SetTransform(transform);
    return *this;
  }
  
  ComputedStyleBuilder& SetTransformBox(ETransformBox box) {
    style_->SetTransformBox(box);
    return *this;
  }
  
  ComputedStyleBuilder& SetTransformOrigin(const TransformOrigin& origin) {
    style_->SetTransformOrigin(origin);
    return *this;
  }
  
  ComputedStyleBuilder& SetTransformStyle3D(ETransformStyle3D style) {
    style_->SetTransformStyle3D(style);
    return *this;
  }
  
  // Get properties for modification during building
  const FontDescription& GetFontDescription() const {
    return style_->GetFontDescription();
  }
  
  const AtomicString& Locale() const {
    return style_->Locale();
  }
  
  // Get Font object
  Font GetFont() const { return style_->GetFont(); }
  
  // Get writing mode
  WritingMode GetWritingMode() const { return style_->GetWritingMode(); }
  
  // Get effective zoom
  float EffectiveZoom() const { return style_->EffectiveZoom(); }
  
  // Get specified line height
  Length SpecifiedLineHeight() const { return style_->SpecifiedLineHeight(); }
  
  // User select
  ComputedStyleBuilder& SetUserSelect(EUserSelect select) {
    style_->SetUserSelect(select);
    return *this;
  }
  
  // Vertical align
  ComputedStyleBuilder& SetVerticalAlign(const Length& align) {
    style_->SetVerticalAlign(align);
    return *this;
  }
  
  // Visibility inheritance
  ComputedStyleBuilder& SetVisibilityIsInherited(bool inherited) {
    // TODO: Track visibility inheritance
    return *this;
  }
  
  // Line break
  ComputedStyleBuilder& SetLineBreak(LineBreak line_break) {
    style_->SetLineBreak(line_break);
    return *this;
  }
  
  // Webkit line clamp
  ComputedStyleBuilder& SetWebkitLineClamp(int clamp) {
    style_->SetWebkitLineClamp(clamp);
    return *this;
  }
  
  // White space collapse
  ComputedStyleBuilder& SetWhiteSpaceCollapse(WhiteSpaceCollapse collapse) {
    style_->SetWhiteSpaceCollapse(collapse);
    return *this;
  }
  
  // Widows
  ComputedStyleBuilder& SetWidows(short widows) {
    style_->SetWidows(widows);
    return *this;
  }
  
  // Word spacing
  ComputedStyleBuilder& SetWordSpacing(float spacing) {
    style_->SetWordSpacing(spacing);
    return *this;
  }

 private:
  std::unique_ptr<ComputedStyle> style_;
};

}  // namespace webf

#endif  // WEBF_CORE_STYLE_COMPUTED_STYLE_H
