// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_test_helpers.h"
#include "core/css/css_custom_ident_value.h"
#include "core/css/css_style_sheet.h"
#include "core/css/css_syntax_string_parser.h"
#include "core/css/css_variable_data.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_local_context.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_selector_parser.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "gtest/gtest.h"
#include "longhands.h"

namespace webf {

namespace css_test_helpers {

TestStyleSheet::~TestStyleSheet() {
  // Ensure proper cleanup order
  style_sheet_ = nullptr;
  document_ = nullptr;
  execution_context_ = nullptr;
  env_.reset();
}

TestStyleSheet::TestStyleSheet() {
  // Properly initialize the test environment
  env_ = TEST_init();
  execution_context_ = env_->page()->executingContext();
  // Use the document from the page instead of creating a new one
  document_ = execution_context_->document();
  style_sheet_ = CreateStyleSheet(*document_);
}

CSSStyleSheet* CreateStyleSheet(Document& document) {
  // Create parser context without Document to avoid memory leaks in tests
  auto parser_context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto contents = std::make_shared<StyleSheetContents>(parser_context, NullURL().GetString());
  return CSSStyleSheet::CreateInline(document.GetExecutingContext(), contents, document, TextPosition::MinimumPosition());
}

std::shared_ptr<CSSVariableData> CreateVariableData(const String& s) {
  bool is_animation_tainted = false;
  bool needs_variable_resolution = false;
  return CSSVariableData::Create(s, is_animation_tainted, needs_variable_resolution);
}

std::shared_ptr<const CSSValue> CreateCustomIdent(const char* s) {
  return std::make_shared<CSSCustomIdentValue>(AtomicString::CreateFromUTF8(s));
}

std::shared_ptr<const CSSValue> ParseLonghand(Document& document,
                                              const CSSProperty& property,
                                              const String& value) {
  const auto* longhand = DynamicTo<Longhand>(property);
  if (!longhand) {
    return nullptr;
  }

  // Create parser context without Document to avoid memory leaks in tests
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  CSSParserLocalContext local_context;

  CSSTokenizer tokenizer{StringView(value)};
  CSSParserTokenStream stream(tokenizer);
  return longhand->ParseSingleValue(stream, context, local_context);
}

std::shared_ptr<const CSSPropertyValueSet> ParseDeclarationBlock(const String& block_text, CSSParserMode mode) {
  auto set = std::make_shared<MutableCSSPropertyValueSet>(mode);
  auto context = std::make_shared<CSSParserContext>(mode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  set->ParseDeclarationList(AtomicString(block_text), sheet);
  return set;
}

std::shared_ptr<StyleRuleBase> ParseRule(Document& document, const String& text) {
  // Note: Document parameter kept for API compatibility but not used
  // Use a temporary shared_ptr for the sheet contents instead of creating a full CSSStyleSheet
  const auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet_contents = std::make_shared<StyleSheetContents>(context);
  return CSSParser::ParseRule(context, sheet_contents, CSSNestingType::kNone,
                              /*parent_rule_for_nesting=*/nullptr, text);
}

std::shared_ptr<const CSSValue> ParseValue(Document& document, const String& syntax, const String& value) {
  auto syntax_definition = CSSSyntaxStringParser(syntax).Parse();
  if (!syntax_definition.has_value()) {
    return nullptr;
  }
  const auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  return syntax_definition->Parse(value.ToStringView(), context,
                                  /* is_animation_tainted */ false);
}

std::shared_ptr<CSSSelectorList> ParseSelectorList(const String& string) {
  return ParseSelectorList(string, CSSNestingType::kNone,
                           /*parent_rule_for_nesting=*/nullptr);
}

std::shared_ptr<CSSSelectorList> ParseSelectorList(const String& string,
                                                   CSSNestingType nesting_type,
                                                   std::shared_ptr<const StyleRule> parent_rule_for_nesting) {
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  CSSTokenizer tokenizer{StringView(string)};
  CSSParserTokenStream stream(tokenizer);
  std::vector<CSSSelector> arena;
  tcb::span<CSSSelector> vector = CSSSelectorParser::ParseSelector(
      stream, context, nesting_type, std::move(parent_rule_for_nesting),
      /* semicolon_aborts_nested_selector */ false, sheet, arena);
  return CSSSelectorList::AdoptSelectorVector(vector);
}

}  // namespace css_test_helpers

}  // namespace webf
