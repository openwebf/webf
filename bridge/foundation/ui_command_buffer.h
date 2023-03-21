/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_FOUNDATION_UI_COMMAND_BUFFER_H_
#define BRIDGE_FOUNDATION_UI_COMMAND_BUFFER_H_

#include <cinttypes>
#include "bindings/qjs/native_string_utils.h"
#include "native_value.h"

namespace webf {

class ExecutingContext;

enum class UICommand {
  kCreateElement,
  kCreateTextNode,
  kCreateComment,
  kCreateDocument,
  kCreateWindow,
  kDisposeEventTarget,
  kAddEvent,
  kRemoveNode,
  kInsertAdjacentNode,
  kSetStyle,
  kSetAttribute,
  kRemoveAttribute,
  kCloneNode,
  kRemoveEvent,
  kCreateDocumentFragment,
  kCreateSVGElement,
  kCreateElementNS,
};

#define MAXIMUM_UI_COMMAND_SIZE 2048

struct UICommandItem {
  UICommandItem() = default;
  UICommandItem(int32_t id, int32_t type, SharedNativeString* args_01, SharedNativeString* args_02, void* nativePtr)
      : type(type),
        string_01(reinterpret_cast<int64_t>(args_01->string())),
        args_01_length(args_01->length()),
        string_02(reinterpret_cast<int64_t>(args_02->string())),
        args_02_length(args_02->length()),
        id(id),
        nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, SharedNativeString* args_01, void* nativePtr)
      : type(type),
        string_01(reinterpret_cast<int64_t>(args_01->string())),
        args_01_length(args_01->length()),
        id(id),
        nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  UICommandItem(int32_t id, int32_t type, void* nativePtr)
      : type(type), id(id), nativePtr(reinterpret_cast<int64_t>(nativePtr)){};
  int32_t type{0};
  int32_t id{0};
  int32_t args_01_length{0};
  int32_t args_02_length{0};
  int64_t string_01{0};
  int64_t string_02{0};
  int64_t nativePtr{0};
};

bool isDartHotRestart();

class UICommandBuffer {
 public:
  UICommandBuffer() = delete;
  explicit UICommandBuffer(ExecutingContext* context);
  ~UICommandBuffer();
  void addCommand(int32_t id, UICommand type, void* nativePtr);
  void addCommand(int32_t id,
                  UICommand type,
                  std::unique_ptr<SharedNativeString>&& args_01,
                  std::unique_ptr<SharedNativeString>&& args_02,
                  void* nativePtr);
  void addCommand(int32_t id, UICommand type, std::unique_ptr<SharedNativeString>&& args_01, void* nativePtr);
  UICommandItem* data();
  int64_t size();
  bool empty();
  void clear();

 private:
  void addCommand(const UICommandItem& item);

  ExecutingContext* context_{nullptr};
  UICommandItem buffer_[MAXIMUM_UI_COMMAND_SIZE];
  bool update_batched_{false};
  int64_t size_{0};
};

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_UI_COMMAND_BUFFER_H_
