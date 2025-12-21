/*
 * Copyright (C) 2020 Google Inc. All rights reserved.
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

#ifndef WEBF_CORE_CSS_RESOLVER_CASCADE_RESOLVER_H_
#define WEBF_CORE_CSS_RESOLVER_CASCADE_RESOLVER_H_

#include <vector>
#include "core/css/css_property_name.h"
#include "core/css/properties/css_property.h"
#include "core/css/resolver/cascade_filter.h"
#include "core/css/resolver/cascade_origin.h"
#include "foundation/macros.h"
// For caching parsed longhands from pending substitutions
#include "core/css/css_property_value.h"

namespace webf { namespace cssvalue { class CSSPendingSubstitutionValue; } }

namespace webf {

class CSSProperty;
class CSSVariableData;

// CascadeResolver is an object passed on the stack during Apply. Its most
// important job is to detect cycles during Apply (in general, keep track of
// which properties we're currently applying).
 class CascadeResolver {
  WEBF_STACK_ALLOCATED();

 public:
  // A 'locked' property is a property we are in the process of applying.
  // In other words, once a property is locked, locking it again would form
  // a cycle, and is therefore an error.
  bool IsLocked(const CSSProperty& property) const;

  // Returns the property we're currently applying.
  const CSSProperty* CurrentProperty() const {
    return stack_.empty() ? nullptr : stack_.back();
  }

  // We do not allow substitution of animation-tainted values into
  // an animation-affecting property.
  //
  // https://drafts.csswg.org/css-variables/#animation-tainted
  bool AllowSubstitution(CSSVariableData*) const;

  bool Rejects(const CSSProperty& property) {
    if (filter_.Accepts(property)) {
      return false;
    }
    rejected_flags_ |= property.GetFlags();
    return true;
  }

  // Collects CSSProperty::Flags from the given property. The Flags() function
  // can then be used to see which flags have been observed..
  void CollectFlags(const CSSProperty& property, StyleCascadeOrigin origin) {
    CSSProperty::Flags flags = property.GetFlags();
    author_flags_ |= (origin == StyleCascadeOrigin::kAuthor ? flags : 0);
    flags_ |= flags;
  }

  CSSProperty::Flags Flags() const { return flags_; }

  // Like Flags, but for the author origin only.
  CSSProperty::Flags AuthorFlags() const { return author_flags_; }

  // The CSSProperty::Flags of all properties rejected by the CascadeFilter.
  CSSProperty::Flags RejectedFlags() const { return rejected_flags_; }

  // Automatically locks and unlocks the given property. (See
  // CascadeResolver::IsLocked).
  class AutoLock {
    WEBF_STACK_ALLOCATED();

   public:
    AutoLock(const CSSProperty& property, CascadeResolver& resolver);
    ~AutoLock();

   private:
    CascadeResolver& resolver_;
  };

 private:
  friend class AutoLock;
  friend class StyleCascade;
  friend class TestCascadeResolver;

  CascadeResolver(CascadeFilter filter, uint8_t generation)
      : filter_(filter), generation_(generation) {}

  // If the given property is already being applied, returns true.
  bool DetectCycle(const CSSProperty& property);
  
  // Returns true whenever the CascadeResolver is in a cycle state.
  // This DOES NOT detect cycles; the caller must call DetectCycle first.
  bool InCycle() const { return cycle_depth_ > 0; }

  std::vector<const CSSProperty*> stack_;
  size_t cycle_depth_ = 0;
  CascadeFilter filter_;
  const uint8_t generation_ = 0;
  CSSProperty::Flags author_flags_ = 0;
  CSSProperty::Flags flags_ = 0;
  CSSProperty::Flags rejected_flags_ = 0;

  // Cache for resolving CSSPendingSubstitutionValue like Blink
  struct PendingSubstitutionCache {
    const cssvalue::CSSPendingSubstitutionValue* value = nullptr;
    std::vector<CSSPropertyValue> parsed_properties;
  } shorthand_cache_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_CASCADE_RESOLVER_H_
