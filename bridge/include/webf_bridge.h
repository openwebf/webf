/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_BRIDGE_EXPORT_H
#define WEBF_BRIDGE_EXPORT_H

#include <include/dart_api_dl.h>
#include <functional>
#include <thread>

#define WEBF_EXPORT_C extern "C" __attribute__((visibility("default"))) __attribute__((used))
#define WEBF_EXPORT __attribute__((__visibility__("default")))

class SharedNativeString;
class NativeValue;
class NativeScreen;
class NativeByteCode;

struct WebFInfo {
  const char* app_name{nullptr};
  const char* app_version{nullptr};
  const char* app_revision{nullptr};
  const char* system_name{nullptr};
};

typedef void (*Task)(void*);
typedef std::function<void(bool)> DartWork;
typedef void (*AllocateNewPageCallback)(Dart_Handle dart_handle, void*);
typedef void (*DisposePageCallback)(Dart_Handle dart_handle);
typedef void (*InvokeModuleEventCallback)(Dart_Handle dart_handle, void*);
typedef void (*EvaluateQuickjsByteCodeCallback)(Dart_Handle dart_handle, int8_t);
typedef void (*DumpQuickjsByteCodeCallback)(Dart_Handle);
typedef void (*ParseHTMLCallback)(Dart_Handle);
typedef void (*EvaluateScriptsCallback)(Dart_Handle dart_handle, int8_t);

WEBF_EXPORT_C
void* initDartIsolateContextSync(int64_t dart_port,
                                 uint64_t* dart_methods,
                                 int32_t dart_methods_len);

WEBF_EXPORT_C
void allocateNewPage(double thread_identity,
                     int32_t sync_buffer_size,
                     int8_t use_legacy_ui_command,
                     int8_t enable_blink,
                     void* dart_isolate_context,
                     void* native_widget_element_shapes,
                     int32_t shape_len,
                     Dart_Handle dart_handle,
                     AllocateNewPageCallback result_callback);

WEBF_EXPORT_C
void* allocateNewPageSync(double thread_identity,
                          void* dart_isolate_context,
                          void* native_widget_element_shapes,
                          int32_t shape_len,
                          int8_t enable_blink);

WEBF_EXPORT_C
int64_t newPageIdSync();

WEBF_EXPORT_C
void disposePage(double dedicated_thread,
                 void* dart_isolate_context,
                 void* page,
                 Dart_Handle dart_handle,
                 DisposePageCallback result_callback);

WEBF_EXPORT_C
void disposePageSync(double dedicated_thread, void* dart_isolate_context, void* page);

WEBF_EXPORT_C
void evaluateScripts(void* page,
                     const char* code,
                     uint64_t code_len,
                     uint8_t** parsed_bytecodes,
                     uint64_t* bytecode_len,
                     const char* bundleFilename,
                     int32_t start_line,
                     void* script_element_,
                     Dart_Handle dart_handle,
                     EvaluateScriptsCallback result_callback);

WEBF_EXPORT_C
void evaluateModule(void* page,
                    const char* code,
                    uint64_t code_len,
                    uint8_t** parsed_bytecodes,
                    uint64_t* bytecode_len,
                    const char* bundleFilename,
                    int32_t start_line,
                    void* script_element_,
                    Dart_Handle dart_handle,
                    EvaluateScriptsCallback result_callback);

WEBF_EXPORT_C
void evaluateQuickjsByteCode(void* page,
                             uint8_t* bytes,
                             int32_t byteLen,
                             void* script_element_,
                             Dart_Handle dart_handle,
                             EvaluateQuickjsByteCodeCallback result_callback);

WEBF_EXPORT_C
void dumpQuickjsByteCode(void* page,
                         const char* code,
                         int32_t code_len,
                         uint8_t** parsed_bytecodes,
                         uint64_t* bytecode_len,
                         const char* url,
                         bool is_module,
                         Dart_Handle dart_handle,
                         DumpQuickjsByteCodeCallback result_callback);

WEBF_EXPORT_C
void parseHTML(void* page,
               char* code,
               int32_t length,
               Dart_Handle dart_handle,
               ParseHTMLCallback result_callback);

// Environment change callbacks: one media value per function.
// These notify the native Blink CSS engine that the given value has changed
// and pass the concrete value across the bridge; MediaValues will still
// query the up-to-date environment from Dart when evaluating media queries.
WEBF_EXPORT_C
void onViewportSizeChanged(void* page, double inner_width, double inner_height);

WEBF_EXPORT_C
void onDevicePixelRatioChanged(void* page, double device_pixel_ratio);

// |scheme| is a UTF-8 string such as "light" or "dark" (not null-terminated),
// with explicit |length|.
WEBF_EXPORT_C
void onColorSchemeChanged(void* page, const char* scheme, int32_t length);

WEBF_EXPORT_C
void* parseSVGResult(const char* code, int32_t length);
WEBF_EXPORT_C
void freeSVGResult(void* svgTree);
WEBF_EXPORT_C
void invokeModuleEvent(void* page,
                       SharedNativeString* module,
                       const char* eventType,
                       void* event,
                       NativeValue* extra,
                       Dart_Handle dart_handle,
                       InvokeModuleEventCallback result_callback);

WEBF_EXPORT_C
void* allocateNativeBindingObject();

WEBF_EXPORT_C
bool isNativeBindingObjectDisposed(void* native_binding_object);

WEBF_EXPORT_C
void batchFreeNativeBindingObjects(void** pointers, int32_t count);

WEBF_EXPORT_C
WebFInfo* getWebFInfo();
WEBF_EXPORT_C
void dispatchUITask(void* page, void* context, void* callback);
WEBF_EXPORT_C
void* getUICommandItems(void* page);

WEBF_EXPORT_C
int64_t getUICommandItemSize(void* page);

WEBF_EXPORT_C
void freeActiveCommandBuffer(void* ui_command_buffer);

WEBF_EXPORT_C
void clearUICommandItems(void* page);
WEBF_EXPORT_C
void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName);
WEBF_EXPORT_C
void registerPluginCode(const char* code, int32_t length, const char* pluginName);

WEBF_EXPORT_C int8_t isJSThreadBlocked(void* dart_isolate_context, double context_id);

WEBF_EXPORT_C void executeNativeCallback(DartWork* work_ptr);
WEBF_EXPORT_C
void init_dart_dynamic_linking(void* data);
WEBF_EXPORT_C
void on_dart_context_finalized(void* dart_isolate_context);

#endif  // WEBF_BRIDGE_EXPORT_H
