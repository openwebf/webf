/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_collection.h"
#include "core/dom/container_node.h"

namespace webf {

HTMLCollection::HTMLCollection(ContainerNode* base, CollectionType) : base_(base), ScriptWrappable(base->ctx()) {}

unsigned int HTMLCollection::length() const {
  return nodes_.size();
}

Element* HTMLCollection::item(unsigned int offset, ExceptionState& exception_state) const {
  return nodes_.at(offset);
}

bool HTMLCollection::NamedPropertyQuery(const AtomicString& key, ExceptionState&) {
  int32_t index = std::stoi(key.ToStdString());
  return index >= 0 && index < nodes_.size();
}

void HTMLCollection::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) {
  for (int i = 0; i < nodes_.size(); i++) {
    names.emplace_back(AtomicString(ctx(), std::to_string(i)));
  }
}

void HTMLCollection::Trace(GCVisitor* visitor) const {
  visitor->Trace(base_);
  for (auto& node : nodes_) {
    node->Trace(visitor);
  }
}

}  // namespace webf
