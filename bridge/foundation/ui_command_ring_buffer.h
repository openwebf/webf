/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_FOUNDATION_UI_COMMAND_RING_BUFFER_H_
#define BRIDGE_FOUNDATION_UI_COMMAND_RING_BUFFER_H_

#include <atomic>
#include <memory>
#include <vector>
#include <condition_variable>
#include <mutex>
#include "foundation/ui_command_buffer.h"
#include "core/binding_object.h"

namespace webf {

class ExecutingContext;

// A thread-safe ring buffer designed for efficient UI command storage and retrieval
// between JS worker thread and Dart UI thread
class UICommandRingBuffer {
 public:
  static constexpr size_t kDefaultCapacity = 65536;  // 64K commands
  static constexpr size_t kMinCapacity = 1024;
  static constexpr size_t kMaxCapacity = 1048576;  // 1M commands
  
  explicit UICommandRingBuffer(size_t initial_capacity = kDefaultCapacity);
  ~UICommandRingBuffer();
  
  // Producer operations (JS thread)
  bool Push(const UICommandItem& item);
  bool PushBatch(const UICommandItem* items, size_t count);
  
  // Consumer operations (Dart thread)
  size_t PopBatch(UICommandItem* items, size_t max_count);
  
  // Utility methods
  size_t Size() const;
  bool Empty() const;
  bool Full() const;
  size_t Capacity() const;
  void Clear();
  
  // Dynamic resizing
  bool Resize(size_t new_capacity);
  
 private:
  // Internal implementation using lock-free atomic operations
  struct alignas(64) ProducerState {
    std::atomic<size_t> head{0};
    char padding[64 - sizeof(std::atomic<size_t>)];
  };
  
  struct alignas(64) ConsumerState {
    std::atomic<size_t> tail{0};
    char padding[64 - sizeof(std::atomic<size_t>)];
  };
  
  // Separate cache lines to avoid false sharing
  ProducerState producer_;
  ConsumerState consumer_;
  
  std::unique_ptr<UICommandItem[]> buffer_;
  size_t capacity_;
  size_t capacity_mask_;  // For fast modulo operation (capacity - 1)
  
  // Overflow buffer for when ring buffer is full
  std::mutex overflow_mutex_;
  std::vector<UICommandItem> overflow_buffer_;
  
  // Producer mutex for thread-safe multi-producer scenario
  std::mutex producer_mutex_;
  
  // Helper methods
  size_t NextIndex(size_t index) const { return (index + 1) & capacity_mask_; }
  bool IsPowerOfTwo(size_t n) const { return n && !(n & (n - 1)); }
};

// Command package for efficient batch transfer
struct UICommandPackage {
  uint32_t kind_mask{0};  // Bitmask of command types in this package
  std::vector<UICommandItem> commands;
  uint64_t sequence_number{0};  // For maintaining order across packages
  
  void AddCommand(const UICommandItem& item);
  bool ShouldSplit(UICommand next_command) const;
  void Clear();
};

// Package-based ring buffer for batched command transfer
class UICommandPackageRingBuffer {
 public:
  static constexpr size_t kDefaultPackageCapacity = 1024;  // Number of packages
  
  explicit UICommandPackageRingBuffer(ExecutingContext* context, size_t capacity = kDefaultPackageCapacity);
  ~UICommandPackageRingBuffer();
  
  // Producer operations
  void AddCommand(UICommand type,
                  SharedNativeString* args_01,
                  NativeBindingObject* native_binding_object,
                  void* nativePtr2,
                  bool request_ui_update = true);
  void FlushCurrentPackage();
  
  // Consumer operations
  std::unique_ptr<UICommandPackage> PopPackage();
  
  // Utility methods
  size_t PackageCount() const;
  bool Empty() const;
  bool HasUnflushedCommands() const;
  void Clear();

 private:
  ExecutingContext* context_;

  // Current package being built
  std::mutex current_package_mutex_;
  std::unique_ptr<UICommandPackage> current_package_;
  std::atomic<uint64_t> sequence_counter_{0};
  
  // Ring buffer of packages
  struct PackageSlot {
    std::atomic<bool> ready{false};
    std::unique_ptr<UICommandPackage> package;
  };
  
  std::unique_ptr<PackageSlot[]> packages_;
  size_t capacity_;
  size_t capacity_mask_;
  
  std::atomic<size_t> write_index_{0};
  std::atomic<size_t> read_index_{0};
  
  // Overflow handling
  std::mutex overflow_mutex_;
  std::vector<std::unique_ptr<UICommandPackage>> overflow_packages_;
  
  // Helper methods
  bool ShouldCreateNewPackage(UICommand command) const;
  void PushPackage(std::unique_ptr<UICommandPackage> package);
};

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_UI_COMMAND_RING_BUFFER_H_