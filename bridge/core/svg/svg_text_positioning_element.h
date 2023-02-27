/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_TEXT_POSITIONING_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_TEXT_POSITIONING_ELEMENT_H_

#include "core/svg/svg_text_content_element.h"

namespace webf {

class SVGTextPositioningElement : public SVGTextContentElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGTextPositioningElement*;
  SVGTextPositioningElement(const AtomicString&, Document&);

 private:
};
}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_TEXT_POSITIONING_ELEMENT_H_
