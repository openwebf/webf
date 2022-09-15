/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_collection.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/dom/container_node.h"

namespace webf {

HTMLCollection::HTMLCollection(ContainerNode* base, CollectionType) : base_(base), ScriptWrappable(base->ctx()) {}

unsigned int HTMLCollection::length() const {
  std::vector<Element> elements;
  NodeList* node_list = base_->childNodes();
  int32_t length = 0;

  for (int i = 0; i < node_list->length(); i++) {
    if (DynamicTo<Element>(node_list->item(i, ASSERT_NO_EXCEPTION()))) {
      length++;
    }
  }

  return length;
}

Element* HTMLCollection::item(unsigned int offset, ExceptionState& exception_state) const {
  std::vector<Element*> elements;
  NodeList* node_list = base_->childNodes();
  int32_t length = 0;

  for (int i = 0; i < node_list->length(); i++) {
    auto* element = DynamicTo<Element>(node_list->item(i, ASSERT_NO_EXCEPTION()));
    if (element) {
      elements.emplace_back(element);
    }
  }

  return nodes_.at(offset);
}

bool HTMLCollection::NamedPropertyQuery(const AtomicString& key, ExceptionState&) {
  int32_t index = std::stoi(key.ToStdString());
  return index >= 0 && index < nodes_.size();
}

void HTMLCollection::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) {
  names.emplace_back(AtomicString(ctx(), "length"));
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
