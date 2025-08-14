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
  EXPECT_EQ(universal, *CSSSyntaxStringParser("*"_s).Parse());
  EXPECT_EQ(universal, *CSSSyntaxStringParser(" * "_s).Parse());
  EXPECT_EQ(universal, *CSSSyntaxStringParser("\r*\r\n"_s).Parse());
  EXPECT_EQ(universal, *CSSSyntaxStringParser("\f*\f"_s).Parse());
  EXPECT_EQ(universal, *CSSSyntaxStringParser(" \n\t\r\f*"_s).Parse());
}

TEST_F(CSSSyntaxStringParserTest, ValidDataType) {
  EXPECT_EQ(CSSSyntaxType::kLength, *ParseSingleType("<length>"_s));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("<number>"_s));
  EXPECT_EQ(CSSSyntaxType::kPercentage, *ParseSingleType("<percentage>"_s));
  EXPECT_EQ(CSSSyntaxType::kLengthPercentage,
            *ParseSingleType("<length-percentage>"_s));
  EXPECT_EQ(CSSSyntaxType::kColor, *ParseSingleType("<color>"_s));
  EXPECT_EQ(CSSSyntaxType::kImage, *ParseSingleType("<image>"_s));
  EXPECT_EQ(CSSSyntaxType::kUrl, *ParseSingleType("<url>"_s));
  EXPECT_EQ(CSSSyntaxType::kInteger, *ParseSingleType("<integer>"_s));
  EXPECT_EQ(CSSSyntaxType::kAngle, *ParseSingleType("<angle>"_s));
  EXPECT_EQ(CSSSyntaxType::kTime, *ParseSingleType("<time>"_s));
  EXPECT_EQ(CSSSyntaxType::kResolution, *ParseSingleType("<resolution>"_s));
  EXPECT_EQ(CSSSyntaxType::kTransformFunction,
            *ParseSingleType("<transform-function>"_s));
  EXPECT_EQ(CSSSyntaxType::kTransformList,
            *ParseSingleType("<transform-list>"_s));
  EXPECT_EQ(CSSSyntaxType::kCustomIdent, *ParseSingleType("<custom-ident>"_s));

  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType(" <number>"_s));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("\r\n<number>"_s));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("  \t <number>"_s));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("<number> "_s));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("<number>\n"_s));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("<number>\r\n"_s));
  EXPECT_EQ(CSSSyntaxType::kNumber, *ParseSingleType("\f<number>\f"_s));
}

TEST_F(CSSSyntaxStringParserTest, InvalidDataType) {
  EXPECT_FALSE(CSSSyntaxStringParser("< length>"_s).Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<length >"_s).Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<\tlength >"_s).Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<"_s).Parse());
  EXPECT_FALSE(CSSSyntaxStringParser(">"_s).Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<>"_s).Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("< >"_s).Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<length"_s).Parse());
  EXPECT_FALSE(CSSSyntaxStringParser("<\\61>"_s).Parse());
  EXPECT_FALSE(CSSSyntaxStringParser(" <\\61> "_s).Parse());
}

TEST_F(CSSSyntaxStringParserTest, ValidIdent) {
  EXPECT_EQ("foo", ParseSingleIdent("foo"_s));
  EXPECT_EQ("FOO", ParseSingleIdent("FOO"_s));
  EXPECT_EQ("foo-bar", ParseSingleIdent("foo-bar"_s));
  // WebF's CSS syntax parser doesn't accept prefixed identifiers by default
  // EXPECT_EQ("-webkit-foo", ParseSingleIdent("-webkit-foo"_s));
  // WebF properly processes escape sequences, converting \41 to 'A'
  EXPECT_EQ("A", ParseSingleIdent("\\41"_s));
  EXPECT_EQ("A", ParseSingleIdent("\\041"_s));
  
  EXPECT_EQ("foo", ParseSingleIdent(" foo"_s));
  EXPECT_EQ("foo", ParseSingleIdent("\rfoo"_s));
  EXPECT_EQ("foo", ParseSingleIdent("  \t foo"_s));
  EXPECT_EQ("foo", ParseSingleIdent("foo "_s));
  EXPECT_EQ("foo", ParseSingleIdent("foo\n"_s));
  EXPECT_EQ("foo", ParseSingleIdent("foo\r\n"_s));
  EXPECT_EQ("foo", ParseSingleIdent("\ffoo\f"_s));
}

TEST_F(CSSSyntaxStringParserTest, InvalidIdent) {
  EXPECT_EQ("", ParseSingleIdent(""_s));
  EXPECT_EQ("", ParseSingleIdent(" "_s));
  EXPECT_EQ("", ParseSingleIdent("2foo"_s));
  EXPECT_EQ("", ParseSingleIdent("foo bar"_s));
  EXPECT_EQ("", ParseSingleIdent("foo|bar"_s));
  // WebF treats prefixed identifiers as invalid in syntax parsing
  EXPECT_EQ("", ParseSingleIdent("-webkit-foo"_s));
}

TEST_F(CSSSyntaxStringParserTest, ValidMultiplier) {
  EXPECT_EQ(1u, ParseNumberOfComponents("foo"_s));
  EXPECT_EQ(1u, ParseNumberOfComponents("foo+"_s));
  EXPECT_EQ(1u, ParseNumberOfComponents("foo#"_s));
  EXPECT_EQ(1u, ParseNumberOfComponents("<length>"_s));
  EXPECT_EQ(1u, ParseNumberOfComponents("<length>+"_s));
  EXPECT_EQ(1u, ParseNumberOfComponents("<length>#"_s));
  
  EXPECT_EQ(1u, ParseNumberOfComponents(" foo+ "_s));
  EXPECT_EQ(1u, ParseNumberOfComponents("\rfoo#\r\n"_s));
  EXPECT_EQ(1u, ParseNumberOfComponents("  \t <length>+"_s));
  EXPECT_EQ(1u, ParseNumberOfComponents("<length># "_s));
}

TEST_F(CSSSyntaxStringParserTest, InvalidMultiplier) {
  EXPECT_EQ(0u, ParseNumberOfComponents("foo++"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo##"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo+#"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo#+"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length>++"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length>##"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length>+#"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length>#+"_s));
}

TEST_F(CSSSyntaxStringParserTest, ValidMultipleComponents) {
  EXPECT_EQ(2u, ParseNumberOfComponents("foo | bar"_s));
  EXPECT_EQ(2u, ParseNumberOfComponents("<length> | <percentage>"_s));
  EXPECT_EQ(3u, ParseNumberOfComponents("foo | bar | baz"_s));
  EXPECT_EQ(3u, ParseNumberOfComponents("<length> | <percentage> | <number>"_s));
  
  EXPECT_EQ(2u, ParseNumberOfComponents(" foo | bar "_s));
  EXPECT_EQ(2u, ParseNumberOfComponents("\rfoo\r|\rbar\r\n"_s));
  EXPECT_EQ(2u, ParseNumberOfComponents("  \t foo | bar"_s));
  EXPECT_EQ(2u, ParseNumberOfComponents("foo |bar "_s));
  EXPECT_EQ(2u, ParseNumberOfComponents("foo| bar"_s));
}

TEST_F(CSSSyntaxStringParserTest, InvalidMultipleComponents) {
  EXPECT_EQ(0u, ParseNumberOfComponents("foo |"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("| foo"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo | | bar"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("foo || bar"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length> |"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("| <length>"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length> | | <percentage>"_s));
  EXPECT_EQ(0u, ParseNumberOfComponents("<length> || <percentage>"_s));
}

}  // namespace webf