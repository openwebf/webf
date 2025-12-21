/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "string_impl.h"
#include <cstring>
#include <iterator>
#include "atomic_string.h"
#include "gtest/gtest.h"

namespace webf {
namespace {

TEST(StringImplTest, NullTermination8Bit) {
  // Test that 8-bit strings are null-terminated
  const char* test_str = "Hello, World!";
  size_t len = strlen(test_str);
  auto string_impl = StringImpl::CreateFromUTF8(test_str, len);
  
  ASSERT_TRUE(string_impl->Is8Bit());
  const LChar* chars = string_impl->Characters8();
  
  // Verify length matches expected
  EXPECT_EQ(string_impl->length(), len);
  EXPECT_EQ(*string_impl, test_str);
  
  // Verify null terminator exists at the expected position
  EXPECT_EQ(chars[len], '\0');
}

TEST(StringImplTest, NullTermination16Bit) {
  // Test that 16-bit strings are null-terminated
  const char16_t test_str[] = u"Hello, 世界!";
  size_t len = 10; // Length without null terminator
  auto string_impl = StringImpl::Create(test_str, len);
  
  ASSERT_FALSE(string_impl->Is8Bit());
  const char16_t* chars = string_impl->Characters16();
  
  // Verify null terminator exists
  EXPECT_EQ(chars[len], u'\0');
  
  // Verify content matches
  for (size_t i = 0; i < len; i++) {
    EXPECT_EQ(chars[i], test_str[i]);
  }
}

TEST(StringImplTest, NullTerminationUTF8) {
  // Test UTF-8 string creation with null termination
  const char* utf8_str = "Hello, 世界!";
  size_t byte_len = strlen(utf8_str);
  auto string_impl = StringImpl::CreateFromUTF8(utf8_str, byte_len);
  
  // This should create a 16-bit string due to non-ASCII characters
  ASSERT_FALSE(string_impl->Is8Bit());
  const char16_t* chars = string_impl->Characters16();
  size_t char_len = string_impl->length();
  
  // Verify null terminator
  EXPECT_EQ(chars[char_len], u'\0');
}

TEST(StringImplTest, NullTerminationASCIIFromUTF8) {
  // Test UTF-8 string with only ASCII characters
  const char* ascii_str = "ASCII only string";
  size_t len = strlen(ascii_str);
  auto string_impl = StringImpl::CreateFromUTF8(ascii_str, len);
  
  // Should create an 8-bit string
  ASSERT_TRUE(string_impl->Is8Bit());
  const LChar* chars = string_impl->Characters8();
  
  // Verify length and content
  EXPECT_EQ(string_impl->length(), len);
  EXPECT_EQ(*string_impl, ascii_str);
  EXPECT_EQ(chars[len], '\0');
}

TEST(StringImplTest, NullTerminationSubstring) {
  // Test that substring also has null termination
  const char* original = "Hello, World!";
  auto string_impl = StringImpl::CreateFromUTF8(original, strlen(original));
  
  // Create substring "World"
  auto substr = StringImpl::Substring(string_impl, 7, 5);
  
  ASSERT_TRUE(substr->Is8Bit());
  const LChar* chars = substr->Characters8();
  
  // Verify substring content
  EXPECT_EQ(substr->length(), 5u);
  EXPECT_EQ(*substr, "World");
  EXPECT_EQ(chars[5], '\0');
}

TEST(StringImplTest, NullTerminationRemoveCharacters) {
  // Test that RemoveCharacters result is null-terminated
  const char* original = "Hello, World!";
  auto string_impl = StringImpl::CreateFromUTF8(original, strlen(original));
  
  // Remove spaces
  auto result = StringImpl::RemoveCharacters(string_impl, [](char16_t c) {
    return c == ' ';
  });
  
  ASSERT_TRUE(result->Is8Bit());
  const LChar* chars = result->Characters8();
  
  // Verify result after removing spaces
  size_t result_len = result->length();
  EXPECT_EQ(*result, "Hello,World!");
  EXPECT_EQ(chars[result_len], '\0');
}

TEST(StringImplTest, NullTerminationEmptyString) {
  // Test empty string creation
  auto empty = StringImpl::CreateFromUTF8("", 0);
  
  // Empty strings should return the static empty instance
  EXPECT_EQ(empty.get(), StringImpl::empty_);
  EXPECT_EQ(empty->length(), 0u);
}

TEST(StringImplTest, NullTerminationAtomicString) {
  // Test that AtomicString also benefits from null termination
  AtomicString atomic_str = "test-string"_as;
  
  ASSERT_TRUE(atomic_str.Is8Bit());
  const LChar* chars = atomic_str.Characters8();
  
  // Verify atomic string content
  EXPECT_EQ(atomic_str.length(), 11u);
  EXPECT_EQ(atomic_str, "test-string");
}

TEST(StringImplTest, NullTerminationWithDataPrefix) {
  // Test the specific case that was failing in dom_string_map.cc
  AtomicString name = "data-test-attribute"_as;
  
  ASSERT_TRUE(name.Is8Bit());
  const LChar* chars = name.Characters8();
  
  // This should work without buffer overflow
  bool starts_with_data = name.StartsWith(StringView("data-"));
  EXPECT_TRUE(starts_with_data);
  
  // Verify length and content
  EXPECT_EQ(name.length(), 19u);
  EXPECT_EQ(name, "data-test-attribute");
}

TEST(StringImplTest, ToUTF8StringFromUTF16) {
  // Vietnamese text with tone marks exercises BMP non-Latin characters.
  const char16_t text[] = u"Bảo hiểm";
  constexpr size_t len = std::size(text) - 1;  // exclude null terminator

  String str(text, len);
  auto utf8 = str.ToUTF8String();

  EXPECT_EQ(utf8, "Bảo hiểm");
}

}  // namespace
}  // namespace webf
