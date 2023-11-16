/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_BRIDGE_EXPORT_H
#define WEBF_BRIDGE_EXPORT_H

#include <include/dart_api_dl.h>
#include <functional>
#include <thread>

#if defined(_WIN32)
#define WEBF_EXPORT_C extern "C" __declspec(dllexport)
#define WEBF_EXPORT __declspec(dllexport)
#else
#define WEBF_EXPORT_C extern "C" __attribute__((visibility("default"))) __attribute__((used))
#define WEBF_EXPORT __attribute__((__visibility__("default")))
#endif

typedef struct SharedNativeString SharedNativeString;
typedef struct NativeValue NativeValue;
typedef struct NativeScreen NativeScreen;
typedef struct NativeByteCode NativeByteCode;

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
typedef void (*EvaluateScriptsCallback)(Dart_Handle dart_handle, int8_t);

WEBF_EXPORT_C
void* initDartIsolateContextSync(int64_t dart_port, uint64_t* dart_methods, int32_t dart_methods_len);

WEBF_EXPORT_C
void allocateNewPage(double thread_identity,
                     void* dart_isolate_context,
                     Dart_Handle dart_handle,
                     AllocateNewPageCallback result_callback);

WEBF_EXPORT_C
void* allocateNewPageSync(double thread_identity, void* dart_isolate_context);

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
                     int32_t startLine,
                     Dart_Handle dart_handle,
                     EvaluateQuickjsByteCodeCallback result_callback);
WEBF_EXPORT_C
void evaluateQuickjsByteCode(void* page,
                             uint8_t* bytes,
                             int32_t byteLen,
                             Dart_Handle dart_handle,
                             EvaluateQuickjsByteCodeCallback result_callback);

WEBF_EXPORT_C
void dumpQuickjsByteCode(void* page,
                         const char* code,
                         int32_t code_len,
                         uint8_t** parsed_bytecodes,
                         uint64_t* bytecode_len,
                         const char* url);

WEBF_EXPORT_C
void parseHTML(void* page, const char* code, int32_t length);
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
WebFInfo* getWebFInfo();
WEBF_EXPORT_C
void dispatchUITask(void* page, void* context, void* callback);
WEBF_EXPORT_C
void* getUICommandItems(void* page);
WEBF_EXPORT_C
uint32_t getUICommandKindFlag(void* page);

WEBF_EXPORT_C
void acquireUiCommandLocks(void* page);

WEBF_EXPORT_C
void releaseUiCommandLocks(void* page);

WEBF_EXPORT_C
int64_t getUICommandItemSize(void* page);
WEBF_EXPORT_C
void clearUICommandItems(void* page);
WEBF_EXPORT_C
void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName);
WEBF_EXPORT_C
void registerPluginCode(const char* code, int32_t length, const char* pluginName);
WEBF_EXPORT_C
int32_t profileModeEnabled();

WEBF_EXPORT_C int8_t isJSThreadBlocked(void* dart_isolate_context, double context_id);

WEBF_EXPORT_C void executeNativeCallback(DartWork* work_ptr);
WEBF_EXPORT_C
void init_dart_dynamic_linking(void* data);
WEBF_EXPORT_C
void register_dart_context_finalizer(Dart_Handle dart_handle, void* dart_isolate_context);

#endif  // WEBF_BRIDGE_EXPORT_H
