/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_DOUBULE_UI_COMMAND_H_
#define MULTI_THREADING_DOUBULE_UI_COMMAND_H_

#include <atomic>
#include <memory>
#include <mutex>
#include "foundation/native_type.h"
#include "foundation/ui_command_buffer.h"
#include "foundation/ui_command_ring_buffer.h"
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
  ~SharedUICommand();

  void AddCommand(UICommand type,
                  std::unique_ptr<SharedNativeString>&& args_01,
                  NativeBindingObject* native_binding_object,
                  void* nativePtr2,
                  bool request_ui_update = true);

  void ConfigureSyncCommandBufferSize(size_t size);

  void* data();
  void clear();
  bool empty();
  int64_t size();
  void SyncAllPackages();  // No-op for compatibility
  void FlushCurrentPackages();

 private:
  ExecutingContext* context_;
  
  // Ring buffer implementation
  std::unique_ptr<UICommandPackageRingBuffer> package_buffer_;
  std::unique_ptr<UICommandSyncStrategy> ui_command_sync_strategy_ = nullptr;
  
  // Buffer for dart-side reading
  std::unique_ptr<UICommandBuffer> read_buffer_;
  std::mutex read_buffer_mutex_;
  
  // Statistics
  std::atomic<uint64_t> total_commands_{0};
  std::atomic<uint64_t> total_packages_{0};
  
  // Helper methods
  void FillReadBuffer();
  void RequestBatchUpdate();
  friend class UICommandSyncStrategy;
  friend class ExecutingContext;
};

}  // namespace webf

#endif  // MULTI_THREADING_DOUBULE_UI_COMMAND_H_