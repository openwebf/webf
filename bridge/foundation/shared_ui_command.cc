/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "shared_ui_command.h"
#include <atomic>
#include <memory>
#include "core/dart_methods.h"
#include "core/executing_context.h"
#include "foundation/logging.h"
#include "foundation/ui_command_buffer.h"
#include "foundation/native_type.h"
#include "foundation/string/atomic_string.h"
#include "bindings/qjs/native_string_utils.h"

namespace webf {

SharedUICommand::SharedUICommand(ExecutingContext* context)
    : context_(context),
      package_buffer_(std::make_unique<UICommandPackageRingBuffer>(context)),
      read_buffer_(std::make_unique<UICommandBuffer>(context)),
      ui_command_sync_strategy_(std::make_unique<UICommandSyncStrategy>(this)) {}

SharedUICommand::~SharedUICommand() = default;

void SharedUICommand::ConfigureSyncCommandBufferSize(size_t size) {
  ui_command_sync_strategy_->ConfigWaitingBufferSize(size);
}

void SharedUICommand::AddCommand(UICommand type,
                                 std::unique_ptr<SharedNativeString>&& args_01,
                                 void* native_binding_object,
                                 void* nativePtr2,
                                 bool request_ui_update) {
  if (type == UICommand::kFinishRecordingCommand) {
    context_->MaybeUpdateStyleForFirstPaint();
  }

  // For non-dedicated contexts, add directly to read buffer
  if (!context_->isDedicated()) {
    std::lock_guard<std::mutex> lock(read_buffer_mutex_);
    read_buffer_->AddCommand(type, args_01.get(), native_binding_object, nativePtr2, request_ui_update);

    if (type == UICommand::kFinishRecordingCommand && read_buffer_->size() > 0) {
      context_->dartMethodPtr()->requestBatchUpdate(false, context_->contextId());
    }
    return;
  }

  // For dedicated contexts, use the sync strategy to handle commands
  // The sync strategy will determine whether to add to waiting queue or flush to ring buffer
  if (type == UICommand::kFinishRecordingCommand) {
    // Calculate if we should request batch update based on waiting commands and ring buffer state
    bool should_request_batch_update =
        ui_command_sync_strategy_->GetWaitingCommandsCount() > 0 || package_buffer_->HasUnflushedCommands() ||
        package_buffer_->HasDeferredPackages() || package_buffer_->PackageCount() > 0;

    if (!context_->needs_first_paint_style_sync_) {
      package_buffer_->FlushDeferredPackages();
    }

    // Flush all waiting ui commands to ring buffer
    ui_command_sync_strategy_->FlushWaitingCommands();

    // Flush current package if it has commands
    if (package_buffer_->HasUnflushedCommands()) {
      package_buffer_->FlushCurrentPackage();
    }

    if (should_request_batch_update) {
      context_->dartMethodPtr()->requestBatchUpdate(true, context_->contextId());
    }
  }

  ui_command_sync_strategy_->RecordUICommand(type, std::move(args_01), native_binding_object, nativePtr2,
                                             request_ui_update);
}

void SharedUICommand::AddStyleByIdCommand(void* native_binding_object,
                                         int32_t property_id,
                                         int64_t value_slot,
                                         SharedNativeString* base_href,
                                         bool request_ui_update) {
  if (!context_->isDedicated()) {
    std::lock_guard<std::mutex> lock(read_buffer_mutex_);
    read_buffer_->AddStyleByIdCommand(native_binding_object, property_id, value_slot, base_href, request_ui_update);
    return;
  }

  UICommandItem item{};
  item.type = static_cast<int32_t>(UICommand::kSetStyleById);
  item.args_01_length = property_id;
  item.string_01 = value_slot;
  item.nativePtr = static_cast<int64_t>(reinterpret_cast<intptr_t>(native_binding_object));
  item.nativePtr2 = static_cast<int64_t>(reinterpret_cast<intptr_t>(base_href));
  ui_command_sync_strategy_->RecordStyleByIdCommand(item, request_ui_update);
}

void SharedUICommand::AddSheetStyleByIdCommand(void* native_binding_object,
                                              int32_t property_id,
                                              int64_t value_slot,
                                              SharedNativeString* base_href,
                                              bool important,
                                              bool request_ui_update) {
  if (!context_->isDedicated()) {
    std::lock_guard<std::mutex> lock(read_buffer_mutex_);
    read_buffer_->AddSheetStyleByIdCommand(native_binding_object, property_id, value_slot, base_href, important,
                                          request_ui_update);
    return;
  }

  UICommandItem item{};
  item.type = static_cast<int32_t>(UICommand::kSetSheetStyleById);
  uint32_t encoded_property_id =
      static_cast<uint32_t>(property_id) | (important ? 0x80000000u : 0u);
  item.args_01_length = static_cast<int32_t>(encoded_property_id);
  item.string_01 = value_slot;
  item.nativePtr = static_cast<int64_t>(reinterpret_cast<intptr_t>(native_binding_object));
  item.nativePtr2 = static_cast<int64_t>(reinterpret_cast<intptr_t>(base_href));
  ui_command_sync_strategy_->RecordStyleByIdCommand(item, request_ui_update);
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

  std::lock_guard<std::mutex> lock(read_buffer_mutex_);
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

void SharedUICommand::SyncAllPackages() {
  // First flush waiting commands from UICommandStrategy to ring buffer
  ui_command_sync_strategy_->FlushWaitingCommands();
  package_buffer_->FlushCurrentPackage();
  if (!context_->needs_first_paint_style_sync_) {
    package_buffer_->FlushDeferredPackages();
  }
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

}  // namespace webf
