/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "element_data.h"
#include "core/base/memory/shared_ptr.h"
#include "core/css/css_property_value_set.h"

namespace webf {

static size_t AdditionalBytesForShareableElementDataWithAttributeCount(unsigned count) {
  return sizeof(Attribute) * count;
}

ElementData::ElementData()
    : bit_field_(IsUniqueFlag::encode(true) | ArraySize::encode(0) | PresentationAttributeStyleIsDirty::encode(false) |
                 StyleAttributeIsDirty::encode(false) | SvgAttributesAreDirty::encode(false)) {}

ElementData::ElementData(unsigned array_size)
    : bit_field_(IsUniqueFlag::encode(false) | ArraySize::encode(array_size) |
                 PresentationAttributeStyleIsDirty::encode(false) | StyleAttributeIsDirty::encode(false) |
                 SvgAttributesAreDirty::encode(false)) {}

ElementData::ElementData(const ElementData& other, bool is_unique)
    : bit_field_(IsUniqueFlag::encode(is_unique) | ArraySize::encode(is_unique ? 0 : other.Attributes().size()) |
                 PresentationAttributeStyleIsDirty::encode(other.bit_field_.get<PresentationAttributeStyleIsDirty>()) |
                 StyleAttributeIsDirty::encode(other.bit_field_.get<StyleAttributeIsDirty>()) |
                 SvgAttributesAreDirty::encode(other.bit_field_.get<SvgAttributesAreDirty>())),
      class_names_(other.class_names_),
      id_for_style_resolution_(other.id_for_style_resolution_) {
  // NOTE: The inline style is copied by the subclass copy constructor since we
  // don't know what to do with it here.
}

std::unique_ptr<UniqueElementData> ElementData::MakeUniqueCopy() const {
  if (auto* unique_element_data = DynamicTo<UniqueElementData>(this))
    return std::make_unique<UniqueElementData>(*unique_element_data);
  return std::make_unique<UniqueElementData>(To<ShareableElementData>(*this));
}

bool ElementData::IsEquivalent(const ElementData* other) const {
  AttributeCollection attributes = Attributes();
  if (!other)
    return attributes.IsEmpty();

  AttributeCollection other_attributes = other->Attributes();
  if (attributes.size() != other_attributes.size())
    return false;

  for (const Attribute& attribute : attributes) {
    const Attribute* other_attr = other_attributes.Find(attribute.GetName());
    if (!other_attr || attribute.Value() != other_attr->Value())
      return false;
  }
  return true;
}

void ElementData::Trace(GCVisitor* visitor) const {
  if (bit_field_.get_concurrently<IsUniqueFlag>()) {
    static_cast<const UniqueElementData*>(this)->TraceAfterDispatch(visitor);
  } else {
    static_cast<const ShareableElementData*>(this)->TraceAfterDispatch(visitor);
  }
}

void ElementData::TraceAfterDispatch(GCVisitor* visitor) const {}

ShareableElementData::ShareableElementData(const std::vector<Attribute>& attributes) : ElementData(attributes.size()) {
  for (unsigned i = 0; i < bit_field_.get<ArraySize>(); ++i)
    new (&attribute_array_[i]) Attribute(attributes[i]);
}

ShareableElementData::~ShareableElementData() {
  for (unsigned i = 0; i < bit_field_.get<ArraySize>(); ++i)
    attribute_array_[i].~Attribute();
}

ShareableElementData::ShareableElementData(const UniqueElementData& other) : ElementData(other, false) {
  DCHECK(!other.presentation_attribute_style_);

  if (other.inline_style_) {
    inline_style_ = other.inline_style_->ImmutableCopyIfNeeded();
  }

  for (unsigned i = 0; i < bit_field_.get<ArraySize>(); ++i)
    new (&attribute_array_[i]) Attribute(other.attribute_vector_.at(i));
}

std::shared_ptr<ShareableElementData> ShareableElementData::CreateWithAttributes(
    const std::vector<Attribute>& attributes) {
  return MakeSharedPtrWithAdditionalBytes<ShareableElementData>(
      AdditionalBytesForShareableElementDataWithAttributeCount(attributes.size()), attributes);
}

UniqueElementData::UniqueElementData() = default;

UniqueElementData::UniqueElementData(const UniqueElementData& other)
    : ElementData(other, true),
      presentation_attribute_style_(other.presentation_attribute_style_),
      attribute_vector_(other.attribute_vector_) {
  inline_style_ = other.inline_style_ ? other.inline_style_->MutableCopy() : nullptr;
}

UniqueElementData::UniqueElementData(const ShareableElementData& other) : ElementData(other, true) {
  // An ShareableElementData should never have a mutable inline
  // CSSPropertyValueSet attached.
  DCHECK(!other.inline_style_ || !other.inline_style_->IsMutable());
  inline_style_ = other.inline_style_;

  unsigned length = other.Attributes().size();
  attribute_vector_.reserve(length);
  for (unsigned i = 0; i < length; ++i)
    attribute_vector_.push_back(other.attribute_array_[i]);
}

std::shared_ptr<ShareableElementData> UniqueElementData::MakeShareableCopy() const {
  return MakeSharedPtrWithAdditionalBytes<ShareableElementData>(
      AdditionalBytesForShareableElementDataWithAttributeCount(attribute_vector_.size()), *this);
}

void UniqueElementData::TraceAfterDispatch(GCVisitor* visitor) const {
  ElementData::TraceAfterDispatch(visitor);
}

}  // namespace webf