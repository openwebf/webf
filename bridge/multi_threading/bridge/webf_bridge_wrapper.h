/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

/**
 * @brief dart call c++ method wrapper, for supporting multi-threading.
 * it's push task on the dart isolate to the JavaScript thread, if the method need callback to dart(for
 * example evaluateQuickjsByteCodeWrapper), it's can't use the postJSSync method, because this will cause the JavaScript
 * thread and dart isolate to wait for each other and cause a deadlock., so it's need use postJS method.
 */
#ifndef MULTI_THREADING_WEBF_BRIDGE_WRAPPER_H_
#define MULTI_THREADING_WEBF_BRIDGE_WRAPPER_H_

#include "include/webf_bridge.h"

WEBF_EXPORT_C
void* initDartIsolateContextWrapper(int8_t dedicated_thread,
                                    int64_t dart_port,
                                    uint64_t* dart_methods,
                                    int32_t dart_methods_len);

WEBF_EXPORT_C
void* allocateNewPageWrapper(void* dart_isolate_context, int32_t targetContextId);

WEBF_EXPORT_C
void disposePageWrapper(void* dart_isolate_context, void* page_);

WEBF_EXPORT_C
int8_t evaluateScriptsWrapper(void* page,
                              const char* code,
                              uint64_t code_len,
                              uint8_t** parsed_bytecodes,
                              uint64_t* bytecode_len,
                              const char* bundleFilename,
                              int32_t startLine);
WEBF_EXPORT_C
int8_t evaluateQuickjsByteCodeWrapper(void* page, uint8_t* bytes, int32_t byteLen);
WEBF_EXPORT_C
void parseHTMLWrapper(void* page, const char* code, int32_t length);
WEBF_EXPORT_C
NativeValue* invokeModuleEventWrapper(void* page,
                                      SharedNativeString* module,
                                      const char* eventType,
                                      void* event,
                                      NativeValue* extra);

#endif  // MULTI_THREADING_WEBF_BRIDGE_WRAPPER_H_
