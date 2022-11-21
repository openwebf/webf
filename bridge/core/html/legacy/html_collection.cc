/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_collection.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/dom/container_node.h"

namespace webf {

HTMLCollection::HTMLCollection(ContainerNode* base, CollectionType type)
    : base_(base), type_(type), ScriptWrappable(base->ctx()) {}

unsigned int HTMLCollection::length() const {
  int32_t length = 0;

  if (type_ == CollectionType::kDocAll) {
    auto* document = DynamicTo<Document>(*base_);
    for (const Node& child : NodeTraversal::InclusiveDescendantsOf(*document->documentElement())) {
      length++;
    }
  }

  return length;
}

Element* HTMLCollection::item(unsigned int offset, ExceptionState& exception_state) const {
  if (type_ == CollectionType::kDocAll) {
    int32_t i = 0;
    auto* document = DynamicTo<Document>(*base_);
    for (Node& child : ElementTraversal ::InclusiveDescendantsOf(*document->documentElement())) {
      if (i == offset) {
        return DynamicTo<Element>(child);
      }
      i++;
    }
  }

  return nullptr;
}

bool HTMLCollection::NamedPropertyQuery(const AtomicString& key, ExceptionState&) {
  int32_t index = std::stoi(key.ToStdString(ctx()));
  return index >= 0 && index < nodes_.size();
}

void HTMLCollection::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) {
  names.emplace_back(AtomicString(ctx(), "length"));
  for (int i = 0; i < nodes_.size(); i++) {
    names.emplace_back(AtomicString(ctx(), std::to_string(i)));
  }
}

void HTMLCollection::Trace(GCVisitor* visitor) const {}

}  // namespace webf
