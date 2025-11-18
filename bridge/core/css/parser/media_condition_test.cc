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
      {"screen", "screen"},
      {"screen and (color)", "screen and (color)"},
      {"all and (min-width:500px)", "all and (min-width:500px)"},
      {"(min-width:500px)", "(min-width:500px)"},
      {"(min-width : -100px)", "(min-width : -100px)"},
      {"(min-width: 100px) and print", "(min-width: 100px) and print"},
      {"(min-width: 100px) and (max-width: 900px)", nullptr},
      {"(min-width: [100px) and (max-width: 900px)", "(min-width: [100px) and (max-width: 900px)"},
      {"not (min-width: 900px)", "not (min-width: 900px)"},
      {"not ( blabla)", "not ( blabla)"},  // <general-enclosed>
      {"", ""},
      {" ", ""},
      {",(min-width: 500px)", ",(min-width: 500px)"},
      {"(min-width: 500px),", "(min-width: 500px),"},
      {"(width: 1px) and (width: 2px), (width: 3px)", "(width: 1px) and (width: 2px), (width: 3px)"},
      {"(width: 1px) and (width: 2px), screen", "(width: 1px) and (width: 2px), screen"},
      {"(min-width: 500px), (min-width: 500px)", "(min-width: 500px), (min-width: 500px)"},
      {"not (min-width: 500px), not (min-width: 500px)", "not (min-width: 500px), not (min-width: 500px)"},
      {"(width: 1px), screen", "(width: 1px), screen"},
      {"screen, (width: 1px)", "screen, (width: 1px)"},
      {"screen, (width: 1px), print", "screen, (width: 1px), print"},

      {nullptr, nullptr}  // Do not remove the terminator line.
  };

  for (unsigned i = 0; test_cases[i].input; ++i) {
    SCOPED_TRACE(test_cases[i].input);
    String tokenizer_string = String::FromUTF8(test_cases[i].input);
    CSSTokenizer tokenizer{tokenizer_string.ToStringView()};
    CSSParserTokenStream stream(tokenizer);
    std::shared_ptr<MediaQuerySet> media_condition_query_set = MediaQueryParser::ParseMediaCondition(stream, nullptr);
    String query_text = media_condition_query_set->MediaText();
    const char* expected_text = test_cases[i].output ? test_cases[i].output : test_cases[i].input;
    EXPECT_EQ(String::FromUTF8(expected_text), query_text);
  }
}

}  // namespace webf
