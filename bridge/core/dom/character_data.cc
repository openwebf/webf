/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "character_data.h"
#include "core/dom/document.h"

namespace webf {

void CharacterData::setData(const AtomicString& data, ExceptionState& exception_state) {
  data_ = data;

  std::unique_ptr<NativeString> args_01 = stringToNativeString("data");
  std::unique_ptr<NativeString> args_02 = data.ToNativeString();

  GetExecutingContext()->uiCommandBuffer()->addCommand(eventTargetId(), UICommand::kSetAttribute, std::move(args_01),
                                                       std::move(args_02), (void*)bindingObject());
}

std::string CharacterData::nodeValue() const {
  return data_.ToStdString();
}
CharacterData::CharacterData(TreeScope& tree_scope, const AtomicString& text, Node::ConstructionType type)
    : Node(tree_scope.GetDocument().GetExecutingContext(), &tree_scope, type),
      data_(!text.IsNull() ? text : AtomicString::Empty()) {
  assert(type == kCreateOther || type == kCreateText);
}

}  // namespace webf
