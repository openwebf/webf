/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2012, 2013 Apple Inc.
 * All rights reserved.
 * Copyright (C) 2011 Research In Motion Limited. All rights reserved.
 * Copyright (C) 2013 Intel Corporation. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_property_value_set.h"
#include <span>
#include "core/css/css_identifier_value.h"
#include "core/css/css_markup.h"
#include "core/css/parser/css_parser.h"
#include "core/css/style_property_serializer.h"
#include "property_bitsets.h"
#include "style_property_shorthand.h"

namespace webf {

void CSSPropertyValueSet::FinalizeGarbageCollectedObject() {
  if (is_mutable_) {
    To<MutableCSSPropertyValueSet>(this)->~MutableCSSPropertyValueSet();
  } else {
    To<ImmutableCSSPropertyValueSet>(this)->~ImmutableCSSPropertyValueSet();
  }
}

template <typename T>
const std::shared_ptr<const CSSValue>* CSSPropertyValueSet::GetPropertyCSSValue(const T& property) const {
  int found_property_index = FindPropertyIndex(property);
  if (found_property_index == -1) {
    return nullptr;
  }
  return PropertyAt(found_property_index).Value();
}

static std::string SerializeShorthand(const CSSPropertyValueSet& property_set, CSSPropertyID property_id) {
  StylePropertyShorthand shorthand = shorthandForProperty(property_id);
  if (!shorthand.length()) {
    return "";
  }

  return StylePropertySerializer(property_set).SerializeShorthand(property_id);
}

template <typename T>
std::string CSSPropertyValueSet::GetPropertyValue(const T& property) const {
  std::string shorthand_serialization = SerializeShorthand(*this, property);
  if (!shorthand_serialization.empty()) {
    return shorthand_serialization;
  }
  const CSSValue* value = GetPropertyCSSValue(property);
  if (value) {
    return value->CssText();
  }
  return "";
}
template const std::shared_ptr<const CSSValue>* CSSPropertyValueSet::GetPropertyCSSValue<CSSPropertyID>(
    const CSSPropertyID&) const;

template <typename T>
bool CSSPropertyValueSet::PropertyIsImportant(const T& property) const {
  int found_property_index = FindPropertyIndex(property);
  if (found_property_index != -1) {
    return PropertyAt(found_property_index).IsImportant();
  }
  return ShorthandIsImportant(property);
}
template bool CSSPropertyValueSet::PropertyIsImportant<CSSPropertyID>(const CSSPropertyID&) const;

const std::shared_ptr<const CSSValue>* CSSPropertyValueSet::GetPropertyCSSValueWithHint(
    const std::string& property_name,
    unsigned index) const {
  assert(property_name == PropertyAt(index).Name().ToString());
  return PropertyAt(index).Value();
}

std::string CSSPropertyValueSet::GetPropertyValueWithHint(const std::string& property_name, unsigned int index) const {
  auto value = GetPropertyCSSValueWithHint(property_name, index);
  if (value) {
    return value->get()->CssText();
  }
  return "";
}

bool CSSPropertyValueSet::PropertyIsImportantWithHint(const std::string& property_name, unsigned int index) const {
  assert(property_name == PropertyAt(index).Name().ToString());
  return PropertyAt(index).IsImportant();
}

bool CSSPropertyValueSet::ShorthandIsImportant(CSSPropertyID property_id) const {
  StylePropertyShorthand shorthand = shorthandForProperty(property_id);
  if (!shorthand.length()) {
    return false;
  }

  for (unsigned i = 0; i < shorthand.length(); ++i) {
    if (!PropertyIsImportant(shorthand.properties()[i]->PropertyID())) {
      return false;
    }
  }
  return true;
}

CSSPropertyID CSSPropertyValueSet::GetPropertyShorthand(CSSPropertyID property_id) const {
  int found_property_index = FindPropertyIndex(property_id);
  if (found_property_index == -1) {
    return CSSPropertyID::kInvalid;
  }
  return PropertyAt(found_property_index).ShorthandID();
}

bool CSSPropertyValueSet::IsPropertyImplicit(CSSPropertyID property_id) const {
  int found_property_index = FindPropertyIndex(property_id);
  if (found_property_index == -1) {
    return false;
  }
  return PropertyAt(found_property_index).IsImplicit();
}

std::shared_ptr<const MutableCSSPropertyValueSet> CSSPropertyValueSet::MutableCopy() const {
  return std::make_shared<MutableCSSPropertyValueSet>(*this);
}

std::shared_ptr<const ImmutableCSSPropertyValueSet> CSSPropertyValueSet::ImmutableCopyIfNeeded() const {
  auto* immutable_property_set =
      DynamicTo<ImmutableCSSPropertyValueSet>(const_cast<CSSPropertyValueSet*>(shared_from_this().get()));
  if (immutable_property_set) {
    return std::reinterpret_pointer_cast<const ImmutableCSSPropertyValueSet>(shared_from_this());
  }

  const auto* mutable_this = To<MutableCSSPropertyValueSet>(this);
  return ImmutableCSSPropertyValueSet::Create(mutable_this->property_vector_.data(),
                                              mutable_this->property_vector_.size(), CssParserMode());
}

const std::shared_ptr<const MutableCSSPropertyValueSet> CSSPropertyValueSet::CopyPropertiesInSet(
    const std::vector<const CSSProperty*>& properties) const {
  std::vector<CSSPropertyValue> list;
  list.reserve(properties.size());
  for (unsigned i = 0; i < properties.size(); ++i) {
    CSSPropertyName name(properties[i]->PropertyID());
    auto value = GetPropertyCSSValue(name.Id());
    if (value) {
      list.emplace_back(CSSPropertyValue(name, *value, false));
    }
  }
  return std::make_shared<MutableCSSPropertyValueSet>(list.data(), list.size());
}

std::string CSSPropertyValueSet::AsText() const {
  return StylePropertySerializer(*this).AsText();
}

bool CSSPropertyValueSet::HasFailedOrCanceledSubresources() const {
  unsigned size = PropertyCount();
  for (unsigned i = 0; i < size; ++i) {
    if (PropertyAt(i).Value()->get()->HasFailedOrCanceledSubresources()) {
      return true;
    }
  }
  return false;
}

#ifndef NDEBUG
void CSSPropertyValueSet::ShowStyle() {
  fprintf(stderr, "%s\n", AsText().c_str());
}
#endif

bool CSSPropertyValueSet::PropertyMatches(CSSPropertyID property_id, const CSSValue& property_value) const {
  int found_property_index = FindPropertyIndex(property_id);
  if (found_property_index == -1) {
    return false;
  }
  return *(*PropertyAt(found_property_index).Value()) == property_value;
}

void CSSPropertyValueSet::Trace(webf::GCVisitor*) const {}

void CSSLazyPropertyParser::Trace(webf::GCVisitor*) const {}

ImmutableCSSPropertyValueSet::ImmutableCSSPropertyValueSet(const CSSPropertyValue* properties,
                                                           unsigned length,
                                                           CSSParserMode css_parser_mode,
                                                           bool contains_query_hand)
    : CSSPropertyValueSet(css_parser_mode, length, contains_query_hand) {
  auto* metadata_array = const_cast<CSSPropertyValueMetadata*>(MetadataArray());
  auto* value_array = const_cast<std::shared_ptr<const CSSValue>*>(ValueArray());
  for (unsigned i = 0; i < array_size_; ++i) {
    new (metadata_array + i) CSSPropertyValueMetadata();
    metadata_array[i] = properties[i].Metadata();
    value_array[i] = *properties[i].Value();
  }
}

std::shared_ptr<const ImmutableCSSPropertyValueSet> ImmutableCSSPropertyValueSet::Create(
    const CSSPropertyValue* properties,
    unsigned count,
    CSSParserMode css_parser_mode,
    bool contains_cursor_hand) {
  assert(count < static_cast<unsigned>(kMaxArraySize));
  return std::make_shared<ImmutableCSSPropertyValueSet>(properties, count, css_parser_mode, contains_cursor_hand);
}

// Convert property into an uint16_t for comparison with metadata's property id
// to avoid the compiler converting it to an int multiple times in a loop.
static uint16_t GetConvertedCSSPropertyID(CSSPropertyID property_id) {
  return static_cast<uint16_t>(property_id);
}

static uint16_t GetConvertedCSSPropertyID(const AtomicString&) {
  return static_cast<uint16_t>(CSSPropertyID::kVariable);
}

// static uint16_t GetConvertedCSSPropertyID(AtRuleDescriptorID descriptor_id) {
//   return static_cast<uint16_t>(
//       AtRuleDescriptorIDAsCSSPropertyID(descriptor_id));
// }

static bool IsPropertyMatch(const CSSPropertyValueMetadata& metadata, uint16_t id, CSSPropertyID property_id) {
  DCHECK_EQ(id, static_cast<uint16_t>(property_id));
  bool result = static_cast<uint16_t>(metadata.PropertyID()) == id;
// Only enabled properties except kInternalFontSizeDelta should be part of the
// style.
// TODO(hjkim3323@gmail.com): Remove kInternalFontSizeDelta bypassing hack
#if DCHECK_IS_ON()
  DCHECK(!result || property_id == CSSPropertyID::kInternalFontSizeDelta ||
         CSSProperty::Get(ResolveCSSPropertyID(property_id)).IsWebExposed());
#endif
  return result;
}

static bool IsPropertyMatch(const CSSPropertyValueMetadata& metadata,
                            uint16_t id,
                            const std::string& custom_property_name) {
  DCHECK_EQ(id, static_cast<uint16_t>(CSSPropertyID::kVariable));
  return metadata.Name() == CSSPropertyName(custom_property_name);
}

// static bool IsPropertyMatch(const CSSPropertyValueMetadata& metadata,
//                             uint16_t id,
//                             AtRuleDescriptorID descriptor_id) {
//   return IsPropertyMatch(metadata, id,
//                          AtRuleDescriptorIDAsCSSPropertyID(descriptor_id));
// }

template <typename T>
int ImmutableCSSPropertyValueSet::FindPropertyIndex(const T& property) const {
  uint16_t id = GetConvertedCSSPropertyID(property);
  for (int n = array_size_ - 1; n >= 0; --n) {
    if (IsPropertyMatch(MetadataArray()[n], id, property)) {
      return n;
    }
  }

  return -1;
}

template int ImmutableCSSPropertyValueSet::FindPropertyIndex(const CSSPropertyID&) const;
template int ImmutableCSSPropertyValueSet::FindPropertyIndex(const std::string&) const;
// template int ImmutableCSSPropertyValueSet::FindPropertyIndex(
//     const AtRuleDescriptorID&) const;

MutableCSSPropertyValueSet::MutableCSSPropertyValueSet(CSSParserMode css_parser_mode)
    : CSSPropertyValueSet(css_parser_mode) {}

MutableCSSPropertyValueSet::MutableCSSPropertyValueSet(const CSSPropertyValue* properties, unsigned length)
    : CSSPropertyValueSet(kHTMLStandardMode) {
  property_vector_.reserve(length);
  for (unsigned i = 0; i < length; ++i) {
    property_vector_.emplace_back(properties[i]);
    may_have_logical_properties_ |= kLogicalGroupProperties.Has(properties[i].Id());
  }
}

MutableCSSPropertyValueSet::MutableCSSPropertyValueSet(const CSSPropertyValueSet& other)
    : CSSPropertyValueSet(other.CssParserMode()) {
  if (auto* other_mutable_property_set = DynamicTo<MutableCSSPropertyValueSet>(other)) {
    property_vector_ = other_mutable_property_set->property_vector_;
    may_have_logical_properties_ = other_mutable_property_set->may_have_logical_properties_;
  } else {
    property_vector_.reserve(other.PropertyCount());
    for (unsigned i = 0; i < other.PropertyCount(); ++i) {
      PropertyReference property = other.PropertyAt(i);
      property_vector_.emplace_back(CSSPropertyValue(property.PropertyMetadata(), *property.Value()));
      may_have_logical_properties_ |= kLogicalGroupProperties.Has(property.Id());
    }
  }
}

MutableCSSPropertyValueSet::SetResult MutableCSSPropertyValueSet::AddParsedProperties(
    const std::vector<CSSPropertyValue>& properties) {
  SetResult changed = kUnchanged;
  property_vector_.reserve(property_vector_.size() + properties.size());
  for (unsigned i = 0; i < properties.size(); ++i) {
    changed = std::max(changed, SetLonghandProperty(properties[i]));
  }
  return changed;
}

bool MutableCSSPropertyValueSet::AddRespectingCascade(const CSSPropertyValue& property) {
  // Only add properties that have no !important counterpart present
  if (!PropertyIsImportant(property.Id()) || property.IsImportant()) {
    return SetLonghandProperty(property);
  }
  return false;
}

void MutableCSSPropertyValueSet::SetProperty(CSSPropertyID property_id,
                                             std::shared_ptr<const CSSValue> value,
                                             bool important) {
  DCHECK_NE(property_id, CSSPropertyID::kVariable);
  DCHECK_NE(property_id, CSSPropertyID::kWhiteSpace);
  StylePropertyShorthand shorthand = shorthandForProperty(property_id);
  if (!shorthand.length()) {
    SetLonghandProperty(CSSPropertyValue(CSSPropertyName(property_id), std::move(value), important));
    return;
  }

  RemovePropertiesInSet(shorthand.properties());

  // The simple shorthand expansion below doesn't work for `white-space`.
  DCHECK_NE(property_id, CSSPropertyID::kWhiteSpace);
  for (int i = 0; i < shorthand.length(); i++) {
    const CSSProperty* longhand = shorthand.properties()[i];
    CSSPropertyName longhand_name(longhand->PropertyID());
    property_vector_.emplace_back(CSSPropertyValue(longhand_name, std::move(value), important));
  }
}
void MutableCSSPropertyValueSet::SetProperty(const CSSPropertyName& name,
                                             std::shared_ptr<const CSSValue> value,
                                             bool important) {
  if (name.Id() == CSSPropertyID::kVariable) {
    SetLonghandProperty(CSSPropertyValue(name, value, important));
  } else {
    SetProperty(name.Id(), value, important);
  }
}

MutableCSSPropertyValueSet::SetResult MutableCSSPropertyValueSet::ParseAndSetProperty(
    CSSPropertyID unresolved_property,
    const std::string& value,
    bool important,
    StyleSheetContents* context_style_sheet) {
  DCHECK_GE(unresolved_property, kFirstCSSProperty);

  // Setting the value to an empty string just removes the property in both IE
  // and Gecko. Setting it to null seems to produce less consistent results, but
  // we treat it just the same.
  if (value.empty()) {
    return RemoveProperty(ResolveCSSPropertyID(unresolved_property)) ? kChangedPropertySet : kUnchanged;
  }

  // When replacing an existing property value, this moves the property to the
  // end of the list. Firefox preserves the position, and MSIE moves the
  // property to the beginning.
  return CSSParser::ParseValue(this, unresolved_property, value, important, context_style_sheet);
}

MutableCSSPropertyValueSet::SetResult MutableCSSPropertyValueSet::ParseAndSetCustomProperty(
    const std::string& custom_property_name,
    const std::string& value,
    bool important,
    StyleSheetContents* context_style_sheet,
    bool is_animation_tainted) {
  if (value.empty()) {
    return RemoveProperty(custom_property_name) ? kChangedPropertySet : kUnchanged;
  }
  return CSSParser::ParseValueForCustomProperty(this, custom_property_name, value, important, context_style_sheet,
                                                is_animation_tainted);
}

MutableCSSPropertyValueSet::SetResult MutableCSSPropertyValueSet::SetLonghandProperty(CSSPropertyValue property) {
  const CSSPropertyID id = property.Id();
  DCHECK_EQ(shorthandForProperty(id).length(), 0u);
  CSSPropertyValue* to_replace;
  if (id == CSSPropertyID::kVariable) {
    to_replace = const_cast<CSSPropertyValue*>(FindPropertyPointer(property.Name()));
  } else {
    to_replace = FindInsertionPointForID(id);
  }
  if (to_replace) {
    if (*to_replace == property) {
      return kUnchanged;
    }
    *to_replace = std::move(property);
    return kModifiedExisting;
  } else {
    may_have_logical_properties_ |= kLogicalGroupProperties.Has(id);
  }
  property_vector_.push_back(std::move(property));
  return kChangedPropertySet;
}

void MutableCSSPropertyValueSet::SetLonghandProperty(CSSPropertyID property_id, std::shared_ptr<const CSSValue> value) {
  DCHECK_EQ(shorthandForProperty(property_id).length(), 0u);
  CSSPropertyValue* to_replace = FindInsertionPointForID(property_id);
  if (to_replace) {
    *to_replace = CSSPropertyValue(CSSPropertyName(property_id), value);
  } else {
    may_have_logical_properties_ |= kLogicalGroupProperties.Has(property_id);
    property_vector_.emplace_back(CSSPropertyName(property_id), value);
  }
}

MutableCSSPropertyValueSet::SetResult MutableCSSPropertyValueSet::SetLonghandProperty(CSSPropertyID property_id,
                                                                                      CSSValueID identifier,
                                                                                      bool important) {
  CSSPropertyName name(property_id);
  return SetLonghandProperty(CSSPropertyValue(name, CSSIdentifierValue::Create(identifier), important));
}

template <typename T>
bool MutableCSSPropertyValueSet::RemoveProperty(const T& property, std::string* return_text) {
  if (RemoveShorthandProperty(property)) {
    if (return_text) {
      *return_text = "";
    }
    return true;
  }

  int found_property_index = FindPropertyIndex(property);
  return RemovePropertyAtIndex(found_property_index, return_text);
}

inline bool ContainsId(const std::span<const CSSProperty* const>& set, CSSPropertyID id) {
  for (const CSSProperty* const property : set) {
    if (property->IDEquals(id)) {
      return true;
    }
  }
  return false;
}

bool MutableCSSPropertyValueSet::RemovePropertiesInSet(std::span<const CSSProperty* const> set) {
  if (property_vector_.empty()) {
    return false;
  }

  CSSPropertyValue* properties = property_vector_.data();
  unsigned old_size = property_vector_.size();
  unsigned new_index = 0;
  for (unsigned old_index = 0; old_index < old_size; ++old_index) {
    const CSSPropertyValue& property = properties[old_index];
    if (ContainsId(set, property.Id())) {
      continue;
    }
    // Modify property_vector_ in-place since this method is
    // performance-sensitive.
    properties[new_index++] = properties[old_index];
  }
  if (new_index != old_size) {
    property_vector_.reserve(new_index);
    return true;
  }
  return false;
}

}  // namespace webf
