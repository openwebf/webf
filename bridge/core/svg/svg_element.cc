/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/**
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "svg_element.h"
#include "element_namespace_uris.h"

namespace webf {
SVGElement::SVGElement(const AtomicString& tag_name, Document* document, ConstructionType type)
    : Element(element_namespace_uris::ksvg, tag_name, AtomicString::Null(), document, type) {}

bool SVGElement::IsSVGElement() const {
  return true;
}

bool SVGElement::IsStyledElement() const {
  return false;
}

void SVGElement::SetNeedsStyleRecalcForInstances(StyleChangeType change_type,
                                                 const StyleChangeReasonForTracing& reason) {
  /* // TODO(guopengfei)：未支持
  const std::unordered_set<WeakMember<SVGElement>>& set = InstancesForElement();
  if (set.empty())
    return;

  for (SVGElement* instance : set)
    instance->SetNeedsStyleRecalc(change_type, reason);
    */
}

}  // namespace webf
