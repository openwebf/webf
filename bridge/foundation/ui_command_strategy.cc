/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "ui_command_strategy.h"
#include <math.h>
#include <algorithm>
#include "core/binding_object.h"
#include "logging.h"
#include "shared_ui_command.h"

namespace webf {

static uint64_t set_nth_bit_to_zero(uint64_t source, size_t nth) {
  uint64_t bitmask = ~(1ULL << nth);
  return source & bitmask;
}

uint64_t WaitingStatus::MaxSize() {
  return 64 * storage.size();
}

void WaitingStatus::Reset() {
  for (auto& i : storage) {
    i = UINT64_MAX;
  }
}

bool WaitingStatus::IsFullActive() {
  return std::all_of(storage.begin(), storage.end(), [](uint64_t i) { return i == 0; });
}

void WaitingStatus::SetActiveAtIndex(uint64_t index) {
  double storage_index = floor(index / 64);

  if (storage_index < storage.size()) {
    storage[storage_index] = set_nth_bit_to_zero(storage[storage_index], index % 64);
  }
}

UICommandSyncStrategy::UICommandSyncStrategy(SharedUICommand* host) : host_(host) {}

void UICommandSyncStrategy::Reset() {
  waiting_status.Reset();
  frequency_map_.clear();
  waiting_commands_.clear();
}
void UICommandSyncStrategy::RecordUICommand(UICommand type,
                                            std::unique_ptr<SharedNativeString>&& args_01,
                                            NativeBindingObject* native_binding_object,
                                            void* native_ptr2,
                                            bool request_ui_update) {
  switch (type) {
    case UICommand::kStartRecordingCommand:
    case UICommand::kCreateDocument:
    case UICommand::kCreateWindow:
    case UICommand::kAsyncCaller:
    case UICommand::kRemoveAttribute: {
      SyncToRingBuffer();
      // Add command to ring buffer directly for immediate sync commands
      host_->package_buffer_->AddCommand(type, args_01.get(), native_binding_object, native_ptr2, request_ui_update);
      break;
    }
    case UICommand::kCreateElement:
    case UICommand::kCreateComment:
    case UICommand::kCreateTextNode:
    case UICommand::kCreateDocumentFragment:
    case UICommand::kCreateSVGElement:
    case UICommand::kCreateElementNS:
    case UICommand::kRemoveNode:
    case UICommand::kAddEvent:
    case UICommand::kCloneNode: {
      // Add this command to the waiting queue
      AddToWaitingQueue(type, std::move(args_01), native_binding_object, native_ptr2, request_ui_update);

      // Check this command based on the native_binding_object pointer
      RecordOperationForPointer(native_binding_object);
      SyncToRingBufferIfNecessary();

      break;
    }
    case UICommand::kSetStyle:
    case UICommand::kClearStyle:
    case UICommand::kSetAttribute:
    case UICommand::kSetProperty:
    case UICommand::kRemoveEvent:
    case UICommand::kDisposeBindingObject: {
      // Add this command to the waiting queue
      AddToWaitingQueue(type, std::move(args_01), native_binding_object, native_ptr2, request_ui_update);
      break;
    }
    case UICommand::kInsertAdjacentNode: {
      // Add this command to the waiting queue
      AddToWaitingQueue(type, std::move(args_01), native_binding_object, native_ptr2, request_ui_update);

      RecordOperationForPointer(native_binding_object);
      RecordOperationForPointer((NativeBindingObject*)native_ptr2);

      SyncToRingBufferIfNecessary();
      break;
    }
    case UICommand::kFinishRecordingCommand:
      break;
  }
}

void UICommandSyncStrategy::ConfigWaitingBufferSize(size_t size) {
  waiting_status.storage.reserve(size);
  for (int i = 0; i < size; i++) {
    waiting_status.storage.emplace_back(UINT64_MAX);
  }
}

void UICommandSyncStrategy::SyncToRingBuffer() {
  // Flush the waiting buffer to ring buffer
  FlushWaitingCommands();
  Reset();
}

void UICommandSyncStrategy::SyncToRingBufferIfNecessary() {
  if (frequency_map_.size() > waiting_status.MaxSize() && waiting_status.IsFullActive()) {
    SyncToRingBuffer();
  }
}

void UICommandSyncStrategy::RecordOperationForPointer(NativeBindingObject* ptr) {
  size_t index;
  if (frequency_map_.count(ptr) == 0) {
    index = frequency_map_.size();

    // Store the bit wise index for ptr.
    frequency_map_[ptr] = index;
  } else {
    index = frequency_map_[ptr];
  }

  // Update flag's nth bit wise to 0
  waiting_status.SetActiveAtIndex(index);

  SyncToRingBufferIfNecessary();
}

void UICommandSyncStrategy::AddToWaitingQueue(UICommand type,
                                              std::unique_ptr<SharedNativeString>&& args_01,
                                              NativeBindingObject* native_binding_object,
                                              void* native_ptr2,
                                              bool request_ui_update) {
  waiting_commands_.push_back({
    type,
    std::move(args_01),
    native_binding_object,
    native_ptr2,
    request_ui_update
  });
}

void UICommandSyncStrategy::FlushWaitingCommands() {
  // Flush all waiting commands to the ring buffer
  for (auto& cmd : waiting_commands_) {
    host_->package_buffer_->AddCommand(
      cmd.type,
      cmd.args_01.get(),
      cmd.native_binding_object,
      cmd.native_ptr2,
      cmd.request_ui_update
    );
  }
  waiting_commands_.clear();
}

}  // namespace webf
