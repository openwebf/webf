/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "element_data.h"

namespace webf {

void ElementData::CopyWith(ElementData* other) {}

void ElementData::TraceAfterDispatch(GCVisitor* visitor) const {
  visitor->TraceMember(inline_style_);
  //visitor->TraceMember(class_names_);
}

void ElementData::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(class_lists_);
  visitor->TraceMember(data_set_);
}

DOMTokenList* ElementData::GetClassList() const {
  return class_lists_;
}

void ElementData::SetClassList(DOMTokenList* dom_token_lists) {
  class_lists_ = dom_token_lists;
}

DOMStringMap* ElementData::DataSet() const {
  return data_set_;
}

void ElementData::SetDataSet(webf::DOMStringMap* data_set) {
  data_set_ = data_set;
}

inline AttributeCollection ElementData::Attributes() const {
  if (auto* unique_element_data = DynamicTo<UniqueElementData>(this))
    return unique_element_data->Attributes();
  return To<ShareableElementData>(this)->Attributes();
}

}  // namespace webf