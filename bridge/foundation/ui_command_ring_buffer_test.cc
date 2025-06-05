/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "foundation/ui_command_ring_buffer.h"
#include "gtest/gtest.h"
#include <thread>
#include <chrono>
#include <atomic>
#include <vector>

namespace webf {

class UICommandRingBufferTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Setup code
  }
  
  void TearDown() override {
    // Cleanup code
  }
};

// Test basic push and pop operations
TEST_F(UICommandRingBufferTest, BasicPushPop) {
  UICommandRingBuffer buffer(1024);
  
  // Test single push/pop
  UICommandItem item1(static_cast<int32_t>(UICommand::kCreateElement), nullptr, nullptr, nullptr);
  EXPECT_TRUE(buffer.Push(item1));
  EXPECT_EQ(buffer.Size(), 1);
  EXPECT_FALSE(buffer.Empty());
  
  UICommandItem result[1];
  size_t popped = buffer.PopBatch(result, 1);
  EXPECT_EQ(popped, 1);
  EXPECT_EQ(result[0].type, item1.type);
  EXPECT_TRUE(buffer.Empty());
}

// Test batch operations
TEST_F(UICommandRingBufferTest, BatchOperations) {
  UICommandRingBuffer buffer(1024);
  
  // Create batch of commands
  std::vector<UICommandItem> items;
  for (int i = 0; i < 100; i++) {
    items.emplace_back(i, nullptr, nullptr, nullptr);
  }
  
  // Push batch
  EXPECT_TRUE(buffer.PushBatch(items.data(), items.size()));
  EXPECT_EQ(buffer.Size(), 100);
  
  // Pop batch
  UICommandItem results[100];
  size_t popped = buffer.PopBatch(results, 100);
  EXPECT_EQ(popped, 100);
  
  // Verify order preserved
  for (int i = 0; i < 100; i++) {
    EXPECT_EQ(results[i].type, i);
  }
}

// Test overflow handling
TEST_F(UICommandRingBufferTest, OverflowHandling) {
  UICommandRingBuffer buffer(16);  // Small buffer to test overflow
  
  // Push more items than capacity
  std::vector<UICommandItem> items;
  for (int i = 0; i < 100; i++) {
    items.emplace_back(i, nullptr, nullptr, nullptr);
  }
  
  EXPECT_TRUE(buffer.PushBatch(items.data(), items.size()));
  EXPECT_EQ(buffer.Size(), 100);
  
  // Pop all items
  UICommandItem results[100];
  size_t popped = buffer.PopBatch(results, 100);
  EXPECT_EQ(popped, 100);
  
  // Verify all items preserved in order
  for (int i = 0; i < 100; i++) {
    EXPECT_EQ(results[i].type, i);
  }
}

// Test concurrent producer/consumer
TEST_F(UICommandRingBufferTest, ConcurrentProducerConsumer) {
  UICommandRingBuffer buffer(1024);
  std::atomic<int> total_produced(0);
  std::atomic<int> total_consumed(0);
  std::atomic<bool> stop_flag(false);
  
  // Producer thread
  std::thread producer([&]() {
    int count = 0;
    while (count < 10000) {
      UICommandItem item(count, nullptr, nullptr, nullptr);
      if (buffer.Push(item)) {
        total_produced.fetch_add(1);
        count++;
      }
    }
  });
  
  // Consumer thread
  std::thread consumer([&]() {
    UICommandItem items[100];
    while (total_consumed.load() < 10000) {
      size_t popped = buffer.PopBatch(items, 100);
      total_consumed.fetch_add(popped);
      
      // Small delay to simulate processing
      if (popped == 0) {
        std::this_thread::sleep_for(std::chrono::microseconds(10));
      }
    }
  });
  
  producer.join();
  consumer.join();
  
  EXPECT_EQ(total_produced.load(), 10000);
  EXPECT_EQ(total_consumed.load(), 10000);
  EXPECT_TRUE(buffer.Empty());
}

// Test multiple producers
TEST_F(UICommandRingBufferTest, MultipleProducers) {
  UICommandRingBuffer buffer(4096);
  std::atomic<int> total_produced(0);
  const int num_producers = 4;
  const int items_per_producer = 2500;
  
  std::vector<std::thread> producers;
  for (int i = 0; i < num_producers; i++) {
    producers.emplace_back([&, producer_id = i]() {
      for (int j = 0; j < items_per_producer; j++) {
        UICommandItem item(producer_id * 10000 + j, nullptr, nullptr, nullptr);
        buffer.Push(item);  // Push always returns true
        total_produced.fetch_add(1);
      }
    });
  }
  
  // Wait for all producers
  for (auto& producer : producers) {
    producer.join();
  }
  
  EXPECT_EQ(total_produced.load(), num_producers * items_per_producer);
  EXPECT_EQ(buffer.Size(), num_producers * items_per_producer);
}

// Test package-based ring buffer
TEST_F(UICommandRingBufferTest, PackageBasedBuffer) {
  // Note: This test is disabled as it requires a proper ExecutingContext
  // In production, the UICommandPackageRingBuffer would be created with a valid context
  GTEST_SKIP() << "Requires proper ExecutingContext setup";
}

// Test command batching strategy
TEST_F(UICommandRingBufferTest, CommandBatchingStrategy) {
  UICommandPackage package;
  
  // Test node creation commands stay together
  package.AddCommand(UICommandItem(static_cast<int32_t>(UICommand::kCreateElement), nullptr, nullptr, nullptr));
  package.AddCommand(UICommandItem(static_cast<int32_t>(UICommand::kCreateTextNode), nullptr, nullptr, nullptr));
  EXPECT_FALSE(package.ShouldSplit(UICommand::kCreateComment));
  
  // Test split on node mutation after creation
  EXPECT_TRUE(package.ShouldSplit(UICommand::kInsertAdjacentNode));
  
  // Test split on special commands
  package.Clear();
  package.AddCommand(UICommandItem(static_cast<int32_t>(UICommand::kSetStyle), nullptr, nullptr, nullptr));
  EXPECT_TRUE(package.ShouldSplit(UICommand::kStartRecordingCommand));
  EXPECT_TRUE(package.ShouldSplit(UICommand::kFinishRecordingCommand));
  EXPECT_TRUE(package.ShouldSplit(UICommand::kAsyncCaller));
}

// Test SharedUICommandRingBuffer integration
TEST_F(UICommandRingBufferTest, SharedUICommandIntegration) {
  // Note: This test is disabled as it requires a proper ExecutingContext
  // In production, the SharedUICommandRingBuffer would be created with a valid context
  GTEST_SKIP() << "Requires proper ExecutingContext setup";
}

// Stress test with high volume
TEST_F(UICommandRingBufferTest, StressTestHighVolume) {
  UICommandRingBuffer buffer(65536);
  const int total_commands = 1000000;  // 1 million commands
  std::atomic<bool> producer_done(false);
  std::atomic<int> consumed(0);
  
  // Producer thread - simulate JS worker pushing commands rapidly
  std::thread producer([&]() {
    for (int i = 0; i < total_commands; i++) {
      UICommandItem item(i % 100, nullptr, nullptr, nullptr);
      while (!buffer.Push(item)) {
        // In real implementation, this would expand buffer or wait
        std::this_thread::yield();
      }
    }
    producer_done.store(true);
  });
  
  // Consumer thread - simulate Dart reading commands
  std::thread consumer([&]() {
    UICommandItem items[1000];
    while (consumed.load() < total_commands) {
      size_t popped = buffer.PopBatch(items, 1000);
      consumed.fetch_add(popped);
      
      // Simulate processing time
      if (popped > 0) {
        std::this_thread::sleep_for(std::chrono::microseconds(popped));
      }
    }
  });
  
  producer.join();
  consumer.join();
  
  EXPECT_EQ(consumed.load(), total_commands);
  EXPECT_TRUE(buffer.Empty());
}

}  // namespace webf