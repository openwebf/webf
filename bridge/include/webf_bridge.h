/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_BRIDGE_EXPORT_H
#define WEBF_BRIDGE_EXPORT_H

#include <thread>
#include <include/dart_api_dl.h>

#define WEBF_EXPORT_C extern "C" __attribute__((visibility("default"))) __attribute__((used))
#define WEBF_EXPORT __attribute__((__visibility__("default")))

typedef struct SharedNativeString SharedNativeString;
typedef struct NativeValue NativeValue;
typedef struct NativeScreen NativeScreen;
typedef struct NativeByteCode NativeByteCode;

struct WebFInfo;

struct WebFInfo {
  const char* app_name{nullptr};
  const char* app_version{nullptr};
  const char* app_revision{nullptr};
  const char* system_name{nullptr};
};

typedef void (*Task)(void*);
WEBF_EXPORT_C
void* initDartIsolateContext(uint64_t* dart_methods, int32_t dart_methods_len);
WEBF_EXPORT_C
void* allocateNewPage(void* dart_isolate_context, int32_t targetContextId);
WEBF_EXPORT_C
void disposePage(void* dart_isolate_context, void* page);
WEBF_EXPORT_C
int8_t evaluateScripts(void* page,
                       SharedNativeString* code,
                       uint8_t** parsed_bytecodes,
                       uint64_t* bytecode_len,
                       const char* bundleFilename,
                       int32_t startLine);
WEBF_EXPORT_C
int8_t evaluateQuickjsByteCode(void* page, uint8_t* bytes, int32_t byteLen);
WEBF_EXPORT_C
void parseHTML(void* page, const char* code, int32_t length);
WEBF_EXPORT_C
NativeValue* invokeModuleEvent(void* page,
                               SharedNativeString* module,
                               const char* eventType,
                               void* event,
                               NativeValue* extra);
WEBF_EXPORT_C
WebFInfo* getWebFInfo();
WEBF_EXPORT_C
void dispatchUITask(void* page, void* context, void* callback);
WEBF_EXPORT_C
void* getUICommandItems(void* page);
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

WEBF_EXPORT_C
void init_dart_dynamic_linking(void* data);
WEBF_EXPORT_C
void register_dart_context_finalizer(Dart_Handle dart_handle, void* dart_isolate_context);

#endif  // WEBF_BRIDGE_EXPORT_H
