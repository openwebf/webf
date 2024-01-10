/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef MULTI_THREADING_UI_COMMAND_STRATEGY_H
#define MULTI_THREADING_UI_COMMAND_STRATEGY_H

#include <unordered_map>
#include "foundation/ui_command_buffer.h"

namespace webf {

class SharedUICommand;
class SharedNativeString;

class UICommandSyncStrategy {
 public:
  UICommandSyncStrategy(SharedUICommand* shared_ui_command);

  bool ShouldSync();
  void Reset();
  void RecordUICommand(UICommand type,
                       std::unique_ptr<SharedNativeString>& args_01,
                       void* native_ptr,
                       void* native_ptr2,
                       bool request_ui_update);

 private:

  void SyncToReserve();
  void SyncToReserveIfNecessary();
  void RecordOperationForPointer(void* ptr);

  bool should_sync{false};
  SharedUICommand* host_;
  uint64_t waiting_status{UINT64_MAX};
  std::unordered_map<void*, size_t> frequency_map_;
  friend class SharedUICommand;
};

}

#endif // MULTI_THREADING_UI_COMMAND_STRATEGY_H