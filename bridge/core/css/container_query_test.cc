// Copyright 2024 The WebF Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/container_query.h"
#include "core/css/css_test_helpers.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/parser/container_query_parser.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/css/style_rule.h"
#include "core/dom/document.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

using css_test_helpers::ParseRule;

namespace {

std::shared_ptr<StyleRuleContainer> ParseContainerRule(const String& rule_string) {
  auto context = std::make_shared<CSSParserContext>(CSSParserMode::kHTMLStandardMode,
                                                    kHTMLStandardMode, SecureContextMode::kInsecureContext);
  auto* rule = ParseRule(rule_string, context);
  if (!rule || !rule->IsContainerRule()) {
    return nullptr;
  }
  return std::static_pointer_cast<StyleRuleContainer>(rule);
}

bool IsValidContainerQuery(const String& query_string) {
  auto context = std::make_shared<CSSParserContext>(CSSParserMode::kHTMLStandardMode,
                                                    kHTMLStandardMode, SecureContextMode::kInsecureContext);
  CSSParserTokenizer tokenizer(query_string);
  CSSParserTokenRange range = tokenizer.TokenRange();
  ContainerQueryParser parser(context);
  return parser.ConsumeContainerCondition(range) != nullptr;
}

}  // namespace

TEST(ContainerQuery, BasicContainerRuleParsing) {
  auto env = TEST_init();
  
  // Test basic @container rule
  {
    auto rule = ParseContainerRule("@container (width > 400px) { .item { flex: 1; } }");
    EXPECT_TRUE(rule);
  }
  
  // Test named container
  {
    auto rule = ParseContainerRule("@container sidebar (width > 400px) { .item { flex: 1; } }");
    EXPECT_TRUE(rule);
  }
  
  // Test multiple conditions
  {
    auto rule = ParseContainerRule("@container (width > 400px) and (height > 300px) { .item { flex: 1; } }");
    EXPECT_TRUE(rule);
  }
}

TEST(ContainerQuery, SizeQueries) {
  auto env = TEST_init();
  
  // Width queries
  EXPECT_TRUE(IsValidContainerQuery("(width > 400px)"));
  EXPECT_TRUE(IsValidContainerQuery("(min-width: 400px)"));
  EXPECT_TRUE(IsValidContainerQuery("(max-width: 800px)"));
  EXPECT_TRUE(IsValidContainerQuery("(400px < width < 800px)"));
  
  // Height queries
  EXPECT_TRUE(IsValidContainerQuery("(height > 300px)"));
  EXPECT_TRUE(IsValidContainerQuery("(min-height: 300px)"));
  EXPECT_TRUE(IsValidContainerQuery("(max-height: 600px)"));
  
  // Inline-size queries
  EXPECT_TRUE(IsValidContainerQuery("(inline-size > 400px)"));
  EXPECT_TRUE(IsValidContainerQuery("(min-inline-size: 400px)"));
  EXPECT_TRUE(IsValidContainerQuery("(max-inline-size: 800px)"));
  
  // Block-size queries
  EXPECT_TRUE(IsValidContainerQuery("(block-size > 300px)"));
  EXPECT_TRUE(IsValidContainerQuery("(min-block-size: 300px)"));
  EXPECT_TRUE(IsValidContainerQuery("(max-block-size: 600px)"));
  
  // Aspect-ratio queries
  EXPECT_TRUE(IsValidContainerQuery("(aspect-ratio > 1)"));
  EXPECT_TRUE(IsValidContainerQuery("(min-aspect-ratio: 4/3)"));
  EXPECT_TRUE(IsValidContainerQuery("(max-aspect-ratio: 16/9)"));
  EXPECT_TRUE(IsValidContainerQuery("(1 < aspect-ratio < 2)"));
}

TEST(ContainerQuery, LogicalQueries) {
  auto env = TEST_init();
  
  // OR conditions
  EXPECT_TRUE(IsValidContainerQuery("(width > 400px) or (height > 300px)"));
  
  // AND conditions
  EXPECT_TRUE(IsValidContainerQuery("(width > 400px) and (height > 300px)"));
  
  // NOT conditions
  EXPECT_TRUE(IsValidContainerQuery("not (width < 400px)"));
  
  // Complex conditions
  EXPECT_TRUE(IsValidContainerQuery("((width > 400px) and (height > 300px)) or (aspect-ratio > 2)"));
}

TEST(ContainerQuery, StyleQueries) {
  auto env = TEST_init();
  
  // Style queries for custom properties
  EXPECT_TRUE(IsValidContainerQuery("style(--theme: dark)"));
  EXPECT_TRUE(IsValidContainerQuery("style(--primary-color: blue)"));
  
  // Combined style and size queries
  EXPECT_TRUE(IsValidContainerQuery("(width > 400px) and style(--theme: dark)"));
}

TEST(ContainerQuery, RangeSyntax) {
  auto env = TEST_init();
  
  // Modern range syntax
  EXPECT_TRUE(IsValidContainerQuery("(width > 400px)"));
  EXPECT_TRUE(IsValidContainerQuery("(width >= 400px)"));
  EXPECT_TRUE(IsValidContainerQuery("(width < 800px)"));
  EXPECT_TRUE(IsValidContainerQuery("(width <= 800px)"));
  EXPECT_TRUE(IsValidContainerQuery("(width = 600px)"));
  
  // Complex ranges
  EXPECT_TRUE(IsValidContainerQuery("(400px < width < 800px)"));
  EXPECT_TRUE(IsValidContainerQuery("(400px <= width <= 800px)"));
  EXPECT_TRUE(IsValidContainerQuery("(1 < aspect-ratio <= 2)"));
}

TEST(ContainerQuery, InvalidQueries) {
  auto env = TEST_init();
  
  // Invalid feature names
  EXPECT_FALSE(IsValidContainerQuery("(color: red)"));
  EXPECT_FALSE(IsValidContainerQuery("(display: flex)"));
  
  // Invalid syntax
  EXPECT_FALSE(IsValidContainerQuery("width > 400px"));  // Missing parentheses
  EXPECT_FALSE(IsValidContainerQuery("(width >> 400px)")); // Invalid operator
  EXPECT_FALSE(IsValidContainerQuery("(400px > width > 800px)")); // Wrong direction
}

TEST(ContainerQuery, ContainerProperties) {
  auto env = TEST_init();
  
  // Test container-name property
  {
    auto value = css_parsing_utils::ConsumeContainerName(
        CSSParserTokenRange(CSSParserTokenizer("sidebar").TokenRange()),
        std::make_shared<CSSParserContext>(CSSParserMode::kHTMLStandardMode,
                                          kHTMLStandardMode, SecureContextMode::kInsecureContext));
    EXPECT_TRUE(value);
  }
  
  // Test container-type property
  {
    auto value = css_parsing_utils::ConsumeIdent<CSSValueID::kNormal, CSSValueID::kSize, 
                                                  CSSValueID::kInlineSize>(
        CSSParserTokenRange(CSSParserTokenizer("inline-size").TokenRange()));
    EXPECT_TRUE(value);
  }
  
  // Test multiple container names
  {
    auto value = css_parsing_utils::ConsumeContainerName(
        CSSParserTokenRange(CSSParserTokenizer("sidebar main").TokenRange()),
        std::make_shared<CSSParserContext>(CSSParserMode::kHTMLStandardMode,
                                          kHTMLStandardMode, SecureContextMode::kInsecureContext));
    EXPECT_TRUE(value);
  }
}

}  // namespace webf