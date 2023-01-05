/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_DART_METHODS_H_
#define WEBF_DART_METHODS_H_

/// Functions implements at dart side, including timer, Rendering and module API.
/// Communicate via Dart FFI.

#include <memory>
#include <thread>
#include "foundation/native_string.h"
#include "foundation/native_value.h"

#define WEBF_EXPORT __attribute__((__visibility__("default")))

namespace webf {

using AsyncCallback = void (*)(void* callback_context, int32_t context_id, const char* errmsg);
using AsyncRAFCallback = void (*)(void* callback_context, int32_t context_id, double result, const char* errmsg);
using AsyncModuleCallback = NativeValue* (*)(void* callback_context,
                                             int32_t context_id,
                                             const char* errmsg,
                                             NativeValue* value);
using AsyncBlobCallback =
    void (*)(void* callback_context, int32_t context_id, const char* error, uint8_t* bytes, int32_t length);
typedef NativeValue* (*InvokeModule)(void* callback_context,
                                     int32_t context_id,
                                     NativeString* moduleName,
                                     NativeString* method,
                                     NativeValue* params,
                                     AsyncModuleCallback callback);
typedef void (*RequestBatchUpdate)(int32_t context_id);
typedef void (*ReloadApp)(int32_t context_id);
typedef int32_t (*SetTimeout)(void* callback_context, int32_t context_id, AsyncCallback callback, int32_t timeout);
typedef int32_t (*SetInterval)(void* callback_context, int32_t context_id, AsyncCallback callback, int32_t timeout);
typedef int32_t (*RequestAnimationFrame)(void* callback_context, int32_t context_id, AsyncRAFCallback callback);
typedef void (*ClearTimeout)(int32_t context_id, int32_t timerId);
typedef void (*CancelAnimationFrame)(int32_t context_id, int32_t id);
typedef void (*ToBlob)(void* callback_context,
                       int32_t context_id,
                       AsyncBlobCallback blobCallback,
                       int32_t elementId,
                       double devicePixelRatio);
typedef void (*OnJSError)(int32_t context_id, const char*);
typedef void (*OnJSLog)(int32_t context_id, int32_t level, const char*);
typedef void (*FlushUICommand)(int32_t context_id);
typedef void (
    *CreateBindingObject)(int32_t context_id, void* native_binding_object, int32_t type, void* args, int32_t argc);

using MatchImageSnapshotCallback = void (*)(void* callback_context, int32_t context_id, int8_t, const char* errmsg);
using MatchImageSnapshot = void (*)(void* callback_context,
                                    int32_t context_id,
                                    uint8_t* bytes,
                                    int32_t length,
                                    NativeString* name,
                                    MatchImageSnapshotCallback callback);
using Environment = const char* (*)();

#if ENABLE_PROFILE
struct NativePerformanceEntryList {
  uint64_t* entries;
  int32_t length;
};
typedef NativePerformanceEntryList* (*GetPerformanceEntries)(int32_t);
#endif

struct MousePointer {
  int32_t context_id;
  double x;
  double y;
  double change;
  int32_t signal_kind;
  double delta_x;
  double delta_y;
};
using SimulatePointer =
    void (*)(void* ptr, MousePointer*, int32_t length, int32_t pointer, AsyncCallback async_callback);
using SimulateInputText = void (*)(NativeString* nativeString);

struct DartMethodPointer {
  DartMethodPointer() = delete;
  explicit DartMethodPointer(const uint64_t* dart_methods, int32_t dartMethodsLength);

  InvokeModule invokeModule{nullptr};
  RequestBatchUpdate requestBatchUpdate{nullptr};
  ReloadApp reloadApp{nullptr};
  SetTimeout setTimeout{nullptr};
  SetInterval setInterval{nullptr};
  ClearTimeout clearTimeout{nullptr};
  RequestAnimationFrame requestAnimationFrame{nullptr};
  CancelAnimationFrame cancelAnimationFrame{nullptr};
  ToBlob toBlob{nullptr};
  OnJSError onJsError{nullptr};
  OnJSLog onJsLog{nullptr};
  MatchImageSnapshot matchImageSnapshot{nullptr};
  Environment environment{nullptr};
  SimulatePointer simulatePointer{nullptr};
  SimulateInputText simulateInputText{nullptr};
  FlushUICommand flushUICommand{nullptr};
  CreateBindingObject create_binding_object{nullptr};
#if ENABLE_PROFILE
  GetPerformanceEntries getPerformanceEntries{nullptr};
#endif
};

}  // namespace webf

#endif
