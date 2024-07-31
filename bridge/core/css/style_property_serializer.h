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

class CSSPropertyName;
class CSSPropertyValueSet;
class StylePropertyShorthand;

class StylePropertySerializer {
  WEBF_STACK_ALLOCATED();

 public:
  explicit StylePropertySerializer(const CSSPropertyValueSet&);

  std::string AsText() const;
  std::string SerializeShorthand(CSSPropertyID) const;

 private:
  std::string GetCommonValue(const StylePropertyShorthand&) const;
  std::string BorderPropertyValue(const StylePropertyShorthand&,
                             const StylePropertyShorthand&,
                             const StylePropertyShorthand&) const;
  std::string BorderImagePropertyValue() const;
  std::string BorderRadiusValue() const;
  std::string GetLayeredShorthandValue(const StylePropertyShorthand&) const;
  std::string Get2Values(const StylePropertyShorthand&) const;
  std::string Get4Values(const StylePropertyShorthand&) const;
  std::string PageBreakPropertyValue(const StylePropertyShorthand&) const;
  std::string GetShorthandValue(const StylePropertyShorthand&,
                           std::string separator = " ") const;
  std::string GetShorthandValueForColumnRule(const StylePropertyShorthand&) const;
  std::string GetShorthandValueForColumns(const StylePropertyShorthand&) const;
  // foo || bar || ... || baz
  // https://drafts.csswg.org/css-values-4/#component-combinators
  std::string GetShorthandValueForDoubleBarCombinator(
      const StylePropertyShorthand&) const;
  std::string GetShorthandValueForGrid(const StylePropertyShorthand&) const;
  std::string GetShorthandValueForGridArea(const StylePropertyShorthand&) const;
  std::string GetShorthandValueForGridLine(const StylePropertyShorthand&) const;
  std::string GetShorthandValueForGridTemplate(const StylePropertyShorthand&) const;
  std::string ContainerValue() const;
  std::string TimelineValue(const StylePropertyShorthand&) const;
  std::string ScrollTimelineValue() const;
  std::string ViewTimelineValue() const;
  std::string AnimationRangeShorthandValue() const;
  std::string FontValue() const;
  std::string FontSynthesisValue() const;
  std::string FontVariantValue() const;
  bool AppendFontLonghandValueIfNotNormal(const CSSProperty&,
                                          std::string& result) const;
  std::string OffsetValue() const;
  std::string TextDecorationValue() const;
  std::string TextSpacingValue() const;
  std::string ContainIntrinsicSizeValue() const;
  std::string WhiteSpaceValue() const;
  std::string ScrollStartValue() const;
  std::string ScrollStartTargetValue() const;
  std::string PositionTryValue() const;
  std::string GetPropertyText(const CSSPropertyName&,
                         const std::string& value,
                         bool is_important,
                         bool is_not_first_decl) const;
  bool IsPropertyShorthandAvailable(const StylePropertyShorthand&) const;
  bool ShorthandHasOnlyInitialOrInheritedValue(
      const StylePropertyShorthand&) const;
  void AppendBackgroundPropertyAsText(std::string& result,
                                      unsigned& num_decls) const;

  // This function does checks common to all shorthands, and returns:
  // - The serialization if the shorthand serializes as a css-wide keyword.
  // - An empty string if either some longhands are not set, the important
  // flag is not set consistently, or css-wide keywords are used. In these
  // cases serialization will always fail.
  // - A null std::string otherwise.
  std::string CommonShorthandChecks(const StylePropertyShorthand&) const;

  // Only StylePropertySerializer uses the following two classes.
  class PropertyValueForSerializer {
    WEBF_STACK_ALLOCATED();

   public:
    explicit PropertyValueForSerializer(
        CSSPropertyValueSet::PropertyReference property)
        : value_(property.Value()->get()),
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

  std::string GetCustomPropertyText(const PropertyValueForSerializer&,
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
      assert(index >= property_set_->PropertyCount());
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
