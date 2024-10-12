/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_STYLE_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_STYLE_ELEMENT_H_

#include "svg_element.h"
#include "svg_names.h"

namespace webf {

class SVGStyleElement : public SVGElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGStyleElement*;
  SVGStyleElement(Document&);

 private:
};

template <>
struct DowncastTraits<SVGStyleElement> {
  static bool AllowFrom(const Element& element) {
    return element.IsSVGElement() && element.HasTagName(svg_names::kstyle);
  }
  static bool AllowFrom(const Node& node) {
    return node.IsHTMLElement() && IsA<SVGStyleElement>(To<SVGElement>(node));
  }
};

}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_STYLE_ELEMENT_H_
