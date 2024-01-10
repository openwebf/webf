/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "character_data.h"
#include "built_in_string.h"
#include "core/dom/document.h"
#include "mutation_observer_interest_group.h"
#include "qjs_character_data.h"

namespace webf {

void CharacterData::setData(const AtomicString& data, ExceptionState& exception_state) {
  AtomicString old_data = data_;
  data_ = data;

  std::unique_ptr<SharedNativeString> args_01 = data.ToNativeString(ctx());
  std::unique_ptr<SharedNativeString> args_02 = stringToNativeString("data");
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kSetAttribute, std::move(args_01),
                                                       bindingObject(), args_02.release());

  DidModifyData(old_data);
}

void CharacterData::DidModifyData(const webf::AtomicString& old_data) {
  std::shared_ptr<MutationObserverInterestGroup> mutation_recipients =
      MutationObserverInterestGroup::CreateForCharacterDataMutation(*this);
  if (mutation_recipients != nullptr) {
    mutation_recipients->EnqueueMutationRecord(MutationRecord::CreateCharacterData(this, old_data));
  }
}

AtomicString CharacterData::nodeValue() const {
  return data_;
}

bool CharacterData::IsCharacterDataNode() const {
  return true;
}

void CharacterData::setNodeValue(const AtomicString& value, ExceptionState& exception_state) {
  setData(!value.IsEmpty() ? value : built_in_string::kempty_string, exception_state);
}

CharacterData::CharacterData(TreeScope& tree_scope, const AtomicString& text, Node::ConstructionType type)
    : Node(tree_scope.GetDocument().GetExecutingContext(), &tree_scope, type), data_(text) {
  assert(type == kCreateOther || type == kCreateText);
}

}  // namespace webf
