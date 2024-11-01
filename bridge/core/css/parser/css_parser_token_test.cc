// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "gtest/gtest.h"
#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_tokenizer.h"

namespace webf {

static CSSParserToken IdentToken(const std::string& string) {
  return CSSParserToken(kIdentToken, string);
}
static CSSParserToken DimensionToken(double value, const std::string& unit) {
  CSSParserToken token(kNumberToken, value, kNumberValueType, kNoSign);
  token.ConvertToDimensionWithUnit(unit);
  return token;
}

static std::string RoundTripToken(std::string str) {
  CSSTokenizer tokenizer(str);
  StringBuilder sb;
  tokenizer.TokenizeSingle().Serialize(sb);
  return sb.ReleaseString();
}

TEST(CSSParserTokenTest, SerializeDoubles) {
  EXPECT_EQ("1.5", RoundTripToken("1.500"));
  EXPECT_EQ("2", RoundTripToken("2"));
  EXPECT_EQ("2.0", RoundTripToken("2.0"));
  EXPECT_EQ("1234567890.0", RoundTripToken("1234567890.0"));
  EXPECT_EQ("1e+30", RoundTripToken("1e30"));
  EXPECT_EQ("0.00001525878", RoundTripToken("0.00001525878"));
  EXPECT_EQ("0.00001525878rad", RoundTripToken("0.00001525878rad"));
}


}