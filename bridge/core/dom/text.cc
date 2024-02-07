/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "text.h"
#include "document.h"

namespace webf {

Text* Text::Create(Document& document, const AtomicString& value) {
  return MakeGarbageCollected<Text>(document, value, ConstructionType::kCreateText);
}

Text* Text::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<Text>(*context->document(), AtomicString::Empty(), ConstructionType::kCreateText);
}

Text* Text::Create(ExecutingContext* context, const AtomicString& value, ExceptionState& executing_context) {
  return MakeGarbageCollected<Text>(*context->document(), value, ConstructionType::kCreateText);
}

Node::NodeType Text::nodeType() const {
  return Node::kTextNode;
}

RustMethods* Text::rustMethodPointer() {
  auto* super_rust_method = CharacterData::rustMethodPointer();
  static auto* rust_method = new TextNodeRustMethods(static_cast<CharacterDataRustMethods*>(super_rust_method));
  return rust_method;
}

std::string Text::nodeName() const {
  return "#text";
}

Node* Text::Clone(Document& document, CloneChildrenFlag flag) const {
  Node* copy = Create(document, data());
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kCloneNode, nullptr, bindingObject(),
                                                       copy->bindingObject());
  return copy;
}

}  // namespace webf
