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

TestStyleSheet::~TestStyleSheet() = default;

TestStyleSheet::TestStyleSheet() {
  document_ = Document::Create(execution_context_, ASSERT_NO_EXCEPTION());
  style_sheet_ = CreateStyleSheet(*document_);
}

CSSStyleSheet* CreateStyleSheet(Document& document) {
  return CSSStyleSheet::CreateInline(document, NullURL(), TextPosition::MinimumPosition());
}

std::shared_ptr<CSSVariableData> CreateVariableData(std::string s) {
  bool is_animation_tainted = false;
  bool needs_variable_resolution = false;
  return CSSVariableData::Create(s, is_animation_tainted, needs_variable_resolution);
}

std::shared_ptr<const CSSValue> CreateCustomIdent(const char* s) {
  return std::make_shared<CSSCustomIdentValue>(std::string(s));
}

std::shared_ptr<const CSSValue> ParseLonghand(Document& document,
                                              const CSSProperty& property,
                                              const std::string& value) {
  const auto* longhand = DynamicTo<Longhand>(property);
  if (!longhand) {
    return nullptr;
  }

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode, &document);
  CSSParserLocalContext local_context;

  CSSTokenizer tokenizer(value);
  CSSParserTokenStream stream(tokenizer);
  return longhand->ParseSingleValue(stream, context, local_context);
}

std::shared_ptr<const CSSPropertyValueSet> ParseDeclarationBlock(const std::string& block_text, CSSParserMode mode) {
  auto set = std::make_shared<MutableCSSPropertyValueSet>(mode);
  set->ParseDeclarationList(block_text, nullptr);
  return set;
}

std::shared_ptr<StyleRuleBase> ParseRule(Document& document, const std::string& text) {
  MemberMutationScope scope{document.GetExecutingContext()};
  auto* sheet = CSSStyleSheet::CreateInline(document, NullURL(), TextPosition::MinimumPosition());
  const auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  return CSSParser::ParseRule(context, sheet->Contents(), CSSNestingType::kNone,
                              /*parent_rule_for_nesting=*/nullptr, text);
}

std::shared_ptr<const CSSValue> ParseValue(Document& document, std::string syntax, std::string value) {
  auto syntax_definition = CSSSyntaxStringParser(syntax).Parse();
  if (!syntax_definition.has_value()) {
    return nullptr;
  }
  const auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  return syntax_definition->Parse(value, context,
                                  /* is_animation_tainted */ false);
}

std::shared_ptr<CSSSelectorList> ParseSelectorList(const std::string& string) {
  return ParseSelectorList(string, CSSNestingType::kNone,
                           /*parent_rule_for_nesting=*/nullptr,
                           /*is_within_scope=*/false);
}

std::shared_ptr<CSSSelectorList> ParseSelectorList(const std::string& string,
                                                   CSSNestingType nesting_type,
                                                   std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                                   bool is_within_scope) {
  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);
  CSSTokenizer tokenizer(string);
  CSSParserTokenStream stream(tokenizer);
  std::vector<CSSSelector> arena;
  tcb::span<CSSSelector> vector = CSSSelectorParser::ParseSelector(
      stream, context, nesting_type, std::move(parent_rule_for_nesting), is_within_scope,
      /* semicolon_aborts_nested_selector */ false, sheet, arena);
  return CSSSelectorList::AdoptSelectorVector(vector);
}

}  // namespace css_test_helpers

}  // namespace webf
