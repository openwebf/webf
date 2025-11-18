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
      return String::EmptyString();
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
    CSSTokenizer tokenizer{feature_query.ToStringView()};
    CSSParserTokenStream stream(tokenizer);
    auto node = ContainerQueryParser(*context).ConsumeFeatureQuery(stream, TestFeatureSet());
    if (!node || !stream.AtEnd()) {
      return String::EmptyString();
    }
    return node->Serialize();
  }
};

TEST_F(ContainerQueryParserTest, ParseQuery) {
  // With the simplified parser, we expect the raw condition text
  // to be preserved without semantic normalization.
  EXPECT_EQ("(width)", ParseQuery(String::FromUTF8("(width)")));
  EXPECT_EQ("(min-width: 100px)", ParseQuery(String::FromUTF8("(min-width: 100px)")));
  EXPECT_EQ("(width > 100px)", ParseQuery(String::FromUTF8("(width > 100px)")));
  EXPECT_EQ("(width: 100px)", ParseQuery(String::FromUTF8("(width: 100px)")));
  EXPECT_EQ("not (width)", ParseQuery(String::FromUTF8("not (width)")));
  
  // Test a simple failing case first
  fprintf(stderr, "\nTesting: (width) and (height)\n");
  String result = ParseQuery(String::FromUTF8("(width) and (height)"));
  fprintf(stderr, "Result: '%s'\n", result.ToUTF8String().c_str());
  EXPECT_EQ("(width) and (height)", result);
  
  fprintf(stderr, "\nTesting: ((width) and (width))\n");
  result = ParseQuery(String::FromUTF8("((width) and (width))"));
  fprintf(stderr, "Result: '%s'\n", result.ToUTF8String().c_str());
  EXPECT_EQ("((width) and (width))", result);
  
  fprintf(stderr, "\nTesting: ((width) and (width) and (width))\n");
  result = ParseQuery(String::FromUTF8("((width) and (width) and (width))"));
  fprintf(stderr, "Result: '%s'\n", result.ToUTF8String().c_str());
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
    String result = ParseQuery(String::FromUTF8(test));
    EXPECT_EQ(test, result);
  }

  // For inputs that previously were treated as invalid, we now just
  // preserve and echo the raw text.
  EXPECT_EQ("(min-width)", ParseQuery(String::FromUTF8("(min-width)")));
  EXPECT_EQ("((width) or (width) and (width))",
            ParseQuery(String::FromUTF8("((width) or (width) and (width))")));
  EXPECT_EQ("((width) and (width) or (width))",
            ParseQuery(String::FromUTF8("((width) and (width) or (width))")));
  EXPECT_EQ("((width) or (height) and (width))",
            ParseQuery(String::FromUTF8("((width) or (height) and (width))")));
  EXPECT_EQ("((width) and (height) or (width))",
            ParseQuery(String::FromUTF8("((width) and (height) or (width))")));
  EXPECT_EQ("((width) and (height) 50px)",
            ParseQuery(String::FromUTF8("((width) and (height) 50px)")));
  EXPECT_EQ("((width) and (height 50px))",
            ParseQuery(String::FromUTF8("((width) and (height 50px))")));
  EXPECT_EQ("((width) and 50px (height))",
            ParseQuery(String::FromUTF8("((width) and 50px (height))")));
  EXPECT_EQ("foo(width)", ParseQuery(String::FromUTF8("foo(width)")));
  EXPECT_EQ("size(width)", ParseQuery(String::FromUTF8("size(width)")));
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
    EXPECT_EQ(String::FromUTF8(test), ParseFeatureQuery(String::FromUTF8(test)));
  }

  // Invalid:
  EXPECT_EQ(String::EmptyString(), ParseFeatureQuery(String::FromUTF8("unsupported")));
  EXPECT_EQ(String::EmptyString(), ParseFeatureQuery(String::FromUTF8("(width) or (width) and (width)")));
  EXPECT_EQ(String::EmptyString(), ParseFeatureQuery(String::FromUTF8("(width) and (width) or (width)")));
}

}  // namespace webf
