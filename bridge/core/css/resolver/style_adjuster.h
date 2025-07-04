/*
 * Copyright (C) 2013 Google, Inc.
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Apple Inc.
 * All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
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

#ifndef WEBF_CORE_CSS_RESOLVER_STYLE_ADJUSTER_H_
#define WEBF_CORE_CSS_RESOLVER_STYLE_ADJUSTER_H_

#include <memory>
#include "foundation/macros.h"
#include "core/style/computed_style_constants.h"

namespace webf {

class ComputedStyleBuilder;
class ComputedStyle;
class Element;
class ElementResolveContext;
class StyleRequest;

// Certain CSS property values can only be applied to certain elements
// or in certain contexts. StyleAdjuster handles these cases by adjusting
// computed style values that would otherwise be invalid.
class StyleAdjuster {
  WEBF_STATIC_ONLY(StyleAdjuster);

 public:
  // Applies various adjustments to the computed style based on the element
  // and its context. This is called after the cascade has determined the
  // initial computed values.
  static void AdjustComputedStyle(ElementResolveContext&,
                                  const StyleRequest&,
                                  Element*,
                                  ComputedStyleBuilder&);

 private:
  // Adjust display values based on CSS rules.
  // https://www.w3.org/TR/CSS2/visuren.html#dis-pos-flo
  static void AdjustStyleForDisplay(ComputedStyleBuilder&,
                                    const ComputedStyle& parent_style,
                                    const ComputedStyle* layout_parent_style,
                                    Element*);

  // Adjust overflow values for compatibility and special cases.
  static void AdjustOverflow(ComputedStyleBuilder&);

  // TODO: Add helper methods when ComputedStyleBuilder supports getters

  // Check if an element is in the top layer (fullscreen, dialog, etc).
  static bool IsInTopLayer(Element*);

  // Apply adjustments specific to certain HTML elements.
  static void AdjustStyleForHTMLElement(Element&, ComputedStyleBuilder&);

  // Adjust computed values for specific element types.
  static void AdjustStyleForEditableContent(Element&,
                                           ComputedStyleBuilder&,
                                           const ComputedStyle& parent_style);

  // Position and z-index adjustments.
  static void AdjustPositionAndZIndex(Element*,
                                      const Element* parent_element,
                                      ComputedStyleBuilder&);

  // Adjust text decorations that shouldn't propagate.
  static void AdjustTextDecorationPropagation(ComputedStyleBuilder&,
                                              const Element*);
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_STYLE_ADJUSTER_H_