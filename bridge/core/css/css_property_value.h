/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006 Apple Computer, Inc.
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

#ifndef WEBF_CSS_PROPERTY_VALUE_H
#define WEBF_CSS_PROPERTY_VALUE_H

#include <utility>

#include "foundation/macros.h"
#include "core/css/css_property_name.h"
#include "core/css/css_property_names.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/css/css_value.h"

namespace webf {

//class CSSValue; // TODO(xiezuobing): core/css/css_value.h

struct CSSPropertyValueMetadata {
  WEBF_DISALLOW_NEW();
 public:
  CSSPropertyValueMetadata() = default;

  CSSPropertyValueMetadata(const CSSPropertyName&,
                           bool is_set_from_shorthand,
                           int index_in_shorthands_vector,
                           bool important,
                           bool implicit);

  CSSPropertyID ShorthandID() const;
  CSSPropertyID PropertyID() const {
    return ConvertToCSSPropertyID(property_id_);
  }

  CSSPropertyName Name() const;

  AtomicString custom_name_;
  unsigned property_id_ : kCSSPropertyIDBitLength;
  unsigned is_set_from_shorthand_ : 1;
  // If this property was set as part of an ambiguous shorthand, gives the index
  // in the shorthands vector.
  unsigned index_in_shorthands_vector_ : 2;
  unsigned important_ : 1;
  // Whether or not the property was set implicitly as the result of a
  // shorthand.
  unsigned implicit_ : 1;
};

class CSSPropertyValue {
  WEBF_DISALLOW_NEW();

 public:
  CSSPropertyValue(const CSSPropertyName& name,
                   std::shared_ptr<const CSSValue> value,
                   bool important = false,
                   bool is_set_from_shorthand = false,
                   int index_in_shorthands_vector = 0,
                   bool implicit = false)
      : metadata_(name,
                  is_set_from_shorthand,
                  index_in_shorthands_vector,
                  important,
                  implicit),
        value_(std::move(value)) {}

  CSSPropertyValue(const CSSPropertyValue& other)
      : metadata_(other.metadata_),
        value_(other.value_) {}
  CSSPropertyValue& operator=(const CSSPropertyValue& other) = default;

  // FIXME: Remove this.
  CSSPropertyValue(CSSPropertyValueMetadata metadata, std::shared_ptr<const CSSValue> value)
      : metadata_(std::move(metadata)),
        value_(std::move(value)) {}

  CSSPropertyID Id() const { return metadata_.PropertyID(); }
  const AtomicString& CustomPropertyName() const {
    assert(Id() == CSSPropertyID::kVariable);
    return metadata_.custom_name_;
  }
  bool IsSetFromShorthand() const { return metadata_.is_set_from_shorthand_; }
  CSSPropertyID ShorthandID() const { return metadata_.ShorthandID(); }
  bool IsImportant() const { return metadata_.important_; }
  void SetImportant() { metadata_.important_ = true; }
  CSSPropertyName Name() const { return metadata_.Name(); }

  const CSSValue* Value() const { return value_.get(); }

  const CSSPropertyValueMetadata& Metadata() const { return metadata_; }

  bool operator==(const CSSPropertyValue& other) const;

  void Trace(GCVisitor* visitor) const {  }

 private:
  CSSPropertyValueMetadata metadata_;
  std::shared_ptr<const CSSValue> value_;
};

//namespace {
//template <>
//struct VectorTraits<webf::CSSPropertyValue>
//    : VectorTraitsBase<webf::CSSPropertyValue> {
//  static const bool kCanInitializeWithMemset = true;
//  static const bool kCanClearUnusedSlotsWithMemset = true;
//  static const bool kCanMoveWithMemcpy = true;
//  static const bool kCanTraceConcurrently = true;
//};

}  // namespace webf

#endif  // WEBF_CSS_PROPERTY_VALUE_H