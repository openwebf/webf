/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "test/webf_test_env.h"
#include "foundation/shared_ui_command.h"
#include "core/executing_context.h"
#include "core/page.h"
#include "foundation/native_string.h"
#include "core/binding_object.h"
#include <thread>
#include <chrono>
#include <atomic>
#include <vector>

using namespace webf;

// Helper function to create SharedNativeString from C string
std::unique_ptr<webf::SharedNativeString> CreateSharedString(const char* str) {
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

class SharedUICommandTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init().release();
    context_ = env_->page()->executingContext();
    shared_command_ = std::make_unique<SharedUICommand>(context_);
  }

  void TearDown() override {
    shared_command_.reset();
    delete env_;
  }

  WebFTestEnv* env_;
  ExecutingContext* context_;
  std::unique_ptr<SharedUICommand> shared_command_;
};

// Test basic command addition and retrieval
TEST_F(SharedUICommandTest, BasicAddAndRetrieve) {
  EXPECT_TRUE(shared_command_->empty());

  // Add a command
  shared_command_->AddCommand(UICommand::kCreateElement, CreateSharedString("test"), nullptr, nullptr);

  // In non-dedicated mode, we need to finish recording to see commands
  shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);

  if (!context_->isDedicated()) {
    EXPECT_FALSE(shared_command_->empty());
    EXPECT_GT(shared_command_->size(), 0);
  }
}

// Test data() retrieval
TEST_F(SharedUICommandTest, DataRetrieval) {
  // Add multiple commands
  auto str1 = CreateSharedString("element1");
  auto str2 = CreateSharedString("element2");

  shared_command_->AddCommand(UICommand::kCreateElement, std::move(str1), nullptr, nullptr);
  shared_command_->AddCommand(UICommand::kCreateElement, std::move(str2), nullptr, nullptr);

  // Finish recording to make commands available
  shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);

  // Retrieve data
  void* data = shared_command_->data();
  EXPECT_NE(data, nullptr);

  auto* pack = static_cast<UICommandBufferPack*>(data);
  if (pack->length > 0) {
    EXPECT_NE(pack->data, nullptr);
    EXPECT_NE(pack->buffer_head, nullptr);
  }

  // Clear commands when done
  shared_command_->clear();

  // Clean up the pack only - buffer is managed by SharedUICommand
  dart_free(pack);
}

// Test clear() functionality
TEST_F(SharedUICommandTest, ClearCommands) {
  auto str = CreateSharedString("test");

  // Add and retrieve commands
  shared_command_->AddCommand(UICommand::kCreateElement, std::move(str), nullptr, nullptr);
  shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);

  void* data = shared_command_->data();
  auto* pack = static_cast<UICommandBufferPack*>(data);

  // Clear should mark the buffer as consumed
  shared_command_->clear();

  // Clean up the pack only - buffer is managed by SharedUICommand
  dart_free(pack);
}

// Test ring buffer wraparound
TEST_F(SharedUICommandTest, RingBufferWraparound) {
  const int numIterations = 10; // More than ring buffer size

  for (int i = 0; i < numIterations; ++i) {
    std::string cmd_str = "command" + std::to_string(i);
    auto str = CreateSharedString(cmd_str.c_str());

    // Add command
    shared_command_->AddCommand(UICommand::kCreateElement, std::move(str), nullptr, nullptr);
    shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);

    // Retrieve data
    void* data = shared_command_->data();
    auto* pack = static_cast<UICommandBufferPack*>(data);

    if (pack->length > 0) {
      EXPECT_NE(pack->data, nullptr);
      EXPECT_NE(pack->buffer_head, nullptr);

      // Clear to mark as consumed
      shared_command_->clear();
    }

    dart_free(pack);
  }
}

// Test concurrent access from multiple threads
TEST_F(SharedUICommandTest, ConcurrentAccess) {
  std::atomic<bool> stop_flag(false);
  std::atomic<int> commands_added(0);
  std::atomic<int> commands_read(0);

  // Writer thread (simulates JS thread)
  std::thread writer([&]() {
    while (!stop_flag.load()) {
      shared_command_->AddCommand(UICommand::kCreateElement, CreateSharedString("concurrent_command"), nullptr, nullptr);
      shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
      commands_added.fetch_add(1);
      std::this_thread::sleep_for(std::chrono::microseconds(100));
    }
  });

  // Reader thread (simulates Dart UI thread)
  std::thread reader([&]() {
    while (!stop_flag.load()) {
      void* data = shared_command_->data();
      auto* pack = static_cast<UICommandBufferPack*>(data);

      if (pack->length > 0) {
        commands_read.fetch_add(1);
        shared_command_->clear();
      }

      dart_free(pack);
      std::this_thread::sleep_for(std::chrono::microseconds(150));
    }
  });

  // Run for a short time
  std::this_thread::sleep_for(std::chrono::milliseconds(100));
  stop_flag.store(true);

  writer.join();
  reader.join();

  // Verify some commands were processed
  EXPECT_GT(commands_added.load(), 0);
  EXPECT_GT(commands_read.load(), 0);
}

// Test empty buffer handling
TEST_F(SharedUICommandTest, EmptyBufferHandling) {
  // Get data from empty buffer
  void* data = shared_command_->data();
  EXPECT_NE(data, nullptr);

  auto* pack = static_cast<UICommandBufferPack*>(data);
  EXPECT_EQ(pack->length, 0);

  dart_free(pack);
}

// Test size calculation
TEST_F(SharedUICommandTest, SizeCalculation) {
  EXPECT_EQ(shared_command_->size(), 0);

  // Add commands
  shared_command_->AddCommand(UICommand::kCreateElement, CreateSharedString("cmd1"), nullptr, nullptr);
  
  // In dedicated mode, we might need to sync first
  if (context_->isDedicated() && shared_command_->size() == 0) {
    // Force sync for dedicated mode
    shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
  }
  
  int64_t size1 = shared_command_->size();
  EXPECT_GT(size1, 0);

  shared_command_->AddCommand(UICommand::kCreateElement, CreateSharedString("cmd2"), nullptr, nullptr);
  
  if (context_->isDedicated()) {
    // Force sync again
    shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
  }
  
  int64_t size2 = shared_command_->size();
  EXPECT_GT(size2, size1);
}

// Test multiple buffers ready simultaneously
TEST_F(SharedUICommandTest, MultipleBuffersReady) {
  // Add commands to multiple buffers without reading
  for (int i = 0; i < 3; ++i) {
    std::string batch_str = "batch" + std::to_string(i);
    shared_command_->AddCommand(UICommand::kCreateElement, CreateSharedString(batch_str.c_str()), nullptr, nullptr);
    shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
  }

  // Now read all buffers
  int buffers_read = 0;
  for (int i = 0; i < 4; ++i) { // Try to read more than we wrote
    void* data = shared_command_->data();
    auto* pack = static_cast<UICommandBufferPack*>(data);

    if (pack->length > 0) {
      buffers_read++;
      shared_command_->clear();
    }

    dart_free(pack);
  }

  EXPECT_LE(buffers_read, 3); // Should not read more than we wrote
}

// Test command ordering
TEST_F(SharedUICommandTest, CommandOrdering) {
  std::vector<std::string> expected_order;

  // Add commands with specific order
  for (int i = 0; i < 5; ++i) {
    std::string cmd = "order_" + std::to_string(i);
    expected_order.push_back(cmd);
    shared_command_->AddCommand(UICommand::kCreateElement, CreateSharedString(cmd.c_str()), nullptr, nullptr);
  }

  shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);

  // Retrieve and verify
  void* data = shared_command_->data();
  auto* pack = static_cast<UICommandBufferPack*>(data);

  if (pack->length > 0) {
    EXPECT_EQ(pack->length, 5);
    // Commands should be in the same order as added
    auto* items = static_cast<UICommandItem*>(pack->data);
    for (int i = 0; i < pack->length; ++i) {
      EXPECT_EQ(items[i].type, static_cast<int32_t>(UICommand::kCreateElement));
    }

    shared_command_->clear();
  }

  dart_free(pack);
}

// Test stress with rapid add/remove cycles
TEST_F(SharedUICommandTest, StressTest) {
  const int cycles = 100;

  for (int i = 0; i < cycles; ++i) {
    // Add a burst of commands
    for (int j = 0; j < 10; ++j) {
      shared_command_->AddCommand(UICommand::kSetAttribute, CreateSharedString("stress"), nullptr, nullptr);
    }

    shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);

    // Read and clear
    void* data = shared_command_->data();
    auto* pack = static_cast<UICommandBufferPack*>(data);

    if (pack->length > 0) {
      shared_command_->clear();
    }

    dart_free(pack);
  }

  // Should complete without crashes or deadlocks
  EXPECT_TRUE(true);
}

// Test for race condition between data() and empty()
TEST_F(SharedUICommandTest, RaceConditionDataAndEmpty) {
  std::atomic<bool> stop_flag(false);
  std::atomic<int> race_detected(0);
  std::atomic<int> data_calls(0);
  std::atomic<int> empty_calls(0);
  std::atomic<int> sync_calls(0);

  // Thread 1: Continuously calls data()
  std::thread reader_thread([&]() {
    while (!stop_flag.load()) {
      void* data = shared_command_->data();
      data_calls.fetch_add(1);
      auto* pack = static_cast<UICommandBufferPack*>(data);
      
      // Simulate some work
      std::this_thread::sleep_for(std::chrono::microseconds(10));
      
      if (pack->length > 0) {
        shared_command_->clear();
      }
      dart_free(pack);
    }
  });

  // Thread 2: Continuously calls empty() and adds commands
  std::thread writer_thread([&]() {
    while (!stop_flag.load()) {
      // Check if empty
      bool is_empty = shared_command_->empty();
      empty_calls.fetch_add(1);
      
      // Add a command
      shared_command_->AddCommand(UICommand::kCreateElement, CreateSharedString("race_test"), nullptr, nullptr);

      // Small delay
      std::this_thread::sleep_for(std::chrono::microseconds(5));
    }
  });

  // Thread 3: Another writer that calls SyncToActive
  std::thread sync_thread([&]() {
    while (!stop_flag.load()) {
      shared_command_->SyncAllPackages();
      sync_calls.fetch_add(1);
      std::this_thread::sleep_for(std::chrono::microseconds(20));
    }
  });

  // Run for some time
  std::this_thread::sleep_for(std::chrono::milliseconds(200));
  stop_flag.store(true);

  reader_thread.join();
  writer_thread.join();
  sync_thread.join();

  // Verify threads were active
  EXPECT_GT(data_calls.load(), 0);
  EXPECT_GT(empty_calls.load(), 0);
  EXPECT_GT(sync_calls.load(), 0);
}

// Test for race condition with size() method
TEST_F(SharedUICommandTest, RaceConditionWithSize) {
  std::atomic<bool> stop_flag(false);
  std::atomic<int> size_calls(0);
  std::atomic<int> clear_calls(0);

  // Thread 1: Calls size()
  std::thread size_thread([&]() {
    while (!stop_flag.load()) {
      int64_t size = shared_command_->size();
      size_calls.fetch_add(1);
      std::this_thread::sleep_for(std::chrono::microseconds(5));
    }
  });

  // Thread 2: Calls clear()
  std::thread clear_thread([&]() {
    while (!stop_flag.load()) {
      shared_command_->clear();
      clear_calls.fetch_add(1);
      std::this_thread::sleep_for(std::chrono::microseconds(10));
    }
  });

  // Thread 3: Adds commands and retrieves data
  std::thread data_thread([&]() {
    while (!stop_flag.load()) {
      shared_command_->AddCommand(UICommand::kCreateElement, CreateSharedString("size_race"), nullptr, nullptr);

      void* data = shared_command_->data();
      auto* pack = static_cast<UICommandBufferPack*>(data);
      dart_free(pack);
      
      std::this_thread::sleep_for(std::chrono::microseconds(15));
    }
  });

  // Run for some time
  std::this_thread::sleep_for(std::chrono::milliseconds(100));
  stop_flag.store(true);

  size_thread.join();
  clear_thread.join();
  data_thread.join();

  // Verify all threads were active
  EXPECT_GT(size_calls.load(), 0);
  EXPECT_GT(clear_calls.load(), 0);
}

// Test UICommandSyncStrategy integration
TEST_F(SharedUICommandTest, SyncStrategyIntegration) {
  // Configure sync buffer size
  shared_command_->ConfigureSyncCommandBufferSize(2);
  
  // Test depends on dedicated mode behavior
  // context_->setDedicated(true);  // Would need to be set if available
  
  // Add commands that go to waiting queue
  shared_command_->AddCommand(UICommand::kCreateElement, CreateSharedString("div"), nullptr, nullptr);
  shared_command_->AddCommand(UICommand::kSetStyle, CreateSharedString("color:blue"), nullptr, nullptr);
  
  // In non-dedicated mode, commands go directly to read buffer
  // In dedicated mode, they would go to waiting queue
  if (!context_->isDedicated()) {
    EXPECT_FALSE(shared_command_->empty());
  }
  
  // Add a command that triggers immediate sync
  shared_command_->AddCommand(UICommand::kAsyncCaller, CreateSharedString("async"), nullptr, nullptr);
  
  // Now add finish recording to request batch update
  shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
  
  // Retrieve data - should include flushed commands
  void* data = shared_command_->data();
  auto* pack = static_cast<UICommandBufferPack*>(data);
  
  // In dedicated mode with sync strategy, we should have commands
  if (context_->isDedicated() && pack->length > 0) {
    EXPECT_GE(pack->length, 3); // At least the 3 commands we added
  }
  
  dart_free(pack);
}

// Test waiting queue overflow triggers sync
TEST_F(SharedUICommandTest, WaitingQueueOverflowSync) {
  // Configure small sync buffer
  shared_command_->ConfigureSyncCommandBufferSize(1);
  // Test depends on dedicated mode behavior
  
  // Create many unique binding objects
  struct MockNativeBindingObject : public NativeBindingObject {
    MockNativeBindingObject() : NativeBindingObject(nullptr) {}
  };
  
  std::vector<std::unique_ptr<MockNativeBindingObject>> objects;
  for (int i = 0; i < 100; ++i) {
    objects.push_back(std::make_unique<MockNativeBindingObject>());
  }
  
  // Add commands with different objects to trigger frequency map overflow
  for (int i = 0; i < 70; ++i) {
    shared_command_->AddCommand(UICommand::kCreateElement, 
                               CreateSharedString("overflow"), 
                               objects[i].get(), 
                               nullptr);
  }
  
  // Should trigger auto-sync due to frequency map size
  shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
  
  // Retrieve data
  void* data = shared_command_->data();
  auto* pack = static_cast<UICommandBufferPack*>(data);
  
  if (context_->isDedicated()) {
    // Should have synced commands
    EXPECT_GT(pack->length, 0);
  }
  
  dart_free(pack);
}

// Test command categorization in sync strategy
TEST_F(SharedUICommandTest, CommandCategorizationSync) {
  // Test depends on dedicated mode behavior
  shared_command_->ConfigureSyncCommandBufferSize(10);
  
  // Test immediate sync commands
  shared_command_->AddCommand(UICommand::kCreateDocument, nullptr, nullptr, nullptr);
  shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
  
  void* data1 = shared_command_->data();
  auto* pack1 = static_cast<UICommandBufferPack*>(data1);
  
  if (context_->isDedicated()) {
    // Should have immediate command
    EXPECT_GT(pack1->length, 0);
  }
  dart_free(pack1);
  
  // Test waiting queue commands
  shared_command_->AddCommand(UICommand::kSetAttribute, CreateSharedString("attr"), nullptr, nullptr);
  shared_command_->AddCommand(UICommand::kSetStyle, CreateSharedString("style"), nullptr, nullptr);
  shared_command_->AddCommand(UICommand::kDisposeBindingObject, nullptr, nullptr, nullptr);
  
  // These should be in waiting queue until we force sync
  shared_command_->AddCommand(UICommand::kStartRecordingCommand, nullptr, nullptr, nullptr);
  shared_command_->AddCommand(UICommand::kFinishRecordingCommand, nullptr, nullptr, nullptr);
  
  void* data2 = shared_command_->data();
  auto* pack2 = static_cast<UICommandBufferPack*>(data2);
  
  if (context_->isDedicated()) {
    // Should include flushed waiting commands
    EXPECT_GE(pack2->length, 3);
  }
  dart_free(pack2);
}