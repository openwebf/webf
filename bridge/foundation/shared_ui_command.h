/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_DOUBULE_UI_COMMAND_H_
#define MULTI_THREADING_DOUBULE_UI_COMMAND_H_

#include <atomic>
#include "foundation/native_type.h"
#include "foundation/ui_command_buffer.h"

namespace webf {

class SharedUICommand : public DartReadable {
 public:
  SharedUICommand(ExecutingContext* context);

  void addCommand(UICommand type,
                  std::unique_ptr<SharedNativeString>&& args_01,
                  void* nativePtr,
                  void* nativePtr2,
                  bool request_ui_update = true);

  void* data();
  uint32_t kindFlag();
  int64_t size();
  bool empty();
  void clear();
  void sync();

 private:
  void swap();
  void appendBackCommandToFront();
  std::unique_ptr<UICommandBuffer> front_buffer_ = nullptr;
  std::unique_ptr<UICommandBuffer> back_buffer = nullptr;
  std::atomic<bool> is_blocking_writing_;
  ExecutingContext* context_;
  friend class UICommandBuffer;
};

}  // namespace webf

#endif  // MULTI_THREADING_DOUBULE_UI_COMMAND_H_