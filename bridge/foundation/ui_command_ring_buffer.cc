/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "ui_command_ring_buffer.h"
#include <algorithm>
#include <cstring>
#include "core/executing_context.h"
#include "foundation/logging.h"
#include "bindings/qjs/native_string_utils.h"

namespace webf {

static size_t RoundUpToPowerOfTwo(size_t n) {
  if (n <= 1) return 1;

  n--;
  n |= n >> 1;
  n |= n >> 2;
  n |= n >> 4;
  n |= n >> 8;
  n |= n >> 16;
  if (sizeof(size_t) > 4) {
    n |= n >> 32;
  }
  n++;

  return n;
}

// UICommandRingBuffer implementation

UICommandRingBuffer::UICommandRingBuffer(size_t initial_capacity) {
  // Ensure capacity is power of 2 for fast modulo operation
  capacity_ = RoundUpToPowerOfTwo(std::clamp(initial_capacity, kMinCapacity, kMaxCapacity));
  capacity_mask_ = capacity_ - 1;
  buffer_ = std::make_unique<UICommandItem[]>(capacity_);
}

UICommandRingBuffer::~UICommandRingBuffer() = default;

bool UICommandRingBuffer::Push(const UICommandItem& item) {
  // Use producer mutex for simplicity and correctness with multiple producers
  std::lock_guard<std::mutex> lock(producer_mutex_);
  
  size_t current_head = producer_.head.load(std::memory_order_relaxed);
  size_t next_head = NextIndex(current_head);
  
  // Check if buffer is full
  if (next_head == consumer_.tail.load(std::memory_order_acquire)) {
    // Buffer is full, use overflow buffer
    std::lock_guard<std::mutex> overflow_lock(overflow_mutex_);
    overflow_buffer_.push_back(item);
    return true;
  }
  
  // Write item to buffer
  buffer_[current_head] = item;
  
  // Update head with release semantics to ensure write is visible
  producer_.head.store(next_head, std::memory_order_release);
  return true;
}

bool UICommandRingBuffer::PushBatch(const UICommandItem* items, size_t count) {
  if (!items || count == 0) return false;
  
  // For batch operations, just use Push for each item to ensure thread safety
  // This is less efficient but ensures correctness with multiple producers
  for (size_t i = 0; i < count; ++i) {
    Push(items[i]);
  }
  
  return true;
}

size_t UICommandRingBuffer::PopBatch(UICommandItem* items, size_t max_count) {
  if (!items || max_count == 0) return 0;
  
  size_t count = 0;
  
  // First, drain overflow buffer if any
  {
    std::lock_guard<std::mutex> lock(overflow_mutex_);
    if (!overflow_buffer_.empty()) {
      size_t overflow_count = std::min(max_count, overflow_buffer_.size());
      std::memcpy(items, overflow_buffer_.data(), overflow_count * sizeof(UICommandItem));
      overflow_buffer_.erase(overflow_buffer_.begin(), overflow_buffer_.begin() + overflow_count);
      count = overflow_count;
      items += overflow_count;
      max_count -= overflow_count;
    }
  }
  
  if (max_count == 0) return count;
  
  // Then drain ring buffer
  size_t current_tail = consumer_.tail.load(std::memory_order_relaxed);
  size_t current_head = producer_.head.load(std::memory_order_acquire);
  
  size_t ring_count = 0;
  while (current_tail != current_head && max_count > 0) {
    items[ring_count++] = buffer_[current_tail];
    current_tail = NextIndex(current_tail);
    max_count--;
  }
  
  consumer_.tail.store(current_tail, std::memory_order_release);
  return count + ring_count;
}

size_t UICommandRingBuffer::Size() const {
  size_t head = producer_.head.load(std::memory_order_acquire);
  size_t tail = consumer_.tail.load(std::memory_order_acquire);
  size_t ring_size = (head - tail) & capacity_mask_;
  
  std::lock_guard<std::mutex> lock(const_cast<std::mutex&>(overflow_mutex_));
  return ring_size + overflow_buffer_.size();
}

bool UICommandRingBuffer::Empty() const {
  return Size() == 0;
}

bool UICommandRingBuffer::Full() const {
  size_t head = producer_.head.load(std::memory_order_relaxed);
  size_t tail = consumer_.tail.load(std::memory_order_acquire);
  return NextIndex(head) == tail;
}

size_t UICommandRingBuffer::Capacity() const {
  return capacity_;
}

void UICommandRingBuffer::Clear() {
  std::lock_guard<std::mutex> producer_lock(producer_mutex_);
  
  producer_.head.store(0, std::memory_order_release);
  consumer_.tail.store(0, std::memory_order_release);
  
  std::lock_guard<std::mutex> overflow_lock(overflow_mutex_);
  overflow_buffer_.clear();
}

bool UICommandRingBuffer::Resize(size_t new_capacity) {
  // Validate new capacity
  new_capacity = RoundUpToPowerOfTwo(std::clamp(new_capacity, kMinCapacity, kMaxCapacity));
  if (new_capacity == capacity_) {
    return true;  // Already at requested size
  }
  
  // Lock both producer and consumer to ensure no concurrent access
  std::lock_guard<std::mutex> producer_lock(producer_mutex_);
  
  // Get current state
  size_t current_head = producer_.head.load(std::memory_order_relaxed);
  size_t current_tail = consumer_.tail.load(std::memory_order_relaxed);
  size_t current_size = (current_head - current_tail) & capacity_mask_;
  
  // Check if new capacity can hold current data
  if (new_capacity < current_size) {
    return false;  // Cannot resize smaller than current data
  }
  
  // Create new buffer
  auto new_buffer = std::make_unique<UICommandItem[]>(new_capacity);
  size_t new_capacity_mask = new_capacity - 1;
  
  // Copy existing data to new buffer
  size_t new_index = 0;
  size_t old_index = current_tail;
  while (old_index != current_head) {
    new_buffer[new_index] = buffer_[old_index];
    old_index = (old_index + 1) & capacity_mask_;
    new_index++;
  }
  
  // Update buffer and metadata
  buffer_ = std::move(new_buffer);
  capacity_ = new_capacity;
  capacity_mask_ = new_capacity_mask;
  
  // Reset indices
  consumer_.tail.store(0, std::memory_order_release);
  producer_.head.store(new_index, std::memory_order_release);
  
  return true;
}

// UICommandPackage implementation

void UICommandPackage::AddCommand(const UICommandItem& item) {
  commands.push_back(item);
  UICommandKind kind = GetKindFromUICommand(static_cast<UICommand>(item.type));
  kind_mask |= static_cast<uint32_t>(kind);
}

bool UICommandPackage::ShouldSplit(UICommand next_command) const {
  // Split package based on command type strategy
  UICommandKind next_kind = GetKindFromUICommand(next_command);
  
  // Always split on certain commands
  switch (next_command) {
    case UICommand::kStartRecordingCommand:
    case UICommand::kFinishRecordingCommand:
    case UICommand::kAsyncCaller:
      return true;
    default:
      break;
  }
  
  // Split if mixing incompatible command types
  if ((kind_mask & static_cast<uint32_t>(UICommandKind::kNodeCreation)) && 
      (static_cast<uint32_t>(next_kind) & static_cast<uint32_t>(UICommandKind::kNodeMutation))) {
    return true;
  }
  
  // Split if package is getting too large
  if (commands.size() >= 1000) {
    return true;
  }
  
  return false;
}

void UICommandPackage::Clear() {
  kind_mask = 0;
  commands.clear();
  sequence_number = 0;
}

// UICommandPackageRingBuffer implementation

UICommandPackageRingBuffer::UICommandPackageRingBuffer(ExecutingContext* context, size_t capacity)
    : context_(context) {
  capacity_ = RoundUpToPowerOfTwo(capacity);
  capacity_mask_ = capacity_ - 1;
  packages_ = std::make_unique<PackageSlot[]>(capacity_);
  current_package_ = std::make_unique<UICommandPackage>();
}

UICommandPackageRingBuffer::~UICommandPackageRingBuffer() = default;

void UICommandPackageRingBuffer::AddCommand(UICommand type,
                                           SharedNativeString* args_01,
                                           NativeBindingObject* native_binding_object,
                                           void* nativePtr2,
                                           bool request_ui_update) {
  UICommandItem item(static_cast<int32_t>(type), args_01, native_binding_object, nativePtr2);
  
  std::lock_guard<std::mutex> lock(current_package_mutex_);
  
  // Check if we need to create a new package
  if (!current_package_->commands.empty() && current_package_->ShouldSplit(type)) {
    FlushCurrentPackage();
  }

  current_package_->AddCommand(item);

  // Auto-flush on certain commands
  if (type == UICommand::kFinishRecordingCommand || type == UICommand::kAsyncCaller) {
    FlushCurrentPackage();
  }
}

void UICommandPackageRingBuffer::FlushCurrentPackage() {
  if (current_package_->commands.empty()) {
    return;
  }
  
  current_package_->sequence_number = sequence_counter_.fetch_add(1, std::memory_order_relaxed);
  
  auto package = std::move(current_package_);
  current_package_ = std::make_unique<UICommandPackage>();
  
  PushPackage(std::move(package));
}

void UICommandPackageRingBuffer::PushPackage(std::unique_ptr<UICommandPackage> package) {
  size_t write_idx = write_index_.load(std::memory_order_relaxed);
  size_t next_write_idx = (write_idx + 1) & capacity_mask_;
  
  // Check if buffer is full
  if (next_write_idx == read_index_.load(std::memory_order_acquire)) {
    // Buffer full, use overflow
    std::lock_guard<std::mutex> lock(overflow_mutex_);
    WEBF_LOG(VERBOSE) << " PUSH PACKAGE TO OVERFLOW " << package.get();
    overflow_packages_.push_back(std::move(package));
    return;
  }
  
  // Write package
  packages_[write_idx].package = std::move(package);
  packages_[write_idx].ready.store(true, std::memory_order_release);
  
  // Update write index
  write_index_.store(next_write_idx, std::memory_order_release);
}

std::unique_ptr<UICommandPackage> UICommandPackageRingBuffer::PopPackage() {
  // First check overflow
  {
    std::lock_guard<std::mutex> lock(overflow_mutex_);
    if (!overflow_packages_.empty()) {
      auto package = std::move(overflow_packages_.front());
      WEBF_LOG(VERBOSE) << " POP OVERFLOW PACKAGE " << package.get();
      overflow_packages_.erase(overflow_packages_.begin());
      return package;
    }
  }
  
  // Then check ring buffer
  size_t read_idx = read_index_.load(std::memory_order_relaxed);
  
  if (!packages_[read_idx].ready.load(std::memory_order_acquire)) {
    return nullptr;  // No package available
  }
  
  auto package = std::move(packages_[read_idx].package);
  packages_[read_idx].ready.store(false, std::memory_order_release);
  
  // Update read index
  size_t next_read_idx = (read_idx + 1) & capacity_mask_;
  read_index_.store(next_read_idx, std::memory_order_release);
  
  return package;
}

size_t UICommandPackageRingBuffer::PackageCount() const {
  size_t write_idx = write_index_.load(std::memory_order_acquire);
  size_t read_idx = read_index_.load(std::memory_order_acquire);
  size_t ring_count = (write_idx - read_idx) & capacity_mask_;
  
  std::lock_guard<std::mutex> lock(const_cast<std::mutex&>(overflow_mutex_));
  return ring_count + overflow_packages_.size();
}

bool UICommandPackageRingBuffer::Empty() const {
  // Check if there are any packages in the ring buffer or overflow
  if (PackageCount() > 0) {
    return false;
  }
  
  // Also check if current package has any commands
  std::lock_guard<std::mutex> lock(const_cast<std::mutex&>(current_package_mutex_));
  return current_package_->commands.empty();
}

bool UICommandPackageRingBuffer::HasUnflushedCommands() const {
  std::lock_guard<std::mutex> lock(const_cast<std::mutex&>(current_package_mutex_));
  return !current_package_->commands.empty();
}

void UICommandPackageRingBuffer::Clear() {
  write_index_.store(0, std::memory_order_relaxed);
  read_index_.store(0, std::memory_order_relaxed);
  
  for (size_t i = 0; i < capacity_; ++i) {
    packages_[i].ready.store(false, std::memory_order_relaxed);
    packages_[i].package.reset();
  }
  
  std::lock_guard<std::mutex> lock(overflow_mutex_);
  overflow_packages_.clear();
  
  std::lock_guard<std::mutex> pkg_lock(current_package_mutex_);
  current_package_->Clear();
}

bool UICommandPackageRingBuffer::ShouldCreateNewPackage(UICommand command) const {
  return current_package_->ShouldSplit(command);
}

}  // namespace webf