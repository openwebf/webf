/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "touch_list.h"
#include "touch.h"

namespace webf {

void TouchList::FromNativeTouchList(ExecutingContext* context,
                                    TouchList* touch_list,
                                    NativeTouchList* native_touch_list) {
  MemberMutationScope mutation_scope{context};
  for (size_t i = 0; i < native_touch_list->length; i++) {
    auto* touch = Touch::Create(context, &native_touch_list->touches[i]);
    touch_list->values_.emplace_back(touch);
  }
}

TouchList::TouchList(ExecutingContext* context, NativeTouchList* native_touch_list) : ScriptWrappable(context->ctx()) {
  FromNativeTouchList(context, this, native_touch_list);
}

uint32_t TouchList::length() const {
  return values_.size();
}

Touch* TouchList::item(uint32_t index, ExceptionState& exception_state) const {
  return values_[index];
}

bool TouchList::SetItem(uint32_t index, Touch* touch, ExceptionState& exception_state) {
  if (index >= values_.size()) {
    values_.emplace_back(touch);
  } else {
    values_[index] = touch;
  }
  return true;
}

bool TouchList::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  uint32_t index = std::stoi(key.ToStdString(ctx()));
  return index >= 0 && index < values_.size();
}

void TouchList::NamedPropertyEnumerator(std::vector<AtomicString>& props, ExceptionState& exception_state) {
  for (int i = 0; i < values_.size(); i++) {
    props.emplace_back(AtomicString(ctx(), std::to_string(i)));
  }
}

void TouchList::Trace(GCVisitor* visitor) const {
  for (auto& item : values_) {
    item->Trace(visitor);
  }
}

}  // namespace webf