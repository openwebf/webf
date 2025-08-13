// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/parser/container_query_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"
#include "gtest/gtest.h"

namespace webf {

class ContainerQueryParserTest : public testing::Test {
 public:
  String ParseQuery(const String&& string) {
    auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
    std::shared_ptr<const MediaQueryExpNode> node = ContainerQueryParser(*context).ParseCondition(string);
    if (!node) {
      return "";
    }
    if (node->HasUnknown()) {
      return "<unknown>";
    }
    StringBuilder builder;
    node->SerializeTo(builder);
    return builder.ReleaseString();
  }

  class TestFeatureSet : public MediaQueryParser::FeatureSet {
    WEBF_STACK_ALLOCATED();

   public:
    bool IsAllowed(const AtomicString& feature) const override { return feature == "width"; }
    bool IsAllowedWithoutValue(const AtomicString& feature) const override { return true; }
    bool IsCaseSensitive(const AtomicString& feature) const override { return false; }

    bool SupportsRange() const override { return true; }
  };

  // E.g. https://drafts.csswg.org/css-contain-3/#typedef-style-query
  String ParseFeatureQuery(String feature_query) {
    auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
    CSSTokenizer tokenizer(feature_query);
    CSSParserTokenStream stream(tokenizer);
    auto node = ContainerQueryParser(*context).ConsumeFeatureQuery(stream, TestFeatureSet());
    if (!node || !stream.AtEnd()) {
      return "";
    }
    return node->Serialize();
  }
};

TEST_F(ContainerQueryParserTest, ParseQuery) {
  // Test simple cases that are passing
  EXPECT_EQ("(width)", ParseQuery("(width)"));
  EXPECT_EQ("(min-width: 100px)", ParseQuery("(min-width: 100px)"));
  EXPECT_EQ("(width > 100px)", ParseQuery("(width > 100px)"));
  EXPECT_EQ("(width: 100px)", ParseQuery("(width: 100px)"));
  EXPECT_EQ("not (width)", ParseQuery("not (width)"));
  
  // Test a simple failing case first
  fprintf(stderr, "\nTesting: (width) and (height)\n");
  String result = ParseQuery("(width) and (height)");
  fprintf(stderr, "Result: '%s'\n", result.StdUtf8().c_str());
  EXPECT_EQ("(width) and (height)", result);
  
  fprintf(stderr, "\nTesting: ((width) and (width))\n");
  result = ParseQuery("((width) and (width))");
  fprintf(stderr, "Result: '%s'\n", result.StdUtf8().c_str());
  EXPECT_EQ("((width) and (width))", result);
  
  fprintf(stderr, "\nTesting: ((width) and (width) and (width))\n");
  result = ParseQuery("((width) and (width) and (width))");
  fprintf(stderr, "Result: '%s'\n", result.StdUtf8().c_str());
  EXPECT_EQ("((width) and (width) and (width))", result);
  
  // Test cases that are currently failing
  const char* tests[] = {
      "(not (width))",
      "((not (width)) and (width))",
      "((width) or ((width) and (not (width))))",
      "((width > 100px) and (width > 200px))",
      "((width) and (width) and (width))",
      "((width) or (width) or (width))",
      "(width) or (height)",
  };

  for (const char* test : tests) {
    String result = ParseQuery(test);
    if (result != test) {
      fprintf(stderr, "FAILED: '%s' -> '%s'\n", test, result.StdUtf8().c_str());
    }
    EXPECT_EQ(test, result);
  }

  // Invalid:
  EXPECT_EQ("<unknown>", ParseQuery("(min-width)"));
  EXPECT_EQ("<unknown>", ParseQuery("((width) or (width) and (width))"));
  EXPECT_EQ("<unknown>", ParseQuery("((width) and (width) or (width))"));
  EXPECT_EQ("<unknown>", ParseQuery("((width) or (height) and (width))"));
  EXPECT_EQ("<unknown>", ParseQuery("((width) and (height) or (width))"));
  EXPECT_EQ("<unknown>", ParseQuery("((width) and (height) 50px)"));
  EXPECT_EQ("<unknown>", ParseQuery("((width) and (height 50px))"));
  EXPECT_EQ("<unknown>", ParseQuery("((width) and 50px (height))"));
  EXPECT_EQ("<unknown>", ParseQuery("foo(width)"));
  EXPECT_EQ("<unknown>", ParseQuery("size(width)"));
}

// This test exists primarily to not lose coverage of
// `ContainerQueryParser::ConsumeFeatureQuery`, which is unused until
// style() queries are supported (crbug.com/1302630).
TEST_F(ContainerQueryParserTest, ParseFeatureQuery) {
  const char* tests[] = {
      "width",
      "width: 100px",
      "(not (width)) and (width)",
      "(width > 100px) and (width > 200px)",
      "(width) and (width) and (width)",
      "(width) or (width) or (width)",
  };

  for (const char* test : tests) {
    EXPECT_EQ(String(test), ParseFeatureQuery(test));
  }

  // Invalid:
  EXPECT_EQ("", ParseFeatureQuery("unsupported"));
  EXPECT_EQ("", ParseFeatureQuery("(width) or (width) and (width)"));
  EXPECT_EQ("", ParseFeatureQuery("(width) and (width) or (width)"));
}

}  // namespace webf
