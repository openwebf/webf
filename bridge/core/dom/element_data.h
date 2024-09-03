/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_ELEMENT_DATA_H_
#define WEBF_CORE_DOM_ELEMENT_DATA_H_

#include <core/base/bit_field.h>
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "bindings/qjs/cppgc/member.h"
#include "core/dom/attribute_collection.h"
#include "dom_string_map.h"
#include "dom_token_list.h"

namespace webf {

class ShareableElementData;
class CSSPropertyValueSet;
class UniqueElementData;

class ElementData {
 public:
  void CopyWith(ElementData* other);
  void TraceAfterDispatch(GCVisitor*) const;
  void Trace(GCVisitor* visitor) const;

  DOMTokenList* GetClassList() const;
  void SetClassList(DOMTokenList* dom_token_lists);

  DOMStringMap* DataSet() const;
  void SetDataSet(DOMStringMap* data_set);

  bool style_attribute_is_dirty() const { return style_attribute_is_dirty_; }
  void SetStyleAttributeIsDirty(bool value) const { style_attribute_is_dirty_ = value; }

  AttributeCollection Attributes() const;

  bool HasID() const { return !id_for_style_resolution_.IsNull(); }
  bool HasClass() const { return !class_names_.IsNull(); }

  const SpaceSplitString& ClassNames() const { return class_names_; }

  const AtomicString& IdForStyleResolution() const { return id_for_style_resolution_; }
  AtomicString SetIdForStyleResolution(AtomicString new_id) const {
    return std::exchange(id_for_style_resolution_, std::move(new_id));
  }

  const CSSPropertyValueSet* InlineStyle() const { return inline_style_.get(); }

  const CSSPropertyValueSet* PresentationAttributeStyle() const;

  using BitField = ConcurrentlyReadBitField<uint32_t>;
  using IsUniqueFlag = BitField::DefineFirstValue<bool, 1, BitFieldValueConstness::kConst>;

  BitField bit_field_;

 protected:
  mutable std::shared_ptr<CSSPropertyValueSet> inline_style_;
  mutable SpaceSplitString class_names_;
  mutable AtomicString id_for_style_resolution_;

 private:
  Member<DOMTokenList> class_lists_;
  Member<DOMStringMap> data_set_;
  AtomicString class_;
  mutable bool style_attribute_is_dirty_;
};

// SharableElementData is managed by ElementDataCache and is produced by
// the parser during page load for elements that have identical attributes. This
// is a memory optimization since it's very common for many elements to have
// duplicate sets of attributes (ex. the same classes).
class ShareableElementData final : public ElementData {
 public:
  static ShareableElementData* CreateWithAttributes(const std::vector<Attribute>&);

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

// UniqueElementData is created when an element needs to mutate its attributes
// or gains presentation attribute style (ex. width="10"). It does not need to
// be created to fill in values in the ElementData that are derived from
// attributes. For example populating the inline_style_ from the style attribute
// doesn't require a UniqueElementData as all elements with the same style
// attribute will have the same inline style.
class UniqueElementData final : public ElementData {
 public:
  ShareableElementData* MakeShareableCopy() const;

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
  mutable Member<CSSPropertyValueSet> presentation_attribute_style_;
  AttributeVector attribute_vector_;
};

template <>
struct DowncastTraits<UniqueElementData> {
  static bool AllowFrom(const ElementData& data) { return data.bit_field_.get<ElementData::IsUniqueFlag>(); }
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_ELEMENT_DATA_H_
