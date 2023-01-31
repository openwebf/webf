/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_TEXT_H_
#define BRIDGE_CORE_DOM_TEXT_H_

#include "character_data.h"

namespace webf {

class Text : public CharacterData {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static const unsigned kDefaultLengthLimit = 1 << 16;

  static Text* Create(Document&, const AtomicString&);
  static Text* Create(ExecutingContext* context, ExceptionState& executing_context);
  static Text* Create(ExecutingContext* context, const AtomicString& value, ExceptionState& executing_context);

  Text(TreeScope& tree_scope, const AtomicString& data, ConstructionType type) : CharacterData(tree_scope, data, type) {
    GetExecutingContext()->uiCommandBuffer()->addCommand(eventTargetId(), UICommand::kCreateTextNode,
                                                         std::move(data.ToNativeString(ctx())), (void*)bindingObject());
  }

  NodeType nodeType() const override;

 private:
  std::string nodeName() const override;
  Node* Clone(Document&, CloneChildrenFlag) const override;
};

template <>
struct DowncastTraits<Text> {
  static bool AllowFrom(const Node& node) { return node.IsTextNode(); };
  static bool AllowFrom(const CharacterData& character_data) { return character_data.IsTextNode(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_TEXT_H_
