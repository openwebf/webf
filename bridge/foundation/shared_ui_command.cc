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
      active_buffer(std::make_unique<UICommandBuffer>(context)),
      reserve_buffer_(std::make_unique<UICommandBuffer>(context)),
      waiting_buffer_(std::make_unique<UICommandBuffer>(context)),
      ui_command_sync_strategy_(std::make_unique<UICommandSyncStrategy>(this)),
      is_blocking_writing_(false) {}

void SharedUICommand::AddCommand(UICommand type,
                                 std::unique_ptr<SharedNativeString>&& args_01,
                                 NativeBindingObject* native_binding_object,
                                 void* nativePtr2,
                                 bool request_ui_update) {
  if (!context_->isDedicated()) {
    active_buffer->addCommand(type, std::move(args_01), native_binding_object, nativePtr2, request_ui_update);
    return;
  }

  if (type == UICommand::kFinishRecordingCommand || ui_command_sync_strategy_->ShouldSync()) {
    SyncToActive();
  }

  ui_command_sync_strategy_->RecordUICommand(type, args_01, native_binding_object, nativePtr2, request_ui_update);
}

// first called by dart to being read commands.
void* SharedUICommand::data() {
  // simply spin wait for the swapBuffers to finish.
  while (is_blocking_writing_.load(std::memory_order::memory_order_acquire)) {
  }

  return active_buffer->data();
}

uint32_t SharedUICommand::kindFlag() {
  return active_buffer->kindFlag();
}

// second called by dart to get the size of commands.
int64_t SharedUICommand::size() {
  return active_buffer->size();
}

// third called by dart to clear commands.
void SharedUICommand::clear() {
  active_buffer->clear();
}

// called by c++ to check if there are commands.
bool SharedUICommand::empty() {
  if (context_->isDedicated()) {
    return reserve_buffer_->empty() && waiting_buffer_->empty();
  }

  return active_buffer->empty();
}

void SharedUICommand::SyncToReserve() {
  if (waiting_buffer_->empty()) return;

  if (reserve_buffer_->empty()) {
    swap(waiting_buffer_, reserve_buffer_);
  } else {
    appendCommand(reserve_buffer_, waiting_buffer_);
  }
}

void SharedUICommand::SyncToActive() {
  SyncToReserve();

  if (reserve_buffer_->empty())
    return;

  ui_command_sync_strategy_->Reset();

  if (active_buffer->empty()) {
    swap(reserve_buffer_, active_buffer);
  } else {
    appendCommand(reserve_buffer_, active_buffer);
  }
}

void SharedUICommand::swap(std::unique_ptr<UICommandBuffer>& original, std::unique_ptr<UICommandBuffer>& target) {
  is_blocking_writing_.store(true, std::memory_order::memory_order_release);
  std::swap(target, original);
  is_blocking_writing_.store(false, std::memory_order::memory_order_release);
}

void SharedUICommand::appendCommand(std::unique_ptr<UICommandBuffer>& original, std::unique_ptr<UICommandBuffer>& target) {
  is_blocking_writing_.store(true, std::memory_order::memory_order_release);

  for (int i = 0; i < original->size(); i++) {
    UICommandItem* command_item = original->data();
    target->addCommand(command_item[i]);
  }

  original->clear();

  is_blocking_writing_.store(false, std::memory_order::memory_order_release);
}

}  // namespace webf