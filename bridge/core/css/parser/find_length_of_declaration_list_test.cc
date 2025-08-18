// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "find_length_of_declaration_list-inl.h"
#include "foundation/string/string_view.h"
#include "gtest/gtest.h"

namespace webf {

#if defined(__ARM_NEON__)

static bool BlockAccepted(const String& str) {
  // Close the block, then add various junk afterwards to make sure
  // that it doesn't affect the parsing. (We also need a fair bit of
  // padding since the SIMD code needs there to be room after the end
  // of the block.)
  String test_str = str + R"(}abcdefghi jkl!{}\"\#/*[]                 )";
  return FindLengthOfDeclarationList(test_str.ToStringView()) == str.length();
}

TEST(FindLengthOfDeclarationListTest, Basic) {
  EXPECT_TRUE(BlockAccepted("color: red;"_s));
}

TEST(FindLengthOfDeclarationListTest, Variable) {
  EXPECT_TRUE(BlockAccepted("color: var(--color);"_s));
  EXPECT_TRUE(BlockAccepted("color: var(--variable-name-that-spans-blocks);"_s));
}

TEST(FindLengthOfDeclarationListTest, UnbalancedVariable) {
  // The closing brace here should be ignored as an unbalanced block-end
  // token, so we should hit the junk afterwards and stop with an error.
  EXPECT_FALSE(BlockAccepted("color: var("_s));

  // An underflow; we could ignore them, but it's easier to throw an error.
  EXPECT_FALSE(BlockAccepted("color: var()) red green blue"_s));

  // There are 200 of these; they will cause an overflow. That is just a
  // limitation, but we need to at least detect it.
  EXPECT_FALSE(
      BlockAccepted("color: var"
                    "(((((((((((((((((((((((((((((((((((((((((((((((((("
                    "(((((((((((((((((((((((((((((((((((((((((((((((((("
                    "(((((((((((((((((((((((((((((((((((((((((((((((((("
                    "(((((((((((((((((((((((((((((((((((((((((((((((((("
                    "))))))))))))))))))))))))))))))))))))))))))))))))))"
                    "))))))))))))))))))))))))))))))))))))))))))))))))))"
                    "))))))))))))))))))))))))))))))))))))))))))))))))))"
                    "))))))))))))))))))))))))))))))))))))))))))))))))))"_s));

  // If we did not have overflow detection, this (256 left-parens)
  // would seem acceptable.
  EXPECT_FALSE(
      BlockAccepted("color: var"
                    "(((((((((((((((((((((((((((((((((((((((((((((((((("
                    "(((((((((((((((((((((((((((((((((((((((((((((((((("
                    "(((((((((((((((((((((((((((((((((((((((((((((((((("
                    "(((((((((((((((((((((((((((((((((((((((((((((((((("
                    "(((((((((((((((((((((((((((((((((((((((((((((((((("
                    "(((((("_s));

  // Parens after the end must not be counted.
  EXPECT_EQ(0u, FindLengthOfDeclarationList("a:(()})paddingpaddingpadding"_sv));
}

TEST(FindLengthOfDeclarationListTest, NoSubBlocksAccepted) {
  // Some of these are by design, some of these are just because of
  // limitations in the algorithm.
  EXPECT_FALSE(BlockAccepted(".a { --nested-rule: nope; }"_s));
  EXPECT_FALSE(BlockAccepted("--foo: []"_s));
  EXPECT_FALSE(BlockAccepted("--foo: {}"_s));
}

TEST(FindLengthOfDeclarationListTest, NoCommentsAccepted) {
  // This is also just a limitation in the algorithm.
  // The second example demonstrates the peril.
  EXPECT_FALSE(BlockAccepted("color: black /* any color */"_s));
  EXPECT_FALSE(BlockAccepted("color: black /* } */"_s));

  // However, / and * on themselves are useful and should
  // not stop the block from being accepted.
  EXPECT_TRUE(BlockAccepted("z-index: calc(2 * 3 / 4)"_s));
}

TEST(FindLengthOfDeclarationListTest, String) {
  EXPECT_TRUE(BlockAccepted("--foo: \"some string\""_s));
  EXPECT_TRUE(BlockAccepted("--foo: \"(\""_s));
  EXPECT_TRUE(BlockAccepted("--foo: \"}\""_s));
  EXPECT_TRUE(BlockAccepted("--foo: \"[]\""_s));
  EXPECT_TRUE(BlockAccepted("--foo: \"/* comment */\""_s));

  EXPECT_TRUE(BlockAccepted("--foo: 'some string'"_s));
  EXPECT_TRUE(BlockAccepted("--foo: '('"_s));
  EXPECT_TRUE(BlockAccepted("--foo: '}'"_s));
  EXPECT_TRUE(BlockAccepted("--foo: '[]'"_s));
  EXPECT_TRUE(BlockAccepted("--foo: '/* comment */'"_s));

  EXPECT_TRUE(BlockAccepted("--foo: \"this is fine\" 'it really is'"_s));
  EXPECT_FALSE(BlockAccepted("--foo: \"don't\" } \"accept'this!\""_s));

  // We don't support escapes (this is just a limitation).
  EXPECT_FALSE(BlockAccepted("--foo: \"\\n\""_s));
  EXPECT_FALSE(BlockAccepted("--foo: \"\\\""_s));

  // We don't support nested quotes (this is also just a limitation).
  EXPECT_FALSE(BlockAccepted("--foo: \"it's OK\""_s));
  EXPECT_FALSE(BlockAccepted("--foo: '1\" = 2.54cm'"_s));
}

TEST(FindLengthOfDeclarationListTest, IgnoringDangerousAfterBlock) {
  EXPECT_EQ(0u, FindLengthOfDeclarationList("a:b[selector containing difficult stuff]}paddingpaddingpadding"_sv));
  EXPECT_EQ(3u, FindLengthOfDeclarationList("a:b}[selector containing difficult stuff]paddingpaddingpadding"_sv));
}

TEST(FindLengthOfDeclarationListTest, NonASCII) {
  // Non-ASCII long after the block should not matter.
  EXPECT_EQ(10u, FindLengthOfDeclarationList("--foo: bar}                   ❤️"_sv));

  // We should also support these characters inside the block itself.
  EXPECT_TRUE(BlockAccepted("--foo: \"❤️\""_s));
  EXPECT_TRUE(BlockAccepted("font-family: 😊"_s));

  // Also make sure we don't simply _ignore_ the top UTF-16 byte;
  // these two characters become 01 7B and 7B 01 depending on
  // endianness, and should _not_ match as { (which is 0x7B).
  EXPECT_TRUE(BlockAccepted("--fooŻ笁: value"_s));
}

#endif  // SIMD

}  // namespace webf