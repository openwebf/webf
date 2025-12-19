// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/media_list.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/parser/media_query_parser.h"
#include "gtest/gtest.h"

namespace webf {

typedef struct {
  const char* input;
  const char* output;
} MediaConditionTestCase;

TEST(MediaConditionParserTest, Basic) {
  MediaConditionTestCase test_cases[] = {
      {"screen", "not all"},
      {"screen and (color)", "not all"},
      {"all and (min-width:500px)", "not all"},
      {"(min-width:500px)", "(min-width: 500px)"},
      {"(min-width : -100px)", "(min-width: -100px)"},
      {"(min-width: 100px) and print", "not all"},
      {"(min-width: 100px) and (max-width: 900px)", nullptr},
      {"(min-width: [100px) and (max-width: 900px)", "not all"},
      {"not (min-width: 900px)", "not (min-width: 900px)"},
      {"not ( blabla)", "not ( blabla)"},  // <general-enclosed>
      {"", ""},
      {" ", ""},
      {",(min-width: 500px)", "not all"},
      {"(min-width: 500px),", "not all"},
      {"(width: 1px) and (width: 2px), (width: 3px)", "not all"},
      {"(width: 1px) and (width: 2px), screen", "not all"},
      {"(min-width: 500px), (min-width: 500px)", "not all"},
      {"not (min-width: 500px), not (min-width: 500px)", "not all"},
      {"(width: 1px), screen", "not all"},
      {"screen, (width: 1px)", "not all"},
      {"screen, (width: 1px), print", "not all"},
  };

  for (const MediaConditionTestCase& test_case : test_cases) {
    SCOPED_TRACE(test_case.input);
    String tokenizer_string = String::FromUTF8(test_case.input);
    CSSTokenizer tokenizer{tokenizer_string.ToStringView()};
    CSSParserTokenStream stream(tokenizer);
    std::shared_ptr<MediaQuerySet> media_condition_query_set = MediaQueryParser::ParseMediaCondition(stream, nullptr);
    String query_text = stream.AtEnd() ? media_condition_query_set->MediaText() : String::FromUTF8("not all");
    const char* expected_text = test_case.output ? test_case.output : test_case.input;
    EXPECT_EQ(String::FromUTF8(expected_text), query_text);
  }
}

}  // namespace webf
