// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/parser/css_selector_parser.h"
#include <iostream>
#include <stdexcept>
#include <string_view>
#include "core/css/css_test_helpers.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/style_sheet_contents.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

typedef struct {
  const char* input;
  const int a;
  const int b;
} ANPlusBTestCase;

struct SelectorTestCase {
  // The input string to parse as a selector list.
  const char* input;

  // The expected serialization of the parsed selector list. If nullptr, then
  // the expected serialization is the same as the input value.
  //
  // For selector list that are expected to fail parsing, use the empty
  // string "".
  const char* expected = nullptr;
};

class SelectorParseTest : public ::testing::TestWithParam<SelectorTestCase> {};

TEST_P(SelectorParseTest, Parse) {
  auto param = GetParam();
  SCOPED_TRACE(param.input);
  std::shared_ptr<CSSSelectorList> list = css_test_helpers::ParseSelectorList(param.input);
  const char* expected = param.expected ? param.expected : param.input;
  EXPECT_EQ(std::string(expected), list->SelectorsText());
}

TEST(CSSSelectorParserTest, ValidANPlusB) {
  ANPlusBTestCase test_cases[] = {
      {"odd", 2, 1},
      {"OdD", 2, 1},
      {"even", 2, 0},
      {"EveN", 2, 0},
      {"0", 0, 0},
      {"8", 0, 8},
      {"+12", 0, 12},
      {"-14", 0, -14},

      {"0n", 0, 0},
      {"16N", 16, 0},
      {"-19n", -19, 0},
      {"+23n", 23, 0},
      {"n", 1, 0},
      {"N", 1, 0},
      {"+n", 1, 0},
      {"-n", -1, 0},
      {"-N", -1, 0},

      {"6n-3", 6, -3},
      {"-26N-33", -26, -33},
      {"n-18", 1, -18},
      {"+N-5", 1, -5},
      {"-n-7", -1, -7},

      {"0n+0", 0, 0},
      {"10n+5", 10, 5},
      {"10N +5", 10, 5},
      {"10n -5", 10, -5},
      {"N+6", 1, 6},
      {"n +6", 1, 6},
      {"+n -7", 1, -7},
      {"-N -8", -1, -8},
      {"-n+9", -1, 9},

      {"33N- 22", 33, -22},
      {"+n- 25", 1, -25},
      {"N- 46", 1, -46},
      {"n- 0", 1, 0},
      {"-N- 951", -1, -951},
      {"-n- 951", -1, -951},

      {"29N + 77", 29, 77},
      {"29n - 77", 29, -77},
      {"+n + 61", 1, 61},
      {"+N - 63", 1, -63},
      {"+n/**/- 48", 1, -48},
      {"-n + 81", -1, 81},
      {"-N - 88", -1, -88},

      {"3091970736n + 1", std::numeric_limits<int>::max(), 1},
      {"-3091970736n + 1", std::numeric_limits<int>::min(), 1},
      // B is calculated as +ve first, then negated.
      {"N- 3091970736", 1, -std::numeric_limits<int>::max()},
      {"N+ 3091970736", 1, std::numeric_limits<int>::max()},
  };

  for (auto test_case : test_cases) {
    SCOPED_TRACE(test_case.input);

    std::pair<int, int> ab;
    CSSTokenizer tokenizer(std::string(test_case.input));
    CSSParserTokenStream stream(tokenizer);
    bool passed = CSSSelectorParser::ConsumeANPlusB(stream, ab);
    EXPECT_TRUE(passed);
    EXPECT_EQ(test_case.a, ab.first);
    EXPECT_EQ(test_case.b, ab.second);
  }
}

TEST(CSSSelectorParserTest, InvalidANPlusB) {
  // Some of these have token range prefixes which are valid <an+b> and could
  // in theory be valid in consumeANPlusB, but this behaviour isn't needed
  // anywhere and not implemented.
  const char* test_cases[] = {
      " odd", "+ n", "3m+4", "12n--34", "12n- -34", "12n- +34", "23n-+43", "10n 5", "10n + +5", "10n + -5",
  };

  for (std::string test_case : test_cases) {
    SCOPED_TRACE(test_case);

    std::pair<int, int> ab;
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    bool passed = CSSSelectorParser::ConsumeANPlusB(stream, ab);
    EXPECT_FALSE(passed);
  }
}

TEST(CSSSelectorParserTest, PseudoElementsInCompoundLists) {
  const char* test_cases[] = {":not(::before)",
                              ":not(::content)",
                              ":host(::before)",
                              ":host(::content)",
                              ":host-context(::before)",
                              ":host-context(::content)",
                              ":-webkit-any(::after, ::before)",
                              ":-webkit-any(::content, span)"};

  std::vector<CSSSelector> arena;
  for (const char* test_case : test_cases) {
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kHTMLStandardMode),
                                         CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                         /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
    EXPECT_EQ(vector.size(), 0u);
  }
}

TEST(CSSSelectorParserTest, InvalidSimpleAfterPseudoElementInCompound) {
  const char* test_cases[] = {"::before#id",
                              "::after:hover",
                              ".class::content::before",
                              "::shadow.class",
                              "::selection:window-inactive::before",
                              "::search-text.class",
                              "::search-text::before",
                              "::search-text:hover",
                              "::-webkit-volume-slider.class",
                              "::before:not(.a)",
                              "::shadow:not(::after)",
                              "::-webkit-scrollbar:vertical:not(:first-child)",
                              "video::-webkit-media-text-track-region-container.scrolling",
                              "div ::before.a",
                              "::slotted(div):hover",
                              "::slotted(div)::slotted(span)",
                              "::slotted(div)::before:hover",
                              "::slotted(div)::before::slotted(span)",
                              "::slotted(*)::first-letter",
                              "::slotted(.class)::first-line",
                              "::slotted([attr])::-webkit-scrollbar"};

  std::vector<CSSSelector> arena;
  for (const char* test_case : test_cases) {
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kHTMLStandardMode),
                                         CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                         /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
    EXPECT_EQ(vector.size(), 0u);
  }
}

TEST(CSSSelectorParserTest, TransitionPseudoStyles) {
  struct TestCase {
    const char* selector;
    bool valid;
    std::optional<std::string> argument;
    CSSSelector::PseudoType type;
  };

  TestCase test_cases[] = {
      {"html::view-transition-group(*)", true, std::nullopt, CSSSelector::kPseudoViewTransitionGroup},
      {"html::view-transition-group(foo)", true, "foo", CSSSelector::kPseudoViewTransitionGroup},
      {"html::view-transition-image-pair(foo)", true, "foo", CSSSelector::kPseudoViewTransitionImagePair},
      {"html::view-transition-old(foo)", true, "foo", CSSSelector::kPseudoViewTransitionOld},
      {"html::view-transition-new(foo)", true, "foo", CSSSelector::kPseudoViewTransitionNew},
      {"::view-transition-group(foo)", true, "foo", CSSSelector::kPseudoViewTransitionGroup},
      {"div::view-transition-group(*)", true, std::nullopt, CSSSelector::kPseudoViewTransitionGroup},
      {"::view-transition-group(*)::before", false, std::nullopt, CSSSelector::kPseudoUnknown},
      {"::view-transition-group(*):hover", false, std::nullopt, CSSSelector::kPseudoUnknown},
  };

  std::vector<CSSSelector> arena;
  for (const auto& test_case : test_cases) {
    SCOPED_TRACE(test_case.selector);
    CSSTokenizer tokenizer(test_case.selector);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kHTMLStandardMode),
                                         CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                         /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
    EXPECT_EQ(!vector.empty(), test_case.valid);
    if (!test_case.valid) {
      continue;
    }

    std::shared_ptr<CSSSelectorList> list = CSSSelectorList::AdoptSelectorVector(vector);
    ASSERT_TRUE(list->HasOneSelector());

    auto* selector = list->First();
    while (selector->NextSimpleSelector()) {
      selector = selector->NextSimpleSelector();
    }

    EXPECT_EQ(selector->GetPseudoType(), test_case.type);
    EXPECT_EQ(selector->GetPseudoType() == CSSSelector::kPseudoViewTransition ? selector->Argument()
                                                                              : selector->IdentList()[0],
              test_case.argument);
  }
}

TEST(CSSSelectorParserTest, WorkaroundForInvalidCustomPseudoInUAStyle) {
  // See crbug.com/578131
  const char* test_cases[] = {"video::-webkit-media-text-track-region-container.scrolling",
                              "input[type=\"range\" i]::-webkit-media-slider-container > div"};

  std::vector<CSSSelector> arena;
  for (auto&& test_case : test_cases) {
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kUASheetMode),
                                         CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                         /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
    EXPECT_GT(vector.size(), 0u);
  }
}

TEST(CSSSelectorParserTest, InvalidPseudoElementInNonRightmostCompound) {
  const char* test_cases[] = {"::-webkit-volume-slider *", "::before *", "::-webkit-scrollbar *", "::cue *",
                              "::selection *"};

  std::vector<CSSSelector> arena;
  for (const char* test_case : test_cases) {
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kHTMLStandardMode),
                                         CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                         /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
    EXPECT_EQ(vector.size(), 0u);
  }
}

TEST(CSSSelectorParserTest, UnresolvedNamespacePrefix) {
  const char* test_cases[] = {"ns|div", "div ns|div", "div ns|div "};

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);

  std::vector<CSSSelector> arena;
  for (const char* test_case : test_cases) {
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, context, CSSNestingType::kNone,
                                         /*parent_rule_for_nesting=*/nullptr, /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, sheet, arena);
    EXPECT_EQ(vector.size(), 0u);
  }
}

TEST(CSSSelectorParserTest, UnexpectedPipe) {
  const char* test_cases[] = {"div | .c", "| div", " | div"};

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);

  std::vector<CSSSelector> arena;
  for (const char* test_case : test_cases) {
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, context, CSSNestingType::kNone,
                                         /*parent_rule_for_nesting=*/nullptr, /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, sheet, arena);
    EXPECT_EQ(vector.size(), 0u);
  }
}

TEST(CSSSelectorParserTest, AttributeSelectorUniversalInvalid) {
  const char* test_cases[] = {"[*]", "[*|*]"};

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);

  std::vector<CSSSelector> arena;
  for (std::string test_case : test_cases) {
    SCOPED_TRACE(test_case);
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, context, CSSNestingType::kNone,
                                         /*parent_rule_for_nesting=*/nullptr, /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, sheet, arena);
    EXPECT_EQ(vector.size(), 0u);
  }
}

TEST(CSSSelectorParserTest, InternalPseudo) {
  const char* test_cases[] = {"::-internal-whatever",
                              "::-internal-media-controls-text-track-list",
                              ":-internal-is-html",
                              ":-internal-list-box",
                              ":-internal-multi-select-focus",
                              ":-internal-shadow-host-has-appearance",
                              ":-internal-spatial-navigation-focus",
                              ":-internal-video-persistent",
                              ":-internal-video-persistent-ancestor"};

  std::vector<CSSSelector> arena;
  for (std::string test_case : test_cases) {
    SCOPED_TRACE(test_case);
    {
      CSSTokenizer tokenizer(test_case);
      CSSParserTokenStream stream(tokenizer);
      tcb::span<CSSSelector> author_vector =
          CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kHTMLStandardMode),
                                           CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                           /*is_within_scope=*/false,
                                           /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
      EXPECT_EQ(author_vector.size(), 0u);
    }

    {
      CSSTokenizer tokenizer(test_case);
      CSSParserTokenStream stream(tokenizer);
      tcb::span<CSSSelector> ua_vector =
          CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kUASheetMode),
                                           CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                           /*is_within_scope=*/false,
                                           /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
      EXPECT_GT(ua_vector.size(), 0u);
    }
  }
}

TEST(CSSSelectorParserTest, ScrollMarkerPseudos) {
  struct TestCase {
    const char* selector;
    CSSSelector::PseudoType type;
  };

  TestCase test_cases[] = {
      {"ul::scroll-marker-group", CSSSelector::kPseudoScrollMarkerGroup},
      {"li::scroll-marker", CSSSelector::kPseudoScrollMarker},
  };

  std::vector<CSSSelector> arena;
  for (const auto& test_case : test_cases) {
    SCOPED_TRACE(test_case.selector);
    CSSTokenizer tokenizer(test_case.selector);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kHTMLStandardMode),
                                         CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                         /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
    EXPECT_TRUE(!vector.empty());

    std::shared_ptr<CSSSelectorList> list = CSSSelectorList::AdoptSelectorVector(vector);
    ASSERT_TRUE(list->HasOneSelector());

    const CSSSelector* selector = list->First();
    while (selector->NextSimpleSelector()) {
      selector = selector->NextSimpleSelector();
    }

    EXPECT_EQ(selector->GetPseudoType(), test_case.type);
  }
}

// Pseudo-elements are not valid within :is() as per the spec:
// https://drafts.csswg.org/selectors-4/#matches
static const SelectorTestCase invalid_pseudo_is_argments_data[] = {
    // clang-format off
     {":is(::-webkit-progress-bar)", ":is()"},
     {":is(::-webkit-progress-value)", ":is()"},
     {":is(::-webkit-slider-runnable-track)", ":is()"},
     {":is(::-webkit-slider-thumb)", ":is()"},
     {":is(::after)", ":is()"},
     {":is(::backdrop)", ":is()"},
     {":is(::before)", ":is()"},
     {":is(::cue)", ":is()"},
     {":is(::first-letter)", ":is()"},
     {":is(::first-line)", ":is()"},
     {":is(::grammar-error)", ":is()"},
     {":is(::marker)", ":is()"},
     {":is(::placeholder)", ":is()"},
     {":is(::selection)", ":is()"},
     {":is(::slotted)", ":is()"},
     {":is(::spelling-error)", ":is()"},
     {":is(:after)", ":is()"},
     {":is(:before)", ":is()"},
     {":is(:cue)", ":is()"},
     {":is(:first-letter)", ":is()"},
     {":is(:first-line)", ":is()"},
     // If the selector is nest-containing, it serializes as-is:
     // https://drafts.csswg.org/css-nesting-1/#syntax
     {":is(:unknown(&))"},
    // clang-format on
};

INSTANTIATE_TEST_SUITE_P(InvalidPseudoIsArguments,
                         SelectorParseTest,
                         testing::ValuesIn(invalid_pseudo_is_argments_data));

static const SelectorTestCase is_where_nesting_data[] = {
    // clang-format off
     // These pseudos only accept compound selectors:
//     {"::slotted(:is(.a .b))", "::slotted(:is())"},
//     {"::slotted(:is(.a + .b))", "::slotted(:is())"},
//     {"::slotted(:is(.a, .b + .c))", "::slotted(:is(.a))"},
//     {":host(:is(.a .b))", ":host(:is())"},
//     {":host(:is(.a + .b))", ":host(:is())"},
//     {":host(:is(.a, .b + .c))", ":host(:is(.a))"},
//     {":host-context(:is(.a .b))", ":host-context(:is())"},
//     {":host-context(:is(.a + .b))", ":host-context(:is())"},
//     {":host-context(:is(.a, .b + .c))", ":host-context(:is(.a))"},
//     {"::cue(:is(.a .b))", "::cue(:is())"},
//     {"::cue(:is(.a + .b))", "::cue(:is())"},
//     {"::cue(:is(.a, .b + .c))", "::cue(:is(.a))"},
//     // Only user-action pseudos + :state() are allowed after kPseudoPart:
//     {"::part(foo):is(.a)", "::part(foo):is()"},
//     {"::part(foo):is(.a:hover)", "::part(foo):is()"},
//     {"::part(foo):is(:hover.a)", "::part(foo):is()"},
//     {"::part(foo):is(:hover + .a)", "::part(foo):is()"},
//     {"::part(foo):is(.a + :hover)", "::part(foo):is()"},
//     {"::part(foo):is(:hover:enabled)", "::part(foo):is()"},
//     {"::part(foo):is(:enabled:hover)", "::part(foo):is()"},
//     {"::part(foo):is(:hover, :where(.a))",
//      "::part(foo):is(:hover, :where())"},
//     {"::part(foo):is(:hover, .a)", "::part(foo):is(:hover)"},
     {"::part(foo):is(:state(bar), .a)", "::part(foo):is(:state(bar))"},
     {"::part(foo):is(:enabled)", "::part(foo):is()"},
     // Only scrollbar pseudos after kPseudoScrollbar:
     {"::-webkit-scrollbar:is(:focus)", "::-webkit-scrollbar:is()"},
     // Only :window-inactive after kPseudoSelection:
     {"::selection:is(:focus)", "::selection:is()"},
     // Only user-action pseudos after webkit pseudos:
     {"::-webkit-input-placeholder:is(:enabled)",
      "::-webkit-input-placeholder:is()"},
     {"::-webkit-input-placeholder:is(:not(:enabled))",
      "::-webkit-input-placeholder:is()"},

     // Valid selectors:
     {":is(.a, .b)"},
     {":is(.a\n)", ":is(.a)"},
     {":is(.a .b, .c)"},
     {":is(.a :is(.b .c), .d)"},
     {":is(.a :where(.b .c), .d)"},
     {":where(.a :is(.b .c), .d)"},
     {":not(:is(.a))"},
     {":not(:is(.a, .b))"},
     {":not(:is(.a + .b, .c .d))"},
     {":not(:where(:not(.a)))"},
     {"::slotted(:is(.a))"},
     {"::slotted(:is(div.a))"},
     {"::slotted(:is(.a, .b))"},
     {":host(:is(.a))"},
     {":host(:is(div.a))"},
     {":host(:is(.a, .b))"},
     {":host(:is(.a\n))", ":host(:is(.a))"},
     {":host-context(:is(.a))"},
     {":host-context(:is(div.a))"},
     {":host-context(:is(.a, .b))"},
     {"::cue(:is(.a))"},
     {"::cue(:is(div.a))"},
     {"::cue(:is(.a, .b))"},
     {"::part(foo):is(:hover)"},
     {"::part(foo):is(:hover:focus)"},
     {"::part(foo):is(:is(:hover))"},
     {"::part(foo):is(:focus, :hover)"},
     {"::part(foo):is(:focus, :is(:hover))"},
     {"::part(foo):is(:focus, :state(bar))"},
     {"::-webkit-scrollbar:is(:enabled)"},
     {"::selection:is(:window-inactive)"},
     {"::-webkit-input-placeholder:is(:hover)"},
     {"::-webkit-input-placeholder:is(:not(:hover))"},
     {"::-webkit-input-placeholder:where(:hover)"},
     {"::-webkit-input-placeholder:is()"},
     {"::-webkit-input-placeholder:is(:where(:hover))"},
    // clang-format on
};

INSTANTIATE_TEST_SUITE_P(NestedSelectorValidity, SelectorParseTest, testing::ValuesIn(is_where_nesting_data));

static const SelectorTestCase is_where_forgiving_data[] = {
    // clang-format off
     {":is():where()"},
     {":is(.a, .b):where(.c)"},
     {":is(.a, :unknown, .b)", ":is(.a, .b)"},
     {":where(.a, :unknown, .b)", ":where(.a, .b)"},
     {":is(.a, :unknown)", ":is(.a)"},
     {":is(:unknown, .a)", ":is(.a)"},
     {":is(:unknown)", ":is()"},
     {":is(:unknown, :where(.a))", ":is(:where(.a))"},
     {":is(:unknown, :where(:unknown))", ":is(:where())"},
     {":is(.a, :is(.b, :unknown), .c)", ":is(.a, :is(.b), .c)"},
     {":host(:is(.a, .b + .c, .d))", ":host(:is(.a, .d))"},
     {":is(,,  ,, )", ":is()"},
     {":is(.a,,,,)", ":is(.a)"},
     {":is(,,.a,,)", ":is(.a)"},
     {":is(,,,,.a)", ":is(.a)"},
     {":is(@x {,.b,}, .a)", ":is(.a)"},
     {":is({,.b,} @x, .a)", ":is(.a)"},
     {":is((@x), .a)", ":is(.a)"},
     {":is((.b), .a)", ":is(.a)"},
    // clang-format on
};

INSTANTIATE_TEST_SUITE_P(IsWhereForgiving, SelectorParseTest, testing::ValuesIn(is_where_forgiving_data));
namespace {

AtomicString TagLocalName(const CSSSelector* selector) {
  return selector->TagQName().LocalName();
}

AtomicString AttributeLocalName(const CSSSelector* selector) {
  return selector->Attribute().LocalName();
}

AtomicString SelectorValue(const CSSSelector* selector) {
  return selector->Value();
}

struct ASCIILowerTestCase {
  const char* input;
  const char16_t* expected;
  using GetterFn = std::optional<std::string>(const CSSSelector*);
  GetterFn* getter;
};

}  // namespace

TEST(CSSSelectorParserTest, ShadowPartPseudoElementValid) {
  const char* test_cases[] = {"::part(ident)", "host::part(ident)", "host::part(ident):hover"};

  std::vector<CSSSelector> arena;
  for (std::string test_case : test_cases) {
    SCOPED_TRACE(test_case);
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kHTMLStandardMode),
                                         CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                         /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
    std::shared_ptr<CSSSelectorList> list = CSSSelectorList::AdoptSelectorVector(vector);
    EXPECT_EQ(test_case, list->SelectorsText());
  }
}

TEST(CSSSelectorParserTest, ShadowPartAndBeforeAfterPseudoElementValid) {
  const char* test_cases[] = {"::part(ident)::before",     "::part(ident)::after",        "::part(ident)::placeholder",
                              "::part(ident)::first-line", "::part(ident)::first-letter", "::part(ident)::selection"};

  std::vector<CSSSelector> arena;
  for (std::string test_case : test_cases) {
    SCOPED_TRACE(test_case);
    CSSTokenizer tokenizer(test_case);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, std::make_shared<CSSParserContext>(kHTMLStandardMode),
                                         CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr,
                                         /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
    EXPECT_GT(vector.size(), 0u);
    std::shared_ptr<CSSSelectorList> list = CSSSelectorList::AdoptSelectorVector(vector);
    EXPECT_TRUE(list->IsValid());
    EXPECT_EQ(test_case, list->SelectorsText());
  }
}

TEST(CSSSelectorParserTest, ImplicitShadowCrossingCombinators) {
  struct ShadowCombinatorTest {
    const char* input;
    std::vector<std::pair<AtomicString, CSSSelector::RelationType>> expectation;
  };

  const ShadowCombinatorTest test_cases[] = {
      {
          "*::placeholder",
          {
              {AtomicString("placeholder"), CSSSelector::kUAShadow},
              {g_null_atom, CSSSelector::kSubSelector},
          },
      },
      {
          "div::slotted(*)",
          {
              {AtomicString("slotted"), CSSSelector::kShadowSlot},
              {AtomicString("div"), CSSSelector::kSubSelector},
          },
      },
      {
          "::slotted(*)::placeholder",
          {
              {AtomicString("placeholder"), CSSSelector::kUAShadow},
              {AtomicString("slotted"), CSSSelector::kShadowSlot},
              {g_null_atom, CSSSelector::kSubSelector},
          },
      },
      {
          "span::part(my-part)",
          {
              {AtomicString("part"), CSSSelector::kShadowPart},
              {AtomicString("span"), CSSSelector::kSubSelector},
          },
      },
      {
          "video::-webkit-media-controls",
          {
              {AtomicString("-webkit-media-controls"), CSSSelector::kUAShadow},
              {AtomicString("video"), CSSSelector::kSubSelector},
          },
      },
  };

  auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  auto sheet = std::make_shared<StyleSheetContents>(context);

  std::vector<CSSSelector> arena;
  for (auto test_case : test_cases) {
    SCOPED_TRACE(test_case.input);
    CSSTokenizer tokenizer(test_case.input);
    CSSParserTokenStream stream(tokenizer);
    tcb::span<CSSSelector> vector =
        CSSSelectorParser::ParseSelector(stream, context, CSSNestingType::kNone,
                                         /*parent_rule_for_nesting=*/nullptr, /*is_within_scope=*/false,
                                         /*semicolon_aborts_nested_selector=*/false, sheet, arena);
    std::shared_ptr<CSSSelectorList> list = CSSSelectorList::AdoptSelectorVector(vector);
    EXPECT_TRUE(list->IsValid());
    const CSSSelector* selector = list->First();
    for (auto sub_expectation : test_case.expectation) {
      ASSERT_TRUE(selector);
      AtomicString selector_value =
          selector->Match() == CSSSelector::kTag ? selector->TagQName().LocalName() : selector->Value();
      EXPECT_EQ(sub_expectation.first, selector_value);
      EXPECT_EQ(sub_expectation.second, selector->Relation());
      selector = selector->NextSimpleSelector();
    }
    EXPECT_FALSE(selector);
  }
}

static const SelectorTestCase invalid_pseudo_has_arguments_data[] = {
    // clang-format off
     // restrict use of nested :has()
     {":has(:has(.a))", ""},
     {":has(.a, :has(.b), .c)", ""},
     {":has(.a, :has(.b))", ""},
     {":has(:has(.a), .b)", ""},
     {":has(:is(:has(.a)))", ":has(:is())"},

     // restrict use of pseudo element inside :has()
     {":has(::-webkit-progress-bar)", ""},
     {":has(::-webkit-progress-value)", ""},
     {":has(::-webkit-slider-runnable-track)", ""},
     {":has(::-webkit-slider-thumb)", ""},
     {":has(::after)", ""},
     {":has(::backdrop)", ""},
     {":has(::before)", ""},
     {":has(::cue)", ""},
     {":has(::first-letter)", ""},
     {":has(::first-line)", ""},
     {":has(::grammar-error)", ""},
     {":has(::marker)", ""},
     {":has(::placeholder)", ""},
     {":has(::selection)", ""},
     {":has(::slotted(*))", ""},
     {":has(::part(foo))", ""},
     {":has(::spelling-error)", ""},
     {":has(:after)", ""},
     {":has(:before)", ""},
     {":has(:cue)", ""},
     {":has(:first-letter)", ""},
     {":has(:first-line)", ""},

     // drops empty :has()
     {":has()", ""},
     {":has(,,  ,, )", ""},

     // drops :has() when it contains invalid argument
     {":has(.a,,,,)", ""},
     {":has(,,.a,,)", ""},
     {":has(,,,,.a)", ""},
     {":has(@x {,.b,}, .a)", ""},
     {":has({,.b,} @x, .a)", ""},
     {":has((@x), .a)", ""},
     {":has((.b), .a)", ""},

    // clang-format on
};

INSTANTIATE_TEST_SUITE_P(InvalidPseudoHasArguments,
                         SelectorParseTest,
                         testing::ValuesIn(invalid_pseudo_has_arguments_data));

static const SelectorTestCase has_nesting_data[] = {
    // clang-format off
     // :has() is not allowed in the pseudos accepting only compound selectors:
     {"::slotted(:has(.a))", ""},
     {":host(:has(.a))", ""},
     {":host-context(:has(.a))", ""},
     {"::cue(:has(.a))", ""},
     // :has() is not allowed after pseudo elements:
     {"::part(foo):has(:hover)", ""},
     {"::part(foo):has(:hover:focus)", ""},
     {"::part(foo):has(:focus, :hover)", ""},
     {"::part(foo):has(:focus)", ""},
     {"::part(foo):has(:focus, :state(bar))", ""},
     {"::part(foo):has(.a)", ""},
     {"::part(foo):has(.a:hover)", ""},
     {"::part(foo):has(:hover.a)", ""},
     {"::part(foo):has(:hover + .a)", ""},
     {"::part(foo):has(.a + :hover)", ""},
     {"::part(foo):has(:hover:enabled)", ""},
     {"::part(foo):has(:enabled:hover)", ""},
     {"::part(foo):has(:hover, :where(.a))", ""},
     {"::part(foo):has(:hover, .a)", ""},
     {"::part(foo):has(:state(bar), .a)", ""},
     {"::part(foo):has(:enabled)", ""},
     {"::-webkit-scrollbar:has(:enabled)", ""},
     {"::selection:has(:window-inactive)", ""},
     {"::-webkit-input-placeholder:has(:hover)", ""},
    // clang-format on
};

INSTANTIATE_TEST_SUITE_P(NestedHasSelectorValidity, SelectorParseTest, testing::ValuesIn(has_nesting_data));

static std::shared_ptr<CSSSelectorList> ParseNested(Document* document,
                                                    std::string inner_rule,
                                                    CSSNestingType nesting_type) {
  std::shared_ptr<StyleRuleBase> rule = css_test_helpers::ParseRule(*document, "div {}");
  auto parent_rule_for_nesting =
      nesting_type == CSSNestingType::kNone ? nullptr : std::reinterpret_pointer_cast<const StyleRule>(rule);
  bool is_within_scope = nesting_type == CSSNestingType::kScope;
  std::shared_ptr<CSSSelectorList> list =
      css_test_helpers::ParseSelectorList(inner_rule, nesting_type, parent_rule_for_nesting, is_within_scope);
  if (!list || !list->First()) {
    return nullptr;
  }
  return list;
}

static std::optional<CSSSelector::PseudoType> GetImplicitlyAddedPseudo(Document* document,
                                                                       std::string inner_rule,
                                                                       CSSNestingType nesting_type) {
  std::shared_ptr<CSSSelectorList> list = ParseNested(document, inner_rule, nesting_type);
  if (!list) {
    return std::nullopt;
  }

  std::vector<const CSSSelector*> selectors;
  for (const CSSSelector* selector = list->First(); selector; selector = selector->NextSimpleSelector()) {
    selectors.push_back(selector);
  }
  // The back of `selectors` now contains the leftmost simple CSSSelector.

  // Ignore leading :true.
  if (!selectors.empty() && selectors.back()->GetPseudoType() == CSSSelector::kPseudoTrue) {
    selectors.pop_back();
  }

  const CSSSelector* back = !selectors.empty() ? selectors.back() : nullptr;
  if (!back || back->Match() != CSSSelector::kPseudoClass || !back->IsImplicit()) {
    return std::nullopt;
  }
  return back->GetPseudoType();
}

TEST(CSSSelectorParserTest, NestingTypeImpliedDescendant) {
  auto test = TEST_init();
  auto* document = test->page()->executingContext()->document();
  // Nesting selector (&)
  EXPECT_EQ(CSSSelector::kPseudoParent, GetImplicitlyAddedPseudo(document, ".foo", CSSNestingType::kNesting));
  EXPECT_EQ(CSSSelector::kPseudoParent, GetImplicitlyAddedPseudo(document, ".foo:is(.bar)", CSSNestingType::kNesting));
  EXPECT_EQ(CSSSelector::kPseudoParent, GetImplicitlyAddedPseudo(document, "> .foo", CSSNestingType::kNesting));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > &", CSSNestingType::kNesting));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :is(.b, &)", CSSNestingType::kNesting));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, "& .foo", CSSNestingType::kNesting));

  // :scope
  EXPECT_EQ(CSSSelector::kPseudoScope, GetImplicitlyAddedPseudo(document, ".foo", CSSNestingType::kScope));
  EXPECT_EQ(CSSSelector::kPseudoScope, GetImplicitlyAddedPseudo(document, ".foo:is(.bar)", CSSNestingType::kScope));
  EXPECT_EQ(CSSSelector::kPseudoScope, GetImplicitlyAddedPseudo(document, "> .foo", CSSNestingType::kScope));
  // :scope makes a selector :scope-containing:
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :scope", CSSNestingType::kScope));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :is(.b, :scope)", CSSNestingType::kScope));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ":scope .foo", CSSNestingType::kScope));
  // '&' also makes a selector :scope-containing:
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > &", CSSNestingType::kScope));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :is(.b, &)", CSSNestingType::kScope));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :is(.b, !&)", CSSNestingType::kScope));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :is(.b, :scope)", CSSNestingType::kScope));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :is(.b, :SCOPE)", CSSNestingType::kScope));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :is(.b, !:scope)", CSSNestingType::kScope));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, "& .foo", CSSNestingType::kScope));

  // kNone
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo", CSSNestingType::kNone));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo:is(.bar)", CSSNestingType::kNone));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, "> .foo", CSSNestingType::kNone));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > &", CSSNestingType::kNone));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :is(.b, &)", CSSNestingType::kNone));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, "& .foo", CSSNestingType::kNone));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :scope", CSSNestingType::kNone));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ".foo > :is(.b, :scope)", CSSNestingType::kNone));
  EXPECT_EQ(std::nullopt, GetImplicitlyAddedPseudo(document, ":scope .foo", CSSNestingType::kNone));
}

static const CSSSelector* NthSimpleSelector(const CSSSelector& selector, size_t index) {
  size_t i = 0;
  for (const CSSSelector* s = &selector; s; s = s->NextSimpleSelector()) {
    if (i == index) {
      return s;
    }
    ++i;
  }
  return nullptr;
}

struct ScopeActivationData {
  // The selector text, e.g. ".a .b > .c".
  const char* inner_rule;
  // The simple CSSSelector to "focus" the test on, specified by the Nth
  // CSSSelector in the list of simple selectors.
  size_t index;
};

// Each test verifies that the simple selector at the specified selector
// index is ':true' and that it has relation=kPseudoActivation.
ScopeActivationData scope_activation_data[] = {
    // Comments indicate the expected order of simple selectors
    // in the list of simple selectors.

    // [:true, :scope]
    {":scope", 0},

    // [:true, :scope, :true, :scope]
    {":scope :scope", 0},
    {":scope :scope", 2},

    // [.bar, .foo, :true, :scope]
    {".foo > .bar", 2},

    // [.bar, .foo, :true, :scope]
    {"> .foo > .bar", 2},

    // [:true, :scope, .foo]
    {".foo > :scope", 0},

    // [.bar, :true, :scope, .foo]
    {".foo > :scope > .bar", 1},

    // [.bar, :true, :scope, .foo]
    {".foo :scope .bar", 1},

    // [.bar, :true, .a, .b, .c, :scope, .foo]
    {".foo > .a.b.c:scope > .bar", 1},

    // [.bar, :true, .a, :where(...), .foo]
    {".foo > .a:where(.b, :scope) > .bar", 1},

    // [:true, :scope, :true, :scope, .foo]
    {".foo > :scope > :scope", 0},
    {".foo > :scope > :scope", 2},

    // [:true, &, :true, :scope]
    {".a :scope > &", 0},
    {".a :scope > &", 2},

    // [:true, &]
    {"&", 0},

    // [:true, &, :true, &, :true, &]
    {"& & &", 0},
    {"& & &", 2},
    {"& & &", 4},
};
class ScopeActivationTest : public ::testing::TestWithParam<ScopeActivationData> {};

INSTANTIATE_TEST_SUITE_P(CSSSelectorParserTest, ScopeActivationTest, testing::ValuesIn(scope_activation_data));

TEST_P(ScopeActivationTest, All) {
  ScopeActivationData param = GetParam();
  SCOPED_TRACE(param.inner_rule);

  auto env = TEST_init();
  auto* document = env->page()->executingContext()->document();

  std::shared_ptr<CSSSelectorList> list = ParseNested(document, param.inner_rule, CSSNestingType::kScope);
  ASSERT_TRUE(list);
  ASSERT_TRUE(list->First());
  const CSSSelector* selector = NthSimpleSelector(*list->First(), param.index);
  ASSERT_TRUE(selector);
  SCOPED_TRACE(selector->SimpleSelectorTextForDebug());
  EXPECT_EQ(CSSSelector::kPseudoTrue, selector->GetPseudoType());
  EXPECT_EQ(CSSSelector::kScopeActivation, selector->Relation());
}

// Returns the number of simple selectors that match `predicate`, including
// selectors within nested selector lists (e.g. :is()).
template <typename PredicateFunc>
static size_t CountSimpleSelectors(const CSSSelectorList& list, PredicateFunc predicate) {
  size_t count = 0;
  for (const CSSSelector* selector = list.First(); selector; selector = CSSSelectorList::Next(*selector)) {
    for (const CSSSelector* s = selector; s; s = s->NextSimpleSelector()) {
      if (s->SelectorList()) {
        count += CountSimpleSelectors(*s->SelectorList(), predicate);
      }
      if (predicate(*s)) {
        ++count;
      }
    }
  }
  return count;
}

template <typename PredicateFunc>
static std::optional<size_t> CountSimpleSelectors(Document* document,
                                                  std::string selector_text,
                                                  CSSNestingType nesting_type,
                                                  PredicateFunc predicate) {
  std::shared_ptr<CSSSelectorList> list = ParseNested(document, selector_text, nesting_type);
  if (!list || !list->First()) {
    return std::nullopt;
  }
  return CountSimpleSelectors<PredicateFunc>(*list, predicate);
}

static std::optional<size_t> CountPseudoTrue(Document* document,
                                             std::string selector_text,
                                             CSSNestingType nesting_type) {
  return CountSimpleSelectors(document, selector_text, nesting_type, [](const CSSSelector& selector) {
    return selector.GetPseudoType() == CSSSelector::kPseudoTrue;
  });
}

static std::optional<size_t> CountScopeActivations(Document* document,
                                                   std::string selector_text,
                                                   CSSNestingType nesting_type) {
  return CountSimpleSelectors(document, selector_text, nesting_type, [](const CSSSelector& selector) {
    return selector.Relation() == CSSSelector::kScopeActivation;
  });
}

static std::optional<size_t> CountPseudoTrueWithScopeActivation(Document* document,
                                                                std::string selector_text,
                                                                CSSNestingType nesting_type) {
  return CountSimpleSelectors(document, selector_text, nesting_type, [](const CSSSelector& selector) {
    return selector.GetPseudoType() == CSSSelector::kPseudoTrue && selector.Relation() == CSSSelector::kScopeActivation;
  });
}

TEST(CSSSelectorParserTest, CountMatchesSelfTest) {
  auto env = TEST_init();
  auto* document = env->page()->executingContext()->document();
  auto is_focus = [](const CSSSelector& selector) { return selector.GetPseudoType() == CSSSelector::kPseudoFocus; };
  auto is_hover = [](const CSSSelector& selector) { return selector.GetPseudoType() == CSSSelector::kPseudoHover; };
  EXPECT_EQ(2u, CountSimpleSelectors(document, ":focus > .a > :focus", CSSNestingType::kNone, is_focus));
  EXPECT_EQ(3u, CountSimpleSelectors(document, ":focus > .a > :focus, .b, :focus", CSSNestingType::kNone, is_focus));
  EXPECT_EQ(0u, CountSimpleSelectors(document, ".a > .b", CSSNestingType::kNone, is_focus));
  EXPECT_EQ(
      4u, CountSimpleSelectors(document, ":hover > :is(:hover, .a, :hover) > :hover", CSSNestingType::kNone, is_hover));
}

struct ScopeActivationCountData {
  // The selector text, e.g. ".a .b > .c".
  const char* selector_text;
  // The expected number of :true pseudo-classes with relation=kScopeActivation
  // if the selector is parsed with CSSNestingType::kScope.
  size_t pseudo_count;
};

ScopeActivationCountData scope_activation_count_data[] = {
    // Implicit :scope with descendant combinator:
    {".a", 1},
    {".a .b", 1},
    {".a .b > .c", 1},

    // Implicit :scope for relative selectors:
    {"> .a", 1},
    {"> .a .b", 1},
    {"> .a .b > .c", 1},

    // Explicit :scope top-level:
    {":scope", 1},
    {".a :scope", 1},
    {".a > :scope > .b", 1},
    {":scope > :scope", 2},
    {":scope > .a > :scope", 2},

    // :scope in inner selector lists:
    {".a > :is(.b, :scope, .c) .d", 1},
    {".a > :not(.b, :scope, .c) .d", 1},
    {".a > :is(.b, :scope, .c):scope .d", 1},
    {".a > :is(.b, :scope, .c):scope .d:scope", 2},
    {".a > :is(.b, :scope, :scope, .c):scope .d:scope", 2},
    {".a > :has(> :scope):scope > .b", 1},

    // As the previous section, but using '&' instead of :scope.
    {".a > :is(.b, &, .c) .d", 1},
    {".a > :not(.b, &, .c) .d", 1},
    {".a > :is(.b, &, .c)& .d", 1},
    {".a > :is(.b, &, .c)& .d&", 2},
    {".a > :is(.b, &, &, .c)& .d&", 2},
    {".a > :has(> &)& > .b", 1},
};

class ScopeActivationCountTest : public ::testing::TestWithParam<ScopeActivationCountData> {
 private:
};

INSTANTIATE_TEST_SUITE_P(CSSSelectorParserTest,
                         ScopeActivationCountTest,
                         testing::ValuesIn(scope_activation_count_data));

TEST_P(ScopeActivationCountTest, Scope) {
  ScopeActivationCountData param = GetParam();
  SCOPED_TRACE(param.selector_text);

  auto env = TEST_init();
  auto* document = env->page()->executingContext()->document();

  // We expect :true and kScopeActivation to only occur ever occur together.
  EXPECT_EQ(param.pseudo_count, CountPseudoTrue(document, param.selector_text, CSSNestingType::kScope));
  EXPECT_EQ(param.pseudo_count, CountScopeActivations(document, param.selector_text, CSSNestingType::kScope));
  EXPECT_EQ(param.pseudo_count,
            CountPseudoTrueWithScopeActivation(document, param.selector_text, CSSNestingType::kScope));
}

TEST_P(ScopeActivationCountTest, Nesting) {
  ScopeActivationCountData param = GetParam();
  SCOPED_TRACE(param.selector_text);

  auto env = TEST_init();
  auto* document = env->page()->executingContext()->document();

  // We do not expect any inserted :true/kScopeActivation for kNesting.
  EXPECT_EQ(0u, CountPseudoTrue(document, param.selector_text, CSSNestingType::kNesting));
  EXPECT_EQ(0u, CountScopeActivations(document, param.selector_text, CSSNestingType::kNesting));
  EXPECT_EQ(0u, CountPseudoTrueWithScopeActivation(document, param.selector_text, CSSNestingType::kNesting));
}

TEST_P(ScopeActivationCountTest, None) {
  ScopeActivationCountData param = GetParam();
  SCOPED_TRACE(param.selector_text);

  auto env = TEST_init();
  auto* document = env->page()->executingContext()->document();

  // We do not expect any inserted :true/kScopeActivation for kNone. Note that
  // relative selectors do not parse for kNone.
  EXPECT_EQ(0u, CountPseudoTrue(document, param.selector_text, CSSNestingType::kNone).value_or(0));
  EXPECT_EQ(0u, CountScopeActivations(document, param.selector_text, CSSNestingType::kNone).value_or(0));
  EXPECT_EQ(0u, CountPseudoTrueWithScopeActivation(document, param.selector_text, CSSNestingType::kNone).value_or(0));
}

}  // namespace webf