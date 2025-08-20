/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_SVG_SVG_ELEMENT_H_
#define BRIDGE_CORE_SVG_SVG_ELEMENT_H_

#include "core/dom/element.h"
#include "core/dom/global_event_handlers.h"

namespace webf {

class SVGElement : public Element {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = SVGElement*;
  SVGElement(const AtomicString& tag_name, Document* document, ConstructionType = kCreateHTMLElement);

 private:
};
}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_ELEMENT_H_
