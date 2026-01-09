/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "ui_command_buffer.h"
#include "core/dart_methods.h"
#include "core/executing_context.h"
#include "foundation/logging.h"
#include "include/webf_bridge.h"
#include "string/utf8_codecs.h"

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
    case UICommand::kSetInlineStyle:
    case UICommand::kSetStyleById:
    case UICommand::kSetPseudoStyle:
    case UICommand::kRemovePseudoStyle:
    case UICommand::kClearPseudoStyle:
    case UICommand::kClearStyle:
    case UICommand::kClearSheetStyle:
    case UICommand::kSetSheetStyle:
    case UICommand::kSetSheetStyleById:
      return UICommandKind::kStyleUpdate;
    case UICommand::kSetAttribute:
    case UICommand::kRemoveAttribute:
      return UICommandKind::kAttributeUpdate;
    case UICommand::kDisposeBindingObject:
      return UICommandKind::kDisposeBindingObject;
    case UICommand::kStartRecordingCommand:
    case UICommand::kFinishRecordingCommand:
      return UICommandKind::kOperation;
    case UICommand::kRequestAnimationFrame:
      return UICommandKind::kOperation;
    case UICommand::kAddIntersectionObserver:
    case UICommand::kRemoveIntersectionObserver:
    case UICommand::kDisconnectIntersectionObserver:
      return UICommandKind::kIntersectionObserver;
    default:
      return UICommandKind::kUknownCommand;
  }
}

UICommandBuffer::UICommandBuffer(ExecutingContext* context)
    : context_(context), buffer_((UICommandItem*)malloc(sizeof(UICommandItem) * MAXIMUM_UI_COMMAND_SIZE)) {}

UICommandBuffer::~UICommandBuffer() {
  free(buffer_);
}

void UICommandBuffer::AddCommand(UICommand type,
                                 SharedNativeString* args_01,
                                 void* nativePtr,
                                 void* nativePtr2,
                                 bool request_ui_update) {
  if (type == UICommand::kFinishRecordingCommand) {
    return;
  }

  UICommandItem item{static_cast<int32_t>(type), args_01, nativePtr, nativePtr2};
  updateFlags(type);
  addCommand(item, request_ui_update);
}

void UICommandBuffer::AddStyleByIdCommand(void* nativePtr,
                                         int32_t property_id,
                                         int64_t value_slot,
                                         SharedNativeString* base_href,
                                         bool request_ui_update) {
  UICommandItem item{};
  item.type = static_cast<int32_t>(UICommand::kSetStyleById);
  item.args_01_length = property_id;
  item.string_01 = value_slot;
  item.nativePtr = static_cast<int64_t>(reinterpret_cast<intptr_t>(nativePtr));
  item.nativePtr2 = static_cast<int64_t>(reinterpret_cast<intptr_t>(base_href));
  updateFlags(UICommand::kSetStyleById);
  addCommand(item, request_ui_update);
}

void UICommandBuffer::AddSheetStyleByIdCommand(void* nativePtr,
                                               int32_t property_id,
                                               int64_t value_slot,
                                               SharedNativeString* base_href,
                                               bool important,
                                               bool request_ui_update) {
  UICommandItem item{};
  item.type = static_cast<int32_t>(UICommand::kSetSheetStyleById);
  uint32_t encoded_property_id =
      static_cast<uint32_t>(property_id) | (important ? 0x80000000u : 0u);
  item.args_01_length = static_cast<int32_t>(encoded_property_id);
  item.string_01 = value_slot;
  item.nativePtr = static_cast<int64_t>(reinterpret_cast<intptr_t>(nativePtr));
  item.nativePtr2 = static_cast<int64_t>(reinterpret_cast<intptr_t>(base_href));
  updateFlags(UICommand::kSetSheetStyleById);
  addCommand(item, request_ui_update);
}

void UICommandBuffer::updateFlags(UICommand command) {
  UICommandKind type = GetKindFromUICommand(command);
  kind_flag = kind_flag | type;
}

void UICommandBuffer::addCommand(const UICommandItem& item, bool request_ui_update) {
  if (UNLIKELY(!context_->dartIsolateContext()->valid())) {
    return;
  }

  if (size_ >= max_size_) {
    buffer_ = (UICommandItem*)realloc(buffer_, sizeof(UICommandItem) * max_size_ * 2);
    max_size_ = max_size_ * 2;
  }

  buffer_[size_] = item;
  size_++;
}

void UICommandBuffer::addCommands(const webf::UICommandItem* items, int64_t item_size, bool request_ui_update) {
  if (UNLIKELY(!context_->dartIsolateContext()->valid())) {
    return;
  }

  int64_t target_size = size_ + item_size;
  if (target_size > max_size_) {
    buffer_ = (UICommandItem*)realloc(buffer_, sizeof(UICommandItem) * target_size * 2);
    max_size_ = target_size * 2;
  }

  std::memcpy(buffer_ + size_, items, sizeof(UICommandItem) * item_size);
  size_ = target_size;
}

UICommandItem* UICommandBuffer::data() {
  return buffer_;
}

uint32_t UICommandBuffer::kindFlag() {
  return kind_flag;
}

int64_t UICommandBuffer::size() {
  return size_;
}

bool UICommandBuffer::empty() {
  return size_ == 0;
}

void UICommandBuffer::clear() {
  if (buffer_ == nullptr)
    return;
  memset(buffer_, 0, sizeof(UICommandItem) * size_);
  size_ = 0;
  kind_flag = 0;
  update_batched_ = false;
}

}  // namespace webf
