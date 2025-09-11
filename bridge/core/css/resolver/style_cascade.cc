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

#include "core/css/cascade_layer_map.h"
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
#include "core/css/css_unset_value.h"
#include "core/css/css_invalid_variable_value.h"
#include "core/css/css_pending_substitution_value.h"
#include "core/platform/text/writing_direction_mode.h"
#include "foundation/logging.h"

namespace webf {

namespace {

CSSPropertyID UnvisitedID(CSSPropertyID id) {
  if (id == CSSPropertyID::kVariable) {
    return id;
  }
  const CSSProperty& property = CSSProperty::Get(id);
  if (!property.IsVisited()) {
    return id;
  }
  return property.GetUnvisitedProperty()->PropertyID();
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
  const CSSProperty& property = name.IsCustomProperty() ?
      CSSProperty::Get(CSSPropertyID::kVariable) :
      CSSProperty::Get(name.Id());
  
  // Convert CascadeOrigin to StyleCascadeOrigin
  StyleCascadeOrigin style_origin = StyleCascadeOrigin::kAuthor;
  if (origin == CascadeOrigin::kUserAgent) {
    style_origin = StyleCascadeOrigin::kUserAgent;
  } else if (origin == CascadeOrigin::kUser) {
    style_origin = StyleCascadeOrigin::kUser;
  }
  
  // Use implicit outer layer order (max value) as in Blink.
  // This ensures cascade priorities are properly ordered.
  const CSSValue* resolved = Resolve(ResolveSurrogate(property), value,
                                     CascadePriority(style_origin, false, CascadeLayerMap::kImplicitOuterLayerOrder, 0),
                                     origin, resolver);
  
  DCHECK(resolved);
  
  // TODO(crbug.com/1185745): Cycles in animations get special handling by our
  // implementation. This is not per spec, but the correct behavior is not
  // defined at the moment.
  // WebF doesn't have CSSCyclicVariableValue yet, so we skip this check
  
  // TODO(crbug.com/1185745): We should probably not return 'unset' for
  // properties where CustomProperty::SupportsGuaranteedInvalid return true.
  if (resolved->IsInvalidVariableValue()) {
    return cssvalue::CSSUnsetValue::Create().get();
  }
  
  return resolved;
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
  
  // WEBF_LOG(VERBOSE) << "AnalyzeMatchResult: " << matched_properties.size() << " matched property sets";
  
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
    // WEBF_LOG(VERBOSE) << "Property set has " << properties.PropertyCount() << " properties, origin: " << static_cast<int>(entry.origin);
    
    for (unsigned i = 0; i < properties.PropertyCount(); ++i) {
      const StylePropertySet::PropertyReference property = properties.PropertyAt(i);
      
      if (!property.Value() || !*property.Value()) {
        continue;
      }
      
      // WEBF_LOG(VERBOSE) << "Property ID: " << static_cast<int>(property.Id()) << " value: " << property.Value()->get()->CssText();
      
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
                               entry.is_inline_style,  // is_inline_style
                               CascadeLayerMap::kImplicitOuterLayerOrder,      // layer_order
                               position++);  // position
      
      // Add to cascade map
      if (property.Id() == CSSPropertyID::kVariable) {
        // Custom property
        const auto& metadata = property.PropertyMetadata();
        if (!metadata.custom_name_.IsNull()) {
          map_.Add(metadata.custom_name_, priority);
        }
      } else {
        // Regular property - resolve surrogates first
        const CSSProperty& css_property = CSSProperty::Get(property.Id());
        const CSSProperty& resolved_property = ResolveSurrogate(css_property);
        // WEBF_LOG(VERBOSE) << "Adding property " << static_cast<int>(resolved_property.PropertyID()) << " to cascade map at position " << (position - 1);
        map_.Add(resolved_property.PropertyID(), priority);
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
    CascadePriority* priority = map_.Find(name);
    if (priority) {
      // Custom properties are handled differently, they don't use the normal
      // LookupAndApplyValue path. Instead, they're resolved during substitution.
      priority->SetGeneration(generation_);
    }
    return;
  }
  
  const CSSProperty& property = CSSProperty::Get(name.Id());
  LookupAndApply(property, resolver);
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
  
  // WEBF_LOG(VERBOSE) << "ValueAt looking for position " << position;
  
  for (const auto& entry : result.GetMatchedProperties()) {
    if (!entry.properties) {
      continue;
    }
    
    const StylePropertySet& properties = *entry.properties;
    for (unsigned i = 0; i < properties.PropertyCount(); ++i) {
      if (current_pos == position) {
        const auto& prop = properties.PropertyAt(i);
        // WEBF_LOG(VERBOSE) << "Found property at position " << position << ": ID=" << static_cast<int>(prop.Id());
        return prop.Value() ? prop.Value()->get() : nullptr;
      }
      current_pos++;
    }
  }
  
  // WEBF_LOG(VERBOSE) << "No property found at position " << position;
  return nullptr;
}

const CSSValue* StyleCascade::Resolve(const CSSProperty& property,
                                      const CSSValue& value,
                                      CascadePriority priority,
                                      CascadeOrigin& origin,
                                      CascadeResolver& resolver) {
  DCHECK(!property.IsSurrogate());
  
  const CSSValue* result = ResolveSubstitutions(property, value, resolver);
  DCHECK(result);
  
  if (result->IsRevertValue()) {
    return ResolveRevert(property, *result, origin, resolver);
  }
  if (result->IsRevertLayerValue()) {
    return ResolveRevertLayer(property, priority, origin, resolver);
  }
  
  resolver.CollectFlags(property, priority.GetOrigin());
  
  return result;
}

std::shared_ptr<MutableCSSPropertyValueSet> StyleCascade::BuildWinningPropertySet() {
  AnalyzeIfNeeded();
  // Create a property set in standard HTML mode.
  auto result = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);

  // Helper to locate the property reference for a flattened position in
  // MatchResult. Returns true if found and fills out the reference.
  auto find_ref_at = [&](uint32_t position,
                         const StylePropertySet** out_set,
                         unsigned* out_index,
                         CSSPropertyValueSet::PropertyReference* out_prop) -> bool {
    uint32_t current_pos = 0;
    for (const auto& entry : match_result_.GetMatchedProperties()) {
      if (!entry.properties) continue;
      const StylePropertySet& properties = *entry.properties;
      unsigned count = properties.PropertyCount();
      if (position < current_pos + count) {
        unsigned local_index = position - current_pos;
        if (out_set) *out_set = &properties;
        if (out_index) *out_index = local_index;
        if (out_prop) *out_prop = properties.PropertyAt(local_index);
        return true;
      }
      current_pos += count;
    }
    return false;
  };

  // Export native properties (non-custom)
  for (CSSPropertyID id : map_.NativeBitset()) {
    const CascadePriority* prio = map_.FindKnownToExist(id);
    if (!prio) continue;
    uint32_t pos = prio->GetPosition();
    const StylePropertySet* set = nullptr;
    unsigned idx = 0;
    CSSPropertyValueSet::PropertyReference prop_ref = CSSPropertyValueSet::PropertyReference(*result, 0);
    if (!find_ref_at(pos, &set, &idx, &prop_ref)) {
      continue;
    }

    // Get shared CSSValue and importance.
    const std::shared_ptr<const CSSValue>* value_ptr = prop_ref.Value();
    if (!value_ptr || !(*value_ptr)) continue;
    bool important = prop_ref.PropertyMetadata().important_ || prio->IsImportant();

    // Set property by ID with original value object; no evaluation performed.
    result->SetProperty(id, *value_ptr, important);
  }

  // Export custom properties
  for (const auto& entry : map_.GetCustomMap()) {
    const AtomicString& custom_name = entry.first;
    const CascadePriority* prio = map_.Find(CSSPropertyName(custom_name));
    if (!prio) continue;
    uint32_t pos = prio->GetPosition();
    const StylePropertySet* set = nullptr;
    unsigned idx = 0;
    CSSPropertyValueSet::PropertyReference prop_ref = CSSPropertyValueSet::PropertyReference(*result, 0);
    if (!find_ref_at(pos, &set, &idx, &prop_ref)) {
      continue;
    }
    const std::shared_ptr<const CSSValue>* value_ptr = prop_ref.Value();
    if (!value_ptr || !(*value_ptr)) continue;
    bool important = prop_ref.PropertyMetadata().important_ || prio->IsImportant();
    result->SetProperty(CSSPropertyName(custom_name), *value_ptr, important);
  }

  return result;
}

std::shared_ptr<MutableCSSPropertyValueSet> StyleCascade::ExportWinningPropertySet() {
  return BuildWinningPropertySet();
}

const CSSValue* StyleCascade::ResolveSubstitutions(const CSSProperty& property,
                                                   const CSSValue& value,
                                                   CascadeResolver& resolver) {
  if (const auto* v = DynamicTo<CSSUnparsedDeclarationValue>(value)) {
    if (property.GetCSSPropertyName().IsCustomProperty()) {
      return ResolveCustomProperty(property, *v, resolver);
    } else {
      return ResolveVariableReference(property, *v, resolver);
    }
  }
  if (const auto* v = DynamicTo<cssvalue::CSSPendingSubstitutionValue>(value)) {
    return ResolvePendingSubstitution(property, *v, resolver);
  }
  return &value;
}

const CSSValue* StyleCascade::ResolveCustomProperty(
    const CSSProperty& property,
    const CSSUnparsedDeclarationValue& value,
    CascadeResolver& resolver) {
  DCHECK(!property.IsSurrogate());
  DCHECK(!resolver.IsLocked(property));
  CascadeResolver::AutoLock lock(property, resolver);
  
  std::shared_ptr<CSSVariableData> data = value.VariableDataValue();
  
  if (data && data->NeedsVariableResolution()) {
    data = ResolveVariableData(data.get(), resolver);
    if (!data) {
      return CSSInvalidVariableValue::Create().get();
    }
  }
  
  if (resolver.InCycle()) {
    // WebF doesn't have CSSCyclicVariableValue yet, return invalid instead
    return CSSInvalidVariableValue::Create().get();
  }
  
  if (!data) {
    return CSSInvalidVariableValue::Create().get();
  }
  
  if (data == value.VariableDataValue()) {
    return &value;
  }
  
  // If a declaration, once all var() functions are substituted in, contains
  // only a CSS-wide keyword (and possibly whitespace), its value is determined
  // as if that keyword were its specified value all along.
  //
  // https://drafts.csswg.org/css-variables/#substitute-a-var
  // TODO: Implement CSS-wide keyword checking when CSSTokenizer is available
  
  return &value;
}

const CSSValue* StyleCascade::ResolveVariableReference(
    const CSSProperty& property,
    const CSSUnparsedDeclarationValue& value,
    CascadeResolver& resolver) {
  DCHECK(!property.IsSurrogate());
  DCHECK(!resolver.IsLocked(property));
  CascadeResolver::AutoLock lock(property, resolver);
  
  std::shared_ptr<CSSVariableData> data = value.VariableDataValue();
  
  DCHECK(data);
  
  // TODO: Implement full variable reference resolution with ResolveTokensInto
  // For now, if the value contains variable references but we can't resolve them,
  // return unset to use the initial value
  if (data && data->NeedsVariableResolution()) {
    return cssvalue::CSSUnsetValue::Create().get();
  }
  
  // If no variable resolution is needed, we should parse the value
  // TODO: Implement parsing when CSSTokenizer and proper parser context is available
  
  return cssvalue::CSSUnsetValue::Create().get();
}

const CSSValue* StyleCascade::ResolvePendingSubstitution(
    const CSSProperty& property,
    const cssvalue::CSSPendingSubstitutionValue& value,
    CascadeResolver& resolver) {
  DCHECK(!property.IsSurrogate());
  DCHECK(!resolver.IsLocked(property));
  CascadeResolver::AutoLock lock(property, resolver);

  DCHECK_NE(property.PropertyID(), CSSPropertyID::kVariable);

  // Pending substitution values represent shorthand properties that contain
  // var() references. In WebF's current implementation, we'll return unset
  // to use the initial value, as we don't have full variable substitution yet.
  //
  // In Blink, this would parse the shorthand value, resolve variables,
  // and return the appropriate longhand values.
  return cssvalue::CSSUnsetValue::Create().get();
}


// https://drafts.csswg.org/css-cascade-4/#default
StyleCascadeOrigin TargetOriginForRevert(CascadeOrigin origin) {
  switch (origin) {
    case CascadeOrigin::kUserAgent:
      return StyleCascadeOrigin::kNone;
    case CascadeOrigin::kUser:
      return StyleCascadeOrigin::kUserAgent;
    case CascadeOrigin::kAuthor:
      return StyleCascadeOrigin::kUser;
    default:
      return StyleCascadeOrigin::kNone;
  }
}

const CSSValue* StyleCascade::ResolveRevert(const CSSProperty& property,
                                            const CSSValue& value,
                                            CascadeOrigin& origin,
                                            CascadeResolver& resolver) {
  StyleCascadeOrigin target_origin = TargetOriginForRevert(origin);
  
  switch (target_origin) {
    case StyleCascadeOrigin::kNone:
      return cssvalue::CSSUnsetValue::Create().get();
    case StyleCascadeOrigin::kUserAgent:
    case StyleCascadeOrigin::kUser:
    case StyleCascadeOrigin::kAuthor: {
      const CascadePriority* p =
          map_.Find(property.GetCSSPropertyName(), target_origin);
      if (!p || !p->HasOrigin()) {
        origin = CascadeOrigin::kUserAgent;  // Default to user agent instead of kNone
        return cssvalue::CSSUnsetValue::Create().get();
      }
      // Convert StyleCascadeOrigin back to CascadeOrigin
      StyleCascadeOrigin style_origin = p->GetOrigin();
      if (style_origin == StyleCascadeOrigin::kUserAgent ||
          style_origin == StyleCascadeOrigin::kImportantUserAgent) {
        origin = CascadeOrigin::kUserAgent;
      } else if (style_origin == StyleCascadeOrigin::kUser ||
                 style_origin == StyleCascadeOrigin::kImportantUser) {
        origin = CascadeOrigin::kUser;
      } else {
        origin = CascadeOrigin::kAuthor;
      }
      return Resolve(property, *ValueAt(match_result_, p->GetPosition()),
                     *p, origin, resolver);
    }
    default:
      // For other origins like kAnimation, kTransition, etc.
      return cssvalue::CSSUnsetValue::Create().get();
  }
}

const CSSValue* StyleCascade::ResolveRevertLayer(const CSSProperty& property,
                                                 CascadePriority priority,
                                                 CascadeOrigin& origin,
                                                 CascadeResolver& resolver) {
  const CascadePriority* p = map_.FindRevertLayer(
      property.GetCSSPropertyName(), priority.ForLayerComparison());
  if (!p || !p->HasOrigin()) {
    origin = CascadeOrigin::kUserAgent;  // Default to user agent instead of kNone
    return cssvalue::CSSUnsetValue::Create().get();
  }
  // Convert StyleCascadeOrigin back to CascadeOrigin
  StyleCascadeOrigin style_origin = p->GetOrigin();
  if (style_origin == StyleCascadeOrigin::kUserAgent ||
      style_origin == StyleCascadeOrigin::kImportantUserAgent) {
    origin = CascadeOrigin::kUserAgent;
  } else if (style_origin == StyleCascadeOrigin::kUser ||
             style_origin == StyleCascadeOrigin::kImportantUser) {
    origin = CascadeOrigin::kUser;
  } else {
    origin = CascadeOrigin::kAuthor;
  }
  return Resolve(property, *ValueAt(match_result_, p->GetPosition()),
                 *p, origin, resolver);
}

std::shared_ptr<CSSVariableData> StyleCascade::ResolveVariableData(
    CSSVariableData* data,
    CascadeResolver& resolver) {
  DCHECK(data && data->NeedsVariableResolution());
  
  // WebF doesn't have full token stream support yet, so we'll return nullptr
  // to indicate that we can't resolve variables within variable data yet.
  // This will cause the calling code to treat it as invalid.
  //
  // In Blink, this would:
  // 1. Create a TokenSequence from the variable data
  // 2. Parse the original text as a token stream
  // 3. Call ResolveTokensInto to resolve all var() references
  // 4. Build new variable data from the resolved tokens
  //
  // When CSSTokenizer and full parser support is available, this should be
  // implemented following Blink's pattern.
  return nullptr;
}

const CSSProperty& StyleCascade::ResolveSurrogate(const CSSProperty& property) {
  if (!property.IsSurrogate()) {
    return property;
  }
  // This marks the cascade as dependent on cascade-affecting properties
  // even for simple surrogates like -webkit-writing-mode, but there isn't
  // currently a flag to distinguish such surrogates from e.g. css-logical
  // properties.
  depends_on_cascade_affecting_property_ = true;
  
  // For now, use default writing direction (horizontal-tb, ltr)
  // TODO: Get actual writing direction from the current style when available
  WritingDirectionMode writing_direction(WritingMode::kHorizontalTb, TextDirection::kLtr);
  
  const CSSProperty* original = property.SurrogateFor(writing_direction);
  DCHECK(original);
  return *original;
}

}  // namespace webf
