/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "document_fragment.h"
#include "document.h"
#include "events/event_target.h"

namespace webf {

DocumentFragment* DocumentFragment::Create(Document& document) {
  return MakeGarbageCollected<DocumentFragment>(&document, ConstructionType::kCreateDocumentFragment);
}

DocumentFragment* DocumentFragment::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<DocumentFragment>(context->document(), ConstructionType::kCreateDocumentFragment);
}

DocumentFragment::DocumentFragment(Document* document, ConstructionType type) : ContainerNode(document, type) {}

std::string DocumentFragment::nodeName() const {
  return "#document-fragment";
}

Node::NodeType DocumentFragment::nodeType() const {
  return NodeType::kDocumentFragmentNode;
}

std::string DocumentFragment::nodeValue() const {
  return "";
}

Node* DocumentFragment::Clone(Document& factory, CloneChildrenFlag flag) const {
  DocumentFragment* clone = Create(factory);
  if (flag != CloneChildrenFlag::kSkip)
    clone->CloneChildNodesFrom(*this, flag);
  return clone;
}

bool DocumentFragment::ChildTypeAllowed(NodeType type) const {
  switch (type) {
    case kElementNode:
    case kCommentNode:
    case kTextNode:
      return true;
    default:
      return false;
  }
}

}  // namespace webf
