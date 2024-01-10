/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <math.h>
#include "ui_command_strategy.h"
#include "shared_ui_command.h"
#include "logging.h"

namespace webf {

static uint64_t set_nth_bit_to_zero(uint64_t source, size_t nth) {
  uint64_t bitmask = ~(1ULL << nth);
  return source & bitmask;
}

uint64_t WaitingStatus::MaxSize() {
  return 64 * storage.size();
}

void WaitingStatus::Reset() {
  for(auto& i : storage) {
    i = UINT64_MAX;
  }
}

bool WaitingStatus::IsFullActive() {
  return std::all_of(storage.begin(), storage.end(), [](uint64_t i) { return i == 0; });
}

void WaitingStatus::SetActiveAtIndex(uint64_t index) {
  size_t storage_index = floor(index / 64);

  if (storage_index < storage.size()) {
    storage[storage_index] = set_nth_bit_to_zero(storage[storage_index], index % 64);
  }
}

UICommandSyncStrategy::UICommandSyncStrategy(SharedUICommand* host): host_(host) {}

bool UICommandSyncStrategy::ShouldSync() {
  return should_sync;
}

void UICommandSyncStrategy::Reset() {
  should_sync = false;
  waiting_status.Reset();
  frequency_map_.clear();
}
void UICommandSyncStrategy::RecordUICommand(UICommand type,
                                            std::unique_ptr<SharedNativeString>& args_01,
                                            void* native_ptr,
                                            void* native_ptr2,
                                            bool request_ui_update) {
  switch (type) {
    case UICommand::kStartRecordingCommand:
    case UICommand::kCreateDocument:
    case UICommand::kCreateWindow: {
      SyncToReserve();
      host_->reserve_buffer_->addCommand(type, std::move(args_01), native_ptr, native_ptr2, request_ui_update);
      break;
    }
    case UICommand::kCreateElement:
    case UICommand::kCreateComment:
    case UICommand::kCreateTextNode:
    case UICommand::kCreateDocumentFragment:
    case UICommand::kCreateSVGElement:
    case UICommand::kCreateElementNS:
    case UICommand::kRemoveNode:
    case UICommand::kCloneNode:
    case UICommand::kSetStyle:
    case UICommand::kClearStyle:
    case UICommand::kSetAttribute:
    case UICommand::kRemoveAttribute: {
      host_->waiting_buffer_->addCommand(type, std::move(args_01), native_ptr, native_ptr2, request_ui_update);

      RecordOperationForPointer(native_ptr);
      SyncToReserveIfNecessary();

      break;
    }
    case UICommand::kRemoveEvent:
    case UICommand::kAddEvent:
    case UICommand::kDisposeBindingObject: {
      host_->waiting_buffer_->addCommand(type, std::move(args_01), native_ptr, native_ptr2, request_ui_update);
      break;
    }
    case UICommand::kInsertAdjacentNode: {
      host_->waiting_buffer_->addCommand(type, std::move(args_01), native_ptr, native_ptr2, request_ui_update);

      RecordOperationForPointer(native_ptr);
      RecordOperationForPointer(native_ptr2);

      SyncToReserveIfNecessary();
      break;
    }
    case UICommand::kFinishRecordingCommand:
      break;
  }
}

void UICommandSyncStrategy::SyncToReserve() {
  host_->SyncToReserve();
  waiting_status.Reset();
  frequency_map_.clear();
  should_sync = true;
}

void UICommandSyncStrategy::SyncToReserveIfNecessary() {
  if (frequency_map_.size() > waiting_status.MaxSize() && waiting_status.IsFullActive()) {
    WEBF_LOG(VERBOSE) << "SYNC TO RESERVE";
    SyncToReserve();
  }
}

void UICommandSyncStrategy::RecordOperationForPointer(void* ptr) {
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

  SyncToReserveIfNecessary();
}

}  // namespace webf