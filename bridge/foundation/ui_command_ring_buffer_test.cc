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

// Genuinely exercise the overflow path. kMinCapacity clamps small requests up to
// 1024, so the named-but-misleading OverflowHandling test above never actually
// overflows. Pushing well past 1024 forces items into the overflow buffer and
// guards against the FIFO violation where overflow was drained before the ring.
TEST_F(UICommandRingBufferTest, OverflowPreservesFifoOrder) {
  const int kTotal = 3000;  // > kMinCapacity (1024) so overflow is used
  UICommandRingBuffer buffer(1024);

  for (int i = 0; i < kTotal; i++) {
    UICommandItem item(i, nullptr, nullptr, nullptr);
    buffer.Push(item);
  }
  EXPECT_EQ(buffer.Size(), static_cast<size_t>(kTotal));

  std::vector<int> drained;
  UICommandItem out[256];
  while (true) {
    size_t n = buffer.PopBatch(out, 256);
    if (n == 0) break;
    for (size_t j = 0; j < n; j++) drained.push_back(out[j].type);
  }

  ASSERT_EQ(drained.size(), static_cast<size_t>(kTotal));
  for (int i = 0; i < kTotal; i++) {
    EXPECT_EQ(drained[i], i) << "overflow reordered at index " << i;
  }
}

// Interleaving pops and pushes is the case that the simple "drain ring then
// overflow" rule alone cannot satisfy: once the ring drains below full while the
// overflow still holds older items, a new push must stay in overflow (sticky) to
// keep global FIFO order.
TEST_F(UICommandRingBufferTest, OverflowInterleavedPreservesFifoOrder) {
  UICommandRingBuffer buffer(1024);  // capacity 1024 -> holds 1023 before overflow
  int next_push = 0;
  std::vector<int> drained;
  UICommandItem out[2048];  // must be >= the largest max_count passed to PopBatch below

  auto push_n = [&](int n) {
    for (int i = 0; i < n; i++) {
      UICommandItem item(next_push++, nullptr, nullptr, nullptr);
      buffer.Push(item);
    }
  };
  auto pop_n = [&](size_t n) {
    size_t got = buffer.PopBatch(out, n);
    for (size_t j = 0; j < got; j++) drained.push_back(out[j].type);
  };

  push_n(1100);  // fills the ring and spills the remainder into overflow
  pop_n(500);    // drains from the ring head (oldest)
  push_n(200);   // overflow is non-empty -> these must stick to overflow

  // Drain everything that remains.
  while (true) {
    size_t before = drained.size();
    pop_n(256);
    if (drained.size() == before) break;
  }

  ASSERT_EQ(drained.size(), static_cast<size_t>(next_push));
  for (int i = 0; i < next_push; i++) {
    EXPECT_EQ(drained[i], i) << "interleaved overflow reordered at index " << i;
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