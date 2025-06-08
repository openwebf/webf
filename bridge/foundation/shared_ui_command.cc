/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "shared_ui_command.h"
#include "core/dart_methods.h"
#include "core/executing_context.h"
#include "foundation/logging.h"
#include "foundation/ui_command_buffer.h"

namespace webf {

SharedUICommand::SharedUICommand(ExecutingContext* context)
    : context_(context),
      package_buffer_(std::make_unique<UICommandPackageRingBuffer>(context)),
      read_buffer_(std::make_unique<UICommandBuffer>(context)) {}

SharedUICommand::~SharedUICommand() = default;

void SharedUICommand::AddCommand(UICommand type,
                                 SharedNativeString* args_01,
                                 NativeBindingObject* native_binding_object,
                                 void* nativePtr2,
                                 bool request_ui_update) {
  // For non-dedicated contexts, add directly to read buffer
  if (!context_->isDedicated()) {
    std::lock_guard<std::mutex> lock(read_buffer_mutex_);
    read_buffer_->AddCommand(type, args_01, native_binding_object, nativePtr2, request_ui_update);

    if (type == UICommand::kFinishRecordingCommand && read_buffer_->size() > 0) {
      context_->dartMethodPtr()->requestBatchUpdate(false, context_->contextId());
    }
    return;
  }

  // For dedicated contexts, use the ring buffer
  package_buffer_->AddCommand(type, args_01, native_binding_object, nativePtr2, request_ui_update);
  total_commands_.fetch_add(1, std::memory_order_relaxed);

  // Request batch update on certain commands
  if (type == UICommand::kFinishRecordingCommand || type == UICommand::kAsyncCaller) {
    RequestBatchUpdate();
  }
}

void* SharedUICommand::data() {
  std::lock_guard<std::mutex> lock(read_buffer_mutex_);

  // Fill read buffer from ring buffer
  FillReadBuffer();

  // Create the UI command buffer pack for Dart
  auto* pack = (UICommandBufferPack*)dart_malloc(sizeof(UICommandBufferPack));
  pack->length = read_buffer_->size();
  pack->data = read_buffer_->data();
  pack->buffer_head = read_buffer_.release();

  // Create new read buffer
  read_buffer_ = std::make_unique<UICommandBuffer>(context_);

  return pack;
}

void SharedUICommand::clear() {
  std::lock_guard<std::mutex> lock(read_buffer_mutex_);
  read_buffer_->clear();
  package_buffer_->Clear();
}

bool SharedUICommand::empty() {
  if (!context_->isDedicated()) {
    std::lock_guard<std::mutex> lock(read_buffer_mutex_);
    return read_buffer_->empty();
  }

  return package_buffer_->Empty() && read_buffer_->empty();
}

int64_t SharedUICommand::size() {
  std::lock_guard<std::mutex> lock(read_buffer_mutex_);

  int64_t total_size = read_buffer_->size();

  // Count commands in packages
  if (context_->isDedicated()) {
    // This is an approximation - we'd need to iterate packages for exact count
    total_size += package_buffer_->PackageCount() * 100;  // Estimate 100 commands per package
  }

  return total_size;
}

void SharedUICommand::SyncToActive() {
  // No-op for compatibility - ring buffer handles synchronization automatically
  WEBF_LOG(VERBOSE) << "SyncToActive called - no-op in ring buffer implementation";
}

void SharedUICommand::SyncToReserve() {
  // No-op for compatibility - ring buffer handles synchronization automatically
  WEBF_LOG(VERBOSE) << "SyncToReserve called - no-op in ring buffer implementation";
}

void SharedUICommand::ConfigureSyncCommandBufferSize(size_t size) {
  // Could implement dynamic resizing if needed
  WEBF_LOG(VERBOSE) << "ConfigureSyncCommandBufferSize not implemented for ring buffer";
}

void SharedUICommand::FillReadBuffer() {
  if (!context_->isDedicated()) {
    return;
  }

  // Pop packages from ring buffer and add to read buffer
  while (auto package = package_buffer_->PopPackage()) {
    total_packages_.fetch_add(1, std::memory_order_relaxed);

    for (const auto& item : package->commands) {
      read_buffer_->addCommand(item, false);
    }
  }
}

void SharedUICommand::RequestBatchUpdate() {
  if (!package_buffer_->Empty()) {
    context_->dartMethodPtr()->requestBatchUpdate(true, context_->contextId());
  }
}

}  // namespace webf