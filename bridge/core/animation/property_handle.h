// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_ANIMATION_PROPERTY_HANDLE_H_
#define WEBF_CORE_ANIMATION_PROPERTY_HANDLE_H_

#include "core/css/css_property_name.h"
#include "css_property_instance.h"
#include "core/css/properties/css_property.h"
#include "core/dom/qualified_name.h"
#include "core/base/memory/stack_allocated.h"
#include "core/platform/hash_traits.h"

namespace webf {

// Represents the property of a PropertySpecificKeyframe.
class PropertyHandle {
  WEBF_DISALLOW_NEW();

 public:
  explicit PropertyHandle(const CSSProperty& property,
                          bool is_presentation_attribute = false)
      : handle_type_(is_presentation_attribute ? kHandlePresentationAttribute
                                               : kHandleCSSProperty),
        css_property_(&property) {
    assert(CSSPropertyID::kVariable != property.PropertyID());
  }

  // TODO(crbug.com/980160): Eliminate call to GetCSSPropertyVariable().
  explicit PropertyHandle(const AtomicString& property_name)
      : handle_type_(kHandleCSSCustomProperty),
        css_property_(&GetCSSPropertyVariable()),
        property_name_(property_name) {}

  // TODO(crbug.com/980160): Eliminate call to GetCSSPropertyVariable().
  explicit PropertyHandle(const CSSPropertyName& property_name)
      : handle_type_(property_name.IsCustomProperty() ? kHandleCSSCustomProperty
                                                      : kHandleCSSProperty),
        css_property_(property_name.IsCustomProperty()
                          ? &GetCSSPropertyVariable()
                          : &CSSProperty::Get(property_name.Id())),
        property_name_(property_name.IsCustomProperty()
                           ? property_name.ToString()
                           : AtomicString::Null()) {}

  explicit PropertyHandle(const QualifiedName& attribute_name)
      : handle_type_(kHandleSVGAttribute), svg_attribute_(&attribute_name) {}

  bool operator==(const PropertyHandle&) const;
  bool operator!=(const PropertyHandle& other) const {
    return !(*this == other);
  }

  unsigned GetHash() const;

  bool IsCSSProperty() const {
    return handle_type_ == kHandleCSSProperty || IsCSSCustomProperty();
  }
  const CSSProperty& GetCSSProperty() const {
    assert(IsCSSProperty());
    return *css_property_;
  }

  bool IsCSSCustomProperty() const {
    return handle_type_ == kHandleCSSCustomProperty;
  }
  const AtomicString& CustomPropertyName() const {
    assert(IsCSSCustomProperty());
    return property_name_;
  }

  bool IsPresentationAttribute() const {
    return handle_type_ == kHandlePresentationAttribute;
  }
  const CSSProperty& PresentationAttribute() const {
    assert(IsPresentationAttribute());
    return *css_property_;
  }

  bool IsSVGAttribute() const { return handle_type_ == kHandleSVGAttribute; }
  const QualifiedName& SvgAttribute() const {
    assert(IsSVGAttribute());
    return *svg_attribute_;
  }

  CSSPropertyName GetCSSPropertyName() const {
    if (handle_type_ == kHandleCSSCustomProperty)
      return CSSPropertyName(property_name_);
    assert(IsCSSProperty() || IsPresentationAttribute());
    return CSSPropertyName(css_property_->PropertyID());
  }

  // 显式默认析构函数
  //~PropertyHandle() = delete;

 private:
  enum HandleType {
    kHandleEmptyValueForHashTraits,
    kHandleDeletedValueForHashTraits,
    kHandleCSSProperty,
    kHandleCSSCustomProperty,
    kHandlePresentationAttribute,
    kHandleSVGAttribute,
  };

  explicit PropertyHandle(HandleType handle_type)
      : handle_type_(handle_type), svg_attribute_(nullptr) {}

  static PropertyHandle EmptyValueForHashTraits() {
    return PropertyHandle(kHandleEmptyValueForHashTraits);
  }

  static PropertyHandle DeletedValueForHashTraits() {
    return PropertyHandle(kHandleDeletedValueForHashTraits);
  }

  bool IsDeletedValueForHashTraits() const {
    return handle_type_ == kHandleDeletedValueForHashTraits;
  }

  HandleType handle_type_;
  union {
    std::shared_ptr<const CSSProperty> css_property_;
    std::shared_ptr<const QualifiedName> svg_attribute_;
  };
  AtomicString property_name_;

  friend struct ::WTF::HashTraits<webf::PropertyHandle>;
};

}  // namespace webf

namespace WTF {

template <>
struct HashTraits<webf::PropertyHandle>
    : SimpleClassHashTraits<webf::PropertyHandle> {
  static unsigned GetHash(const webf::PropertyHandle& handle) {
    return handle.GetHash();
  }

  static void ConstructDeletedValue(webf::PropertyHandle& slot) {
    new (webf::NotNullTag::kNotNull, &slot) webf::PropertyHandle(
        webf::PropertyHandle::DeletedValueForHashTraits());
  }
  static bool IsDeletedValue(const webf::PropertyHandle& value) {
    return value.IsDeletedValueForHashTraits();
  }

  static webf::PropertyHandle EmptyValue() {
    return webf::PropertyHandle::EmptyValueForHashTraits();
  }
};

}  // namespace WTF

#endif  // WEBF_CORE_ANIMATION_PROPERTY_HANDLE_H_
