/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CHARACTER_DATA_H
#define BRIDGE_CHARACTER_DATA_H

#include "node.h"
#include "plugin_api_gen/character_data.h"

namespace webf {

class Document;

class CharacterData : public Node {
  DEFINE_WRAPPERTYPEINFO();

 public:
  //  static CharacterDataRustMethods* rustMethodPointer();

  const AtomicString& data() const { return data_; }
  int64_t length() const { return data_.length(); };
  void setData(const AtomicString& data, ExceptionState& exception_state);

  void DidModifyData(const AtomicString& old_data);

  AtomicString nodeValue() const override;
  bool IsCharacterDataNode() const override;
  void setNodeValue(const AtomicString&, ExceptionState&) override;

  const CharacterDataPublicMethods* characterDataPublicMethods();

 protected:
  CharacterData(TreeScope& tree_scope, const AtomicString& text, ConstructionType type);

 private:
  AtomicString data_;
};

template <>
struct DowncastTraits<CharacterData> {
  static bool AllowFrom(const Node& node) { return node.IsCharacterDataNode(); }
  static bool AllowFrom(const EventTarget& event_target) {
    return event_target.IsNode() && To<Node>(event_target).IsCharacterDataNode();
  }
};

}  // namespace webf

#endif  // BRIDGE_CHARACTER_DATA_H
