/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "element_data.h"

namespace webf {

void ElementData::CopyWith(ElementData* other) {}

void ElementData::Trace(GCVisitor* visitor) const {
  visitor->Trace(class_lists_);
}

DOMTokenList* ElementData::GetClassList() const {
  return class_lists_;
}

void ElementData::SetClassList(DOMTokenList* dom_token_lists) {
  class_lists_ = dom_token_lists;
}

}  // namespace webf