/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "webf_test_env.h"
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "core/css/css_default_style_sheets.h"
#include "core/css/rule_set.h"
#include "core/css/media_query_evaluator.h"
#include "core/css/selector_checker.h"
#include "core/css/element_rule_collector.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/dom/document.h"
#include "core/html/html_element.h"
#include "core/html/html_body_element.h"
#include "core/css/parser/css_parser.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/parser/css_parser_context.h"
#include "foundation/string/wtf_string.h"

namespace webf {

class SelectorTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
    context_ = env_->page()->executingContext();
    document_ = context_->document();
  }

  void TearDown() override {
    document_ = nullptr;
    context_ = nullptr;
    env_.reset();
  }

  Document* GetDocument() { return document_; }

 private:
  std::unique_ptr<WebFTestEnv> env_;
  ExecutingContext* context_ = nullptr;
  Document* document_ = nullptr;
};

TEST_F(SelectorTest, SimpleSelectorMatching) {
  MemberMutationScope mutation_scope{GetDocument()->GetExecutingContext()};
  
  // Get body element
  auto* body = GetDocument()->body();
  ASSERT_NE(body, nullptr);
  
  // Create simple CSS
  String simple_css = "body { display: block; }"_s;
  
  auto parser_context = std::make_shared<CSSParserContext>(kUASheetMode);
  auto sheet = std::make_shared<StyleSheetContents>(parser_context);
  
  CSSParser::ParseSheet(parser_context, sheet, simple_css);
  
  EXPECT_EQ(sheet->RuleCount(), 1u);
  
  // Create RuleSet
  auto rule_set = std::make_shared<RuleSet>();
  MediaQueryEvaluator evaluator("screen");
  rule_set->AddRulesFromSheet(sheet, evaluator, kRuleHasNoSpecialState);
  
  // Get body rules
  const auto& body_rules = rule_set->TagRules(AtomicString::CreateFromUTF8("body"));
  ASSERT_GT(body_rules.size(), 0u);
  
  // Test selector matching directly
  auto& rule_data = body_rules[0];
  ASSERT_NE(rule_data, nullptr);
  
  // Create selector checker
  SelectorChecker checker(SelectorChecker::kResolvingStyle);
  
  // Create checking context
  SelectorChecker::SelectorCheckingContext context(body);
  context.selector = &rule_data->Selector();
  
  // Try to match
  SelectorChecker::MatchResult result;
  bool matched = checker.Match(context, result);
  
  EXPECT_TRUE(matched) << "Selector should match body element";
}

}  // namespace webf