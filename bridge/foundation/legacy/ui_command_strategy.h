/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef LEGACY_MULTI_THREADING_UI_COMMAND_STRATEGY_H
#define LEGACY_MULTI_THREADING_UI_COMMAND_STRATEGY_H

#include <unordered_map>
#include <vector>
#include "foundation/ui_command_buffer.h"
#include "foundation/ui_command_strategy.h"

namespace webf {

class LegacySharedUICommand;
struct SharedNativeString;
struct NativeBindingObject;

class LegacyUICommandSyncStrategy {
 public:
  LegacyUICommandSyncStrategy(LegacySharedUICommand* shared_ui_command);

  bool ShouldSync();
  void Reset();
  void RecordUICommand(UICommand type,
                       SharedNativeString* args_01,
                       NativeBindingObject* native_ptr,
                       void* native_ptr2,
                       bool request_ui_update);
  void ConfigWaitingBufferSize(size_t size);

 private:
  void SyncToReserve();
  void SyncToReserveIfNecessary();
  void RecordOperationForPointer(NativeBindingObject* ptr);

  bool should_sync{false};
  LegacySharedUICommand* host_;
  WaitingStatus waiting_status;
  size_t sync_buffer_size_;
  std::unordered_map<void*, size_t> frequency_map_;
  friend class LegacySharedUICommand;
};

}  // namespace webf

#endif  // LEGACY_MULTI_THREADING_UI_COMMAND_STRATEGY_H