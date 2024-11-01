// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_STYLE_RULE_FONT_FEATURE_VALUES_H
#define WEBF_STYLE_RULE_FONT_FEATURE_VALUES_H

#include "core/css/style_rule.h"

namespace webf {


struct FeatureIndicesWithPriority {
  std::vector<uint32_t> indices;
  unsigned layer_order = std::numeric_limits<unsigned>::max();
};

using FontFeatureAliases = std::unordered_map<AtomicString, FeatureIndicesWithPriority, AtomicString::KeyHasher>;

class StyleRuleFontFeature : public StyleRuleBase {
 public:
  enum class FeatureType {
    kStylistic,
    kStyleset,
    kCharacterVariant,
    kSwash,
    kOrnaments,
    kAnnotation
  };

  explicit StyleRuleFontFeature(FeatureType);
  StyleRuleFontFeature(const StyleRuleFontFeature&);
  ~StyleRuleFontFeature();

  void UpdateAlias(AtomicString alias, const std::vector<uint32_t>& features);

  void OverrideAliasesIn(FontFeatureAliases& destination);

  FeatureType GetFeatureType() { return type_; }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  FeatureType type_;
  FontFeatureAliases feature_aliases_;
};

template <>
struct DowncastTraits<StyleRuleFontFeature> {
  static bool AllowFrom(const StyleRuleBase& rule) {
    return rule.IsFontFeatureRule();
  }
};

class FontFeatureValuesStorage {
 public:
  FontFeatureValuesStorage(FontFeatureAliases stylistic,
                           FontFeatureAliases styleset,
                           FontFeatureAliases character_variant,
                           FontFeatureAliases swash,
                           FontFeatureAliases ornaments,
                           FontFeatureAliases annotation);

  FontFeatureValuesStorage() = default;
  FontFeatureValuesStorage(const FontFeatureValuesStorage& other) = default;

  FontFeatureValuesStorage& operator=(const FontFeatureValuesStorage& other) =
      default;

  std::vector<uint32_t> ResolveStylistic(AtomicString) const;
  std::vector<uint32_t> ResolveStyleset(AtomicString) const;
  std::vector<uint32_t> ResolveCharacterVariant(AtomicString) const;
  std::vector<uint32_t> ResolveSwash(AtomicString) const;
  std::vector<uint32_t> ResolveOrnaments(AtomicString) const;
  std::vector<uint32_t> ResolveAnnotation(AtomicString) const;

  void SetLayerOrder(unsigned layer_order);

  // Update and extend this FontFeatureValuesStorage with information from
  // `other`. Intended to be used for fusing multiple at-rules in a document and
  // across cascade layers so that their maps became unified, compare
  // https://drafts.csswg.org/css-fonts-4/#font-feature-values-syntax: If
  // multiple @font-feature-values rules are defined for a given family, the
  // resulting values definitions are the union of the definitions contained
  // within these rules. If `other` is passed in with a higher `layer_order`,
  // existing alias keys are overridden with the values from `other`.
  void FuseUpdate(const FontFeatureValuesStorage& other, unsigned layer_order);

 private:
  // TODO(https://crbug.com/716567): Only styleset and character variant take
  // two values for each alias, the others take 1 value. Consider reducing
  // storage here.
  FontFeatureAliases stylistic_;
  FontFeatureAliases styleset_;
  FontFeatureAliases character_variant_;
  FontFeatureAliases swash_;
  FontFeatureAliases ornaments_;
  FontFeatureAliases annotation_;
  static std::vector<uint32_t> ResolveInternal(const FontFeatureAliases&,
                                          AtomicString);

  friend class StyleRuleFontFeatureValues;
};

class StyleRuleFontFeatureValues : public StyleRuleBase {
 public:
  StyleRuleFontFeatureValues(std::vector<AtomicString> families,
                             FontFeatureAliases stylistic,
                             FontFeatureAliases styleset,
                             FontFeatureAliases character_variant,
                             FontFeatureAliases swash,
                             FontFeatureAliases ornaments,
                             FontFeatureAliases annotation);
  StyleRuleFontFeatureValues(const StyleRuleFontFeatureValues&);
  ~StyleRuleFontFeatureValues();

  const std::vector<AtomicString>& GetFamilies() const { return families_; }
  AtomicString FamilyAsString() const;

  void SetFamilies(std::vector<AtomicString>);

  std::shared_ptr<StyleRuleFontFeatureValues> Copy() const {
    return std::make_shared<StyleRuleFontFeatureValues>(*this);
  }

  const FontFeatureValuesStorage& Storage() { return feature_values_storage_; }

  // Accessors needed for cssom implementation.
  FontFeatureAliases* GetStylistic() {
    return &feature_values_storage_.stylistic_;
  }
  FontFeatureAliases* GetStyleset() {
    return &feature_values_storage_.styleset_;
  }
  FontFeatureAliases* GetCharacterVariant() {
    return &feature_values_storage_.character_variant_;
  }
  FontFeatureAliases* GetSwash() { return &feature_values_storage_.swash_; }
  FontFeatureAliases* GetOrnaments() {
    return &feature_values_storage_.ornaments_;
  }
  FontFeatureAliases* GetAnnotation() {
    return &feature_values_storage_.annotation_;
  }

  void SetCascadeLayer(const CascadeLayer* layer) { layer_ = layer; }
  const CascadeLayer* GetCascadeLayer() const { return layer_.Get(); }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::vector<AtomicString> families_;
  FontFeatureValuesStorage feature_values_storage_;
  Member<const CascadeLayer> layer_;
};

template <>
struct DowncastTraits<StyleRuleFontFeatureValues> {
  static bool AllowFrom(const StyleRuleBase& rule) {
    return rule.IsFontFeatureValuesRule();
  }
};


}  // namespace webf

#endif  // WEBF_STYLE_RULE_FONT_FEATURE_VALUES_H
