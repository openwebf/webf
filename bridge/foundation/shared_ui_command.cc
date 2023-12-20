/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "shared_ui_command.h"
#include "core/executing_context.h"
#include "foundation/logging.h"
#include "ui_command_buffer.h"

namespace webf {

SharedUICommand::SharedUICommand(ExecutingContext* context)
    : context_(context), front_buffer_(std::make_unique<UICommandBuffer>(context)), is_blocking_writing_(false) {}

void SharedUICommand::addCommand(UICommand type,
                                 std::unique_ptr<SharedNativeString>&& args_01,
                                 void* nativePtr,
                                 void* nativePtr2,
                                 bool request_ui_update) {
  if (!context_->isDedicated()) {
    front_buffer_->addCommand(type, std::move(args_01), nativePtr, nativePtr2, request_ui_update);
    return;
  }

  while (is_blocking_writing_) {
    // simply spin wait for the swapBuffers to finish.
  }

  front_buffer_->addCommand(type, std::move(args_01), nativePtr, nativePtr2, request_ui_update);
}

// first called by dart to begin read commands.
void* SharedUICommand::data() {
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
  return front_buffer_->empty();
}

void SharedUICommand::acquireLocks() {
  is_blocking_writing_ = true;
}

void SharedUICommand::releaseLocks() {
  is_blocking_writing_ = false;
}

}  // namespace webf