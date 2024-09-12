/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CHARACTER_DATA_H
#define BRIDGE_CHARACTER_DATA_H

#include "plugin_api/character_data.h"
#include "node.h"

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
  CharacterDataPublicMethods character_data_public_methods;
};

template <>
struct DowncastTraits<CharacterData> {
  static bool AllowFrom(const Node& node) { return node.IsCharacterDataNode(); }
};

}  // namespace webf

#endif  // BRIDGE_CHARACTER_DATA_H
