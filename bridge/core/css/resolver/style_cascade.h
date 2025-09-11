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

#ifndef WEBF_CORE_CSS_RESOLVER_STYLE_CASCADE_H_
#define WEBF_CORE_CSS_RESOLVER_STYLE_CASCADE_H_

#include <memory>
#include <utility>
#include "core/css/css_property_name.h"
#include "core/css/css_property_value.h"
#include "core/css/properties/css_bitset.h"
#include "core/css/properties/css_property.h"
#include "core/css/resolver/cascade_filter.h"
#include "core/css/resolver/cascade_map.h"
#include "core/css/resolver/cascade_origin.h"
#include "core/css/resolver/cascade_priority.h"
#include "core/css/match_result.h"
#include "foundation/macros.h"

namespace webf {

namespace cssvalue {
class CSSPendingSubstitutionValue;
}  // namespace cssvalue

class CascadeResolver;
class CSSParserContext;
class CSSProperty;
class CSSUnparsedDeclarationValue;
class CSSValue;
class CSSVariableData;
class MatchResult;
class StyleResolverState;

// StyleCascade analyzes declarations provided by CSS rules and animations,
// and figures out which declarations should be skipped, and which should be
// applied (and in which order).
//
// Usage:
//
//   StyleCascade cascade(state);
//   cascade.MutableMatchResult().AddMatchedProperties(...matched rule...);
//   cascade.MutableMatchResult().AddMatchedProperties(...another rule...);
//   cascade.Apply();
//
// [1] https://drafts.csswg.org/css-cascade/#cascade
class StyleCascade {
  WEBF_STACK_ALLOCATED();

 public:
  StyleCascade(StyleResolverState& state) : state_(state) {}
  StyleCascade(const StyleCascade&) = delete;
  StyleCascade& operator=(const StyleCascade&) = delete;

  const MatchResult& GetMatchResult() { return match_result_; }

  // Access the MatchResult in order to add declarations to it.
  // The modifications made will be taken into account during Apply().
  //
  // It is invalid to modify the MatchResult after Apply has been called
  // (unless Reset is called first).
  MatchResult& MutableMatchResult();

  // Applies the current CSS declarations to the StyleResolverState.
  //
  // It is valid to call Apply multiple times (up to 15), and each call may
  // provide a different filter.
  void Apply(CascadeFilter = CascadeFilter());

  // Returns a CSSBitset containing the !important declarations (analyzing
  // if needed). If there are no !important declarations, returns nullptr.
  std::unique_ptr<CSSBitset> GetImportantSet();

  bool InlineStyleLost() const { return map_.InlineStyleLost(); }

  // Resets the cascade to its initial state. Note that this does not undo
  // any changes already applied to the StyleResolverState/ComputedStyle.
  void Reset();

  // Resolves a value in the context of the cascade.
  const CSSValue* Resolve(const CSSPropertyName&,
                          const CSSValue&,
                          CascadeOrigin,
                          CascadeResolver&);

  // Public wrapper to export the winning declared values as a property set.
  std::shared_ptr<MutableCSSPropertyValueSet> ExportWinningPropertySet();

 private:
  // Before we can Apply the cascade, the MatchResult must be Analyzed.
  // This means going through all the declarations, and adding them to
  // the CascadeMap, which gives us a complete picture of which
  // declarations won the cascade.
  void AnalyzeIfNeeded();
  void AnalyzeMatchResult();

  // Apply methods for different phases of cascade application
  void ApplyCascadeAffecting(CascadeResolver&);
  void ApplyHighPriority(CascadeResolver&);
  void ApplyMatchResult(CascadeResolver&);

  // Looks up a value and applies it
  void LookupAndApply(const CSSPropertyName&, CascadeResolver&);
  void LookupAndApply(const CSSProperty&, CascadeResolver&);
  void LookupAndApplyValue(const CSSProperty&,
                           CascadePriority*,
                           CascadeResolver&);
  void LookupAndApplyDeclaration(const CSSProperty&,
                                 CascadePriority*,
                                 CascadeResolver&);

  // Helper to get values from match result
  const CSSValue* ValueAt(const MatchResult&, uint32_t position) const;

  // Resolve methods
  const CSSValue* Resolve(const CSSProperty&,
                          const CSSValue&,
                          CascadePriority,
                          CascadeOrigin&,
                          CascadeResolver&);

  // Build a property set containing the winning declared values from the
  // current cascade match result. This preserves original CSSValue objects
  // (no evaluation), suitable for emitting to Dart or persisting as inline style.
  std::shared_ptr<MutableCSSPropertyValueSet> BuildWinningPropertySet();
  const CSSValue* ResolveSubstitutions(const CSSProperty&,
                                       const CSSValue&,
                                       CascadeResolver&);
  const CSSValue* ResolveCustomProperty(const CSSProperty&,
                                        const CSSUnparsedDeclarationValue&,
                                        CascadeResolver&);
  const CSSValue* ResolveVariableReference(const CSSProperty&,
                                           const CSSUnparsedDeclarationValue&,
                                           CascadeResolver&);
  const CSSValue* ResolvePendingSubstitution(const CSSProperty&,
                                             const cssvalue::CSSPendingSubstitutionValue&,
                                             CascadeResolver&);
  const CSSValue* ResolveRevert(const CSSProperty&,
                                const CSSValue&,
                                CascadeOrigin&,
                                CascadeResolver&);
  const CSSValue* ResolveRevertLayer(const CSSProperty&,
                                     CascadePriority,
                                     CascadeOrigin&,
                                     CascadeResolver&);

  std::shared_ptr<CSSVariableData> ResolveVariableData(CSSVariableData*,
                                                        CascadeResolver&);

  const CSSProperty& ResolveSurrogate(const CSSProperty&);

  StyleResolverState& state_;
  MatchResult match_result_;
  CascadeMap map_;

  // Generation is a number that's incremented by one for each call to Apply
  // (the first call to Apply has generation 1).
  uint8_t generation_ = 0;

  bool needs_match_result_analyze_ = false;
  bool depends_on_cascade_affecting_property_ = false;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_STYLE_CASCADE_H_
