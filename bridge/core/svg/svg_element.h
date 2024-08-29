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

  void SetNeedsStyleRecalcForInstances(StyleChangeType, const StyleChangeReasonForTracing&);

 private:
  bool IsSVGElement() const = delete;     // This will catch anyone doing an unnecessary check.
  bool IsStyledElement() const = delete;  // This will catch anyone doing an unnecessary check.
};

template <typename T>
bool IsElementOfType(const SVGElement&);
template <>
inline bool IsElementOfType<const SVGElement>(const SVGElement&) {
  return true;
}
template <>
inline bool IsElementOfType<const SVGElement>(const Node& node) {
  return IsA<SVGElement>(node);
}
template <>
struct DowncastTraits<SVGElement> {
  static bool AllowFrom(const Node& node) { return node.IsSVGElement(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_SVG_SVG_ELEMENT_H_
