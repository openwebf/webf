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
#include "core/css/css_markup.h"
#include "core/css/style_property_serializer.h"
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

const std::shared_ptr<const CSSValue>* CSSPropertyValueSet::GetPropertyCSSValueWithHint(const std::string& property_name,
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

}  // namespace webf
