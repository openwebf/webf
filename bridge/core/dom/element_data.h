/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_ELEMENT_DATA_H_
#define WEBF_CORE_DOM_ELEMENT_DATA_H_

#include <core/base/bit_field.h>
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "bindings/qjs/cppgc/member.h"
#include "core/base/strings/string_util.h"
#include "core/dom/attribute_collection.h"
#include "dom_string_map.h"
#include "dom_token_list.h"
#include "foundation/ascii_types.h"

namespace webf {

class ShareableElementData;
class CSSPropertyValueSet;
class UniqueElementData;

// ElementData represents very common, but not necessarily unique to an element,
// data such as attributes, inline style, and parsed class names and ids.
class ElementData {
 public:
  ElementData();
  void ClearClass() const { class_names_.Clear(); }
  void SetClass(const AtomicString& class_names) const {
    DCHECK(!class_names.empty());
    class_names_.Set(class_names);
  }
  void SetClassFoldingCase(JSContext* ctx, const AtomicString& class_names) const {
    if (class_names.IsLowerASCII()) {
      return SetClass(class_names);
    }
    return SetClass(class_names.LowerASCII());
  }
  const SpaceSplitString& ClassNames() const { return class_names_; }

  const AtomicString& IdForStyleResolution() const { return id_for_style_resolution_; }
  AtomicString SetIdForStyleResolution(AtomicString new_id) const {
    return std::exchange(id_for_style_resolution_, std::move(new_id));
  }

  const CSSPropertyValueSet* InlineStyle() const { return inline_style_.get(); }

  const CSSPropertyValueSet* PresentationAttributeStyle() const;

  AttributeCollection Attributes() const;

  bool HasID() const { return !id_for_style_resolution_.IsNull(); }
  bool HasClass() const { return !class_names_.IsNull(); }

  bool IsEquivalent(const ElementData* other) const;

  bool IsUnique() const { return bit_field_.get<IsUniqueFlag>(); }

  void TraceAfterDispatch(GCVisitor*) const;
  void Trace(GCVisitor*) const;

 protected:
  using BitField = ConcurrentlyReadBitField<uint32_t>;
  using IsUniqueFlag = BitField::DefineFirstValue<bool, 1, BitFieldValueConstness::kConst>;
  using ArraySize = IsUniqueFlag::DefineNextValue<uint32_t, 28, BitFieldValueConstness::kConst>;
  using PresentationAttributeStyleIsDirty = ArraySize::DefineNextValue<bool, 1>;
  using StyleAttributeIsDirty = PresentationAttributeStyleIsDirty::DefineNextValue<bool, 1>;
  using SvgAttributesAreDirty = StyleAttributeIsDirty::DefineNextValue<bool, 1>;

  explicit ElementData(unsigned array_size);
  ElementData(const ElementData&, bool is_unique);

  bool presentation_attribute_style_is_dirty() const { return bit_field_.get<PresentationAttributeStyleIsDirty>(); }
  bool style_attribute_is_dirty() const { return bit_field_.get<StyleAttributeIsDirty>(); }
  bool svg_attributes_are_dirty() const { return bit_field_.get<SvgAttributesAreDirty>(); }

  // Following 3 fields are meant to be mutable and can change even when const.
  void SetPresentationAttributeStyleIsDirty(bool presentation_attribute_style_is_dirty) const {
    const_cast<BitField*>(&bit_field_)->set<PresentationAttributeStyleIsDirty>(presentation_attribute_style_is_dirty);
  }
  void SetStyleAttributeIsDirty(bool style_attribute_is_dirty) const {
    const_cast<BitField*>(&bit_field_)->set<StyleAttributeIsDirty>(style_attribute_is_dirty);
  }
  void SetSvgAttributesAreDirty(bool svg_attributes_are_dirty) const {
    const_cast<BitField*>(&bit_field_)->set<SvgAttributesAreDirty>(svg_attributes_are_dirty);
  }

  BitField bit_field_;

  mutable std::shared_ptr<const CSSPropertyValueSet> inline_style_;
  mutable SpaceSplitString class_names_;
  mutable AtomicString id_for_style_resolution_;

 private:
  friend class Element;
  friend class HTMLImageElement;
  friend class ShareableElementData;
  friend class UniqueElementData;
  friend class SVGElement;
  friend struct DowncastTraits<UniqueElementData>;
  friend struct DowncastTraits<ShareableElementData>;

  std::unique_ptr<UniqueElementData> MakeUniqueCopy() const;
};

#if defined(COMPILER_MSVC)
#pragma warning(push)
// Disable "zero-sized array in struct/union" warning
#pragma warning(disable : 4200)
#endif

// SharableElementData is managed by ElementDataCache and is produced by
// the parser during page load for elements that have identical attributes. This
// is a memory optimization since it's very common for many elements to have
// duplicate sets of attributes (ex. the same classes).
class ShareableElementData final : public ElementData {
 public:
  static std::shared_ptr<ShareableElementData> CreateWithAttributes(const std::vector<Attribute>&);

  explicit ShareableElementData(const std::vector<Attribute>&);
  explicit ShareableElementData(const UniqueElementData&);
  ~ShareableElementData();

  void TraceAfterDispatch(GCVisitor* visitor) const { ElementData::TraceAfterDispatch(visitor); }

  AttributeCollection Attributes() const;

  Attribute attribute_array_[0];
};

template <>
struct DowncastTraits<ShareableElementData> {
  static bool AllowFrom(const ElementData& data) { return !data.bit_field_.get<ElementData::IsUniqueFlag>(); }
};

#if defined(COMPILER_MSVC)
#pragma warning(pop)
#endif

// UniqueElementData is created when an element needs to mutate its attributes
// or gains presentation attribute style (ex. width="10"). It does not need to
// be created to fill in values in the ElementData that are derived from
// attributes. For example populating the inline_style_ from the style attribute
// doesn't require a UniqueElementData as all elements with the same style
// attribute will have the same inline style.
class UniqueElementData final : public ElementData {
 public:
  std::shared_ptr<ShareableElementData> MakeShareableCopy() const;

  MutableAttributeCollection Attributes();
  AttributeCollection Attributes() const;

  UniqueElementData();
  explicit UniqueElementData(const ShareableElementData&);
  explicit UniqueElementData(const UniqueElementData&);

  void TraceAfterDispatch(GCVisitor*) const;

  // FIXME: We might want to support sharing element data for elements with
  // presentation attribute style. Lots of table cells likely have the same
  // attributes. Most modern pages don't use presentation attributes though
  // so this might not make sense.
  mutable std::shared_ptr<const CSSPropertyValueSet> presentation_attribute_style_;
  AttributeVector attribute_vector_;
};

template <>
struct DowncastTraits<UniqueElementData> {
  static bool AllowFrom(const ElementData& data) { return data.bit_field_.get<ElementData::IsUniqueFlag>(); }
};

inline const CSSPropertyValueSet* ElementData::PresentationAttributeStyle() const {
  if (!bit_field_.get<IsUniqueFlag>())
    return nullptr;
  return To<UniqueElementData>(this)->presentation_attribute_style_.get();
}

inline AttributeCollection ElementData::Attributes() const {
  if (auto* unique_element_data = DynamicTo<UniqueElementData>(this))
    return unique_element_data->Attributes();
  return To<ShareableElementData>(this)->Attributes();
}

inline AttributeCollection ShareableElementData::Attributes() const {
  return AttributeCollection(attribute_array_, bit_field_.get<ArraySize>());
}

inline AttributeCollection UniqueElementData::Attributes() const {
  return AttributeCollection(attribute_vector_.data(), attribute_vector_.size());
}

inline MutableAttributeCollection UniqueElementData::Attributes() {
  return MutableAttributeCollection(attribute_vector_);
}

}  // namespace webf

#endif  // WEBF_CORE_DOM_ELEMENT_DATA_H_
