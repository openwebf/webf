/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"

#include <cstring>

#include "foundation/native_string.h"
#include "foundation/native_type.h"
#include "foundation/string/wtf_string.h"
#include "foundation/ui_command_buffer.h"
#include "webf_test_env.h"

using namespace webf;

namespace {

std::string CommandArg01ToUTF8(const UICommandItem& item) {
  if (item.string_01 == 0 || item.args_01_length == 0) {
    return "";
  }
  const auto* utf16 = reinterpret_cast<const UChar*>(static_cast<uintptr_t>(item.string_01));
  return String(utf16, static_cast<size_t>(item.args_01_length)).ToUTF8String();
}

std::string SharedNativeStringToUTF8(const SharedNativeString* s) {
  if (!s || !s->string() || s->length() == 0) {
    return "";
  }
  return String(reinterpret_cast<const UChar*>(s->string()), static_cast<size_t>(s->length())).ToUTF8String();
}

bool HasSetStyleWithKeyValue(ExecutingContext* context, const std::string& key, const std::string& value) {
  auto* pack = static_cast<UICommandBufferPack*>(context->uiCommandBuffer()->data());
  auto* items = static_cast<UICommandItem*>(pack->data);
  for (int64_t i = 0; i < pack->length; ++i) {
    const UICommandItem& item = items[i];
    if (item.type != static_cast<int32_t>(UICommand::kSetStyle)) {
      continue;
    }
    if (CommandArg01ToUTF8(item) != key) {
      continue;
    }
    auto* payload =
        reinterpret_cast<NativeStyleValueWithHref*>(static_cast<uintptr_t>(item.nativePtr2));
    if (!payload) {
      continue;
    }
    if (SharedNativeStringToUTF8(payload->value) == value) {
      return true;
    }
  }
  return false;
}

}  // namespace

TEST(BlinkCSSStyleDeclarationValidation, RejectsInvalidFontSize) {
  bool static errorCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void*, const std::string&, int) {};

  auto env = TEST_init([](double, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  }, nullptr, 0, /*enable_blink=*/1);

  auto* context = env->page()->executingContext();

  // Flush initial microtasks/style export and clear any bootstrap commands.
  TEST_runLoop(context);
  context->uiCommandBuffer()->clear();

  // Set a valid value first.
  const char* set_valid = "document.body.style.fontSize = '18px';";
  env->page()->evaluateScript(set_valid, strlen(set_valid), "vm://", 0);
  TEST_runLoop(context);
  EXPECT_TRUE(HasSetStyleWithKeyValue(context, "fontSize", "18px"));

  context->uiCommandBuffer()->clear();

  // Invalid font-size should be rejected on the native (Blink) CSS side and
  // thus should not be forwarded to Dart.
  const char* set_invalid = "document.body.style.fontSize = '-1px';";
  env->page()->evaluateScript(set_invalid, strlen(set_invalid), "vm://", 0);
  TEST_runLoop(context);
  EXPECT_FALSE(HasSetStyleWithKeyValue(context, "fontSize", "-1px"));
  EXPECT_EQ(errorCalled, false);
}
