// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_SELECTOR_PARSER_H
#define WEBF_CSS_SELECTOR_PARSER_H

#include <span>
#include "core/base/containers/span.h"
#include "foundation/macros.h"
#include "css_parser_token.h"
#include "css_nesting_type.h"
#include "css_parser_token_range.h"
#include "core/css/css_selector.h"
#include "core/dom/node.h"

namespace webf {

class StyleRule;
class CSSSelector;
class CSSParserContext;
class CSSParserTokenStream;
class StyleSheetContents;
class CSSParserObserver;
class CSSSelectorList;

class CSSSelectorParser {
  WEBF_STACK_ALLOCATED();
 public:
  static tcb::span<CSSSelector> ParseSelector(
      CSSParserTokenStream&,
      std::shared_ptr<const CSSParserContext>,
      CSSNestingType,
      std::shared_ptr<const StyleRule> parent_rule_for_nesting,
      bool is_within_scope,
      bool semicolon_aborts_nested_selector,
      std::shared_ptr<StyleSheetContents>,
      std::vector<CSSSelector>&);

  static tcb::span<CSSSelector> ConsumeSelector(
      CSSParserTokenStream&,
      std::shared_ptr<const CSSParserContext>,
      CSSNestingType,
      std::shared_ptr<const StyleRule> parent_rule_for_nesting,
      bool is_within_scope,
      bool semicolon_aborts_nested_selector,
      std::shared_ptr<StyleSheetContents>,
      std::shared_ptr<CSSParserObserver>,
      std::vector<CSSSelector>&);

  static bool ConsumeANPlusB(CSSParserTokenStream&, std::pair<int, int>&);
  std::shared_ptr<const CSSSelectorList> ConsumeNthChildOfSelectors(CSSParserTokenStream&);

  static bool SupportsComplexSelector(CSSParserTokenStream&,
                                      std::shared_ptr<const CSSParserContext>);

  static CSSSelector::PseudoType ParsePseudoType(const std::string& name,
                                                 bool has_arguments,
                                                 const Document*);

  static PseudoId ParsePseudoElement(const std::string& selector_string, const Node* parent, AtomicString& argument);

  // https://drafts.csswg.org/css-cascade-6/#typedef-scope-start
  // https://drafts.csswg.org/css-cascade-6/#typedef-scope-end
  //
  // Parse errors are signalled by returning std::nullopt. Empty spans are
  // normal and expected, since <scope-start> / <scope-end> are forgiving
  // selector lists.
  static std::optional<tcb::span<CSSSelector>> ParseScopeBoundary(
      CSSParserTokenStream&,
      std::shared_ptr<const CSSParserContext>,
      CSSNestingType,
      std::shared_ptr<const StyleRule> parent_rule_for_nesting,
      bool is_within_scope,
      std::shared_ptr<StyleSheetContents>,
      std::vector<CSSSelector>&);

 private:
  CSSSelectorParser(std::shared_ptr<const CSSParserContext>,
                    std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                    bool is_within_scope,
                    bool semicolon_aborts_nested_selector,
                    std::shared_ptr<StyleSheetContents>,
                    std::vector<CSSSelector>&);

  // These will all consume trailing comments if successful.

  // If CSSNestingType::kNesting is passed, we're at the top level of a nested
  // style rule, which means:
  //
  //  - If the rule starts with a combinator (e.g. “> .a”), we will prepend
  //    an implicit & (parent selector).
  //  - If the selector parses but is not nest-containing
  //    (this cannot happen in the previous situation, of course),
  //    we will also prepend an implicit &, making a descendant selector
  //    (so e.g. “.a” becomes “& .a”.)
  //
  // CSSNestingType::kScope is similar, but will prepend relative selectors with
  // :scope instead of &.
  tcb::span<CSSSelector> ConsumeComplexSelectorList(CSSParserTokenStream& stream,
                                                     CSSNestingType);
  tcb::span<CSSSelector> ConsumeComplexSelectorList(
      CSSParserTokenStream& stream,
      std::shared_ptr<CSSParserObserver> observer,
      CSSNestingType);
  std::shared_ptr<CSSSelectorList> ConsumeCompoundSelectorList(CSSParserTokenStream&);
  // Consumes a complex selector list if inside_compound_pseudo_ is false,
  // otherwise consumes a compound selector list.
  std::shared_ptr<CSSSelectorList> ConsumeNestedSelectorList(CSSParserTokenStream&);
  std::shared_ptr<CSSSelectorList> ConsumeForgivingNestedSelectorList(CSSParserTokenStream&);
  // https://drafts.csswg.org/selectors/#typedef-forgiving-selector-list
  std::optional<tcb::span<CSSSelector>> ConsumeForgivingComplexSelectorList(
      CSSParserTokenStream&,
      CSSNestingType);
  std::shared_ptr<CSSSelectorList> ConsumeForgivingCompoundSelectorList(CSSParserTokenStream&);
  // https://drafts.csswg.org/selectors/#typedef-relative-selector-list
  std::shared_ptr<CSSSelectorList> ConsumeForgivingRelativeSelectorList(CSSParserTokenStream&);
  std::shared_ptr<CSSSelectorList> ConsumeRelativeSelectorList(CSSParserTokenStream&);
  void AddPlaceholderSelectorIfNeeded(CSSParserTokenStream& argument);

  tcb::span<CSSSelector> ConsumeNestedRelativeSelector(
      CSSParserTokenStream& stream,
      CSSNestingType);
  tcb::span<CSSSelector> ConsumeRelativeSelector(CSSParserTokenStream&);
  tcb::span<CSSSelector> ConsumeComplexSelector(
      CSSParserTokenStream& stream,
      CSSNestingType,
      bool first_in_complex_selector_list);

  // ConsumePartialComplexSelector() method provides the common logic of
  // consuming a complex selector and consuming a relative selector.
  //
  // After consuming the left-most combinator of a relative selector, we can
  // consume the remaining selectors with the common logic.
  // For example, after consuming the left-most combinator '~' of the relative
  // selector '~ .a ~ .b', we can consume remaining selectors '.a ~ .b'
  // with this method.
  //
  // After consuming the left-most compound selector and a combinator of a
  // complex selector, we can also use this method to consume the remaining
  // selectors of the complex selector.
  //
  // Returns false if parse error.
  bool ConsumePartialComplexSelector(
      CSSParserTokenStream&,
      CSSSelector::RelationType& /* current combinator */,
      unsigned /* previous compound flags */,
      CSSNestingType);

  bool ConsumeName(CSSParserTokenStream&,
                   AtomicString& name,
                   AtomicString& namespace_prefix);

  // These will return true iff the selector is valid;
  // otherwise, the vector will be pushed onto output_.
  bool ConsumeId(CSSParserTokenStream&);
  bool ConsumeClass(CSSParserTokenStream&);
  bool ConsumeAttribute(CSSParserTokenStream&);
  bool ConsumePseudo(CSSParserTokenStream&);
  bool ConsumeNestingParent(CSSParserTokenStream& stream);
  // This doesn't include element names, since they're handled specially
  bool ConsumeSimpleSelector(CSSParserTokenStream&);

  const std::string DefaultNamespace() const;
  AtomicString DetermineNamespace(const AtomicString& prefix);

  // Returns an empty range on error.
  tcb::span<CSSSelector> ConsumeCompoundSelector(CSSParserTokenStream&,
                                                  CSSNestingType);

  bool PeekIsCombinator(CSSParserTokenStream& stream);
  CSSSelector::RelationType ConsumeCombinator(CSSParserTokenStream&);
  CSSSelector::MatchType ConsumeAttributeMatch(CSSParserTokenStream&);
  CSSSelector::AttributeMatchType ConsumeAttributeFlags(CSSParserTokenStream&);

  void PrependTypeSelectorIfNeeded(const AtomicString& namespace_prefix,
                                   bool has_element_name,
                                   const AtomicString& element_name,
                                   size_t start_index_of_compound_selector);
  void SplitCompoundAtImplicitShadowCrossingCombinator(
      tcb::span<CSSSelector> compound_selector);

  void SetInSupportsParsing() { in_supports_parsing_ = true; }

  std::shared_ptr<const CSSParserContext> context_;
  // The parent rule pointed to by the nesting selector (&).
  // https://drafts.csswg.org/css-nesting-1/#nest-selector
  std::shared_ptr<const StyleRule> parent_rule_for_nesting_;
  // True if we're parsing a selector within an @scope rule.
  // https://drafts.csswg.org/selectors-4/#scoped-selector
  const bool is_within_scope_;
  // See AbortsNestedSelectorParsing.
  bool semicolon_aborts_nested_selector_ = false;
  std::shared_ptr<const StyleSheetContents> style_sheet_;

  bool failed_parsing_ = false;
  bool disallow_pseudo_elements_ = false;
  // If we're inside a pseudo class that only accepts compound selectors,
  // for example :host, inner :is()/:where() pseudo classes are also only
  // allowed to contain compound selectors.
  bool inside_compound_pseudo_ = false;
  // When parsing a compound which includes a pseudo-element, the simple
  // selectors permitted to follow that pseudo-element may be restricted.
  // If this is the case, then restricting_pseudo_element_ will be set to the
  // PseudoType of the pseudo-element causing the restriction.
  CSSSelector::PseudoType restricting_pseudo_element_ =
      CSSSelector::kPseudoUnknown;
  // If we're _resisting_ the default namespace, it means that we are inside
  // a nested selector (:is(), :where(), etc) where we should _consider_
  // ignoring the default namespace (depending on circumstance). See the
  // relevant spec text [1] regarding default namespaces for information about
  // those circumstances.
  //
  // [1] https://drafts.csswg.org/selectors/#matches
  bool resist_default_namespace_ = false;
  // While this flag is true, the default namespace is ignored. In other words,
  // the default namespace is '*' while this flag is true.
  bool ignore_default_namespace_ = false;

  // The 'found_pseudo_in_has_argument_' flag is true when we found any pseudo
  // in :has() argument while parsing.
  bool found_pseudo_in_has_argument_ = false;
  bool is_inside_has_argument_ = false;

  // The 'found_complex_logical_combinations_in_has_argument_' flag is true when
  // we found any logical combinations (:is(), :where(), :not()) containing
  // complex selector in :has() argument while parsing.
  bool found_complex_logical_combinations_in_has_argument_ = false;
  bool is_inside_logical_combination_in_has_argument_ = false;

  bool in_supports_parsing_ = false;

  // See the comment on ParseSelector(); when we allocate a CSSSelector,
  // it is on this vector (which we effectively use as an arena).
  std::vector<CSSSelector>& output_;

  class DisallowPseudoElementsScope {
    WEBF_STACK_ALLOCATED();

   public:
    explicit DisallowPseudoElementsScope(CSSSelectorParser* parser)
        : parser_(parser), was_disallowed_(parser_->disallow_pseudo_elements_) {
      parser_->disallow_pseudo_elements_ = true;
    }
    DisallowPseudoElementsScope(const DisallowPseudoElementsScope&) = delete;
    DisallowPseudoElementsScope& operator=(const DisallowPseudoElementsScope&) =
        delete;

    ~DisallowPseudoElementsScope() {
      parser_->disallow_pseudo_elements_ = was_disallowed_;
    }

   private:
    CSSSelectorParser* parser_;
    bool was_disallowed_;
  };

  // A RAII-style class that can do two things:
  //
  //  - When it's destroyed, remove any leftover elements from the vector
  //    (typically output_, our working area) that were not there when we
  //    started. This is especially useful in error handling.
  //
  //  - Return a list of what those elements are; they can then either be
  //    stored away somewhere (e.g. a CSSSelectorList) or committed so that
  //    they remain after destruction instead.
  class ResetVectorAfterScope {
    WEBF_STACK_ALLOCATED();

   public:
    explicit ResetVectorAfterScope(std::vector<CSSSelector>& vector)
        : vector_(vector), initial_size_(vector.size()) {}

    ~ResetVectorAfterScope() {
      DCHECK_GE(vector_.size(), initial_size_);
      if (!committed_) {
        vector_.resize(initial_size_);
      }
    }

    tcb::span<CSSSelector> AddedElements() {
      DCHECK_GE(vector_.size(), initial_size_);
      return {(vector_.data() + initial_size_), vector_.data() + vector_.size()};
    }

    // Make sure the added elements are left on the vector after
    // destruction, contrary to common behavior. This is used after
    // a successful parse where we intend to actually return the
    // given elements. Returns AddedElements() for convenience.
    tcb::span<CSSSelector> CommitAddedElements() {
      committed_ = true;
      return AddedElements();
    }

   private:
    std::vector<CSSSelector>& vector_;
    const uint32_t initial_size_;
    bool committed_ = false;
  };
};

// If we are in nesting context, semicolons abort selector parsing
// (so that e.g. “//color: red; font-size: 10px;” stops at the first
// semicolon instead of eating the entire rest of the block -- the
// standard chooses to parse pretty much everything except an ident
// as a qualified rule and thus a selector). However, at the top level,
// due to web-compat reasons, semicolons should _not_ do so,
// and instead keep consuming the selector up until the block.
//
// This function only deals with semicolons, not other things that would
// abort selector parsing (such as EOF).
static inline bool AbortsNestedSelectorParsing(
    CSSParserTokenType token_type,
    bool semicolon_aborts_nested_selector,
    CSSNestingType nesting_type) {
  return semicolon_aborts_nested_selector && token_type == kSemicolonToken &&
         nesting_type != CSSNestingType::kNone;
}

}  // namespace webf

#endif  // WEBF_CSS_SELECTOR_PARSER_H
