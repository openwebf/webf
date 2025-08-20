/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_TEXT_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_TEXT_ELEMENT_H_

#include "core/svg/svg_text_positioning_element.h"

namespace webf {

class SVGTextElement : public SVGTextPositioningElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGTextElement*;
  explicit SVGTextElement(Document&);

 private:
};
}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_TEXT_ELEMENT_H_
