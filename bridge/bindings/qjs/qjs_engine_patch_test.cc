/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "qjs_engine_patch.h"
#include <codecvt>
#include "gtest/gtest.h"

TEST(JS_ToUnicode, asciiWords) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  JSValue value = JS_NewString(ctx, "helloworld");
  uint32_t bufferLength;
  uint16_t* buffer = JS_ToUnicode(ctx, value, &bufferLength);
  std::u16string u16Value = u"helloworld";
  std::u16string bufferString = std::u16string(reinterpret_cast<char16_t*>(buffer), bufferLength);

  uint8_t results[] = {
      0x68,
      0x00,
      0x65,
      0x00,
      0x6c,
      0x00,
      0x6c,
      0x00,
      0x6f,
      0x00,
      0x77,
      0x00,
      0x6f,
      0x00,
      0x72,
      0x00,
      0x6c,
      0x00,
      0x64,
      0x00
  };

  for(int i = 0; i < bufferLength * 2; i ++) {
    EXPECT_EQ(((uint8_t*)buffer)[i], results[i]);
  }

  EXPECT_EQ(bufferString == u16Value, true);

  JS_FreeValue(ctx, value);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
  delete buffer;
}

TEST(JS_ToUnicode, chineseWords) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  JSValue value = JS_NewString(ctx, "a你的名字12345");
  uint32_t bufferLength;
  uint16_t* buffer = JS_ToUnicode(ctx, value, &bufferLength);

  uint8_t results[] = {
      0x61,
      0x00,
      0x60,
      0x4f,
      0x84,
      0x76,
      0x0d,
      0x54,
      0x57,
      0x5b,
      0x31,
      0x00,
      0x32,
      0x00,
      0x33,
      0x00,
      0x34,
      0x00,
      0x35,
      0x00
  };

  for(int i = 0; i < bufferLength * 2; i ++) {
    EXPECT_EQ(((uint8_t*)buffer)[i], results[i]);
  }

  JS_FreeValue(ctx, value);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}

TEST(JS_ToUnicode, emoji) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  JSValue value = JS_NewString(ctx, "1😀2");
  uint32_t bufferLength;
  uint16_t* buffer = JS_ToUnicode(ctx, value, &bufferLength);


  uint8_t results[] = {
      0X31,
      0X00,
      0X3D,
      0xd8,
      0x00,
      0xde,
      0x32,
      0x00
  };

  for(int i = 0; i < bufferLength * 2; i ++) {
    EXPECT_EQ(((uint8_t*)buffer)[i], results[i]);
  }


  JS_FreeValue(ctx, value);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}

TEST(JS_NewUnicodeString, fromAscii) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  std::u16string source = u"helloworld";
  JSValue result = JS_NewUnicodeString(ctx, reinterpret_cast<const uint16_t*>(source.c_str()), source.length());
  const char* str = JS_ToCString(ctx, result);
  EXPECT_STREQ(str, "helloworld");

  JS_FreeCString(ctx, str);
  JS_FreeValue(ctx, result);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}

TEST(JS_NewUnicodeString, fromChieseCode) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);
  uint8_t input[] = {
      0x61,
      0x00,
      0x60,
      0x4f,
      0x84,
      0x76,
      0x0d,
      0x54,
      0x57,
      0x5b,
      0x31,
      0x00,
      0x32,
      0x00,
      0x33,
      0x00,
      0x34,
      0x00,
      0x35,
      0x00
  };

  JSValue result = JS_NewUnicodeString(ctx, (uint16_t*)&input, 12);
  uint32_t length;
  uint16_t* buffer = JS_ToUnicode(ctx, result, &length);

  for(int i = 0; i < length * 2; i ++) {
    EXPECT_EQ(((uint8_t*)buffer)[i], input[i]);
  }

  JS_FreeValue(ctx, result);
  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);
}
