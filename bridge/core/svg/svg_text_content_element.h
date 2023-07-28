/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_TEXT_CONTENT_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_TEXT_CONTENT_ELEMENT_H_

#include "core/svg/svg_graphics_element.h"

namespace webf {

class SVGTextContentElement : public SVGGraphicsElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGTextContentElement*;
  SVGTextContentElement(const AtomicString&, Document&);

 private:
};
}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_TEXT_CONTENT_ELEMENT_H_
