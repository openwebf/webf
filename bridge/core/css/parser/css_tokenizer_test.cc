// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "gtest/gtest.h"
#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_tokenizer.h"
#include "foundation/macros.h"
#include <assert.h>

namespace webf {

std::string FromUChar32(uint32_t c) {
  StringBuilder input;
  input.Append(c);
  return input.ReleaseString();
}

// This let's us see the line numbers of failing tests
#define TEST_TOKENS(str, ...)     \
  {                                  \
    std::string s = str;               \
    SCOPED_TRACE(s);                 \
    TestTokens(str, __VA_ARGS__); \
  }

void CompareTokens(const CSSParserToken& expected,
                   const CSSParserToken& actual) {
  ASSERT_EQ(expected.GetType(), actual.GetType());
  switch (expected.GetType()) {
    case kDelimiterToken:
      ASSERT_EQ(expected.Delimiter(), actual.Delimiter());
      break;
    case kIdentToken:
    case kFunctionToken:
    case kStringToken:
    case kUrlToken:
      ASSERT_EQ(expected.Value(), actual.Value());
      break;
    case kDimensionToken:
      ASSERT_EQ(expected.Value(), actual.Value());
      ASSERT_EQ(expected.GetNumericValueType(), actual.GetNumericValueType());
      ASSERT_DOUBLE_EQ(expected.NumericValue(), actual.NumericValue());
      break;
    case kNumberToken:
      ASSERT_EQ(expected.GetNumericSign(), actual.GetNumericSign());
      [[fallthrough]];
    case kPercentageToken:
      ASSERT_EQ(expected.GetNumericValueType(), actual.GetNumericValueType());
      ASSERT_DOUBLE_EQ(expected.NumericValue(), actual.NumericValue());
      break;
    case kUnicodeRangeToken:
      ASSERT_EQ(expected.UnicodeRangeStart(), actual.UnicodeRangeStart());
      ASSERT_EQ(expected.UnicodeRangeEnd(), actual.UnicodeRangeEnd());
      break;
    case kHashToken:
      ASSERT_EQ(expected.Value(), actual.Value());
      ASSERT_EQ(expected.GetHashTokenType(), actual.GetHashTokenType());
      break;
    default:
      break;
  }
}

void TestTokens(const std::string& string,
                const CSSParserToken& token1,
                const CSSParserToken& token2 = CSSParserToken(kEOFToken),
                const CSSParserToken& token3 = CSSParserToken(kEOFToken),
                bool unicode_ranges_allowed = false) {
  std::vector<CSSParserToken> expected_tokens;
  expected_tokens.push_back(token1);
  if (token2.GetType() != kEOFToken) {
    expected_tokens.push_back(token2);
    if (token3.GetType() != kEOFToken) {
      expected_tokens.push_back(token3);
    }
  }

  CSSParserTokenRange expected(expected_tokens);

  {
    CSSTokenizer tokenizer(string);
    std::vector<CSSParserToken> tokens;
    tokens = tokenizer.TokenizeToEOF();
    CSSParserTokenRange actual(tokens);


    // Just check that serialization doesn't hit any asserts
    actual.Serialize();

    while (!expected.AtEnd() || !actual.AtEnd()) {
      CompareTokens(expected.Consume(), actual.Consume());
    }
  }
}

void TestUnicodeRangeTokens(
    const std::string& string,
    const CSSParserToken& token1,
    const CSSParserToken& token2 = CSSParserToken(kEOFToken),
    const CSSParserToken& token3 = CSSParserToken(kEOFToken)) {
  TEST_TOKENS(string, token1, token2, token3, true);
}

static CSSParserToken Ident(const std::string& string) {
  return CSSParserToken(kIdentToken, string);
}
static CSSParserToken AtKeyword(const std::string& string) {
  return CSSParserToken(kAtKeywordToken, string);
}
static CSSParserToken GetString(const std::string& string) {
  return CSSParserToken(kStringToken, string);
}
static CSSParserToken Func(const std::string& string) {
  return CSSParserToken(kFunctionToken, string);
}
static CSSParserToken Url(const std::string& string) {
  return CSSParserToken(kUrlToken, string);
}
static CSSParserToken GetHash(const std::string& string, HashTokenType type) {
  return CSSParserToken(type, string);
}
static CSSParserToken Delim(char c) {
  return CSSParserToken(kDelimiterToken, c);
}

static CSSParserToken Number(NumericValueType type,
                             double value,
                             NumericSign sign) {
  return CSSParserToken(kNumberToken, value, type, sign);
}

static CSSParserToken Dimension(NumericValueType type,
                                double value,
                                const std::string& string) {
  CSSParserToken token = Number(type, value, kNoSign);  // sign ignored
  token.ConvertToDimensionWithUnit(string);
  return token;
}

static CSSParserToken Percentage(NumericValueType type, double value) {
  CSSParserToken token = Number(type, value, kNoSign);  // sign ignored
  token.ConvertToPercentage();
  return token;
}

// We need to initialize PartitionAlloc before creating CSSParserTokens
// because CSSParserToken depends on PartitionAlloc. It is safe to call
// WTF::Partitions::initialize() multiple times.
#define DEFINE_TOKEN(name, argument)                       \
  static CSSParserToken& name() {                          \
    static CSSParserToken name = CSSParserToken(argument); \
    return name;                                           \
  }

DEFINE_TOKEN(Whitespace, (kWhitespaceToken))
DEFINE_TOKEN(Colon, (kColonToken))
DEFINE_TOKEN(Semicolon, (kSemicolonToken))
DEFINE_TOKEN(Comma, (kCommaToken))
DEFINE_TOKEN(IncludeMatch, (kIncludeMatchToken))
DEFINE_TOKEN(DashMatch, (kDashMatchToken))
DEFINE_TOKEN(PrefixMatch, (kPrefixMatchToken))
DEFINE_TOKEN(SuffixMatch, (kSuffixMatchToken))
DEFINE_TOKEN(SubstringMatch, (kSubstringMatchToken))
DEFINE_TOKEN(Column, (kColumnToken))
DEFINE_TOKEN(Cdo, (kCDOToken))
DEFINE_TOKEN(Cdc, (kCDCToken))
DEFINE_TOKEN(LeftParenthesis, (kLeftParenthesisToken))
DEFINE_TOKEN(RightParenthesis, (kRightParenthesisToken))
DEFINE_TOKEN(LeftBracket, (kLeftBracketToken))
DEFINE_TOKEN(RightBracket, (kRightBracketToken))
DEFINE_TOKEN(LeftBrace, (kLeftBraceToken))
DEFINE_TOKEN(RightBrace, (kRightBraceToken))
DEFINE_TOKEN(BadString, (kBadStringToken))
DEFINE_TOKEN(BadUrl, (kBadUrlToken))

#undef DEFINE_TOKEN

//std::string FromUChar32(int32_t c) {
//  StringBuilder input;
//  input.Append(c);
//  return input.ReleaseString();
//}

TEST(CSSTokenizerTest, SingleCharacterTokens) {
  TEST_TOKENS("(", LeftParenthesis());
  TEST_TOKENS(")", RightParenthesis());
  TEST_TOKENS("[", LeftBracket());
  TEST_TOKENS("]", RightBracket());
  TEST_TOKENS(",", Comma());
  TEST_TOKENS(":", Colon());
  TEST_TOKENS(";", Semicolon());
  TEST_TOKENS(")[", RightParenthesis(), LeftBracket());
  TEST_TOKENS("[)", LeftBracket(), RightParenthesis());
  TEST_TOKENS("{}", LeftBrace(), RightBrace());
  TEST_TOKENS(",,", Comma(), Comma());
}

TEST(CSSTokenizerTest, MultipleCharacterTokens) {
  TEST_TOKENS("~=", IncludeMatch());
  TEST_TOKENS("|=", DashMatch());
  TEST_TOKENS("^=", PrefixMatch());
  TEST_TOKENS("$=", SuffixMatch());
  TEST_TOKENS("*=", SubstringMatch());
  TEST_TOKENS("||", Column());
  TEST_TOKENS("|||", Column(), Delim('|'));
  TEST_TOKENS("<!--", Cdo());
  TEST_TOKENS("<!---", Cdo(), Delim('-'));
  TEST_TOKENS("-->", Cdc());
}

TEST(CSSTokenizerTest, DelimiterToken) {
  TEST_TOKENS("^", Delim('^'));
  TEST_TOKENS("*", Delim('*'));
  TEST_TOKENS("%", Delim('%'));
  TEST_TOKENS("~", Delim('~'));
  TEST_TOKENS("|", Delim('|'));
  TEST_TOKENS("&", Delim('&'));
  TEST_TOKENS("\x7f", Delim('\x7f'));
  TEST_TOKENS("\1", Delim('\x1'));
  TEST_TOKENS("~-", Delim('~'), Delim('-'));
  TEST_TOKENS("^|", Delim('^'), Delim('|'));
  TEST_TOKENS("$~", Delim('$'), Delim('~'));
  TEST_TOKENS("*^", Delim('*'), Delim('^'));
}

TEST(CSSTokenizerTest, WhitespaceTokens) {
  TEST_TOKENS("   ", Whitespace());
  TEST_TOKENS("\n\rS", Whitespace(), Ident("S"));
  TEST_TOKENS("   *", Whitespace(), Delim('*'));
  TEST_TOKENS("\r\n\f\t2", Whitespace(), Number(kIntegerValueType, 2, kNoSign));
}

TEST(CSSTokenizerTest, Escapes) {
  TEST_TOKENS("hel\\6Co", Ident("hello"));
  TEST_TOKENS("\\26 B", Ident("&B"));
  TEST_TOKENS("'hel\\6c o'", GetString("hello"));
  TEST_TOKENS("'spac\\65\r\ns'", GetString("spaces"));
  TEST_TOKENS("spac\\65\r\ns", Ident("spaces"));
  TEST_TOKENS("spac\\65\n\rs", Ident("space"), Whitespace(), Ident("s"));
  TEST_TOKENS("sp\\61\tc\\65\fs", Ident("spaces"));
  TEST_TOKENS("hel\\6c  o", Ident("hell"), Whitespace(), Ident("o"));
  TEST_TOKENS("test\\\n", Ident("test"), Delim('\\'), Whitespace());
//  TEST_TOKENS("\\E000", Ident(FromUChar32(0xE000)));
  TEST_TOKENS("te\\s\\t", Ident("test"));
  TEST_TOKENS("spaces\\ in\\\tident", Ident("spaces in\tident"));
  TEST_TOKENS("\\.\\,\\:\\!", Ident(".,:!"));
  TEST_TOKENS("\\\r", Delim('\\'), Whitespace());
  TEST_TOKENS("\\\f", Delim('\\'), Whitespace());
  TEST_TOKENS("\\\r\n", Delim('\\'), Whitespace());
}

TEST(CSSTokenizerTest, IdentToken) {
  TEST_TOKENS("simple-ident", Ident("simple-ident"));
  TEST_TOKENS("testing123", Ident("testing123"));
  TEST_TOKENS("hello!", Ident("hello"), Delim('!'));
  TEST_TOKENS("world\5", Ident("world"), Delim('\5'));
  TEST_TOKENS("_under score", Ident("_under"), Whitespace(), Ident("score"));
  TEST_TOKENS("-_underscore", Ident("-_underscore"));
  TEST_TOKENS("-text", Ident("-text"));
  TEST_TOKENS("-\\6d", Ident("-m"));
  TEST_TOKENS("--abc", Ident("--abc"));
  TEST_TOKENS("--", Ident("--"));
  TEST_TOKENS("--11", Ident("--11"));
  TEST_TOKENS("---", Ident("---"));
//  TEST_TOKENS(FromUChar32(0x2003), Ident(FromUChar32(0x2003)));  // em-space
//  TEST_TOKENS(FromUChar32(0xA0),
//              Ident(FromUChar32(0xA0)));  // non-breaking space
//  TEST_TOKENS(FromUChar32(0x1234), Ident(FromUChar32(0x1234)));
//  TEST_TOKENS(FromUChar32(0x12345), Ident(FromUChar32(0x12345)));
//  TEST_TOKENS(std::string("\0", 1u), Ident(FromUChar32(0xFFFD)));
//  TEST_TOKENS(std::string("ab\0c", 4u), Ident("ab" + FromUChar32(0xFFFD) + "c"));
//  TEST_TOKENS(std::string("ab\0c", 4u), Ident("ab" + FromUChar32(0xFFFD) + "c"));
}

TEST(CSSTokenizerTest, FunctionToken) {
  TEST_TOKENS("scale(2)", Func("scale"), Number(kIntegerValueType, 2, kNoSign),
              RightParenthesis());
  TEST_TOKENS("foo-bar\\ baz(", Func("foo-bar baz"));
  TEST_TOKENS("fun\\(ction(", Func("fun(ction"));
  TEST_TOKENS("-foo(", Func("-foo"));
  TEST_TOKENS("url(\"foo.gif\"", Func("url"), GetString("foo.gif"));
  TEST_TOKENS("foo(  \'bar.gif\'", Func("foo"), Whitespace(),
              GetString("bar.gif"));
  // To simplify implementation we drop the whitespace in
  // function(url),whitespace,string()
  TEST_TOKENS("url(  \'bar.gif\'", Func("url"), GetString("bar.gif"));
}

TEST(CSSTokenizerTest, AtKeywordToken) {
  TEST_TOKENS("@at-keyword", AtKeyword("at-keyword"));
  TEST_TOKENS("@testing123", AtKeyword("testing123"));
  TEST_TOKENS("@hello!", AtKeyword("hello"), Delim('!'));
  TEST_TOKENS("@-text", AtKeyword("-text"));
  TEST_TOKENS("@--abc", AtKeyword("--abc"));
  TEST_TOKENS("@--", AtKeyword("--"));
  TEST_TOKENS("@--11", AtKeyword("--11"));
  TEST_TOKENS("@---", AtKeyword("---"));
  TEST_TOKENS("@\\ ", AtKeyword(" "));
  TEST_TOKENS("@-\\ ", AtKeyword("- "));
  TEST_TOKENS("@@", Delim('@'), Delim('@'));
  TEST_TOKENS("@2", Delim('@'), Number(kIntegerValueType, 2, kNoSign));
  TEST_TOKENS("@-1", Delim('@'), Number(kIntegerValueType, -1, kMinusSign));
}

TEST(CSSTokenizerTest, UrlToken) {
  TEST_TOKENS("url(foo.gif)", Url("foo.gif"));
  TEST_TOKENS("urL(https://example.com/cats.png)",
              Url("https://example.com/cats.png"));
  TEST_TOKENS("uRl(what-a.crazy^URL~this\\ is!)",
              Url("what-a.crazy^URL~this is!"));
  TEST_TOKENS("uRL(123#test)", Url("123#test"));
  TEST_TOKENS("Url(escapes\\ \\\"\\'\\)\\()", Url("escapes \"')("));
  TEST_TOKENS("UrL(   whitespace   )", Url("whitespace"));
  TEST_TOKENS("URl( whitespace-eof ", Url("whitespace-eof"));
  TEST_TOKENS("URL(eof", Url("eof"));
  TEST_TOKENS("url(not/*a*/comment)", Url("not/*a*/comment"));
  TEST_TOKENS("urL()", Url(""));
  TEST_TOKENS("uRl(white space),", BadUrl(), Comma());
  TEST_TOKENS("Url(b(ad),", BadUrl(), Comma());
  TEST_TOKENS("uRl(ba'd):", BadUrl(), Colon());
  TEST_TOKENS("urL(b\"ad):", BadUrl(), Colon());
  TEST_TOKENS("uRl(b\"ad):", BadUrl(), Colon());
  TEST_TOKENS("Url(b\\\rad):", BadUrl(), Colon());
  TEST_TOKENS("url(b\\\nad):", BadUrl(), Colon());
  TEST_TOKENS("url(/*'bad')*/", BadUrl(), Delim('*'), Delim('/'));
  TEST_TOKENS("url(ba'd\\\\))", BadUrl(), RightParenthesis());
}

TEST(CSSTokenizerTest, StringToken) {
  TEST_TOKENS("'text'", GetString("text"));
  TEST_TOKENS("\"text\"", GetString("text"));
  TEST_TOKENS("'testing, 123!'", GetString("testing, 123!"));
  TEST_TOKENS("'es\\'ca\\\"pe'", GetString("es'ca\"pe"));
  TEST_TOKENS("'\"quotes\"'", GetString("\"quotes\""));
  TEST_TOKENS("\"'quotes'\"", GetString("'quotes'"));
  TEST_TOKENS("\"mismatch'", GetString("mismatch'"));
  TEST_TOKENS("'text\5\t\13'", GetString("text\5\t\13"));
  TEST_TOKENS("\"end on eof", GetString("end on eof"));
  TEST_TOKENS("'esca\\\nped'", GetString("escaped"));
  TEST_TOKENS("\"esc\\\faped\"", GetString("escaped"));
  TEST_TOKENS("'new\\\rline'", GetString("newline"));
  TEST_TOKENS("\"new\\\r\nline\"", GetString("newline"));
  TEST_TOKENS("'bad\nstring", BadString(), Whitespace(), Ident("string"));
  TEST_TOKENS("'bad\rstring", BadString(), Whitespace(), Ident("string"));
  TEST_TOKENS("'bad\r\nstring", BadString(), Whitespace(), Ident("string"));
  TEST_TOKENS("'bad\fstring", BadString(), Whitespace(), Ident("string"));
//  TEST_TOKENS(std::string("'\0'", 3u), GetString(FromUChar32(0xFFFD)));
//  TEST_TOKENS(std::string("'hel\0lo'", 8u),
//              GetString("hel" + FromUChar32(0xFFFD) + "lo"));
//  TEST_TOKENS(std::string("'h\\65l\0lo'", 10u),
//              GetString("hel" + FromUChar32(0xFFFD) + "lo"));
}

TEST(CSSTokenizerTest, HashToken) {
  TEST_TOKENS("#id-selector", GetHash("id-selector", kHashTokenId));
  TEST_TOKENS("#FF7700", GetHash("FF7700", kHashTokenId));
  TEST_TOKENS("#3377FF", GetHash("3377FF", kHashTokenUnrestricted));
  TEST_TOKENS("#\\ ", GetHash(" ", kHashTokenId));
  TEST_TOKENS("# ", Delim('#'), Whitespace());
  TEST_TOKENS("#\\\n", Delim('#'), Delim('\\'), Whitespace());
  TEST_TOKENS("#\\\r\n", Delim('#'), Delim('\\'), Whitespace());
  TEST_TOKENS("#!", Delim('#'), Delim('!'));
}

TEST(CSSTokenizerTest, NumberToken) {
  TEST_TOKENS("10", Number(kIntegerValueType, 10, kNoSign));
  TEST_TOKENS("12.0", Number(kNumberValueType, 12, kNoSign));
  TEST_TOKENS("+45.6", Number(kNumberValueType, 45.6, kPlusSign));
  TEST_TOKENS("-7", Number(kIntegerValueType, -7, kMinusSign));
  TEST_TOKENS("010", Number(kIntegerValueType, 10, kNoSign));
  TEST_TOKENS("10e0", Number(kNumberValueType, 10, kNoSign));
  TEST_TOKENS("12e3", Number(kNumberValueType, 12000, kNoSign));
  TEST_TOKENS("3e+1", Number(kNumberValueType, 30, kNoSign));
  TEST_TOKENS("12E-1", Number(kNumberValueType, 1.2, kNoSign));
  TEST_TOKENS(".7", Number(kNumberValueType, 0.7, kNoSign));
  TEST_TOKENS("-.3", Number(kNumberValueType, -0.3, kMinusSign));
  TEST_TOKENS("+637.54e-2", Number(kNumberValueType, 6.3754, kPlusSign));
  TEST_TOKENS("-12.34E+2", Number(kNumberValueType, -1234, kMinusSign));

  TEST_TOKENS("+ 5", Delim('+'), Whitespace(),
              Number(kIntegerValueType, 5, kNoSign));
  TEST_TOKENS("-+12", Delim('-'), Number(kIntegerValueType, 12, kPlusSign));
  TEST_TOKENS("+-21", Delim('+'), Number(kIntegerValueType, -21, kMinusSign));
  TEST_TOKENS("++22", Delim('+'), Number(kIntegerValueType, 22, kPlusSign));
  TEST_TOKENS("13.", Number(kIntegerValueType, 13, kNoSign), Delim('.'));
  TEST_TOKENS("1.e2", Number(kIntegerValueType, 1, kNoSign), Delim('.'),
              Ident("e2"));
  TEST_TOKENS("2e3.5", Number(kNumberValueType, 2000, kNoSign),
              Number(kNumberValueType, 0.5, kNoSign));
  TEST_TOKENS("2e3.", Number(kNumberValueType, 2000, kNoSign), Delim('.'));
  TEST_TOKENS("1000000000000000000000000",
              Number(kIntegerValueType, 1e24, kNoSign));
}

TEST(CSSTokenizerTest, DimensionToken) {
  TEST_TOKENS("10px", Dimension(kIntegerValueType, 10, "px"));
  TEST_TOKENS("12.0em", Dimension(kNumberValueType, 12, "em"));
  TEST_TOKENS("-12.0em", Dimension(kNumberValueType, -12, "em"));
  TEST_TOKENS("+45.6__qem", Dimension(kNumberValueType, 45.6, "__qem"));
  TEST_TOKENS("5e", Dimension(kIntegerValueType, 5, "e"));
  TEST_TOKENS("5px-2px", Dimension(kIntegerValueType, 5, "px-2px"));
  TEST_TOKENS("5e-", Dimension(kIntegerValueType, 5, "e-"));
  TEST_TOKENS("5\\ ", Dimension(kIntegerValueType, 5, " "));
  TEST_TOKENS("40\\70\\78", Dimension(kIntegerValueType, 40, "px"));
  TEST_TOKENS("4e3e2", Dimension(kNumberValueType, 4000, "e2"));
  TEST_TOKENS("0x10px", Dimension(kIntegerValueType, 0, "x10px"));
  TEST_TOKENS("4unit ", Dimension(kIntegerValueType, 4, "unit"), Whitespace());
  TEST_TOKENS("5e+", Dimension(kIntegerValueType, 5, "e"), Delim('+'));
  TEST_TOKENS("2e.5", Dimension(kIntegerValueType, 2, "e"),
              Number(kNumberValueType, 0.5, kNoSign));
  TEST_TOKENS("2e+.5", Dimension(kIntegerValueType, 2, "e"),
              Number(kNumberValueType, 0.5, kPlusSign));
}

TEST(CSSTokenizerTest, PercentageToken) {
  TEST_TOKENS("10%", Percentage(kIntegerValueType, 10));
  TEST_TOKENS("+12.0%", Percentage(kNumberValueType, 12));
  TEST_TOKENS("-48.99%", Percentage(kNumberValueType, -48.99));
  TEST_TOKENS("6e-1%", Percentage(kNumberValueType, 0.6));
  TEST_TOKENS("5%%", Percentage(kIntegerValueType, 5), Delim('%'));
}

TEST(CSSTokenizerTest, UnicodeRangeToken) {
  TEST_TOKENS("u+z", Ident("u"), Delim('+'), Ident("z"));
  TEST_TOKENS("u+", Ident("u"), Delim('+'));
  TEST_TOKENS("u+-543", Ident("u"), Delim('+'),
              Number(kIntegerValueType, -543, kMinusSign));

  TEST_TOKENS("u+012345", Ident("u"),
              Number(kIntegerValueType, 12345, kPlusSign));
  TEST_TOKENS("u+a", Ident("u"), Delim('+'), Ident("a"));
}

TEST(CSSTokenizerTest, CommentToken) {
  TEST_TOKENS("/*comment*/a", Ident("a"));
  TEST_TOKENS("/**\\2f**//", Delim('/'));
  TEST_TOKENS("/**y*a*y**/ ", Whitespace());
  TEST_TOKENS(",/* \n :) \n */)", Comma(), RightParenthesis());
  TEST_TOKENS(":/*/*/", Colon());
  TEST_TOKENS("/**/*", Delim('*'));
  TEST_TOKENS(";/******", Semicolon());
}


}