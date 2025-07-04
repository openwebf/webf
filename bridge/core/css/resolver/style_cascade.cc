/*
 * Copyright (C) 2019 Google Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "core/css/resolver/style_cascade.h"

#include "core/css/css_property_value_set.h"
#include "core/css/css_unparsed_declaration_value.h"
#include "core/css/css_value.h"
#include "core/css/css_variable_data.h"
#include "core/css/match_result.h"
#include "core/css/properties/css_property.h"
#include "code_gen/longhands.h"
#include "core/css/resolver/cascade_resolver.h"
#include "core/css/resolver/style_builder.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/style/computed_style.h"

namespace webf {

namespace {

CSSPropertyID UnvisitedID(CSSPropertyID id) {
  // TODO: Implement visited property mapping
  return id;
}

}  // namespace

MatchResult& StyleCascade::MutableMatchResult() {
  needs_match_result_analyze_ = true;
  return match_result_;
}

void StyleCascade::Apply(CascadeFilter filter) {
  AnalyzeIfNeeded();
  
  CascadeResolver resolver(filter, ++generation_);

  ApplyCascadeAffecting(resolver);
  ApplyHighPriority(resolver);
  ApplyMatchResult(resolver);
}

std::unique_ptr<CSSBitset> StyleCascade::GetImportantSet() {
  AnalyzeIfNeeded();
  if (!map_.HasImportant()) {
    return nullptr;
  }
  auto set = std::make_unique<CSSBitset>();
  for (CSSPropertyID id : map_.NativeBitset()) {
    // We use the unvisited ID because visited/unvisited colors are currently
    // interpolated together.
    set->Or(UnvisitedID(id), map_.At(CSSPropertyName(id)).IsImportant());
  }
  return set;
}

void StyleCascade::Reset() {
  map_.Reset();
  match_result_ = MatchResult();  // Create a new empty MatchResult
  generation_ = 0;
  depends_on_cascade_affecting_property_ = false;
}

const CSSValue* StyleCascade::Resolve(const CSSPropertyName& name,
                                      const CSSValue& value,
                                      CascadeOrigin origin,
                                      CascadeResolver& resolver) {
  if (name.IsCustomProperty()) {
    // TODO: Handle custom properties
    return &value;
  }
  const CSSProperty& property = CSSProperty::Get(name.Id());
  
  // Convert CascadeOrigin to StyleCascadeOrigin
  StyleCascadeOrigin style_origin = StyleCascadeOrigin::kAuthor;
  if (origin == CascadeOrigin::kUserAgent) {
    style_origin = StyleCascadeOrigin::kUserAgent;
  } else if (origin == CascadeOrigin::kUser) {
    style_origin = StyleCascadeOrigin::kUser;
  }
  
  // CascadePriority(origin, is_inline_style, layer_order, position, tree_order)
  CascadeOrigin cascade_origin_ref = origin;
  return Resolve(ResolveSurrogate(property), value,
                 CascadePriority(style_origin, false, 0, 0),
                 cascade_origin_ref, resolver);
}

void StyleCascade::AnalyzeIfNeeded() {
  if (needs_match_result_analyze_) {
    AnalyzeMatchResult();
  }
}

void StyleCascade::AnalyzeMatchResult() {
  map_.Reset();
  
  const auto& matched_properties = match_result_.GetMatchedProperties();
  uint32_t position = 0;
  
  for (const auto& entry : matched_properties) {
    if (!entry.properties) {
      continue;
    }
    
    const StylePropertySet& properties = *entry.properties;
    
    // Convert to cascade origin
    CascadeOrigin cascade_origin = CascadeOrigin::kAuthor;
    if (entry.origin == webf::CascadeOrigin::kUserAgent) {
      cascade_origin = CascadeOrigin::kUserAgent;
    } else if (entry.origin == webf::CascadeOrigin::kUser) {
      cascade_origin = CascadeOrigin::kUser;
    }
    
    // Process each property in the set
    for (unsigned i = 0; i < properties.PropertyCount(); ++i) {
      const StylePropertySet::PropertyReference property = properties.PropertyAt(i);
      
      if (!property.Value() || !*property.Value()) {
        continue;
      }
      
      // Convert cascade origin based on importance
      StyleCascadeOrigin style_origin = StyleCascadeOrigin::kAuthor;
      if (cascade_origin == CascadeOrigin::kUserAgent) {
        style_origin = property.IsImportant() ? 
            StyleCascadeOrigin::kImportantUserAgent : StyleCascadeOrigin::kUserAgent;
      } else if (cascade_origin == CascadeOrigin::kUser) {
        style_origin = property.IsImportant() ? 
            StyleCascadeOrigin::kImportantUser : StyleCascadeOrigin::kUser;
      } else {
        style_origin = property.IsImportant() ? 
            StyleCascadeOrigin::kImportantAuthor : StyleCascadeOrigin::kAuthor;
      }
      
      // Build cascade priority
      // CascadePriority(origin, is_inline_style, layer_order, position, tree_order)
      CascadePriority priority(style_origin, 
                               false,  // is_inline_style
                               0,      // layer_order
                               position++);  // position
      
      // Add to cascade map
      if (property.Id() == CSSPropertyID::kVariable) {
        // Custom property
        const auto& metadata = property.PropertyMetadata();
        if (!metadata.custom_name_.IsNull()) {
          map_.Add(metadata.custom_name_, priority);
        }
      } else {
        // Regular property
        map_.Add(property.Id(), priority);
      }
    }
  }
  
  needs_match_result_analyze_ = false;
}

void StyleCascade::ApplyCascadeAffecting(CascadeResolver& resolver) {
  // Apply cascade-affecting properties first (direction, writing-mode)
  for (CSSPropertyID id : {CSSPropertyID::kDirection, CSSPropertyID::kWritingMode}) {
    LookupAndApply(CSSProperty::Get(id), resolver);
  }
}

void StyleCascade::ApplyHighPriority(CascadeResolver& resolver) {
  // Apply high priority properties (font-size, line-height, etc.)
  uint64_t high_priority = map_.HighPriorityBits();
  if (!high_priority) {
    return;
  }
  
  // Apply font-size first if present
  if (high_priority & (1ull << static_cast<uint64_t>(CSSPropertyID::kFontSize))) {
    LookupAndApply(CSSProperty::Get(CSSPropertyID::kFontSize), resolver);
  }
}

void StyleCascade::ApplyMatchResult(CascadeResolver& resolver) {
  // Apply all properties from the cascade map
  for (CSSPropertyID id : map_.NativeBitset()) {
    const CSSProperty& property = CSSProperty::Get(id);
    if (!resolver.Rejects(property)) {
      LookupAndApply(property, resolver);
    }
  }
}

void StyleCascade::LookupAndApply(const CSSPropertyName& name,
                                  CascadeResolver& resolver) {
  if (name.IsCustomProperty()) {
    // TODO: Handle custom properties
    return;
  }
  LookupAndApply(CSSProperty::Get(name.Id()), resolver);
}

void StyleCascade::LookupAndApply(const CSSProperty& property,
                                  CascadeResolver& resolver) {
  CascadePriority* priority = map_.Find(property.GetCSSPropertyName());
  if (priority) {
    LookupAndApplyValue(property, priority, resolver);
  }
}

void StyleCascade::LookupAndApplyValue(const CSSProperty& property,
                                       CascadePriority* priority,
                                       CascadeResolver& resolver) {
  // Check if already applied in this generation
  if (priority && priority->GetGeneration() == generation_) {
    return;
  }
  
  if (priority) {
    priority->SetGeneration(generation_);
  }
  
  LookupAndApplyDeclaration(property, priority, resolver);
}

void StyleCascade::LookupAndApplyDeclaration(const CSSProperty& property,
                                             CascadePriority* priority,
                                             CascadeResolver& resolver) {
  if (!priority) {
    return;
  }
  
  CascadeResolver::AutoLock lock(property, resolver);
  
  const CSSValue* value = ValueAt(match_result_, priority->GetPosition());
  if (value) {
    resolver.CollectFlags(property, priority->GetOrigin());
    
    // Apply the value
    StyleBuilder::ApplyProperty(property.PropertyID(), state_, *value);
  }
}

const CSSValue* StyleCascade::ValueAt(const MatchResult& result, 
                                      uint32_t position) const {
  // This is a simplified version - we need to map position to actual value
  // In a real implementation, this would look up the value from the
  // MatchedProperties based on the position
  uint32_t current_pos = 0;
  
  for (const auto& entry : result.GetMatchedProperties()) {
    if (!entry.properties) {
      continue;
    }
    
    const StylePropertySet& properties = *entry.properties;
    for (unsigned i = 0; i < properties.PropertyCount(); ++i) {
      if (current_pos == position) {
        const auto& prop = properties.PropertyAt(i);
        return prop.Value() ? prop.Value()->get() : nullptr;
      }
      current_pos++;
    }
  }
  
  return nullptr;
}

const CSSValue* StyleCascade::Resolve(const CSSProperty& property,
                                      const CSSValue& value,
                                      CascadePriority priority,
                                      CascadeOrigin& origin,
                                      CascadeResolver& resolver) {
  // Simplified resolution - just return the value as-is
  // In a real implementation, this would handle var(), revert, etc.
  return &value;
}

const CSSValue* StyleCascade::ResolveCustomProperty(
    const CSSProperty& property,
    const CSSUnparsedDeclarationValue& value,
    CascadeResolver& resolver) {
  // TODO: Implement custom property resolution
  return nullptr;
}

const CSSValue* StyleCascade::ResolveVariableReference(
    const CSSProperty& property,
    const CSSUnparsedDeclarationValue& value,
    CascadeResolver& resolver) {
  // TODO: Implement variable reference resolution
  return nullptr;
}


const CSSProperty& StyleCascade::ResolveSurrogate(const CSSProperty& property) {
  // TODO: Implement surrogate resolution (for logical properties)
  return property;
}

}  // namespace webf