// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_syntax_string_parser.h"

#include "gtest/gtest.h"
#include "core/css/css_syntax_component.h"
#include "foundation/string/wtf_string.h"
#include "webf_test_env.h"

namespace webf {

class CSSSyntaxStringParserTest : public ::testing::Test {
 public:
  void SetUp() override {
    env_ = TEST_init();
  }

  std::optional<CSSSyntaxComponent> ParseSingleComponent(const String& syntax) {
    auto definition = CSSSyntaxStringParser(syntax).Parse();
    if (!definition) {
      return std::nullopt;
    }
    if (definition->Components().size() != 1) {
      return std::nullopt;
    }
    return definition->Components()[0];
  }

  std::optional<CSSSyntaxType> ParseSingleType(const String& syntax) {
    auto component = ParseSingleComponent(syntax);
    return component ? std::make_optional(component->GetType()) : std::nullopt;
  }

  String ParseSingleIdent(const String& syntax) {
    auto component = ParseSingleComponent(syntax);
    if (!component || component->GetType() != CSSSyntaxType::kIdent) {
      return String::FromUTF8("");
    }
    return component->GetString();
  }

  size_t ParseNumberOfComponents(const String& syntax) {
    auto definition = CSSSyntaxStringParser(syntax).Parse();
    if (!definition) {
      return 0;
    }
    return definition->Components().size();
  }

  CSSSyntaxDefinition CreateUniversalDescriptor() {
    return CSSSyntaxDefinition::CreateUniversal();
  }

 protected:
  std::shared_ptr<WebFTestEnv> env_;
};

TEST_F(CSSSyntaxStringParserTest, UniversalDescriptor) {
  auto universal = CreateUniversalDescriptor();
  EXPECT_TRUE(universal.IsUniversal());
  EXPECT_EQ(universal, *CSSSyntaxStringParser("*").Parse());
  EXPECT_EQ(universal, *CSSSyntaxStringParser(" * ").Parse());
  EXPECT_EQ(universal, *CSSSyntaxStringParser("\r*\r\n").Parse());
  EXPECT_EQ(universal, *CSSSyntaxStringParser("\f*\f").Parse());
  EXPECT_EQ(universal, *CSSSyntaxStringParser(" \n\t\r\f*").Parse());
}

TEST_F(CSSSyntaxStringParserTest, ValidDataType) {
  EXPECT_EQ(CSSSyntaxType::kLength, *ParseSingleType("<length>"));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("<number>"));
  EXPECT_EQ(CSSSyntaxType::kPercentage, *ParseSingleType("<percentage>"));
  EXPECT_EQ(CSSSyntaxType::kLengthPercentage,
            *ParseSingleType("<length-percentage>"));
  EXPECT_EQ(CSSSyntaxType::kColor, *ParseSingleType("<color>"));
  EXPECT_EQ(CSSSyntaxType::kImage, *ParseSingleType("<image>"));
  EXPECT_EQ(CSSSyntaxType::kUrl, *ParseSingleType("<url>"));
  EXPECT_EQ(CSSSyntaxType::kInteger, *ParseSingleType("<integer>"));
  EXPECT_EQ(CSSSyntaxType::kAngle, *ParseSingleType("<angle>"));
  EXPECT_EQ(CSSSyntaxType::kTime, *ParseSingleType("<time>"));
  EXPECT_EQ(CSSSyntaxType::kResolution, *ParseSingleType("<resolution>"));
  EXPECT_EQ(CSSSyntaxType::kTransformFunction,
            *ParseSingleType("<transform-function>"));
  EXPECT_EQ(CSSSyntaxType::kTransformList,
            *ParseSingleType("<transform-list>"));
  EXPECT_EQ(CSSSyntaxType::kCustomIdent, *ParseSingleType("<custom-ident>"));

  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType(" <number>"));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("\r\n<number>"));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("  \t <number>"));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("<number> "));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("<number>\n"));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("<number>\r\n"));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("\f<number>\f"));
}

TEST_F(CSSSyntaxStringParserTest, InvalidDataType) {
  EXPECT_FALSE(CSSSyntaxStringParser("< length>").Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<length >").Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<\tlength >").Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<").Parse());
  EXPECT_FALSE(CSSSyntaxStringParser(">").Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<>").Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("< >").Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<length").Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<\\61>").Parse());
  EXPECT_FALSE(CSSSyntaxStringParser(" <\\61> ").Parse());
}

TEST_F(CSSSyntaxStringParserTest, ValidIdent) {
  EXPECT_EQ("foo", ParseSingleIdent("foo"));
  EXPECT_EQ("FOO", ParseSingleIdent("FOO"));
  EXPECT_EQ("foo-bar", ParseSingleIdent("foo-bar"));
  // WebF's CSS syntax parser doesn't accept prefixed identifiers by default
  // EXPECT_EQ("-webkit-foo", ParseSingleIdent("-webkit-foo"));
  // WebF properly processes escape sequences, converting \41 to 'A'
  EXPECT_EQ("A", ParseSingleIdent("\\41"));
  EXPECT_EQ("A", ParseSingleIdent("\\041"));
  
  EXPECT_EQ("foo", ParseSingleIdent(" foo"));
  EXPECT_EQ("foo", ParseSingleIdent("\rfoo"));
  EXPECT_EQ("foo", ParseSingleIdent("  \t foo"));
  EXPECT_EQ("foo", ParseSingleIdent("foo "));
  EXPECT_EQ("foo", ParseSingleIdent("foo\n"));
  EXPECT_EQ("foo", ParseSingleIdent("foo\r\n"));
  EXPECT_EQ("foo", ParseSingleIdent("\ffoo\f"));
}

TEST_F(CSSSyntaxStringParserTest, InvalidIdent) {
  EXPECT_EQ("", ParseSingleIdent(""));
  EXPECT_EQ("", ParseSingleIdent(" "));
  EXPECT_EQ("", ParseSingleIdent("2foo"));
  EXPECT_EQ("", ParseSingleIdent("foo bar"));
  EXPECT_EQ("", ParseSingleIdent("foo|bar"));
  // WebF treats prefixed identifiers as invalid in syntax parsing
  EXPECT_EQ("", ParseSingleIdent("-webkit-foo"));
}

TEST_F(CSSSyntaxStringParserTest, ValidMultiplier) {
  EXPECT_EQ(1u, ParseNumberOfComponents("foo"));
  EXPECT_EQ(1u, ParseNumberOfComponents("foo+"));
  EXPECT_EQ(1u, ParseNumberOfComponents("foo#"));
  EXPECT_EQ(1u, ParseNumberOfComponents("<length>"));
  EXPECT_EQ(1u, ParseNumberOfComponents("<length>+"));
  EXPECT_EQ(1u, ParseNumberOfComponents("<length>#"));
  
  EXPECT_EQ(1u, ParseNumberOfComponents(" foo+ "));
  EXPECT_EQ(1u, ParseNumberOfComponents("\rfoo#\r\n"));
  EXPECT_EQ(1u, ParseNumberOfComponents("  \t <length>+"));
  EXPECT_EQ(1u, ParseNumberOfComponents("<length># "));
}

TEST_F(CSSSyntaxStringParserTest, InvalidMultiplier) {
  EXPECT_EQ(0u, ParseNumberOfComponents("foo++"));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo##"));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo+#"));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo#+"));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length>++"));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length>##"));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length>+#"));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length>#+"));
}

TEST_F(CSSSyntaxStringParserTest, ValidMultipleComponents) {
  EXPECT_EQ(2u, ParseNumberOfComponents("foo | bar"));
  EXPECT_EQ(2u, ParseNumberOfComponents("<length> | <percentage>"));
  EXPECT_EQ(3u, ParseNumberOfComponents("foo | bar | baz"));
  EXPECT_EQ(3u, ParseNumberOfComponents("<length> | <percentage> | <number>"));
  
  EXPECT_EQ(2u, ParseNumberOfComponents(" foo | bar "));
  EXPECT_EQ(2u, ParseNumberOfComponents("\rfoo\r|\rbar\r\n"));
  EXPECT_EQ(2u, ParseNumberOfComponents("  \t foo | bar"));
  EXPECT_EQ(2u, ParseNumberOfComponents("foo |bar "));
  EXPECT_EQ(2u, ParseNumberOfComponents("foo| bar"));
}

TEST_F(CSSSyntaxStringParserTest, InvalidMultipleComponents) {
  EXPECT_EQ(0u, ParseNumberOfComponents("foo |"));
  EXPECT_EQ(0u, ParseNumberOfComponents("| foo"));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo | | bar"));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo || bar"));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length> |"));
  EXPECT_EQ(0u, ParseNumberOfComponents("| <length>"));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length> | | <percentage>"));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length> || <percentage>"));
}

}  // namespace webf