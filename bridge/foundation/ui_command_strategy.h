/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_UI_COMMAND_STRATEGY_H
#define MULTI_THREADING_UI_COMMAND_STRATEGY_H

#include <array>
#include <unordered_map>
#include "foundation/ui_command_buffer.h"

namespace webf {

class SharedUICommand;
class SharedNativeString;
class NativeBindingObject;

struct WaitingStatus {
  std::array<uint64_t, 4> storage{UINT64_MAX, UINT64_MAX, UINT64_MAX, UINT64_MAX};

  uint64_t MaxSize();
  void Reset();
  bool IsFullActive();
  void SetActiveAtIndex(uint64_t index);
};

class UICommandSyncStrategy {
 public:
  UICommandSyncStrategy(SharedUICommand* shared_ui_command);

  bool ShouldSync();
  void Reset();
  void RecordUICommand(UICommand type,
                       std::unique_ptr<SharedNativeString>& args_01,
                       NativeBindingObject* native_ptr,
                       void* native_ptr2,
                       bool request_ui_update);

 private:
  void SyncToReserve();
  void SyncToReserveIfNecessary();
  void RecordOperationForPointer(NativeBindingObject* ptr);

  bool should_sync{false};
  SharedUICommand* host_;
  WaitingStatus waiting_status;
  std::unordered_map<void*, size_t> frequency_map_;
  friend class SharedUICommand;
};

}  // namespace webf

#endif  // MULTI_THREADING_UI_COMMAND_STRATEGY_H