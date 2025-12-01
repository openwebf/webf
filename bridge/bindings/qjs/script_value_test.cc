/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "script_value.h"
#include <quickjs/quickjs.h>
#include <codecvt>
#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

using TestCallback = void (*)(JSContext* ctx);

void TestScriptValue(TestCallback callback) {
  auto env = TEST_init();
  callback(env->page()->executingContext()->ctx());
}

TEST(ScriptValue, createErrorObject) {
  TestScriptValue([](JSContext* ctx) {
    ScriptValue value = ScriptValue::CreateErrorObject(ctx, "error");
    EXPECT_EQ(JS_IsError(ctx, value.QJSValue()), true);
  });
}

TEST(ScriptValue, CreateJsonObject) {
  TestScriptValue([](JSContext* ctx) {
    std::string code = "{\"name\": 1}";
    ScriptValue value = ScriptValue::CreateJsonObject(ctx, code.c_str(), code.size());
    EXPECT_EQ(value.IsObject(), true);
  });
}

TEST(ScriptValue, Empty) {
  TestScriptValue([](JSContext* ctx) {
    ScriptValue empty = ScriptValue::Empty(ctx);
    EXPECT_EQ(empty.IsEmpty(), true);
  });
}

TEST(ScriptValue, ToString) {
  TestScriptValue([](JSContext* ctx) {
    std::string code = "{\"name\": 1}";
    ScriptValue json = ScriptValue::CreateJsonObject(ctx, code.c_str(), code.size());
    AtomicString string = json.ToAtomicString(ctx);
    EXPECT_STREQ(string.ToUTF8String().c_str(), "[object Object]");
  });
}

TEST(ScriptValue, CopyAssignment) {
  TestScriptValue([](JSContext* ctx) {
    std::string code = "{\"name\":1}";
    ScriptValue json = ScriptValue::CreateJsonObject(ctx, code.c_str(), code.size());
    struct P {
      ScriptValue value;
    };
    P p;
    p.value = json;
    EXPECT_STREQ(p.value.ToJSONStringify(ctx, nullptr).ToAtomicString(ctx).ToUTF8String().c_str(), code.c_str());
  });
}

TEST(ScriptValue, MoveAssignment) {
  TestScriptValue([](JSContext* ctx) {
    ScriptValue other;
    {
      std::string code = "{\"name\":1}";
      other = ScriptValue::CreateJsonObject(ctx, code.c_str(), code.size());
    }

    EXPECT_STREQ(other.ToJSONStringify(ctx, nullptr).ToAtomicString(ctx).ToUTF8String().c_str(), "{\"name\":1}");
  });
}
