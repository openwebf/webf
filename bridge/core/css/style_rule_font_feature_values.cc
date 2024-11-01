// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_rule_font_feature_values.h"

#include "core/css/style_rule_font_feature_values.h"
#include "core/css/cascade_layer.h"
//#include "platform/wtf/assertions.h"
#include "foundation/string_builder.h"

#include <limits>

namespace webf {


StyleRuleFontFeature::StyleRuleFontFeature(
    StyleRuleFontFeature::FeatureType type)
    : StyleRuleBase(kFontFeature), type_(type) {}

StyleRuleFontFeature::StyleRuleFontFeature(const StyleRuleFontFeature&) =
    default;
StyleRuleFontFeature::~StyleRuleFontFeature() = default;

void StyleRuleFontFeature::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
}

void StyleRuleFontFeature::UpdateAlias(AtomicString alias,
                                       const std::vector<uint32_t>& features) {
  feature_aliases_[alias] = FeatureIndicesWithPriority{features,
                                                       std::numeric_limits<unsigned>::max()};
}

void StyleRuleFontFeature::OverrideAliasesIn(FontFeatureAliases& destination) {
  for (const auto& hash_entry : feature_aliases_) {
    destination[hash_entry.first] = hash_entry.second;
  }
}

FontFeatureValuesStorage::FontFeatureValuesStorage(
    FontFeatureAliases stylistic,
    FontFeatureAliases styleset,
    FontFeatureAliases character_variant,
    FontFeatureAliases swash,
    FontFeatureAliases ornaments,
    FontFeatureAliases annotation)
    : stylistic_(stylistic),
      styleset_(styleset),
      character_variant_(character_variant),
      swash_(swash),
      ornaments_(ornaments),
      annotation_(annotation) {}

std::vector<uint32_t> FontFeatureValuesStorage::ResolveStylistic(
    AtomicString alias) const {
  return ResolveInternal(stylistic_, alias);
}

std::vector<uint32_t> FontFeatureValuesStorage::ResolveStyleset(
    AtomicString alias) const {
  return ResolveInternal(styleset_, alias);
}

std::vector<uint32_t> FontFeatureValuesStorage::ResolveCharacterVariant(
    AtomicString alias) const {
  return ResolveInternal(character_variant_, alias);
}

std::vector<uint32_t> FontFeatureValuesStorage::ResolveSwash(
    AtomicString alias) const {
  return ResolveInternal(swash_, alias);
}

std::vector<uint32_t> FontFeatureValuesStorage::ResolveOrnaments(
    AtomicString alias) const {
  return ResolveInternal(ornaments_, alias);
}
std::vector<uint32_t> FontFeatureValuesStorage::ResolveAnnotation(
    AtomicString alias) const {
  return ResolveInternal(annotation_, alias);
}

void FontFeatureValuesStorage::SetLayerOrder(unsigned layer_order) {
  auto set_layer_order = [layer_order](FontFeatureAliases& aliases) {
    for (auto& entry : aliases) {
      entry.second.layer_order = layer_order;
    }
  };

  set_layer_order(stylistic_);
  set_layer_order(styleset_);
  set_layer_order(character_variant_);
  set_layer_order(swash_);
  set_layer_order(ornaments_);
  set_layer_order(annotation_);
}

void FontFeatureValuesStorage::FuseUpdate(const FontFeatureValuesStorage& other,
                                          unsigned other_layer_order) {
  auto merge_maps = [other_layer_order](FontFeatureAliases& own,
                                        const FontFeatureAliases& other) {
    for (auto entry : other) {
      FeatureIndicesWithPriority entry_updated_order(entry.second);
      entry_updated_order.layer_order = other_layer_order;
      auto insert_result = own.insert({entry.first, entry_updated_order});
      // TODO(xiezuobing)：这里要确认这个stored_value干什么用，不然用std::unordered_map后面不好查bug
      if (!insert_result.second) {
        unsigned existing_layer_order =
            insert_result.stored_value->value.layer_order;
        if (other_layer_order >= existing_layer_order) {
          insert_result.stored_value->value = entry_updated_order;
        }
      }
    }
  };

  merge_maps(stylistic_, other.stylistic_);
  merge_maps(styleset_, other.styleset_);
  merge_maps(character_variant_, other.character_variant_);
  merge_maps(swash_, other.swash_);
  merge_maps(ornaments_, other.ornaments_);
  merge_maps(annotation_, other.annotation_);
}

/* static */
std::vector<uint32_t> FontFeatureValuesStorage::ResolveInternal(
    const FontFeatureAliases& aliases,
    AtomicString alias) {
  auto find_result = aliases.find(alias);
  if (find_result == aliases.end()) {
    return {};
  }
  return find_result->second.indices;
}

StyleRuleFontFeatureValues::StyleRuleFontFeatureValues(
    std::vector<AtomicString> families,
    FontFeatureAliases stylistic,
    FontFeatureAliases styleset,
    FontFeatureAliases character_variant,
    FontFeatureAliases swash,
    FontFeatureAliases ornaments,
    FontFeatureAliases annotation)
    : StyleRuleBase(kFontFeatureValues),
      families_(std::move(families)),
      feature_values_storage_(stylistic,
                              styleset,
                              character_variant,
                              swash,
                              ornaments,
                              annotation) {}

StyleRuleFontFeatureValues::StyleRuleFontFeatureValues(
    const StyleRuleFontFeatureValues&) = default;

StyleRuleFontFeatureValues::~StyleRuleFontFeatureValues() = default;

void StyleRuleFontFeatureValues::SetFamilies(std::vector<AtomicString> families) {
  families_ = std::move(families);
}

AtomicString StyleRuleFontFeatureValues::FamilyAsString() const {
  StringBuilder families;
  for (uint32_t i = 0; i < families_.size(); ++i) {
    families.Append(families_[i]);
    if (i < families_.size() - 1) {
      families.Append(", ");
    }
  }
  return families.ReleaseString();
}

void StyleRuleFontFeatureValues::TraceAfterDispatch(
    GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
//  visitor->Trace(layer_);
}

}  // namespace webf
