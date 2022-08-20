/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "touch_list.h"

namespace webf {

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
}

void TouchList::Trace(GCVisitor* visitor) const {
  for(auto& item : values_) {
    item->Trace(visitor);
  }
}

}