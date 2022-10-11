/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "gtest/gtest.h"
#include <quickjs/quickjs.h>
#include <codecvt>


struct A {
  uint64_t value;
};

TEST(Quickjs, runJs) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);

  std::string code = "(() => { name: 1})()";
  JSValue result = JS_Eval(ctx, code.c_str(), code.size(), "vm://", JS_EVAL_TYPE_GLOBAL);

  JSValue obj = JS_NewObject(ctx);
  JS_FreeValue(ctx, obj);

  JS_FreeContext(ctx);
  JS_FreeRuntime(runtime);

//
//  A a;
//  a.value = 1;

//  EXPECT_EQ(a.value, 1);
}