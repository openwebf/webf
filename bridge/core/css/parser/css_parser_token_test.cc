// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_tokenizer.h"
#include "gtest/gtest.h"

namespace webf {

static CSSParserToken IdentToken(const String& string) {
  return CSSParserToken(kIdentToken, StringView(string));
}
static CSSParserToken DimensionToken(double value, const String& unit) {
  CSSParserToken token(kNumberToken, value, kNumberValueType, kNoSign);
  token.ConvertToDimensionWithUnit(StringView(unit));
  return token;
}

static String RoundTripToken(String str) {
  CSSTokenizer tokenizer{str.ToStringView()};
  StringBuilder sb;
  tokenizer.TokenizeSingle().Serialize(sb);
  return sb.ReleaseString();
}

TEST(CSSParserTokenTest, SerializeDoubles) {
  EXPECT_EQ("1.5"_s, RoundTripToken("1.500"_s));
  EXPECT_EQ("2"_s, RoundTripToken("2"_s));
  EXPECT_EQ("2.0"_s, RoundTripToken("2.0"_s));
  EXPECT_EQ("1234567890.0"_s, RoundTripToken("1234567890.0"_s));
  EXPECT_EQ("1e+30"_s, RoundTripToken("1e30"_s));
  EXPECT_EQ("0.00001525878"_s, RoundTripToken("0.00001525878"_s));
  EXPECT_EQ("0.00001525878rad"_s, RoundTripToken("0.00001525878rad"_s));
}

TEST(CSSParserTokenTest, SerializeStrings) {
  EXPECT_EQ("\"åéîøü\""_s, RoundTripToken("\"åéîøü\""_s));
  EXPECT_EQ("url(åéîøü)"_s, RoundTripToken("url(åéîøü)"_s));
}

}  // namespace webf