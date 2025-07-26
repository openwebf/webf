/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <quickjs/quickjs.h>
#include <codecvt>
#include "event_type_names.h"
#include "gtest/gtest.h"
#include "native_string_utils.h"
#include "webf_test_env.h"

using namespace webf;

using TestCallback = void (*)(JSContext* ctx);

TEST(AtomicString, Empty) {
  TEST_init();
  AtomicString atomic_string = AtomicString::Empty();
  EXPECT_EQ(*atomic_string.Impl(), "");
}

TEST(AtomicString, HashShouldNotEqual8bitAnd16bit) {
  TEST_init();
  AtomicString atomic_string = AtomicString("helloworld");
  AtomicString atomic_string2 = AtomicString(u"helloworld");
  EXPECT_NE(atomic_string.Hash(), atomic_string2.Hash());
}

TEST(AtomicString, FromNativeString) {
  TEST_init();
  auto nativeString = stringToNativeString("helloworld");
  std::unique_ptr<AutoFreeNativeString> str =
      std::unique_ptr<AutoFreeNativeString>(static_cast<AutoFreeNativeString*>(nativeString.release()));
  AtomicString value = AtomicString(str);
  EXPECT_EQ(std::u16string(value.Impl()->Characters16(), value.Impl()->length()), std::u16string(u"helloworld"));
}

TEST(AtomicString, CreateFromStdString) {
  TEST_init();
  AtomicString value = AtomicString("helloworld");
  EXPECT_EQ(std::string(value.Impl()->Characters8(), value.Impl()->length()), "helloworld");
}

TEST(AtomicString, CreateFromJSValue) {
  auto env = TEST_init();
  JSContext* ctx = env->page()->executingContext()->ctx();
  JSValue string = JS_NewString(ctx, "helloworld");
  std::shared_ptr<StringImpl> value =
      env->page()->dartIsolateContext()->stringCache()->GetStringFromJSAtom(ctx, JS_ValueToAtom(ctx, string));
  EXPECT_EQ(std::string(value->Characters8(), value->length()), "helloworld");
  JS_FreeValue(ctx, string);
}

TEST(AtomicString, ToQuickJS) {
  auto env = TEST_init();
  AtomicString value = AtomicString("helloworld");
  JSContext* ctx = env->page()->executingContext()->ctx();
  JSValue qjs_value = env->page()->dartIsolateContext()->stringCache()->GetJSValueFromString(ctx, value.Impl());
  const char* buffer = JS_ToCString(ctx, qjs_value);
  EXPECT_STREQ(buffer, "helloworld");
  JS_FreeValue(ctx, qjs_value);
  JS_FreeCString(ctx, buffer);
}

TEST(AtomicString, ToNativeString) {
  TEST_init();
  AtomicString&& value = AtomicString("helloworld");
  auto native_string = value.ToNativeString();
  const uint16_t* p = native_string->string();
  EXPECT_EQ(native_string->length(), 10);

  uint16_t result[10] = {'h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd'};
  for (int i = 0; i < native_string->length(); i++) {
    EXPECT_EQ(result[i], p[i]);
  }
}

TEST(AtomicString, CopyAssignment) {
  TEST_init();
  AtomicString str = AtomicString("helloworld");
  struct P {
    AtomicString str;
  };
  P p{AtomicString::Empty()};
  p.str = str;
  EXPECT_EQ(p.str == str, true);
}

TEST(AtomicString, MoveAssignment) {
  TEST_init();
  auto str = AtomicString("helloworld");
  auto str2 = AtomicString(std::move(str));
  EXPECT_EQ(str2.ToStdString(), "helloworld");
}

TEST(AtomicString, CopyToRightReference) {
  TEST_init();
  AtomicString str = AtomicString::Empty();
  if (1 + 1 == 2) {
    str = AtomicString("helloworld");
  }
  EXPECT_EQ(str.ToStdString(), "helloworld");
}

TEST(AtomicString, UTF16StringCreation) {
  TEST_init();
  // Test creating AtomicString from UTF-16 literal
  AtomicString utf16_str = AtomicString(u"Hello UTF-16 世界");
  EXPECT_FALSE(utf16_str.Is8Bit());
  EXPECT_EQ(utf16_str.length(), 15);
  
  // Verify Characters16() returns correct data
  const char16_t* chars = utf16_str.Characters16();
  EXPECT_EQ(chars[0], u'H');
  EXPECT_EQ(chars[6], u'U');
  EXPECT_EQ(chars[13], u'世');
  EXPECT_EQ(chars[14], u'界');
}

TEST(AtomicString, UTF16ToStdString) {
  TEST_init();
  // Test UTF-16 to UTF-8 conversion
  AtomicString utf16_str = AtomicString(u"Hello 世界 🌍");
  std::string utf8_str = utf16_str.ToStdString();
  
  // The UTF-8 representation should match
  EXPECT_EQ(utf8_str, "Hello 世界 🌍");
}

TEST(AtomicString, UTF16ToQuickJS) {
  auto env = TEST_init();
  JSContext* ctx = env->page()->executingContext()->ctx();
  
  // Create UTF-16 string with various Unicode characters
  AtomicString utf16_str = AtomicString(u"JavaScript 世界 🚀");
  
  // Convert to QuickJS value
  JSValue qjs_value = utf16_str.ToQuickJS(ctx);
  
  // Verify the string is correctly converted
  const char* result = JS_ToCString(ctx, qjs_value);
  EXPECT_STREQ(result, "JavaScript 世界 🚀");
  
  JS_FreeCString(ctx, result);
  JS_FreeValue(ctx, qjs_value);
}

TEST(AtomicString, UTF16StringCache) {
  auto env = TEST_init();
  JSContext* ctx = env->page()->executingContext()->ctx();
  
  // Create UTF-16 string
  std::u16string test_str = u"Cached UTF-16 String 测试";
  AtomicString utf16_str = AtomicString(test_str.c_str(), test_str.length());
  
  // Put it in the cache
  JSValue qjs_value = env->page()->dartIsolateContext()->stringCache()->GetJSValueFromString(ctx, utf16_str.Impl());
  
  // Retrieve it back from cache
  JSAtom atom = JS_ValueToAtom(ctx, qjs_value);
  std::shared_ptr<StringImpl> cached_str = env->page()->dartIsolateContext()->stringCache()->GetStringFromJSAtom(ctx, atom);
  
  // Verify it's the same string
  EXPECT_FALSE(cached_str->Is8Bit());
  EXPECT_EQ(cached_str->length(), utf16_str.length());
  
  // Compare the actual content
  for (size_t i = 0; i < cached_str->length(); i++) {
    EXPECT_EQ((*cached_str)[i], utf16_str[i]);
  }
  
  JS_FreeAtom(ctx, atom);
  JS_FreeValue(ctx, qjs_value);
}

TEST(AtomicString, MixedUTF8AndUTF16) {
  TEST_init();
  
  // Create both UTF-8 and UTF-16 strings
  AtomicString utf8_str = AtomicString("Hello ASCII");
  AtomicString utf16_str = AtomicString(u"Hello 世界");
  
  // Verify their types
  EXPECT_TRUE(utf8_str.Is8Bit());
  EXPECT_FALSE(utf16_str.Is8Bit());
  
  // Convert both to std::string
  std::string str1 = utf8_str.ToStdString();
  std::string str2 = utf16_str.ToStdString();
  
  EXPECT_EQ(str1, "Hello ASCII");
  EXPECT_EQ(str2, "Hello 世界");
}

TEST(AtomicString, UTF16WithSurrogatePairs) {
  TEST_init();
  
  // Test with emoji that requires surrogate pairs
  const char16_t emoji_str[] = u"Hello 😀 World 🌍";
  AtomicString utf16_str = AtomicString(emoji_str);
  
  EXPECT_FALSE(utf16_str.Is8Bit());
  
  // Convert to UTF-8 and verify
  std::string utf8_result = utf16_str.ToStdString();
  EXPECT_EQ(utf8_result, "Hello 😀 World 🌍");
}

TEST(AtomicString, UTF16ToNativeString) {
  TEST_init();
  
  // Create UTF-16 string
  AtomicString utf16_str = AtomicString(u"Native 字符串");
  
  // Convert to native string
  auto native_str = utf16_str.ToNativeString();
  
  EXPECT_EQ(native_str->length(), 10);
  
  // Verify the content
  const uint16_t* chars = native_str->string();
  EXPECT_EQ(chars[0], u'N');
  EXPECT_EQ(chars[7], u'字');
  EXPECT_EQ(chars[9], u'串');
}

TEST(AtomicString, EmptyUTF16String) {
  TEST_init();
  
  // Test empty UTF-16 string
  AtomicString empty_utf16 = AtomicString(u"");
  
  EXPECT_TRUE(empty_utf16.empty());
  EXPECT_EQ(empty_utf16.length(), 0);
  EXPECT_EQ(empty_utf16.ToStdString(), "");
}

TEST(StringImpl, CreateFromUTF8ASCII) {
  TEST_init();
  
  // Test pure ASCII UTF-8 string
  const char* ascii_utf8 = "Hello World";
  auto str = StringImpl::CreateFromUTF8(ascii_utf8, strlen(ascii_utf8));
  
  EXPECT_TRUE(str->Is8Bit());
  EXPECT_EQ(str->length(), 11);
  EXPECT_EQ(std::string(str->Characters8(), str->length()), "Hello World");
}

TEST(StringImpl, CreateFromUTF8WithUnicode) {
  TEST_init();
  
  // Test UTF-8 with Unicode characters
  const char* utf8_str = "Hello 世界"; // "Hello World" in English and Chinese
  auto str = StringImpl::CreateFromUTF8(utf8_str, strlen(utf8_str));
  
  EXPECT_FALSE(str->Is8Bit());
  EXPECT_EQ(str->length(), 8); // "Hello " (6) + "世界" (2)
  
  const char16_t* chars = str->Characters16();
  EXPECT_EQ(chars[0], u'H');
  EXPECT_EQ(chars[5], u' ');
  EXPECT_EQ(chars[6], u'世');
  EXPECT_EQ(chars[7], u'界');
}

TEST(StringImpl, CreateFromUTF8WithEmoji) {
  TEST_init();
  
  // Test UTF-8 with emoji (4-byte UTF-8, surrogate pairs in UTF-16)
  const char* emoji_utf8 = "Hello 😀";
  auto str = StringImpl::CreateFromUTF8(emoji_utf8, strlen(emoji_utf8));
  
  EXPECT_FALSE(str->Is8Bit());
  EXPECT_EQ(str->length(), 8); // "Hello " (6) + surrogate pair (2)
  
  const char16_t* chars = str->Characters16();
  // Check surrogate pair for 😀 (U+1F600)
  EXPECT_EQ(chars[6], 0xD83D); // High surrogate
  EXPECT_EQ(chars[7], 0xDE00); // Low surrogate
}

TEST(StringImpl, CreateFromUTF8WithLatin1) {
  TEST_init();
  
  // Test UTF-8 with Latin-1 extended characters
  const char* latin1_utf8 = "Café"; // é is U+00E9
  auto str = StringImpl::CreateFromUTF8(latin1_utf8, strlen(latin1_utf8));
  
  EXPECT_TRUE(str->Is8Bit()); // Latin-1 fits in 8-bit
  EXPECT_EQ(str->length(), 4);
  
  const char* chars = str->Characters8();
  EXPECT_EQ(chars[0], 'C');
  EXPECT_EQ(chars[1], 'a');
  EXPECT_EQ(chars[2], 'f');
  EXPECT_EQ(static_cast<unsigned char>(chars[3]), 0xE9);
}

TEST(StringImpl, CreateFromUTF8InvalidSequence) {
  TEST_init();
  
  // Test invalid UTF-8 sequence (should be replaced with U+FFFD)
  const char invalid_utf8[] = "Hello\xFF\xFEWorld";
  auto str = StringImpl::CreateFromUTF8(invalid_utf8, sizeof(invalid_utf8) - 1);
  
  EXPECT_FALSE(str->Is8Bit());
  EXPECT_EQ(str->length(), 12); // "Hello" (5) + replacement chars (2) + "World" (5)
  
  const char16_t* chars = str->Characters16();
  EXPECT_EQ(chars[5], 0xFFFD); // Replacement character
  EXPECT_EQ(chars[6], 0xFFFD); // Replacement character
}

TEST(StringImpl, CreateFromUTF8Empty) {
  TEST_init();
  
  // Test empty string
  auto str1 = StringImpl::CreateFromUTF8("", 0);
  auto str2 = StringImpl::CreateFromUTF8(nullptr, 0);
  
  EXPECT_TRUE(str1->length() == 0);
  EXPECT_TRUE(str2->length() == 0);
  EXPECT_EQ(str1, str2); // Should return the same empty string singleton
}
