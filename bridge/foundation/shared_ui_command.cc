/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "shared_ui_command.h"
#include "core/executing_context.h"
#include "foundation/logging.h"
#include "ui_command_buffer.h"

namespace webf {

SharedUICommand::SharedUICommand(ExecutingContext* context)
    : context_(context),
      front_buffer_(std::make_unique<UICommandBuffer>(context)),
      back_buffer(std::make_unique<UICommandBuffer>(context)),
      is_blocking_writing_(false) {}

void SharedUICommand::addCommand(UICommand type,
                                 std::unique_ptr<SharedNativeString>&& args_01,
                                 void* nativePtr,
                                 void* nativePtr2,
                                 bool request_ui_update) {
  if (!context_->isDedicated()) {
    front_buffer_->addCommand(type, std::move(args_01), nativePtr, nativePtr2, request_ui_update);
    return;
  }

  if (type == UICommand::kFinishRecordingCommand) {
    sync();
  } else {
    back_buffer->addCommand(type, std::move(args_01), nativePtr, nativePtr2, request_ui_update);
  }
}

// first called by dart to being read commands.
void* SharedUICommand::data() {
  // simply spin wait for the swapBuffers to finish.
  while (is_blocking_writing_.load(std::memory_order::memory_order_acquire)) {
  }

  return front_buffer_->data();
}

uint32_t SharedUICommand::kindFlag() {
  return front_buffer_->kindFlag();
}

// second called by dart to get the size of commands.
int64_t SharedUICommand::size() {
  return front_buffer_->size();
}

// third called by dart to clear commands.
void SharedUICommand::clear() {
  front_buffer_->clear();
}

// called by c++ to check if there are commands.
bool SharedUICommand::empty() {
  return back_buffer->empty();
}

void SharedUICommand::sync() {
  if (back_buffer->empty())
    return;

  if (front_buffer_->empty()) {
    swap();
  } else {
    appendBackCommandToFront();
  }
}

void SharedUICommand::swap() {
  is_blocking_writing_.store(true, std::memory_order::memory_order_release);
  std::swap(front_buffer_, back_buffer);
  is_blocking_writing_.store(false, std::memory_order::memory_order_release);
}

void SharedUICommand::appendBackCommandToFront() {
  is_blocking_writing_.store(true, std::memory_order::memory_order_release);

  for (int i = 0; i < back_buffer->size(); i++) {
    UICommandItem* command_item = back_buffer->data();
    front_buffer_->addCommand(command_item[i]);
  }

  back_buffer->clear();

  is_blocking_writing_.store(false, std::memory_order::memory_order_release);
}

}  // namespace webf