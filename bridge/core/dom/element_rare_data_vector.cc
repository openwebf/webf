// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "element_rare_data_vector.h"
#include <bit>
#include "core/css/inline_css_style_declaration.h"
#include "core/css/style_scope_data.h"
#include "core/dom/element.h"
#include "core/dom/element_rare_data_field.h"

namespace webf {

ElementRareDataVector::ElementRareDataVector() = default;

ElementRareDataVector::~ElementRareDataVector() {
  DCHECK(!GetElementRareDataField(FieldId::kPseudoElementData));
}

CSSStyleDeclaration& ElementRareDataVector::EnsureInlineCSSStyleDeclaration(Element* owner_element) {
  return EnsureWrappedField<InlineCssStyleDeclaration>(FieldId::kCssomWrapper, owner_element);
}

unsigned ElementRareDataVector::GetFieldIndex(FieldId field_id) const {
  unsigned field_id_int = static_cast<unsigned>(field_id);
  DCHECK(fields_bitfield_ & (static_cast<BitfieldType>(1) << field_id_int));
  return __builtin_popcount(fields_bitfield_ & ~(~static_cast<BitfieldType>(0) << field_id_int));
}

void ElementRareDataVector::SetElementRareDataField(webf::ElementRareDataVector::FieldId field_id,
                                                    std::shared_ptr<ElementRareDataField> field) {
  unsigned field_id_int = static_cast<unsigned>(field_id);
  if (fields_bitfield_ & (static_cast<BitfieldType>(1) << field_id_int)) {
    if (field) {
      element_rare_data_fields_[GetFieldIndex(field_id)] = field;
    } else {
      element_rare_data_fields_.erase(element_rare_data_fields_.begin() + GetFieldIndex(field_id));
      fields_bitfield_ = fields_bitfield_ & ~(static_cast<BitfieldType>(1) << field_id_int);
    }
  } else if (field) {
    fields_bitfield_ = fields_bitfield_ | (static_cast<BitfieldType>(1) << field_id_int);
    unsigned offset = GetFieldIndex(field_id);
    if (offset > element_rare_data_fields_.size()) {
      element_rare_data_fields_.resize(field_id_int + 1);
    }

    element_rare_data_fields_[offset] = field;
  }
}

void ElementRareDataVector::SetScriptWrappableField(webf::ElementRareDataVector::FieldId field_id,
                                                    webf::ScriptWrappable* field) {
  unsigned field_id_int = static_cast<unsigned>(field_id);
  if (fields_bitfield_ & (static_cast<BitfieldType>(1) << field_id_int)) {
    if (field) {
      script_wrappable_fields_[GetFieldIndex(field_id)] = field;
    } else {
      script_wrappable_fields_.erase(script_wrappable_fields_.begin() + GetFieldIndex(field_id));
      fields_bitfield_ = fields_bitfield_ & ~(static_cast<BitfieldType>(1) << field_id_int);
    }
  } else if (field) {
    fields_bitfield_ = fields_bitfield_ | (static_cast<BitfieldType>(1) << field_id_int);
    unsigned offset = GetFieldIndex(field_id);
    if (offset > script_wrappable_fields_.size()) {
      script_wrappable_fields_.resize(field_id_int + 1);
    }

    script_wrappable_fields_[offset] = field;
  }
}

std::shared_ptr<ElementRareDataField> ElementRareDataVector::GetElementRareDataField(FieldId field_id) const {
  if (fields_bitfield_ & (static_cast<BitfieldType>(1) << static_cast<unsigned>(field_id)))
    return element_rare_data_fields_[GetFieldIndex(field_id)];
  return nullptr;
}

ScriptWrappable* ElementRareDataVector::GetScriptWrappableField(FieldId field_id) const {
  if (fields_bitfield_ & (static_cast<BitfieldType>(1) << static_cast<unsigned>(field_id)))
    return script_wrappable_fields_[GetFieldIndex(field_id)];
  return nullptr;
}

void ElementRareDataVector::Trace(GCVisitor* visitor) const {
  for (auto&& item : script_wrappable_fields_) {
    visitor->TraceMember(item);
  }
  NodeRareData::Trace(visitor);
}

StyleScopeData& ElementRareDataVector::EnsureStyleScopeData() {
  return EnsureElementRareDataField<StyleScopeData>(FieldId::kStyleScopeData);
}
StyleScopeData* ElementRareDataVector::GetStyleScopeData() const {
  return std::static_pointer_cast<StyleScopeData>(GetElementRareDataField(FieldId::kStyleScopeData)).get();
}

}  // namespace webf