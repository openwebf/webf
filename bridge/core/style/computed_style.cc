/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 2004-2005 Allan Sandfeld Jensen (kde@carewolf.com)
 * Copyright (C) 2006, 2007 Nicholas Shanks (webkit@nickshanks.com)
 * Copyright (C) 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012 Apple Inc. All rights reserved.
 * Copyright (C) 2007 Alexey Proskuryakov <ap@webkit.org>
 * Copyright (C) 2007, 2008 Eric Seidel <eric@webkit.org>
 * Copyright (C) 2008, 2009 Torch Mobile Inc. All rights reserved. (http://www.torchmobile.com/)
 * Copyright (c) 2011, Code Aurora Forum. All rights reserved.
 * Copyright (C) Research In Motion Limited 2011. All rights reserved.
 * Contributions by Stephen White and Juan Batiz-Benet
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
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "computed_style.h"

namespace webf {

ComputedStyle::ComputedStyle() = default;

const ComputedStyle& ComputedStyle::GetInitialStyle() {
  static std::shared_ptr<ComputedStyle> initial_style;
  if (!initial_style) {
    initial_style = std::make_shared<ComputedStyle>();
    // Set up initial values
    initial_style->SetDisplay(EDisplay::kInline);
    initial_style->SetPosition(EPosition::kStatic);
    initial_style->SetOverflowX(EOverflow::kVisible);
    initial_style->SetOverflowY(EOverflow::kVisible);
    initial_style->SetDirection(TextDirection::kLtr);
    initial_style->SetWritingMode(WritingMode::kHorizontalTb);
    initial_style->SetOpacity(1.0f);
    initial_style->SetHasAutoZIndex(true);
    initial_style->SetZIndex(0);
    initial_style->SetColor(Color::kBlack);
    initial_style->SetBackgroundColor(Color::kTransparent);
    
    // Set up initial font
    FontDescription font_desc;
    font_desc.SetFamily(FontFamily());
    font_desc.SetSpecifiedSize(16.0f);
    font_desc.SetComputedSize(16.0f);
    font_desc.SetWeight(FontDescription::FontSelectionValue(400));
    font_desc.SetStyle(FontDescription::FontSelectionValue(0));
    font_desc.SetStretch(FontDescription::FontSelectionValue(100));
    initial_style->SetFontDescription(font_desc);
  }
  return *initial_style;
}

std::unique_ptr<ComputedStyle> ComputedStyle::Clone() const {
  return std::make_unique<ComputedStyle>(*this);
}

std::unique_ptr<ComputedStyleBuilder> ComputedStyle::CloneAsBuilder() const {
  return std::make_unique<ComputedStyleBuilder>(*this);
}

bool ComputedStyle::InheritedEqual(const ComputedStyle& other) const {
  // Check inherited properties
  return direction_ == other.direction_ &&
         writing_mode_ == other.writing_mode_ &&
         color_ == other.color_ &&
         font_description_ == other.font_description_ &&
         locale_ == other.locale_;
}

bool ComputedStyle::NonInheritedEqual(const ComputedStyle& other) const {
  // Check non-inherited properties
  return display_ == other.display_ &&
         position_ == other.position_ &&
         overflow_x_ == other.overflow_x_ &&
         overflow_y_ == other.overflow_y_ &&
         opacity_ == other.opacity_ &&
         z_index_ == other.z_index_ &&
         has_auto_z_index_ == other.has_auto_z_index_ &&
         background_color_ == other.background_color_;
}

// ComputedStyleBuilder implementation

ComputedStyleBuilder::ComputedStyleBuilder() 
    : style_(std::make_unique<ComputedStyle>()) {
}

ComputedStyleBuilder::ComputedStyleBuilder(const ComputedStyle& style)
    : style_(std::make_unique<ComputedStyle>(style)) {
}

ComputedStyleBuilder::~ComputedStyleBuilder() = default;

std::shared_ptr<const ComputedStyle> ComputedStyleBuilder::TakeStyle() {
  return std::shared_ptr<const ComputedStyle>(std::move(style_));
}

}  // namespace webf