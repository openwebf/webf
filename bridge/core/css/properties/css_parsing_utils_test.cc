// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/properties/css_parsing_utils.h"
#include "gtest/gtest.h"
#include "foundation/string/string_impl.h"
#include "core/core_initializer.h"

namespace webf {

// Initialize static globals for tests
class TestEnvironment : public ::testing::Environment {
 public:
  void SetUp() override {
    CoreInitializer::Initialize();
  }
};

// Register the environment
static ::testing::Environment* const test_environment =
    ::testing::AddGlobalTestEnvironment(new TestEnvironment);

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
  EXPECT_TRUE(css_parsing_utils::IsCSSWideKeyword(AtomicString(String::FromUTF8("revert"))));
}

double ConsumeAngleValue(const String& target) {
  CSSTokenizer tokenizer(target);
  CSSParserTokenStream stream(tokenizer);
  return ConsumeAngle(stream, MakeContext())->ComputeDegrees();
}

double ConsumeAngleValue(const String& target, double min, double max) {
  CSSTokenizer tokenizer(target);
  CSSParserTokenStream stream(tokenizer);
  return ConsumeAngle(stream, MakeContext(), min, max)->ComputeDegrees();
}

TEST(CSSParsingUtilsTest, ConsumeAngles) {
  const double kMaxDegreeValue = 2867080569122160;

  EXPECT_EQ(10.0, ConsumeAngleValue("10deg"_s));
  EXPECT_EQ(-kMaxDegreeValue, ConsumeAngleValue("-3.40282e+38deg"_s));
  EXPECT_EQ(kMaxDegreeValue, ConsumeAngleValue("3.40282e+38deg"_s));

  EXPECT_EQ(kMaxDegreeValue, ConsumeAngleValue("calc(infinity * 1deg)"_s));
  EXPECT_EQ(-kMaxDegreeValue, ConsumeAngleValue("calc(-infinity * 1deg)"_s));
  EXPECT_EQ(kMaxDegreeValue, ConsumeAngleValue("calc(NaN * 1deg)"_s));

  // Math function with min and max ranges

  EXPECT_EQ(-100, ConsumeAngleValue("calc(-3.40282e+38deg)"_s, -100, 100));
  EXPECT_EQ(100, ConsumeAngleValue("calc(3.40282e+38deg)"_s, -100, 100));
}

TEST(CSSParsingUtilsTest, AtIdent_Range) {
  String text = "foo,bar,10px"_s;
  CSSTokenizer tokenizer(text);
  auto tokens = tokenizer.TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // foo
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // ,
  EXPECT_TRUE(AtIdent(range.Consume(), "bar"));   // bar
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // ,
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // 10px
  EXPECT_FALSE(AtIdent(range.Consume(), "bar"));  // EOF
}

TEST(CSSParsingUtilsTest, AtIdent_Stream) {
  String text = "foo,bar,10px"_s;
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
  String text = "foo,bar,10px"_s;
  CSSTokenizer tokenizer(text);
  auto tokens = tokenizer.TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  EXPECT_TRUE(AtIdent(range.Peek(), "foo"));
  EXPECT_FALSE(ConsumeIfIdent(range, "bar"));
  EXPECT_TRUE(AtIdent(range.Peek(), "foo"));
  EXPECT_TRUE(ConsumeIfIdent(range, "foo"));
  EXPECT_EQ(kCommaToken, range.Peek().GetType());
}

TEST(CSSParsingUtilsTest, ConsumeIfIdent_Stream) {
  String text = "foo,bar,10px"_s;
  CSSTokenizer tokenizer(text);
  CSSParserTokenStream stream(tokenizer);
  EXPECT_TRUE(AtIdent(stream.Peek(), "foo"));
  EXPECT_FALSE(ConsumeIfIdent(stream, "bar"));
  EXPECT_TRUE(AtIdent(stream.Peek(), "foo"));
  EXPECT_TRUE(ConsumeIfIdent(stream, "foo"));
  EXPECT_EQ(kCommaToken, stream.Peek().GetType());
}

TEST(CSSParsingUtilsTest, AtDelimiter_Range) {
  String text = "foo,<,10px"_s;
  CSSTokenizer temp_tokenizer(text);
  auto tokens = temp_tokenizer.TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // foo
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // ,
  EXPECT_TRUE(AtDelimiter(range.Consume(), '<'));   // <
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // ,
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // 10px
  EXPECT_FALSE(AtDelimiter(range.Consume(), '<'));  // EOF
}

TEST(CSSParsingUtilsTest, AtDelimiter_Stream) {
  String text = "foo,<,10px"_s;
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
  String text = "<,=,10px"_s;
  CSSTokenizer temp_tokenizer(text);
  auto tokens = temp_tokenizer.TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  EXPECT_TRUE(AtDelimiter(range.Peek(), '<'));
  EXPECT_FALSE(ConsumeIfDelimiter(range, '='));
  EXPECT_TRUE(AtDelimiter(range.Peek(), '<'));
  EXPECT_TRUE(ConsumeIfDelimiter(range, '<'));
  EXPECT_EQ(kCommaToken, range.Peek().GetType());
}

TEST(CSSParsingUtilsTest, ConsumeIfDelimiter_Stream) {
  String text = "<,=,10px"_s;
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
    String input = String::FromUTF8(test.input);
    SCOPED_TRACE(test.input);
    CSSTokenizer temp_tokenizer(input);
    auto tokens = temp_tokenizer.TokenizeToEOF();
    CSSParserTokenRange range(tokens);
    EXPECT_EQ(test.expected, css_parsing_utils::ConsumeAnyValue(range));
    EXPECT_EQ(test.remainder, range.Serialize());
  }
}

TEST(CSSParsingUtilsTest, DashedIdent) {
  struct Expectations {
    const char* css_text;
    bool is_dashed_indent;
  } expectations[] = {
      {"--grogu", true}, {"--1234", true}, {"--\U0001F37A", true}, {"--", true},       {"-", false},
      {"blue", false},   {"body", false},  {"0", false},           {"#FFAA00", false},
  };
  for (auto& expectation : expectations) {
    String css_text = String::FromUTF8(expectation.css_text);
    SCOPED_TRACE(expectation.css_text);
    CSSTokenizer temp_tokenizer(css_text);
    auto tokens = temp_tokenizer.TokenizeToEOF();
    CSSParserTokenRange range(tokens);
    EXPECT_EQ(css_parsing_utils::IsDashedIdent(range.Peek()), expectation.is_dashed_indent);
  }
}

TEST(CSSParsingUtilsTest, ConsumeAbsoluteColor) {
  auto ConsumeColorForTest = [](const String& css_text, auto func) {
    CSSTokenizer tokenizer(css_text);
    auto tokens = tokenizer.TokenizeToEOF();
    CSSParserTokenRange range(tokens);
    auto context = MakeContext();
    return func(range, context);
  };

  struct {
    WEBF_STACK_ALLOCATED();

   public:
    String css_text;
    std::shared_ptr<const CSSIdentifierValue> consume_color_expectation;
    std::shared_ptr<const CSSIdentifierValue> consume_absolute_color_expectation;
  } expectations[]{
      {"Canvas"_s, CSSIdentifierValue::Create(CSSValueID::kCanvas), nullptr},
      {"HighlightText"_s, CSSIdentifierValue::Create(CSSValueID::kHighlighttext), nullptr},
      {"GrayText"_s, CSSIdentifierValue::Create(CSSValueID::kGraytext), nullptr},
      {"blue"_s, CSSIdentifierValue::Create(CSSValueID::kBlue), CSSIdentifierValue::Create(CSSValueID::kBlue)},
      // Deprecated system colors are not allowed either.
      {"ActiveBorder"_s, CSSIdentifierValue::Create(CSSValueID::kActiveborder), nullptr},
      {"WindowText"_s, CSSIdentifierValue::Create(CSSValueID::kWindowtext), nullptr},
      {"currentcolor"_s, CSSIdentifierValue::Create(CSSValueID::kCurrentcolor), nullptr},
  };
  for (auto& expectation : expectations) {
    EXPECT_EQ(ConsumeColorForTest(expectation.css_text, css_parsing_utils::ConsumeColor<CSSParserTokenRange>),
              expectation.consume_color_expectation);
    EXPECT_EQ(ConsumeColorForTest(expectation.css_text, 
                                  static_cast<std::shared_ptr<const CSSValue>(*)(CSSParserTokenRange&, std::shared_ptr<const CSSParserContext>)>(css_parsing_utils::ConsumeAbsoluteColor)),
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
    String input = String::FromUTF8(test);
    SCOPED_TRACE(test);
    CSSTokenizer tokenizer(input);
    std::vector<CSSParserToken> tokens = tokenizer.TokenizeToEOF();
    CSSParserTokenRange range(tokens);
    EXPECT_EQ(nullptr, css_parsing_utils::ConsumeColor(range, MakeContext()));
    EXPECT_EQ(test, range.Serialize());
  }
}

}  // namespace

}  // namespace webf