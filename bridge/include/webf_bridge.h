/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_BRIDGE_EXPORT_H
#define WEBF_BRIDGE_EXPORT_H

#include <thread>

#define WEBF_EXPORT_C extern "C" __attribute__((visibility("default"))) __attribute__((used))
#define WEBF_EXPORT __attribute__((__visibility__("default")))

WEBF_EXPORT_C
std::thread::id getUIThreadId();

typedef struct NativeString NativeString;
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
typedef void (*ConsoleMessageHandler)(void* ctx, const std::string& message, int logLevel);

WEBF_EXPORT_C
void initJSPagePool(int poolSize);
WEBF_EXPORT_C
void disposePage(int32_t contextId);
WEBF_EXPORT_C
int32_t allocateNewPage(int32_t targetContextId);
WEBF_EXPORT_C
void* getPage(int32_t contextId);
bool checkPage(int32_t contextId);
bool checkPage(int32_t contextId, void* context);
WEBF_EXPORT_C
void evaluateScripts(int32_t contextId, NativeString* code, const char* bundleFilename, int32_t startLine);
WEBF_EXPORT_C
void evaluateQuickjsByteCode(int32_t contextId, uint8_t* bytes, int32_t byteLen);
WEBF_EXPORT_C
void parseHTML(int32_t contextId, const char* code, int32_t length);
WEBF_EXPORT_C
void reloadJsContext(int32_t contextId);
WEBF_EXPORT_C
void invokeModuleEvent(int32_t contextId,
                       NativeString* module,
                       const char* eventType,
                       void* event,
                       NativeString* extra);
WEBF_EXPORT_C
void registerDartMethods(int32_t contextId, uint64_t* methodBytes, int32_t length);
WEBF_EXPORT_C
WebFInfo* getWebFInfo();
WEBF_EXPORT_C
void dispatchUITask(int32_t contextId, void* context, void* callback);
WEBF_EXPORT_C
void flushUITask(int32_t contextId);
WEBF_EXPORT_C
void registerUITask(int32_t contextId, Task task, void* data);
WEBF_EXPORT_C
void* getUICommandItems(int32_t contextId);
WEBF_EXPORT_C
int64_t getUICommandItemSize(int32_t contextId);
WEBF_EXPORT_C
void clearUICommandItems(int32_t contextId);
WEBF_EXPORT_C
void registerContextDisposedCallbacks(int32_t contextId, Task task, void* data);
WEBF_EXPORT_C
void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName);
WEBF_EXPORT_C
int32_t profileModeEnabled();

WEBF_EXPORT
void setConsoleMessageHandler(ConsoleMessageHandler handler);

#endif  // WEBF_BRIDGE_EXPORT_H
