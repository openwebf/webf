/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Apple Inc.
 * All rights reserved.
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

#include "style_resolver_state.h"

#include "core/dom/element.h"
#include "core/dom/document.h"
#include "core/style/computed_style.h"

namespace webf {

StyleResolverState::StyleResolverState(Document& document, Element& element)
    : element_context_(element),
      document_(&document),
      element_(&element),
      selector_checker_(SelectorChecker::kResolvingStyle),
      css_to_length_conversion_data_(),
      parent_style_(nullptr),
      layout_parent_style_(nullptr),
      old_style_(nullptr),
      styled_element_(&element),
      element_type_(ElementType::kElement),
      container_unit_context_(nullptr),
      is_for_highlight_(false),
      uses_highlight_pseudo_inheritance_(false),
      is_outside_flat_tree_(false),
      can_trigger_animations_(true),
      had_no_matched_properties_(false),
      conditionally_affects_animations_(false),
      affects_compositor_snapshots_(false),
      rejected_legacy_overlapping_(false),
      has_tree_scoped_reference_(false) {
  // Initialize with a proper ComputedStyleBuilder with initial values
  // Don't set it here, let the StyleResolver initialize it properly
}

StyleResolverState::~StyleResolverState() = default;

bool StyleResolverState::IsInheritedForUnset(const CSSProperty& property) const {
  return property.IsInherited();
}

const Element* StyleResolverState::ParentElement() const {
  return element_->parentElement();
}

const ComputedStyle* StyleResolverState::RootElementStyle() const {
  // TODO: Implement getting root element style
  return nullptr;
}

EInsideLink StyleResolverState::InsideLink() const {
  // TODO: Implement inside link detection
  return EInsideLink::kNotInsideLink;
}

void StyleResolverState::UpdateLengthConversionData() {
  if (!style_builder_) {
    return;
  }
  
  // Create viewport size - for now just use default values
  CSSToLengthConversionData::ViewportSize viewport_size(800, 600);
  
  // Create container sizes
  CSSToLengthConversionData::ContainerSizes container_sizes(element_);
  
  // Update the conversion data
  css_to_length_conversion_data_ = CSSToLengthConversionData(
      *style_builder_,
      parent_style_,
      RootElementStyle(),
      viewport_size,
      container_sizes,
      style_builder_->EffectiveZoom(),
      length_conversion_flags_
  );
}

const ComputedStyle* StyleResolverState::TakeStyle() {
  // TODO: Implement
  return nullptr;
}

Element* StyleResolverState::GetAnimatingElement() const {
  // TODO: Implement
  return element_;
}

PseudoElement* StyleResolverState::GetPseudoElement() const {
  // TODO: Implement
  return nullptr;
}

void StyleResolverState::SetParentStyle(const ComputedStyle* style) {
  parent_style_ = style;
}

void StyleResolverState::SetLayoutParentStyle(const ComputedStyle* style) {
  layout_parent_style_ = style;
}

void StyleResolverState::LoadPendingResources() {
  // TODO: Implement
}

const FontDescription& StyleResolverState::ParentFontDescription() const {
  if (parent_style_) {
    return parent_style_->GetFontDescription();
  }
  return ComputedStyle::GetInitialStyle().GetFontDescription();
}

void StyleResolverState::SetZoom(float zoom) {
  // TODO: Implement
}

void StyleResolverState::SetEffectiveZoom(float zoom) {
  // TODO: Implement
}

void StyleResolverState::SetWritingMode(WritingMode mode) {
  style_builder_->SetWritingMode(mode);
}

CSSParserMode StyleResolverState::GetParserMode() const {
  // TODO: Implement quirks mode detection
  return kHTMLStandardMode;
}

const CSSValue& StyleResolverState::ResolveLightDarkPair(const CSSValue& value) {
  // TODO: Implement light-dark pair resolution
  return value;
}

bool StyleResolverState::CanAffectAnimations() const {
  return conditionally_affects_animations_;
}

void StyleResolverState::UpdateFont() {
  // TODO: Implement font update
}

void StyleResolverState::UpdateLineHeight() {
  // TODO: Implement line height update
}

CSSToLengthConversionData StyleResolverState::FontSizeConversionData() {
  // Create conversion data for font size calculations
  // This uses the parent style's font size
  if (parent_style_) {
    CSSToLengthConversionData::FontSizes font_sizes(
        parent_style_->GetFont().SpecifiedSize(),
        parent_style_->GetFont().SpecifiedSize(),
        parent_style_->GetFont(),
        1.0f  // zoom
    );
    CSSToLengthConversionData::LineHeightSize line_height_size;
    CSSToLengthConversionData::ViewportSize viewport_size;
    CSSToLengthConversionData::ContainerSizes container_sizes;
    
    return CSSToLengthConversionData(
        WritingMode::kHorizontalTb,
        font_sizes,
        line_height_size,
        viewport_size,
        container_sizes,
        1.0f,  // zoom
        length_conversion_flags_
    );
  }
  return CSSToLengthConversionData();
}

CSSToLengthConversionData StyleResolverState::UnzoomedLengthConversionData() {
  // Create conversion data without zoom
  if (style_builder_) {
    CSSToLengthConversionData::FontSizes font_sizes(
        style_builder_->GetFont().SpecifiedSize(),
        style_builder_->GetFont().SpecifiedSize(),
        style_builder_->GetFont(),
        1.0f  // zoom
    );
    CSSToLengthConversionData::LineHeightSize line_height_size;
    CSSToLengthConversionData::ViewportSize viewport_size;
    CSSToLengthConversionData::ContainerSizes container_sizes;
    
    return CSSToLengthConversionData(
        style_builder_->GetWritingMode(),
        font_sizes,
        line_height_size,
        viewport_size,
        container_sizes,
        1.0f,  // unzoomed
        length_conversion_flags_
    );
  }
  return CSSToLengthConversionData();
}

CSSToLengthConversionData StyleResolverState::UnzoomedLengthConversionData(const FontSizeStyle& font_size_style) {
  // Create conversion data with specific font size style
  CSSToLengthConversionData::FontSizes font_sizes(
      font_size_style.GetFont().SpecifiedSize(),
      font_size_style.GetFont().SpecifiedSize(),
      font_size_style.GetFont(),
      1.0f  // zoom
  );
  CSSToLengthConversionData::LineHeightSize line_height_size;
  CSSToLengthConversionData::ViewportSize viewport_size;
  CSSToLengthConversionData::ContainerSizes container_sizes;
  
  return CSSToLengthConversionData(
      WritingMode::kHorizontalTb,
      font_sizes,
      line_height_size,
      viewport_size,
      container_sizes,
      1.0f,  // unzoomed
      length_conversion_flags_
  );
}

}  // namespace webf
