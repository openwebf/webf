/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef MULTI_THREADING_UI_COMMAND_STRATEGY_H
#define MULTI_THREADING_UI_COMMAND_STRATEGY_H

#include <unordered_map>
#include <vector>
#include "foundation/ui_command_buffer.h"

namespace webf {

class SharedUICommand;
struct SharedNativeString;
struct NativeBindingObject;

struct WaitingStatus {
 std::vector<uint64_t> storage;
 uint64_t MaxSize();
 void Reset();
 bool IsFullActive();
 void SetActiveAtIndex(uint64_t index);
};

class UICommandSyncStrategy {
public:
 UICommandSyncStrategy(SharedUICommand* shared_ui_command);

 void Reset();
 void RecordUICommand(UICommand type,
                      std::unique_ptr<SharedNativeString>&& args_01,
                      NativeBindingObject* native_ptr,
                      void* native_ptr2,
                      bool request_ui_update);
 void ConfigWaitingBufferSize(size_t size);
 size_t GetWaitingCommandsCount() const { return waiting_commands_.size(); }
 void FlushWaitingCommands();

private:
 void SyncToRingBuffer();
 void SyncToRingBufferIfNecessary();
 void RecordOperationForPointer(NativeBindingObject* ptr);
 void AddToWaitingQueue(UICommand type,
                       std::unique_ptr<SharedNativeString>&& args_01,
                       NativeBindingObject* native_binding_object,
                       void* native_ptr2,
                       bool request_ui_update);

 SharedUICommand* host_;
 WaitingStatus waiting_status;
 size_t sync_buffer_size_;
 std::unordered_map<void*, size_t> frequency_map_;
 
 // Waiting command structure
 struct WaitingCommand {
   UICommand type;
   std::unique_ptr<SharedNativeString> args_01;
   NativeBindingObject* native_binding_object;
   void* native_ptr2;
   bool request_ui_update;
 };
 std::vector<WaitingCommand> waiting_commands_;
 
 friend class SharedUICommand;
};

}  // namespace webf

#endif  // MULTI_THREADING_UI_COMMAND_STRATEGY_H