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

UICommandKind GetKindFromUICommand(UICommand command) {
  switch (command) {
    case UICommand::kCreateElement:
    case UICommand::kCreateTextNode:
    case UICommand::kCreateComment:
    case UICommand::kCreateDocument:
    case UICommand::kCreateWindow:
    case UICommand::kRemoveNode:
    case UICommand::kCreateDocumentFragment:
    case UICommand::kCreateSVGElement:
    case UICommand::kCreateElementNS:
    case UICommand::kCloneNode:
      return UICommandKind::kNodeCreation;
    case UICommand::kInsertAdjacentNode:
      return UICommandKind::kNodeMutation;
    case UICommand::kAddEvent:
    case UICommand::kRemoveEvent:
      return UICommandKind::kEvent;
    case UICommand::kSetStyle:
    case UICommand::kClearStyle:
      return UICommandKind::kStyleUpdate;
    case UICommand::kSetAttribute:
    case UICommand::kRemoveAttribute:
      return UICommandKind::kAttributeUpdate;
    case UICommand::kDisposeBindingObject:
      return UICommandKind::kDisposeBindingObject;
    case UICommand::kStartRecordingCommand:
    case UICommand::kFinishRecordingCommand:
      return UICommandKind::kOperation;
  }
}

UICommandBuffer::UICommandBuffer(ExecutingContext* context)
    : context_(context) {
  storage_.buffer_ = (UICommandItem*)malloc(sizeof(UICommandItem) * MAXIMUM_UI_COMMAND_SIZE);
}

UICommandBuffer::~UICommandBuffer() {
  free(storage_.buffer_);
}

void UICommandBuffer::addCommand(UICommand command,
                                 std::unique_ptr<SharedNativeString>&& args_01,
                                 void* nativePtr,
                                 void* nativePtr2,
                                 bool request_ui_update) {
  if (!is_recording_) {
    UICommandItem recording_item{static_cast<int32_t>(UICommand::kStartRecordingCommand), nullptr, nullptr, nullptr};
    updateFlags(command);
    addCommand(recording_item, false);
    is_recording_ = true;
  }

  if (command == UICommand::kFinishRecordingCommand) {
    if (size_ == 0) return;
    if (storage_.buffer_[size_ - 1].type == static_cast<int32_t>(UICommand::kFinishRecordingCommand)) return;
  }

  UICommandItem item{static_cast<int32_t>(command), args_01.get(), nativePtr, nativePtr2};
  updateFlags(command);
  addCommand(item, request_ui_update);
}

void UICommandBuffer::updateFlags(UICommand command) {
  UICommandKind type = GetKindFromUICommand(command);
  storage_.kind_flag = storage_.kind_flag | type;
}


void UICommandBuffer::addCommand(const UICommandItem& item, bool request_ui_update) {
  if (UNLIKELY(!context_->dartIsolateContext()->valid())) {
    return;
  }

  if (size_ >= max_size_) {
    storage_.buffer_ = (UICommandItem*)realloc(storage_.buffer_, sizeof(UICommandItem) * max_size_ * 2);
    max_size_ = max_size_ * 2;
  }

#if FLUTTER_BACKEND
  if (UNLIKELY(request_ui_update && !update_batched_ && context_->IsContextValid())) {
    context_->dartMethodPtr()->requestBatchUpdate(context_->isDedicated(), context_->contextId());
    update_batched_ = true;
  }
#endif

  storage_.buffer_[size_] = item;
  size_++;
}

void* UICommandBuffer::data() {
  return &storage_;
}

bool UICommandBuffer::isRecording() {
  return is_recording_;
}

int64_t UICommandBuffer::size() {
  return size_;
}

bool UICommandBuffer::empty() {
  return size_ == 0;
}

void UICommandBuffer::clear() {
  memset(storage_.buffer_, 0, sizeof(UICommandItem) * size_);
  size_ = 0;
  storage_.kind_flag = 0;
  update_batched_ = false;
}

}  // namespace webf
