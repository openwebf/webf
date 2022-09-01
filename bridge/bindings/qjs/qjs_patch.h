/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_QJS_PATCH_H
#define BRIDGE_QJS_PATCH_H

#include <quickjs/list.h>
#include <quickjs/quickjs.h>
#include "quickjs/cutils.h"

#ifdef __cplusplus
extern "C" {
#endif

uint16_t* JS_ToUnicode(JSContext* ctx, JSValueConst value, uint32_t* length);
JSValue JS_NewUnicodeString(JSRuntime* runtime, JSContext* ctx, const uint16_t* code, uint32_t length);
JSClassID JSValueGetClassId(JSValue);
BOOL JS_IsProxy(JSValue value);
BOOL JS_HasClassId(JSRuntime* runtime, JSClassID classId);
JSValue JS_GetProxyTarget(JSValue value);

#ifdef __cplusplus
}
#endif

#endif  // BRIDGE_QJS_PATCH_H
