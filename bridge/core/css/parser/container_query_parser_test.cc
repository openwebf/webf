// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "gtest/gtest.h"
#include "core/css/parser/container_query_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_tokenizer.h"

namespace webf {

class ContainerQueryParserTest : public testing::Test {
 public:
  std::string ParseQuery(const std::string&& string) {
    auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
    std::shared_ptr<const MediaQueryExpNode> node =
        ContainerQueryParser(*context).ParseCondition(string);
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
    bool IsAllowed(const std::string& feature) const override {
      return feature == "width";
    }
    bool IsAllowedWithoutValue(const std::string& feature) const override {
      return true;
    }
    bool IsCaseSensitive(const std::string& feature) const {
      return false;
    }

    bool SupportsRange() const {
      return true;
    }
  };

  // E.g. https://drafts.csswg.org/css-contain-3/#typedef-style-query
  std::string ParseFeatureQuery(std::string feature_query) {
    auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
    auto [tokens, raw_offsets] =
        CSSTokenizer(feature_query).TokenizeToEOFWithOffsets();
    CSSParserTokenRange range(tokens);
    CSSParserTokenOffsets offsets(tokens, std::move(raw_offsets),
                                  feature_query);
    auto node =
        ContainerQueryParser(*context).ConsumeFeatureQuery(range, offsets,
                                                           TestFeatureSet());
    if (!node || !range.AtEnd()) {
      return "";
    }
    return node->Serialize();
  }
};


TEST_F(ContainerQueryParserTest, ParseQuery) {
  const char* tests[] = {
      "(width)",
      "(min-width: 100px)",
      "(width > 100px)",
      "(width: 100px)",
      "(not (width))",
      "((not (width)) and (width))",
      "((not (width)) and (width))",
      "((width) and (width))",
      "((width) or ((width) and (not (width))))",
      "((width > 100px) and (width > 200px))",
      "((width) and (width) and (width))",
      "((width) or (width) or (width))",
      "not (width)",
      "(width) and (height)",
      "(width) or (height)",
  };

  for (const char* test : tests) {
    EXPECT_EQ(test, ParseQuery(test));
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
    EXPECT_EQ(std::string(test), ParseFeatureQuery(test));
  }

  // Invalid:
  EXPECT_EQ("", ParseFeatureQuery("unsupported"));
  EXPECT_EQ("", ParseFeatureQuery("(width) or (width) and (width)"));
  EXPECT_EQ("", ParseFeatureQuery("(width) and (width) or (width)"));
}


}
