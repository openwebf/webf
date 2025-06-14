/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <quickjs/quickjs.h>
#include <codecvt>
#include "event_type_names.h"
#include "gtest/gtest.h"
#include "native_string_utils.h"
#include "qjs_engine_patch.h"
#include "webf_test_env.h"

using namespace webf;

using TestCallback = void (*)(JSContext* ctx);

TEST(AtomicString, Empty) {
  TEST_init();
  AtomicString atomic_string = AtomicString::Empty();
  EXPECT_STREQ(atomic_string.Impl()->Characters8(), "");
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
  AtomicString&& value = AtomicString("helloworld");
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
  AtomicString str = AtomicString("helloworld");
  struct P {
    AtomicString str;
  };
  P p{AtomicString::Empty()};
  p.str = str;
  EXPECT_EQ(p.str == str, true);
}

TEST(AtomicString, MoveAssignment) {
  auto&& str = AtomicString("helloworld");
  auto&& str2 = AtomicString(std::move(str));
  EXPECT_EQ(str2.ToStdString(), "helloworld");
}

TEST(AtomicString, CopyToRightReference) {
  AtomicString str = AtomicString::Empty();
  if (1 + 1 == 2) {
    str = AtomicString("helloworld");
  }
  EXPECT_EQ(str.ToStdString(), "helloworld");
}
