// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_TEST_HELPERS_H_
#define WEBF_CORE_CSS_CSS_TEST_HELPERS_H_

#include <optional>
#include "core/executing_context.h"
#include "core/css/css_property_value_set.h"
#include "core/css/style_rule.h"
#include "foundation/macros.h"

namespace webf {

class Document;
class CSSStyleSheet;
class CSSVariableData;
class CSSValue;
class CSSProperty;
class PropertyRegistration;

namespace css_test_helpers {

// Example usage:
//
// css_test_helpers::TestStyleSheet sheet;
// sheet.addCSSRule("body { color: red} #a { position: absolute }");
// RuleSet& ruleSet = sheet.ruleSet();
// ... examine RuleSet to find the rule and test properties on it.
class TestStyleSheet {
  WEBF_DISALLOW_NEW();

 public:
  TestStyleSheet();
  ~TestStyleSheet();

  const Document& GetDocument() { return *document_; }

  void AddCSSRules(const std::string& rule_text, bool is_empty_sheet = false);
//  RuleSet& GetRuleSet();
//  CSSRuleList* CssRules();

 private:
  ExecutingContext* execution_context_;
  Document* document_;
  CSSStyleSheet* style_sheet_;
};

CSSStyleSheet* CreateStyleSheet(Document& document);

std::shared_ptr<CSSVariableData> CreateVariableData(std::string);
std::shared_ptr<const CSSValue> CreateCustomIdent(const char*);
std::shared_ptr<const CSSValue> ParseLonghand(Document& document,
                              const CSSProperty&,
                              const std::string& value);
std::shared_ptr<const CSSPropertyValueSet> ParseDeclarationBlock(
    const std::string& block_text,
    CSSParserMode mode = kHTMLStandardMode);
std::shared_ptr<StyleRuleBase> ParseRule(Document& document, std::string text);

// Parse a value according to syntax defined by:
// https://drafts.css-houdini.org/css-properties-values-api-1/#syntax-strings
std::shared_ptr<const CSSValue> ParseValue(Document&, std::string syntax, std::string value);

std::shared_ptr<CSSSelectorList> ParseSelectorList(const std::string&);
// Parse the selector as if nested with the given CSSNestingType, using
// the specified StyleRule to resolve either the parent selector "&"
// (for kNesting), or the :scope pseudo-class (for kScope).
std::shared_ptr<CSSSelectorList> ParseSelectorList(const std::string&,
                                   CSSNestingType,
                                   std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                   bool is_within_scope);

}  // namespace css_test_helpers
}  // namespace blink

#endif  // WEBF_CORE_CSS_CSS_TEST_HELPERS_H_