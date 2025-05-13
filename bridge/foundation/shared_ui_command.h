/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_DOUBULE_UI_COMMAND_H_
#define MULTI_THREADING_DOUBULE_UI_COMMAND_H_

#include <atomic>
#include <memory>
#include "foundation/native_type.h"
#include "foundation/ui_command_buffer.h"
#include "foundation/ui_command_strategy.h"

namespace webf {

struct NativeBindingObject;

struct UICommandBufferPack {
  void* buffer_head;
  void* data;
  int64_t length;
};

class SharedUICommand : public DartReadable {
 public:
  SharedUICommand(ExecutingContext* context);

  void AddCommand(UICommand type,
                  SharedNativeString* args_01,
                  NativeBindingObject* native_binding_object,
                  void* nativePtr2,
                  bool request_ui_update = true);

  void* data();
  void clear();
  bool empty();
  int64_t size();
  void SyncToActive();
  void SyncToReserve();

  void ConfigureSyncCommandBufferSize(size_t size);

 private:
  void swap(std::unique_ptr<UICommandBuffer>& original, std::unique_ptr<UICommandBuffer>& target);
  void appendCommand(std::unique_ptr<UICommandBuffer>& original, std::unique_ptr<UICommandBuffer>& target);
  std::unique_ptr<UICommandBuffer> active_buffer = nullptr;    // The ui commands which accessible from Dart side
  std::unique_ptr<UICommandBuffer> reserve_buffer_ = nullptr;  // The ui commands which are ready to swap to active.
  std::unique_ptr<UICommandBuffer> waiting_buffer_ =
      nullptr;  // The ui commands which recorded from JS operations and sync to reserve_buffer by once.
  std::atomic<bool> is_blocking_reading_ = false;
  std::atomic<bool> is_blocking_writing_ = false;
  ExecutingContext* context_;
  std::unique_ptr<UICommandSyncStrategy> ui_command_sync_strategy_ = nullptr;
  friend class UICommandBuffer;
  friend class UICommandSyncStrategy;
};

}  // namespace webf

#endif  // MULTI_THREADING_DOUBULE_UI_COMMAND_H_