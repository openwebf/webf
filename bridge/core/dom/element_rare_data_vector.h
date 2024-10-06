// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_DOM_ELEMENT_RARE_DATA_VECTOR_H_
#define WEBF_CORE_DOM_ELEMENT_RARE_DATA_VECTOR_H_

#include "core/dom/node_rare_data.h"
#include "core/dom/element_rare_data_field.h"

namespace webf {

// This class stores lazily-initialized state associated with Elements, each of
// which is identified in the FieldId enum. Since storing pointers to all of
// these classes would take up too much memory, we use a Vector and only include
// the types that have actually been requested. In order to determine which
// index into the vector each type has, an additional bitfield is used to
// indicate which types are currently included in the vector.
//
// Here is an example of what the vector and bitfield would look like if this
// class has initialized a ShadowRoot and an EditContext. We can figure out that
// the first item in the vector is a ShadowRoot because ShadowRoot's spot in the
// bitfield is 1 and everything to the right is a 0. We can figure out that the
// second item is an EditContext because EditContext's spot in the bitfield is a
// 1 and there is one 1 in all of the bits to the right.
// Vector:
//   0: Member<ShadowRoot>
//   1: Member<EditContext>
// Bitfield: 0b00000000000000000000001000000010

class ElementRareDataVector final : public NodeRareData {
 private:
  friend class ElementRareDataVectorTest;
  enum class FieldId : unsigned {
    kDataset = 0,
    kShadowRoot = 1,
    kClassList = 2,
    kAttributeMap = 3,
    kAttrNodeList = 4,
    kCssomWrapper = 5,
    kElementAnimations = 6,
    kIntersectionObserverData = 7,
    kPseudoElementData = 8,
    kEditContext = 9,
    kPart = 10,
    kCssomMapWrapper = 11,
    kElementInternals = 12,
    kAccessibleNode = 13,
    kDisplayLockContext = 14,
    kContainerQueryData = 15,
    kRegionCaptureCropId = 16,
    kResizeObserverData = 17,
    kCustomElementDefinition = 18,
    kPopoverData = 19,
    kPartNamesMap = 20,
    kNonce = 21,
    kIsValue = 22,
    kSavedLayerScrollOffset = 23,
    kAnchorPositionScrollData = 24,
    kAnchorElementObserver = 25,
    kImplicitlyAnchoredElementCount = 26,
    kLastRememberedBlockSize = 27,
    kLastRememberedInlineSize = 28,
    kRestrictionTargetId = 29,
    kStyleScopeData = 30,
    kOutOfFlowData = 31,

    kNumFields = 32,
  };

  const ElementRareDataField* GetField(FieldId field_id) const;
  // GetFieldIndex returns the index in |fields_| that |field_id| is stored in.
  // If |fields_| isn't storing a field for |field_id|, then this returns the
  // index which the data for |field_id| should be inserted into.
  unsigned GetFieldIndex(FieldId field_id) const;
  void SetField(FieldId field_id, ElementRareDataField* field);

  std::vector<Member<ElementRareDataField>> fields_;
  using BitfieldType = uint32_t;
  BitfieldType fields_bitfield_;
  static_assert(sizeof(fields_bitfield_) * 8 >=
                    static_cast<unsigned>(FieldId::kNumFields),
                "field_bitfield_ must be big enough to have a bit for each "
                "field in FieldId.");

  template <typename T>
  class DataFieldWrapper final : public ElementRareDataField {
   public:
    T& Get() { return data_; }
    void Trace(GCVisitor* visitor) const {
      ElementRareDataField::Trace(visitor);
      visitor->TraceMember(data_);
    }

   private:
    Member<T> data_;
  };

  template <typename T, typename... Args>
  T& EnsureField(FieldId field_id, Args&&... args) {
    T* field = static_cast<T*>(GetField(field_id));
    if (!field) {
      field = MakeGarbageCollected<T>(std::forward<Args>(args)...);
      SetField(field_id, field);
    }
    return *field;
  }

  template <typename T>
  T& EnsureWrappedField(FieldId field_id) {
    return EnsureField<DataFieldWrapper<T>>(field_id).Get();
  }

  template <typename T, typename U>
  void SetWrappedField(FieldId field_id, U data) {
    EnsureWrappedField<T>(field_id) = std::move(data);
  }

  template <typename T>
  T* GetWrappedField(FieldId field_id) const {
    auto* wrapper = static_cast<DataFieldWrapper<T>*>(GetField(field_id));
    return wrapper ? &wrapper->Get() : nullptr;
  }

  template <typename T>
  void SetOptionalField(FieldId field_id, std::optional<T> data) {
    if (data) {
      SetWrappedField<T>(field_id, *data);
    } else {
      SetField(field_id, nullptr);
    }
  }

  template <typename T>
  std::optional<T> GetOptionalField(FieldId field_id) const {
    if (auto* value = GetWrappedField<T>(field_id)) {
      return *value;
    }
    return std::nullopt;
  }

 public:
  ElementRareDataVector();
  ~ElementRareDataVector();

  bool HasElementFlag(ElementFlags mask) const {
    return element_flags_ & static_cast<uint16_t>(mask);
  }
  void SetElementFlag(ElementFlags mask, bool value) {
    element_flags_ =
        (element_flags_ & ~static_cast<uint16_t>(mask)) |
        (-static_cast<uint16_t>(value) & static_cast<uint16_t>(mask));
  }
  void ClearElementFlag(ElementFlags mask) {
    element_flags_ &= ~static_cast<uint16_t>(mask);
  }

  void Trace(GCVisitor*) const override;

 private:
};

}

#endif  // WEBF_CORE_DOM_ELEMENT_RARE_DATA_VECTOR_H_
