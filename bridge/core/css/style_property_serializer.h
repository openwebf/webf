/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2012 Apple Inc. All
 * rights reserved.
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

#ifndef THIRD_PARTY_BLINK_RENDERER_CORE_CSS_STYLE_PROPERTY_SERIALIZER_H_
#define THIRD_PARTY_BLINK_RENDERER_CORE_CSS_STYLE_PROPERTY_SERIALIZER_H_

#include <bitset>
#include "core/css/css_property_value_set.h"
#include "core/css/css_value_list.h"

namespace webf {
class StringBuilder;
}  // namespace webf

namespace webf {

class CSSPropertyName;
class CSSPropertyValueSet;
class StylePropertyShorthand;

class StylePropertySerializer {
  WEBF_STACK_ALLOCATED();

 public:
  explicit StylePropertySerializer(const CSSPropertyValueSet&);

  AtomicString AsText() const;
  AtomicString SerializeShorthand(CSSPropertyID) const;

 private:
  AtomicString GetCommonValue(const StylePropertyShorthand&) const;
  AtomicString BorderPropertyValue(const StylePropertyShorthand&,
                             const StylePropertyShorthand&,
                             const StylePropertyShorthand&) const;
  AtomicString BorderImagePropertyValue() const;
  AtomicString BorderRadiusValue() const;
  AtomicString GetLayeredShorthandValue(const StylePropertyShorthand&) const;
  AtomicString Get2Values(const StylePropertyShorthand&) const;
  AtomicString Get4Values(const StylePropertyShorthand&) const;
  AtomicString PageBreakPropertyValue(const StylePropertyShorthand&) const;
  AtomicString GetShorthandValue(const StylePropertyShorthand&,
                           AtomicString separator = " ") const;
  AtomicString GetShorthandValueForColumnRule(const StylePropertyShorthand&) const;
  AtomicString GetShorthandValueForColumns(const StylePropertyShorthand&) const;
  // foo || bar || ... || baz
  // https://drafts.csswg.org/css-values-4/#component-combinators
  AtomicString GetShorthandValueForDoubleBarCombinator(
      const StylePropertyShorthand&) const;
  AtomicString GetShorthandValueForGrid(const StylePropertyShorthand&) const;
  AtomicString GetShorthandValueForGridArea(const StylePropertyShorthand&) const;
  AtomicString GetShorthandValueForGridLine(const StylePropertyShorthand&) const;
  AtomicString GetShorthandValueForGridTemplate(const StylePropertyShorthand&) const;
  AtomicString ContainerValue() const;
  AtomicString TimelineValue(const StylePropertyShorthand&) const;
  AtomicString ScrollTimelineValue() const;
  AtomicString ViewTimelineValue() const;
  AtomicString AnimationRangeShorthandValue() const;
  AtomicString FontValue() const;
  AtomicString FontSynthesisValue() const;
  AtomicString FontVariantValue() const;
  bool AppendFontLonghandValueIfNotNormal(const CSSProperty&,
                                          StringBuilder& result) const;
  AtomicString OffsetValue() const;
  AtomicString TextDecorationValue() const;
  AtomicString TextSpacingValue() const;
  AtomicString ContainIntrinsicSizeValue() const;
  AtomicString WhiteSpaceValue() const;
  AtomicString ScrollStartValue() const;
  AtomicString ScrollStartTargetValue() const;
  AtomicString PositionTryValue(const StylePropertyShorthand&) const;
  AtomicString GetPropertyText(const CSSPropertyName&,
                         const AtomicString& value,
                         bool is_important,
                         bool is_not_first_decl) const;
  bool IsPropertyShorthandAvailable(const StylePropertyShorthand&) const;
  bool ShorthandHasOnlyInitialOrInheritedValue(
      const StylePropertyShorthand&) const;
  void AppendBackgroundPropertyAsText(StringBuilder& result,
                                      unsigned& num_decls) const;

  // This function does checks common to all shorthands, and returns:
  // - The serialization if the shorthand serializes as a css-wide keyword.
  // - An empty string if either some longhands are not set, the important
  // flag is not set consistently, or css-wide keywords are used. In these
  // cases serialization will always fail.
  // - A null string otherwise.
  AtomicString CommonShorthandChecks(const StylePropertyShorthand&) const;

  // Only StylePropertySerializer uses the following two classes.
  class PropertyValueForSerializer {
    WEBF_STACK_ALLOCATED();

   public:
    explicit PropertyValueForSerializer(
        CSSPropertyValueSet::PropertyReference property)
        : value_(&property.Value()),
          name_(property.Name()),
          is_important_(property.IsImportant()) {}

    // TODO(sashab): Make this take a const CSSValue&.
    PropertyValueForSerializer(const CSSPropertyName& name,
                               const CSSValue* value,
                               bool is_important)
        : value_(value), name_(name), is_important_(is_important) {}

    const CSSPropertyName& Name() const { return name_; }
    const CSSValue* Value() const { return value_; }
    bool IsImportant() const { return is_important_; }
    bool IsValid() const { return value_; }

   private:
    const CSSValue* value_;
    CSSPropertyName name_;
    bool is_important_;
  };

  AtomicString GetCustomPropertyText(const PropertyValueForSerializer&,
                               bool is_not_first_decl) const;

  class CSSPropertyValueSetForSerializer final {
    WEBF_DISALLOW_NEW();

   public:
    explicit CSSPropertyValueSetForSerializer(const CSSPropertyValueSet&);

    unsigned PropertyCount() const;
    PropertyValueForSerializer PropertyAt(unsigned index) const;
    bool ShouldProcessPropertyAt(unsigned index) const;
    int FindPropertyIndex(const CSSProperty&) const;
    const CSSValue* GetPropertyCSSValue(const CSSProperty&) const;
    bool IsDescriptorContext() const;

    void Trace(GCVisitor*) const;

   private:
    bool HasExpandedAllProperty() const {
      return HasAllProperty() && need_to_expand_all_;
    }
    bool HasAllProperty() const { return all_index_ != -1; }
    bool IsIndexInPropertySet(unsigned index) const {
      return index < property_set_->PropertyCount();
    }
    CSSPropertyID IndexToPropertyID(unsigned index) const {
      // Iterating over "all"-expanded longhands is done using indices greater
      // than, or equal to, the property set size. Map the index to the property
      // ID based on the property set size.
      //
      // For this property set:
      //
      // div {
      //   --foo: bar;
      //   all: initial;
      //   background-color: green;
      // }
      //
      // We end up with indices (This method is supposed to do the mapping from
      // index to property ID for the enumerated properties from color and
      // onwards):
      //
      // 0: --foo
      // 1: all
      // 2: background-color
      // 3: color (this is kIntFirstCSSProperty)
      // 4: ...
      //
      assert(index, property_set_->PropertyCount());
      return static_cast<CSSPropertyID>(index - property_set_->PropertyCount() +
                                        kIntFirstCSSProperty);
    }
    Member<const CSSPropertyValueSet> property_set_;
    int all_index_;
    std::bitset<kNumCSSProperties> longhand_property_used_;
    bool need_to_expand_all_;
  };

  const CSSPropertyValueSetForSerializer property_set_;
};

}  // namespace blink

#endif  // THIRD_PARTY_BLINK_RENDERER_CORE_CSS_STYLE_PROPERTY_SERIALIZER_H_
