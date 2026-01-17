#include "gtest/gtest.h"

#include <cstring>

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

int64_t CountPseudoCommands(const UICommandItem* items,
                            int64_t length,
                            UICommand command,
                            const std::string& pseudo_type) {
  int64_t count = 0;
  for (int64_t i = 0; i < length; ++i) {
    const UICommandItem& item = items[i];
    if (item.type != static_cast<int32_t>(command)) {
      continue;
    }
    if (CommandArg01ToUTF8(item) == pseudo_type) {
      count++;
    }
  }
  return count;
}

}  // namespace

TEST(BlinkPseudoStyleGating, DoesNotEmitPseudoStylesWithoutContent) {
  auto env = TEST_init(nullptr, nullptr, 0, /*enable_blink=*/1);
  auto* context = env->page()->executingContext();

  // Flush bootstrap microtasks and drop any initial commands.
  TEST_runLoop(context);
  context->uiCommandBuffer()->clear();

  const char* setup = R"JS(
    const style = document.createElement('style');
    style.textContent = `.box::before { color: red; } .box { color: blue; }`;
    document.body.appendChild(style);

    const div = document.createElement('div');
    div.className = 'box';
    div.textContent = 'hi';
    document.body.appendChild(div);
  )JS";
  env->page()->evaluateScript(setup, strlen(setup), "vm://", 0);
  TEST_runLoop(context);

  // Ignore DOM creation commands; only inspect style export.
  context->uiCommandBuffer()->clear();
  {
    MemberMutationScope scope{context};
    context->document()->UpdateStyleForThisDocument();
  }
  context->uiCommandBuffer()->SyncAllPackages();

  auto* pack = static_cast<UICommandBufferPack*>(context->uiCommandBuffer()->data());
  auto* items = static_cast<UICommandItem*>(pack->data);

  EXPECT_EQ(CountPseudoCommands(items, pack->length, UICommand::kSetPseudoStyle, "before"), 0);
  EXPECT_EQ(CountPseudoCommands(items, pack->length, UICommand::kClearPseudoStyle, "before"), 0);
}

TEST(BlinkPseudoStyleGating, EmitsPseudoStylesWhenContentPresent) {
  auto env = TEST_init(nullptr, nullptr, 0, /*enable_blink=*/1);
  auto* context = env->page()->executingContext();

  TEST_runLoop(context);
  context->uiCommandBuffer()->clear();

  const char* setup = R"JS(
    const style = document.createElement('style');
    style.textContent = `.box::before { content: ""; color: red; }`;
    document.body.appendChild(style);

    const div = document.createElement('div');
    div.className = 'box';
    div.textContent = 'hi';
    document.body.appendChild(div);
  )JS";
  env->page()->evaluateScript(setup, strlen(setup), "vm://", 0);
  TEST_runLoop(context);

  context->uiCommandBuffer()->clear();
  {
    MemberMutationScope scope{context};
    context->document()->UpdateStyleForThisDocument();
  }
  context->uiCommandBuffer()->SyncAllPackages();

  auto* pack = static_cast<UICommandBufferPack*>(context->uiCommandBuffer()->data());
  auto* items = static_cast<UICommandItem*>(pack->data);

  EXPECT_GT(CountPseudoCommands(items, pack->length, UICommand::kSetPseudoStyle, "before"), 0);
  EXPECT_GT(CountPseudoCommands(items, pack->length, UICommand::kClearPseudoStyle, "before"), 0);
}
