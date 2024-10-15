// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "element_rare_data_vector.h"
#include "core/css/inline_css_style_declaration.h"
#include "core/dom/element.h"
#include "core/dom/element_rare_data_field.h"

namespace webf {

ElementRareDataVector::ElementRareDataVector() = default;

ElementRareDataVector::~ElementRareDataVector() {
  DCHECK(!GetField(FieldId::kPseudoElementData));
}

CSSStyleDeclaration& ElementRareDataVector::EnsureInlineCSSStyleDeclaration(
    Element* owner_element) {
  return EnsureField<InlineCssStyleDeclaration>(FieldId::kCssomWrapper,
                                                owner_element);
}

ScriptWrappable* ElementRareDataVector::GetField(FieldId field_id) const {
  if (fields_bitfield_ &
      (static_cast<BitfieldType>(1) << static_cast<unsigned>(field_id)))
    return fields_[GetFieldIndex(field_id)];
  return nullptr;
}

unsigned ElementRareDataVector::GetFieldIndex(FieldId field_id) const {
  unsigned field_id_int = static_cast<unsigned>(field_id);
  DCHECK(fields_bitfield_ & (static_cast<BitfieldType>(1) << field_id_int));
  return __builtin_popcount(fields_bitfield_ &
                            ~(~static_cast<BitfieldType>(0) << field_id_int));
}


void ElementRareDataVector::SetField(FieldId field_id,
                                     ScriptWrappable* field) {
  unsigned field_id_int = static_cast<unsigned>(field_id);
  if (fields_bitfield_ & (static_cast<BitfieldType>(1) << field_id_int)) {
    if (field) {
      fields_[GetFieldIndex(field_id)] = field;
    } else {
      fields_.erase(fields_.begin()+ GetFieldIndex(field_id));
      fields_bitfield_ =
          fields_bitfield_ & ~(static_cast<BitfieldType>(1) << field_id_int);
    }
  } else if (field) {
    fields_bitfield_ =
        fields_bitfield_ | (static_cast<BitfieldType>(1) << field_id_int);
    fields_.insert(fields_.begin() + GetFieldIndex(field_id), field);
  }
}

void ElementRareDataVector::Trace(GCVisitor* visitor) const {
  for(auto&& item : fields_) {
    visitor->TraceMember(item);
  }
  NodeRareData::Trace(visitor);
}

}