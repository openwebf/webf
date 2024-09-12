/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_COMMENT_H
#define BRIDGE_COMMENT_H

#include "character_data.h"
#include "plugin_api/comment.h"

namespace webf {

class Comment : public CharacterData {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static Comment* Create(ExecutingContext*, const AtomicString&, ExceptionState&);
  static Comment* Create(Document&, const AtomicString&);

  explicit Comment(TreeScope& tree_scope, const AtomicString& data, ConstructionType type);

  NodeType nodeType() const override;

  const CommentPublicMethods* commentPublicMethods();

 private:
  std::string nodeName() const override;
  Node* Clone(Document&, CloneChildrenFlag) const override;
  CommentPublicMethods comment_public_methods_;
};

template <>
struct DowncastTraits<Comment> {
  static bool AllowFrom(const Node& node) { return node.IsOtherNode(); }
  static bool AllowFrom(const EventTarget& event_target) { return event_target.IsNode() && To<Node>(event_target).IsOtherNode(); }
};

}  // namespace webf

#endif  // BRIDGE_COMMENT_H
