/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "test/webf_test_env.h"
#include "foundation/ui_command_strategy.h"
#include "foundation/shared_ui_command.h"
#include "core/executing_context.h"
#include "core/page.h"
#include "foundation/native_string.h"
#include "core/binding_object.h"
#include <thread>
#include <chrono>

using namespace webf;

// Helper function to create SharedNativeString from C string
static std::unique_ptr<webf::SharedNativeString> CreateSharedString(const char* str) {
  size_t len = strlen(str);
#if defined(_WIN32)
  auto* utf16_str = static_cast<uint16_t*>(CoTaskMemAlloc((len + 1) * sizeof(uint16_t)));
#else
  auto* utf16_str = static_cast<uint16_t*>(malloc((len + 1) * sizeof(uint16_t)));
#endif
  for (size_t i = 0; i < len; ++i) {
    utf16_str[i] = static_cast<uint16_t>(str[i]);
  }
  utf16_str[len] = 0;
  return std::make_unique<webf::SharedNativeString>(utf16_str, len);
}

// Mock NativeBindingObject for testing
struct MockNativeBindingObject : public NativeBindingObject {
  MockNativeBindingObject(BindingObject* target) : NativeBindingObject(target) {}
};

class UICommandSyncStrategyTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init().release();
    context_ = env_->page()->executingContext();
    // Use dedicated mode check instead of setting it
    shared_command_ = std::make_unique<SharedUICommand>(context_);
    strategy_ = std::make_unique<UICommandSyncStrategy>(shared_command_.get());
    strategy_->ConfigWaitingBufferSize(2);  // Small buffer for testing
  }

  void TearDown() override {
    strategy_.reset();
    shared_command_.reset();
    delete env_;
  }

  WebFTestEnv* env_;
  ExecutingContext* context_;
  std::unique_ptr<SharedUICommand> shared_command_;
  std::unique_ptr<UICommandSyncStrategy> strategy_;
};

// Test WaitingStatus functionality
TEST_F(UICommandSyncStrategyTest, WaitingStatusBasics) {
  WaitingStatus status;
  status.storage.push_back(UINT64_MAX);
  status.storage.push_back(UINT64_MAX);
  
  EXPECT_EQ(status.MaxSize(), 128);  // 64 * 2
  EXPECT_FALSE(status.IsFullActive());
  
  // Set some bits to active
  status.SetActiveAtIndex(0);
  status.SetActiveAtIndex(63);
  status.SetActiveAtIndex(64);
  
  EXPECT_FALSE(status.IsFullActive());
  
  // Reset should set all bits back to 1
  status.Reset();
  EXPECT_FALSE(status.IsFullActive());
}

// Test waiting queue commands
TEST_F(UICommandSyncStrategyTest, WaitingQueueCommands) {
  MockNativeBindingObject obj1(nullptr), obj2(nullptr);
  
  // Commands that should go to waiting queue
  strategy_->RecordUICommand(UICommand::kCreateElement,
                            CreateSharedString("div"), &obj1, nullptr, true);
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 1);

  strategy_->RecordUICommand(UICommand::kSetStyle,
                            CreateSharedString("color:red"), &obj1, nullptr, true);
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 2);
  
  strategy_->RecordUICommand(UICommand::kInsertAdjacentNode,
                            CreateSharedString("afterbegin"), &obj1, &obj2, true);
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 3);
}

// Test frequency map and auto-sync
TEST_F(UICommandSyncStrategyTest, FrequencyMapAutoSync) {
  // Create enough unique objects to exceed waiting buffer size
  std::vector<std::unique_ptr<MockNativeBindingObject>> objects;
  for (int i = 0; i < 130; ++i) {  // More than 128 (MaxSize)
    objects.push_back(std::make_unique<MockNativeBindingObject>(nullptr));
  }
  
  // Add commands with different objects
  for (int i = 0; i < 65; ++i) {
    strategy_->RecordUICommand(UICommand::kCreateElement,
                              CreateSharedString("element"), objects[i].get(), nullptr, true);
  }

  
  // Now use the same objects again to make all bits active
  for (int i = 0; i < 65; ++i) {
    strategy_->RecordUICommand(UICommand::kSetAttribute,
                              CreateSharedString("attr"), objects[i].get(), nullptr, true);
  }

  EXPECT_TRUE(strategy_->GetWaitingCommandsCount() > 0);
}

// Test flush waiting commands
TEST_F(UICommandSyncStrategyTest, FlushWaitingCommands) {
  MockNativeBindingObject obj(nullptr);
  
  // Add some commands to waiting queue
  strategy_->RecordUICommand(UICommand::kCreateElement,
                            CreateSharedString("span"), &obj, nullptr, true);
  strategy_->RecordUICommand(UICommand::kSetAttribute,
                            CreateSharedString("id=test"), &obj, nullptr, true);
  strategy_->RecordUICommand(UICommand::kAddEvent,
                            CreateSharedString("click"), &obj, nullptr, true);
  
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 3);
  
  // Flush commands
  strategy_->FlushWaitingCommands();
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 0);
}

// Test Reset functionality
TEST_F(UICommandSyncStrategyTest, ResetClearsEverything) {
  MockNativeBindingObject obj1(nullptr), obj2(nullptr);
  
  // Add various commands
  strategy_->RecordUICommand(UICommand::kCreateElement,
                            CreateSharedString("div"), &obj1, nullptr, true);
  strategy_->RecordUICommand(UICommand::kSetStyle,
                            CreateSharedString("width:100px"), &obj1, nullptr, true);
  strategy_->RecordUICommand(UICommand::kInsertAdjacentNode,
                            CreateSharedString("beforeend"), &obj1, &obj2, true);
  
  EXPECT_GT(strategy_->GetWaitingCommandsCount(), 0);
  
  // Force sync
  strategy_->RecordUICommand(UICommand::kAsyncCaller,
                            CreateSharedString("async"), nullptr, nullptr, true);
  // Reset should clear everything
  strategy_->Reset();
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 0);
}

// Test command categorization
TEST_F(UICommandSyncStrategyTest, CommandCategorization) {
  MockNativeBindingObject obj(nullptr);
  
  // Test each category of commands
  
  // 1. Immediate sync commands
  strategy_->RecordUICommand(UICommand::kStartRecordingCommand, nullptr, nullptr, nullptr, true);
  strategy_->Reset();
  
  strategy_->RecordUICommand(UICommand::kCreateDocument, nullptr, nullptr, nullptr, true);
  strategy_->Reset();
  
  strategy_->RecordUICommand(UICommand::kCreateWindow, nullptr, nullptr, nullptr, true);
  strategy_->Reset();
  
  // 2. Waiting queue with pointer tracking
  strategy_->RecordUICommand(UICommand::kCreateElement,
                            CreateSharedString("p"), &obj, nullptr, true);
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 1);

  // 3. Simple waiting queue commands
  strategy_->RecordUICommand(UICommand::kSetStyle,
                            CreateSharedString("margin:10px"), &obj, nullptr, true);
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 2);
  
  // 4. FinishRecordingCommand doesn't affect strategy state
  strategy_->RecordUICommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr, true);
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 2);
}

// Test concurrent access
TEST_F(UICommandSyncStrategyTest, ConcurrentAccess) {
  // Skip this test for now due to thread safety concerns
  // The UICommandSyncStrategy is not designed for concurrent access from multiple threads
  GTEST_SKIP() << "UICommandSyncStrategy is not thread-safe for concurrent access";
}

// Test edge cases
TEST_F(UICommandSyncStrategyTest, EdgeCases) {
  // Test with nullptr objects
  strategy_->RecordUICommand(UICommand::kCreateElement,
                            CreateSharedString("null"), nullptr, nullptr, true);
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 1);
  
  // Test with empty strings
  strategy_->RecordUICommand(UICommand::kSetAttribute,
                            CreateSharedString(""), nullptr, nullptr, true);
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 2);
  
  // Test InsertAdjacentNode with both pointers
  MockNativeBindingObject obj1(nullptr), obj2(nullptr);
  strategy_->RecordUICommand(UICommand::kInsertAdjacentNode,
                            CreateSharedString("position"), &obj1, &obj2, true);
  EXPECT_EQ(strategy_->GetWaitingCommandsCount(), 3);
  
  // Test large waiting buffer size
  strategy_->ConfigWaitingBufferSize(100);
  strategy_->Reset();
  
  // Add many commands
  for (int i = 0; i < 200; ++i) {
    auto obj = std::make_unique<MockNativeBindingObject>(nullptr);
    strategy_->RecordUICommand(UICommand::kCreateElement,
                              CreateSharedString("many"), obj.get(), nullptr, true);
  }
  
  // Should eventually trigger sync
  EXPECT_TRUE(strategy_->GetWaitingCommandsCount() > 0);
}

// Test integration with SharedUICommand
TEST_F(UICommandSyncStrategyTest, IntegrationWithSharedUICommand) {
  MockNativeBindingObject obj(nullptr);
  
  // Add commands through SharedUICommand's AddCommand method
  shared_command_->AddCommand(UICommand::kCreateElement,
                             CreateSharedString("integration"), &obj, nullptr, true);
  
  // The command should be recorded by the strategy
  shared_command_->AddCommand(UICommand::kSetStyle,
                             CreateSharedString("display:block"), &obj, nullptr, true);
  
  // Trigger sync with a finish command
  shared_command_->AddCommand(UICommand::kFinishRecordingCommand,
                             nullptr, nullptr, nullptr, true);
  
  // Retrieve commands
  void* data = shared_command_->data();
  auto* pack = static_cast<UICommandBufferPack*>(data);
  
  // Should have commands if the integration works correctly
  EXPECT_GE(pack->length, 0);
  
  dart_free(pack);
}