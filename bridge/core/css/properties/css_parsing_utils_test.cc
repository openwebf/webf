// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/properties/css_parsing_utils.h"
#include "gtest/gtest.h"

namespace webf {

namespace {

using css_parsing_utils::AtDelimiter;
using css_parsing_utils::AtIdent;
using css_parsing_utils::ConsumeAngle;
using css_parsing_utils::ConsumeIfDelimiter;
using css_parsing_utils::ConsumeIfIdent;

std::shared_ptr<const CSSParserContext> MakeContext(CSSParserMode mode = kHTMLStandardMode) {
  return std::make_shared<CSSParserContext>(mode);
}

TEST(CSSParsingUtilsTest, Revert) {
  EXPECT_TRUE(css_parsing_utils::IsCSSWideKeyword(CSSValueID::kRevert));
  EXPECT_TRUE(css_parsing_utils::IsCSSWideKeyword("revert"));
}

double ConsumeAngleValue(std::string target) {
  auto tokens = CSSTokenizer(target).TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  return ConsumeAngle(range, MakeContext())->ComputeDegrees();
}

double ConsumeAngleValue(std::string target, double min, double max) {
  auto tokens = CSSTokenizer(target).TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  return ConsumeAngle(range, MakeContext(), min, max)->ComputeDegrees();
}

TEST(CSSParsingUtilsTest, ConsumeAngles) {
  const double kMaxDegreeValue = 2867080569122160;

  EXPECT_EQ(10.0, ConsumeAngleValue("10deg"));
  EXPECT_EQ(-kMaxDegreeValue, ConsumeAngleValue("-3.40282e+38deg"));
  EXPECT_EQ(kMaxDegreeValue, ConsumeAngleValue("3.40282e+38deg"));

  EXPECT_EQ(kMaxDegreeValue, ConsumeAngleValue("calc(infinity * 1deg)"));
  EXPECT_EQ(-kMaxDegreeValue, ConsumeAngleValue("calc(-infinity * 1deg)"));
  EXPECT_EQ(kMaxDegreeValue, ConsumeAngleValue("calc(NaN * 1deg)"));

  // Math function with min and max ranges

  EXPECT_EQ(-100, ConsumeAngleValue("calc(-3.40282e+38deg)", -100, 100));
  EXPECT_EQ(100, ConsumeAngleValue("calc(3.40282e+38deg)", -100, 100));
}

TEST(CSSParsingUtilsTest, AtIdent_Range) {
  std::string text = "foo,bar,10px";
  auto tokens = CSSTokenizer(text).TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // foo
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // ,
  EXPECT_TRUE(AtIdent(range.Consume(), "bar"));   // bar
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // ,
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // 10px
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // EOF
}

TEST(CSSParsingUtilsTest, AtIdent_Stream) {
  std::string text = "foo,bar,10px";
  CSSTokenizer tokenizer(text);
  CSSParserTokenStream stream(tokenizer);
  EXPECT_FALSE(AtIdent(stream.Consume(), "bar"));  // foo
  EXPECT_FALSE(AtIdent(stream.Consume(), "bar"));  // ,
  EXPECT_TRUE(AtIdent(stream.Consume(), "bar"));   // bar
  EXPECT_FALSE(AtIdent(stream.Consume(), "bar"));  // ,
  EXPECT_FALSE(AtIdent(stream.Consume(), "bar"));  // 10px
  EXPECT_FALSE(AtIdent(stream.Consume(), "bar"));  // EOF
}

TEST(CSSParsingUtilsTest, ConsumeIfIdent_Range) {
  std::string text = "foo,bar,10px";
  auto tokens = CSSTokenizer(text).TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  EXPECT_TRUE(AtIdent(range.Peek(), "foo"));
  EXPECT_FALSE(ConsumeIfIdent(range, "bar"));
  EXPECT_TRUE(AtIdent(range.Peek(), "foo"));
  EXPECT_TRUE(ConsumeIfIdent(range, "foo"));
  EXPECT_EQ(kCommaToken, range.Peek().GetType());
}

TEST(CSSParsingUtilsTest, ConsumeIfIdent_Stream) {
  std::string text = "foo,bar,10px";
  CSSTokenizer tokenizer(text);
  CSSParserTokenStream stream(tokenizer);
  EXPECT_TRUE(AtIdent(stream.Peek(), "foo"));
  EXPECT_FALSE(ConsumeIfIdent(stream, "bar"));
  EXPECT_TRUE(AtIdent(stream.Peek(), "foo"));
  EXPECT_TRUE(ConsumeIfIdent(stream, "foo"));
  EXPECT_EQ(kCommaToken, stream.Peek().GetType());
}

TEST(CSSParsingUtilsTest, AtDelimiter_Range) {
  std::string text = "foo,<,10px";
  auto tokens = CSSTokenizer(text).TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // foo
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // ,
  EXPECT_TRUE(AtDelimiter(range.Consume(), '<'));   // <
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // ,
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // 10px
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // EOF
}

TEST(CSSParsingUtilsTest, AtDelimiter_Stream) {
  std::string text = "foo,<,10px";
  CSSTokenizer tokenizer(text);
  CSSParserTokenStream stream(tokenizer);
  EXPECT_FALSE(AtDelimiter(stream.Consume(), '<'));  // foo
  EXPECT_FALSE(AtDelimiter(stream.Consume(), '<'));  // ,
  EXPECT_TRUE(AtDelimiter(stream.Consume(), '<'));   // <
  EXPECT_FALSE(AtDelimiter(stream.Consume(), '<'));  // ,
  EXPECT_FALSE(AtDelimiter(stream.Consume(), '<'));  // 10px
  EXPECT_FALSE(AtDelimiter(stream.Consume(), '<'));  // EOF
}

TEST(CSSParsingUtilsTest, ConsumeIfDelimiter_Range) {
  std::string text = "<,=,10px";
  auto tokens = CSSTokenizer(text).TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  EXPECT_TRUE(AtDelimiter(range.Peek(), '<'));
  EXPECT_FALSE(ConsumeIfDelimiter(range, '='));
  EXPECT_TRUE(AtDelimiter(range.Peek(), '<'));
  EXPECT_TRUE(ConsumeIfDelimiter(range, '<'));
  EXPECT_EQ(kCommaToken, range.Peek().GetType());
}

TEST(CSSParsingUtilsTest, ConsumeIfDelimiter_Stream) {
  std::string text = "<,=,10px";
  CSSTokenizer tokenizer(text);
  CSSParserTokenStream stream(tokenizer);
  EXPECT_TRUE(AtDelimiter(stream.Peek(), '<'));
  EXPECT_FALSE(ConsumeIfDelimiter(stream, '='));
  EXPECT_TRUE(AtDelimiter(stream.Peek(), '<'));
  EXPECT_TRUE(ConsumeIfDelimiter(stream, '<'));
  EXPECT_EQ(kCommaToken, stream.Peek().GetType());
}

TEST(CSSParsingUtilsTest, ConsumeAnyValue) {
  struct {
    // The input string to parse as <any-value>.
    const char* input;
    // The expected result from ConsumeAnyValue.
    bool expected;
    // The serialization of the tokens remaining in the range.
    const char* remainder;
  } tests[] = {
      {"1", true, ""},
      {"1px", true, ""},
      {"1px ", true, ""},
      {"ident", true, ""},
      {"(([ident]))", true, ""},
      {" ( ( 1 ) ) ", true, ""},
      {"rgb(1, 2, 3)", true, ""},
      {"rgb(1, 2, 3", true, ""},
      {"!!!;;;", true, ""},
      {"asdf)", false, ")"},
      {")asdf", false, ")asdf"},
      {"(ab)cd) e", false, ") e"},
      {"(as]df) e", false, " e"},
      {"(a b [ c { d ) e } f ] g h) i", false, " i"},
      {"a url(() b", false, "url(() b"},
  };

  for (const auto& test : tests) {
    std::string input(test.input);
    SCOPED_TRACE(input);
    auto tokens = CSSTokenizer(input).TokenizeToEOF();
    CSSParserTokenRange range(tokens);
    EXPECT_EQ(test.expected, css_parsing_utils::ConsumeAnyValue(range));
    EXPECT_EQ(test.remainder, range.Serialize());
  }
}

TEST(CSSParsingUtilsTest, DashedIdent) {
  struct Expectations {
    std::string css_text;
    bool is_dashed_indent;
  } expectations[] = {
      {"--grogu", true}, {"--1234", true}, {"--\U0001F37A", true}, {"--", true},       {"-", false},
      {"blue", false},   {"body", false},  {"0", false},           {"#FFAA00", false},
  };
  for (auto& expectation : expectations) {
    auto tokens = CSSTokenizer(expectation.css_text).TokenizeToEOF();
    CSSParserTokenRange range(tokens);
    EXPECT_EQ(css_parsing_utils::IsDashedIdent(range.Peek()), expectation.is_dashed_indent);
  }
}

TEST(CSSParsingUtilsTest, ConsumeAbsoluteColor) {
  auto ConsumeColorForTest = [](std::string css_text, auto func) {
    auto tokens = CSSTokenizer(css_text).TokenizeToEOF();
    CSSParserTokenRange range(tokens);
    auto context = MakeContext();
    return func(range, context);
  };

  struct {
    WEBF_STACK_ALLOCATED();

   public:
    std::string css_text;
    std::shared_ptr<const CSSIdentifierValue> consume_color_expectation;
    std::shared_ptr<const CSSIdentifierValue> consume_absolute_color_expectation;
  } expectations[]{
      {"Canvas", CSSIdentifierValue::Create(CSSValueID::kCanvas), nullptr},
      {"HighlightText", CSSIdentifierValue::Create(CSSValueID::kHighlighttext), nullptr},
      {"GrayText", CSSIdentifierValue::Create(CSSValueID::kGraytext), nullptr},
      {"blue", CSSIdentifierValue::Create(CSSValueID::kBlue), CSSIdentifierValue::Create(CSSValueID::kBlue)},
      // Deprecated system colors are not allowed either.
      {"ActiveBorder", CSSIdentifierValue::Create(CSSValueID::kActiveborder), nullptr},
      {"WindowText", CSSIdentifierValue::Create(CSSValueID::kWindowtext), nullptr},
      {"currentcolor", CSSIdentifierValue::Create(CSSValueID::kCurrentcolor), nullptr},
  };
  for (auto& expectation : expectations) {
    EXPECT_EQ(ConsumeColorForTest(expectation.css_text, css_parsing_utils::ConsumeColor<CSSParserTokenRange>),
              expectation.consume_color_expectation);
    EXPECT_EQ(ConsumeColorForTest(expectation.css_text, css_parsing_utils::ConsumeAbsoluteColor),
              expectation.consume_absolute_color_expectation);
  }
}

// Verify that the state of CSSParserTokenRange is preserved
// for failing <color> values.
TEST(CSSParsingUtilsTest, ConsumeColorRangePreservation) {
  const char* tests[] = {
      "color-mix(42deg)",
      "color-contrast(42deg)",
  };
  for (const char*& test : tests) {
    std::string input(test);
    SCOPED_TRACE(input);
    std::vector<CSSParserToken> tokens = CSSTokenizer(input).TokenizeToEOF();
    CSSParserTokenRange range(tokens);
    EXPECT_EQ(nullptr, css_parsing_utils::ConsumeColor(range, MakeContext()));
    EXPECT_EQ(test, range.Serialize());
  }
}

}  // namespace

}  // namespace webf