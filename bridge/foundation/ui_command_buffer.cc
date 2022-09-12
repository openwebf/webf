/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "ui_command_buffer.h"
#include "core/dart_methods.h"
#include "core/executing_context.h"
#include "foundation/logging.h"
#include "include/webf_bridge.h"

namespace webf {

UICommandBuffer::UICommandBuffer(ExecutingContext* context) : context_(context) {}

void UICommandBuffer::addCommand(int32_t id, UICommand type, void* nativePtr) {
  UICommandItem item{id, static_cast<int32_t>(type), nativePtr};
  addCommand(item);
}

void UICommandBuffer::addCommand(int32_t id, UICommand type, std::unique_ptr<NativeString>&& args_01, void* nativePtr) {
  assert(args_01 != nullptr);
  UICommandItem item{id, static_cast<int32_t>(type), args_01.release(), nativePtr};
  addCommand(item);
}

void UICommandBuffer::addCommand(int32_t id,
                                 UICommand type,
                                 std::unique_ptr<NativeString>&& args_01,
                                 std::unique_ptr<NativeString>&& args_02,
                                 void* nativePtr) {
  assert(args_01 != nullptr);
  assert(args_02 != nullptr);
  UICommandItem item{id, static_cast<int32_t>(type), args_01.release(), args_02.release(), nativePtr};
  addCommand(item);
}

void UICommandBuffer::addCommand(const UICommandItem& item) {
  if (size_ >= MAXIMUM_UI_COMMAND_SIZE) {
    context_->FlushUICommand();
    assert(size_ == 0);
  }
  buffer_[size_] = item;
  size_++;
}

UICommandItem* UICommandBuffer::data() {
  return buffer_;
}

int64_t UICommandBuffer::size() {
  return size_;
}

bool UICommandBuffer::empty() {
  return size_ == 0;
}

void UICommandBuffer::clear() {
  for (int i = 0; i < size_; i++) {
    delete[] reinterpret_cast<const uint16_t*>(buffer_[i].string_01);
    delete[] reinterpret_cast<const uint16_t*>(buffer_[i].string_02);
  }
  size_ = 0;
}

}  // namespace webf
