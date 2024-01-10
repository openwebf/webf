/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "comment.h"
#include "built_in_string.h"
#include "document.h"
#include "tree_scope.h"

namespace webf {

Comment* Comment::Create(ExecutingContext* context, const AtomicString& data, ExceptionState& exception_state) {
  return MakeGarbageCollected<Comment>(*context->document(), data.IsNull() ? AtomicString::Empty() : data,
                                       ConstructionType::kCreateOther);
}

Comment* Comment::Create(Document& document, const AtomicString& data) {
  return MakeGarbageCollected<Comment>(document, data, ConstructionType::kCreateOther);
}

Comment::Comment(TreeScope& tree_scope, const AtomicString& data, ConstructionType type)
    : CharacterData(tree_scope, data, type) {
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kCreateComment, nullptr, (void*)bindingObject(),
                                                       nullptr);
}

Node::NodeType Comment::nodeType() const {
  return Node::kCommentNode;
}
std::string Comment::nodeName() const {
  return "#comment";
}

Node* Comment::Clone(Document& factory, CloneChildrenFlag flag) const {
  Node* copy = Create(factory, data());
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kCloneNode, nullptr, bindingObject(),
                                                       copy->bindingObject());
  return copy;
}

}  // namespace webf
