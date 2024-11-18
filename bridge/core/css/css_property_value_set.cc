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
#include "core/base/memory/shared_ptr.h"
#include "core/css/css_identifier_value.h"
#include "core/css/css_markup.h"
#include "core/css/parser/css_parser.h"
#include "core/css/properties/css_property.h"
#include "core/css/property_set_css_style_declaration.h"
#include "core/css/style_property_serializer.h"
#include "core/css/style_sheet_contents.h"
#include "foundation/macros.h"
#include "property_bitsets.h"
#include "style_property_shorthand.h"

namespace webf {

template <typename T>
const std::shared_ptr<const CSSValue>* CSSPropertyValueSet::GetPropertyCSSValue(const T& property) const {
  int found_property_index = FindPropertyIndex(property);
  if (found_property_index == -1) {
    return nullptr;
  }
  return PropertyAt(found_property_index).Value();
}

static std::string SerializeShorthand(std::shared_ptr<const CSSPropertyValueSet> property_set,
                                      CSSPropertyID property_id) {
  StylePropertyShorthand shorthand = shorthandForProperty(property_id);
  if (shorthand.length() == 0) {
    return "";
  }

  return StylePropertySerializer(property_set).SerializeShorthand(property_id);
}

static std::string SerializeShorthand(std::shared_ptr<const CSSPropertyValueSet> property_set,
                                 const AtomicString& custom_property_name) {
  // Custom properties are never shorthands.
  return "";
}

template <typename T>
std::string CSSPropertyValueSet::GetPropertyValue(const T& property) const {
  std::string shorthand_serialization = SerializeShorthand(shared_from_this(), property);
  if (!shorthand_serialization.empty()) {
    return shorthand_serialization;
  }
  const std::shared_ptr<const CSSValue>* value = GetPropertyCSSValue(property);
  if (value) {
    return value->get()->CssText();
  }
  return "";
}
template std::string CSSPropertyValueSet::GetPropertyValue<CSSPropertyID>(const CSSPropertyID&) const;
template std::string CSSPropertyValueSet::GetPropertyValue<AtomicString>(const AtomicString&) const;

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
template bool CSSPropertyValueSet::PropertyIsImportant<AtomicString>(const AtomicString&) const;

const std::shared_ptr<const CSSValue>* CSSPropertyValueSet::GetPropertyCSSValueWithHint(
    const AtomicString& property_name,
    unsigned index) const {
  assert(property_name == PropertyAt(index).Name().ToAtomicString());
  return PropertyAt(index).Value();
}

std::string CSSPropertyValueSet::GetPropertyValueWithHint(const AtomicString& property_name, unsigned int index) const {
  auto value = GetPropertyCSSValueWithHint(property_name, index);
  if (value) {
    return value->get()->CssText();
  }
  return "";
}

bool CSSPropertyValueSet::PropertyIsImportantWithHint(const AtomicString& property_name, unsigned int index) const {
  assert(property_name == PropertyAt(index).Name().ToAtomicString());
  return PropertyAt(index).IsImportant();
}

bool CSSPropertyValueSet::ShorthandIsImportant(CSSPropertyID property_id) const {
  StylePropertyShorthand shorthand = shorthandForProperty(property_id);
  const StylePropertyShorthand::Properties longhands = shorthand.properties();
  if (shorthand.length() == 0) {
    return false;
  }

  for (int i = 0; i < shorthand.length(); i++) {
    if (!PropertyIsImportant(longhands[i]->PropertyID())) {
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
    return reinterpret_pointer_cast<const ImmutableCSSPropertyValueSet>(shared_from_this());
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
  return StylePropertySerializer(shared_from_this()).AsText();
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
  auto* value_array = (const_cast<std::shared_ptr<const CSSValue>*>(ValueArray()));

  for (unsigned i = 0; i < array_size_; ++i) {
    new (metadata_array + i) CSSPropertyValueMetadata();
    metadata_array[i] = properties[i].Metadata();
    value_array[i] = *properties[i].Value();
  }
}

std::shared_ptr<ImmutableCSSPropertyValueSet> ImmutableCSSPropertyValueSet::Create(const CSSPropertyValue* properties,
                                                                                   unsigned count,
                                                                                   CSSParserMode css_parser_mode,
                                                                                   bool contains_cursor_hand) {
  assert(count < static_cast<unsigned>(kMaxArraySize));
  size_t addition_bytes =
      base::bits::AlignUp(sizeof(std::shared_ptr<CSSValue>) * count, alignof(CSSPropertyValueMetadata)) +
      sizeof(CSSPropertyValueMetadata) * count;
  return MakeSharedPtrWithAdditionalBytes<ImmutableCSSPropertyValueSet>(addition_bytes, properties, count,
                                                                        css_parser_mode, contains_cursor_hand);
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
  DCHECK(!result || CSSProperty::Get(ResolveCSSPropertyID(property_id)).IsWebExposed());
#endif
  return result;
}

static bool IsPropertyMatch(const CSSPropertyValueMetadata& metadata,
                            uint16_t id,
                            const AtomicString& custom_property_name) {
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
template int ImmutableCSSPropertyValueSet::FindPropertyIndex(const AtomicString&) const;
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
  if (shorthand.length() == 0) {
    SetLonghandProperty(CSSPropertyValue(CSSPropertyName(property_id), std::move(value), important));
    return;
  }

  RemovePropertiesInSet(shorthand.properties(), shorthand.length());

  // The simple shorthand expansion below doesn't work for `white-space`.
  DCHECK_NE(property_id, CSSPropertyID::kWhiteSpace);
  for (int i = 0; i < shorthand.length(); i++) {
    CSSPropertyName longhand_name(shorthand.properties()[i]->PropertyID());
    property_vector_.emplace_back(CSSPropertyValue(longhand_name, value, important));
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
    std::shared_ptr<StyleSheetContents> context_style_sheet) {
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
    const AtomicString& custom_property_name,
    const std::string& value,
    bool important,
    std::shared_ptr<StyleSheetContents> context_style_sheet,
    bool is_animation_tainted) {
  if (value.empty()) {
    return RemoveProperty(custom_property_name) ? kChangedPropertySet : kUnchanged;
  }
  return CSSParser::ParseValueForCustomProperty(this, custom_property_name.ToStdString(), value, important, context_style_sheet,
                                                is_animation_tainted);
}

MutableCSSPropertyValueSet::SetResult MutableCSSPropertyValueSet::SetLonghandProperty(CSSPropertyValue property) {
  const CSSPropertyID id = property.Id();
  DCHECK_EQ(shorthandForProperty(id).length(), 0u);
  CSSPropertyValue* to_replace;
  if (id == CSSPropertyID::kVariable) {
    to_replace = const_cast<CSSPropertyValue*>(FindPropertyPointer(property.Name().ToAtomicString()));
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
template bool MutableCSSPropertyValueSet::RemoveProperty(
    const CSSPropertyID&,
    std::string*);
template bool MutableCSSPropertyValueSet::RemoveProperty(
    const AtomicString&,
    std::string*);


inline bool ContainsId(const CSSProperty* const set[], unsigned length, CSSPropertyID id) {
  for (unsigned i = 0; i < length; ++i) {
    if (set[i]->IDEquals(id))
      return true;
  }
  return false;
}

bool MutableCSSPropertyValueSet::RemovePropertiesInSet(const CSSProperty* const set[], unsigned length) {
  if (property_vector_.empty())
    return false;

  CSSPropertyValue* properties = property_vector_.data();
  unsigned old_size = property_vector_.size();
  unsigned new_index = 0;
  for (unsigned old_index = 0; old_index < old_size; ++old_index) {
    const CSSPropertyValue& property = properties[old_index];
    if (ContainsId(set, length, property.Id()))
      continue;
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

void MutableCSSPropertyValueSet::RemoveEquivalentProperties(const CSSPropertyValueSet* style) {
  std::vector<CSSPropertyID> properties_to_remove;
  unsigned size = property_vector_.size();
  for (unsigned i = 0; i < size; ++i) {
    PropertyReference property = PropertyAt(i);
    if (style->PropertyMatches(property.Id(), *property.Value()->get())) {
      properties_to_remove.push_back(property.Id());
    }
  }
  // FIXME: This should use mass removal.
  for (unsigned i = 0; i < properties_to_remove.size(); ++i) {
    RemoveProperty(properties_to_remove[i]);
  }
}

void MutableCSSPropertyValueSet::RemoveEquivalentProperties(const CSSStyleDeclaration* style) {
  std::vector<CSSPropertyID> properties_to_remove;
  unsigned size = property_vector_.size();
  for (unsigned i = 0; i < size; ++i) {
    PropertyReference property = PropertyAt(i);
    if (style->CssPropertyMatches(property.Id(), *property.Value()->get())) {
      properties_to_remove.push_back(property.Id());
    }
  }
  // FIXME: This should use mass removal.
  for (unsigned i = 0; i < properties_to_remove.size(); ++i) {
    RemoveProperty(properties_to_remove[i]);
  }
}

void MutableCSSPropertyValueSet::MergeAndOverrideOnConflict(const CSSPropertyValueSet* other) {
  unsigned size = other->PropertyCount();
  for (unsigned n = 0; n < size; ++n) {
    PropertyReference to_merge = other->PropertyAt(n);
    SetLonghandProperty(CSSPropertyValue(to_merge.PropertyMetadata(), *to_merge.Value()));
  }
}

void MutableCSSPropertyValueSet::Clear() {
  property_vector_.clear();
  may_have_logical_properties_ = false;
}

void MutableCSSPropertyValueSet::ParseDeclarationList(const AtomicString& style_declaration,
                                                      std::shared_ptr<StyleSheetContents> context_style_sheet) {
  property_vector_.clear();

  std::shared_ptr<CSSParserContext> context;
  if (context_style_sheet) {
    context = std::make_shared<CSSParserContext>(context_style_sheet->ParserContext().get(), context_style_sheet.get());
    context->SetMode(CssParserMode());
  } else {
    context = std::make_shared<CSSParserContext>(CssParserMode());
  }

  CSSParser::ParseDeclarationList(std::move(context), this, style_declaration.ToStdString());
}

CSSStyleDeclaration* MutableCSSPropertyValueSet::EnsureCSSStyleDeclaration(ExecutingContext* execution_context) {
  // FIXME: get rid of this weirdness of a CSSStyleDeclaration inside of a
  // style property set.
  if (cssom_wrapper_) {
    //    DCHECK(
    //        !static_cast<CSSStyleDeclaration*>(cssom_wrapper_.Get())->parentRule());
    //    DCHECK(!cssom_wrapper_->ParentElement());
    return cssom_wrapper_.get();
  }
  //  new PropertySetCSSStyleDeclaration(execution_context, shared_from_this());
  //  cssom_wrapper_ = std::make_shared<PropertySetCSSStyleDeclaration>(execution_context, shared_from_this());
  return cssom_wrapper_.get();
}

template <typename T>
int MutableCSSPropertyValueSet::FindPropertyIndex(const T& property) const {
  const CSSPropertyValue* begin = property_vector_.data();
  const CSSPropertyValue* it = FindPropertyPointer(property);
  return (it == nullptr) ? -1 : static_cast<int>(it - begin);
}
template int MutableCSSPropertyValueSet::FindPropertyIndex(const CSSPropertyID&) const;
template int MutableCSSPropertyValueSet::FindPropertyIndex(const AtomicString&) const;

void MutableCSSPropertyValueSet::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSPropertyValueSet::TraceAfterDispatch(visitor);
}

template <typename T>
const CSSPropertyValue* MutableCSSPropertyValueSet::FindPropertyPointer(const T& property) const {
  const CSSPropertyValue* begin = property_vector_.data();
  const CSSPropertyValue* end = begin + property_vector_.size();

  uint16_t id = GetConvertedCSSPropertyID(property);

  const CSSPropertyValue* it = std::find_if(begin, end, [property, id](const CSSPropertyValue& css_property) -> bool {
    return IsPropertyMatch(css_property.Metadata(), id, property);
  });
  return (it == end) ? nullptr : it;
}

ALWAYS_INLINE CSSPropertyValue* MutableCSSPropertyValueSet::FindInsertionPointForID(CSSPropertyID property_id) {
  CSSPropertyValue* to_replace = const_cast<CSSPropertyValue*>(FindPropertyPointer(property_id));
  if (to_replace == nullptr) {
    return nullptr;
  }
  if (may_have_logical_properties_) {
    const CSSProperty& prop = CSSProperty::Get(property_id);
    if (prop.IsInLogicalPropertyGroup()) {
      DCHECK(std::count(property_vector_.begin(), property_vector_.end(), *to_replace) > 0);
      int to_replace_index = static_cast<int>(to_replace - property_vector_.data());
      for (size_t n = property_vector_.size() - 1; n > to_replace_index; --n) {
        if (prop.IsInSameLogicalPropertyGroupWithDifferentMappingLogic(PropertyAt(n).Id())) {
          RemovePropertyAtIndex(to_replace_index, nullptr);
          return nullptr;
        }
      }
    }
  }
  return to_replace;
}

bool MutableCSSPropertyValueSet::RemovePropertyAtIndex(int property_index, std::string* return_text) {
  if (property_index == -1) {
    if (return_text) {
      *return_text = "";
    }
    return false;
  }

  if (return_text) {
    *return_text = PropertyAt(property_index).Value()->get()->CssText();
  }

  // A more efficient removal strategy would involve marking entries as empty
  // and sweeping them when the vector grows too big.
  property_vector_.erase(property_vector_.begin() + property_index);

  return true;
}

bool MutableCSSPropertyValueSet::RemoveShorthandProperty(CSSPropertyID property_id) {
  StylePropertyShorthand shorthand = shorthandForProperty(property_id);
  if (shorthand.length() == 0) {
    return false;
  }

  return RemovePropertiesInSet(shorthand.properties(), shorthand.length());
}

CSSPropertyValue* MutableCSSPropertyValueSet::FindCSSPropertyWithName(const CSSPropertyName& name) {
  return const_cast<CSSPropertyValue*>(name.IsCustomProperty() ? FindPropertyPointer(name.ToAtomicString())
                                                               : FindPropertyPointer(name.Id()));
}

}  // namespace webf
