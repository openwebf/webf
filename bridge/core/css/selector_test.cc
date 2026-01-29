/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "webf_test_env.h"
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "core/css/rule_set.h"
#include "core/css/media_query_evaluator.h"
#include "core/css/selector_checker.h"
#include "core/css/selector_filter.h"
#include "core/css/element_rule_collector.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/dom/document.h"
#include "core/html/html_element.h"
#include "core/html/html_body_element.h"
#include "core/html/html_div_element.h"
#include "core/html/html_heading_element.h"
#include "core/html/html_span_element.h"
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

TEST_F(SelectorTest, DescendantSelectorWithAncestorAttributeMatchesWhenAttributeStoredInLegacyAttributes) {
  MemberMutationScope mutation_scope{GetDocument()->GetExecutingContext()};
  GetDocument()->GetExecutingContext()->EnableBlinkEngine();

  auto* body = GetDocument()->body();
  ASSERT_NE(body, nullptr);

  String css_text = ".content[data-v-69423fe3] .at { color: green; }"_s;

  auto parser_context = std::make_shared<CSSParserContext>(kUASheetMode);
  auto sheet = std::make_shared<StyleSheetContents>(parser_context);
  CSSParser::ParseSheet(parser_context, sheet, css_text);

  auto rule_set = std::make_shared<RuleSet>();
  MediaQueryEvaluator evaluator("screen");
  rule_set->AddRulesFromSheet(sheet, evaluator, kRuleHasNoSpecialState);

  auto* container = MakeGarbageCollected<HTMLDivElement>(*GetDocument());
  container->setAttribute(AtomicString::CreateFromUTF8("class"), AtomicString::CreateFromUTF8("content"));
  container->setAttribute(AtomicString::CreateFromUTF8("data-v-69423fe3"), AtomicString::Empty());

  auto* mid = MakeGarbageCollected<HTMLSpanElement>(*GetDocument());
  mid->setAttribute(AtomicString::CreateFromUTF8("data-v-69423fe3"), AtomicString::Empty());

  auto* at = MakeGarbageCollected<HTMLSpanElement>(*GetDocument());
  at->setAttribute(AtomicString::CreateFromUTF8("class"), AtomicString::CreateFromUTF8("at"));

  body->appendChild(container, ASSERT_NO_EXCEPTION());
  container->appendChild(mid, ASSERT_NO_EXCEPTION());
  mid->appendChild(at, ASSERT_NO_EXCEPTION());

  // Build the same selector filter used during style recalc: the filter
  // contains identifiers from the ancestor chain.
  SelectorFilter selector_filter;
  std::vector<Element*> ancestors;
  for (Element* parent = at->parentElement(); parent; parent = parent->parentElement()) {
    ancestors.push_back(parent);
  }
  for (auto it = ancestors.rbegin(); it != ancestors.rend(); ++it) {
    selector_filter.PushElement(**it);
  }
  selector_filter.PushElement(*at);

  StyleResolverState state(*GetDocument(), *at);
  ElementRuleCollector collector(state, SelectorChecker::kResolvingStyle);
  collector.SetSelectorFilter(&selector_filter);

  MatchRequest match_request(rule_set, CascadeOrigin::kAuthor, 0);
  collector.CollectMatchingRules(match_request);
  collector.SortAndTransferMatchedRules();

  EXPECT_FALSE(collector.GetMatchResult().IsEmpty());
}

TEST_F(SelectorTest, DescendantSelectorWithCompoundAncestorMatchesWhenAttributeStoredInLegacyAttributes) {
  MemberMutationScope mutation_scope{GetDocument()->GetExecutingContext()};
  GetDocument()->GetExecutingContext()->EnableBlinkEngine();

  auto* body = GetDocument()->body();
  ASSERT_NE(body, nullptr);

  String css_text = ".content[_ngcontent-abc] h1[_ngcontent-abc] { margin-top: 20px; }"_s;

  auto parser_context = std::make_shared<CSSParserContext>(kUASheetMode);
  auto sheet = std::make_shared<StyleSheetContents>(parser_context);
  CSSParser::ParseSheet(parser_context, sheet, css_text);

  auto rule_set = std::make_shared<RuleSet>();
  MediaQueryEvaluator evaluator("screen");
  rule_set->AddRulesFromSheet(sheet, evaluator, kRuleHasNoSpecialState);

  auto* root = MakeGarbageCollected<HTMLDivElement>(*GetDocument());
  root->setAttribute(AtomicString::CreateFromUTF8("class"), AtomicString::CreateFromUTF8("content"));
  root->setAttribute(AtomicString::CreateFromUTF8("_ngcontent-abc"), AtomicString::Empty());

  auto* left = MakeGarbageCollected<HTMLDivElement>(*GetDocument());
  left->setAttribute(AtomicString::CreateFromUTF8("class"), AtomicString::CreateFromUTF8("left-side"));
  left->setAttribute(AtomicString::CreateFromUTF8("_ngcontent-abc"), AtomicString::Empty());

  auto* h1 = MakeGarbageCollected<HTMLHeadingElement>(AtomicString::CreateFromUTF8("h1"), *GetDocument());
  h1->setAttribute(AtomicString::CreateFromUTF8("_ngcontent-abc"), AtomicString::Empty());

  body->appendChild(root, ASSERT_NO_EXCEPTION());
  root->appendChild(left, ASSERT_NO_EXCEPTION());
  left->appendChild(h1, ASSERT_NO_EXCEPTION());

  SelectorFilter selector_filter;
  std::vector<Element*> ancestors;
  for (Element* parent = h1->parentElement(); parent; parent = parent->parentElement()) {
    ancestors.push_back(parent);
  }
  for (auto it = ancestors.rbegin(); it != ancestors.rend(); ++it) {
    selector_filter.PushElement(**it);
  }
  selector_filter.PushElement(*h1);

  StyleResolverState state(*GetDocument(), *h1);
  ElementRuleCollector collector(state, SelectorChecker::kResolvingStyle);
  collector.SetSelectorFilter(&selector_filter);

  MatchRequest match_request(rule_set, CascadeOrigin::kAuthor, 0);
  collector.CollectMatchingRules(match_request);
  collector.SortAndTransferMatchedRules();

  EXPECT_FALSE(collector.GetMatchResult().IsEmpty());
}

}  // namespace webf
