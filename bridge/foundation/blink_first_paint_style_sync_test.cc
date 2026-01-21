#include "gtest/gtest.h"

#include <cstring>

#include "foundation/ui_command_buffer.h"
#include "webf_test_env.h"

using namespace webf;

namespace {

bool HasCommand(const UICommandItem* items, int64_t length, UICommand command) {
  for (int64_t i = 0; i < length; ++i) {
    if (items[i].type == static_cast<int32_t>(command)) {
      return true;
    }
  }
  return false;
}

}  // namespace

TEST(BlinkFirstPaintStyleSync, EmitsSheetStyleCommandsInFirstBatch) {
  auto env = TEST_init(nullptr, nullptr, 0, /*enable_blink=*/1);
  auto* context = env->page()->executingContext();

  // Flush bootstrap microtasks and drop any initial commands.
  TEST_runLoop(context);
  context->uiCommandBuffer()->clear();

  const char* setup = R"JS(
    const style = document.createElement('style');
    style.textContent = '.box { color: red; }';
    document.body.appendChild(style);

    const div = document.createElement('div');
    div.className = 'box';
    div.textContent = 'hi';
    document.body.appendChild(div);
  )JS";
  env->page()->evaluateScript(setup, strlen(setup), "vm://", 0);

  context->uiCommandBuffer()->SyncAllPackages();
  auto* pack = static_cast<UICommandBufferPack*>(context->uiCommandBuffer()->data());
  auto* items = static_cast<UICommandItem*>(pack->data);

  EXPECT_TRUE(HasCommand(items, pack->length, UICommand::kClearSheetStyle));
  EXPECT_TRUE(HasCommand(items, pack->length, UICommand::kSetSheetStyleById) ||
              HasCommand(items, pack->length, UICommand::kSetSheetStyle));
}

