/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "qjs_patch.h"
#include <string.h>
#include <quickjs/src/core/types.h>


uint16_t* JS_ToUnicode(JSContext* ctx, JSValueConst value, uint32_t* length) {
  if (JS_VALUE_GET_TAG(value) != JS_TAG_STRING) {
    value = JS_ToString(ctx, value);
    if (JS_IsException(value))
      return NULL;
  } else {
    value = JS_DupValue(ctx, value);
  }

  uint16_t* buffer;
  JSString* string = JS_VALUE_GET_STRING(value);

  if (!string->is_wide_char) {
    uint8_t* p = string->u.str8;
    uint32_t len = *length = string->len;
    buffer = (uint16_t*)malloc(sizeof(uint16_t) * len * 2);
    for (size_t i = 0; i < len; i++) {
      buffer[i] = p[i];
      buffer[i + 1] = 0x00;
    }
  } else {
    *length = string->len;
    buffer = (uint16_t*)malloc(sizeof(uint16_t) * string->len);
    memcpy(buffer, string->u.str16, sizeof(uint16_t) * string->len);
  }

  JS_FreeValue(ctx, value);
  return buffer;
}

static JSString* js_alloc_string_rt(JSRuntime* rt, int max_len, int is_wide_char) {
  JSString* str;
  str = (JSString*)(js_malloc_rt(rt, sizeof(JSString) + (max_len << is_wide_char) + 1 - is_wide_char));
  if (unlikely(!str))
    return NULL;
  str->header.ref_count = 1;
  str->is_wide_char = is_wide_char;
  str->len = max_len;
  str->atom_type = 0;
  str->hash = 0;      /* optional but costless */
  str->hash_next = 0; /* optional */
#ifdef DUMP_LEAKS
  list_add_tail(&str->link, &rt->string_list);
#endif
  return str;
}

static JSString* js_alloc_string(JSRuntime* runtime, JSContext* ctx, int max_len, int is_wide_char) {
  JSString* p;
  p = js_alloc_string_rt(runtime, max_len, is_wide_char);
  if (unlikely(!p)) {
    JS_ThrowOutOfMemory(ctx);
    return NULL;
  }
  return p;
}

JSValue JS_NewUnicodeString(JSRuntime* runtime, JSContext* ctx, const uint16_t* code, uint32_t length) {
  JSString* str;
  str = js_alloc_string(runtime, ctx, length, 1);
  if (!str)
    return JS_EXCEPTION;
  memcpy(str->u.str16, code, length * 2);
  return JS_MKPTR(JS_TAG_STRING, str);
}

JSClassID JSValueGetClassId(JSValue obj) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return -1;
  p = JS_VALUE_GET_OBJ(obj);
  return p->class_id;
}

BOOL JS_IsProxy(JSValue value) {
  if (!JS_IsObject(value))
    return FALSE;
  JSObject* p = JS_VALUE_GET_OBJ(value);
  return p->class_id == JS_CLASS_PROXY;
}

BOOL JS_HasClassId(JSRuntime* runtime, JSClassID classId) {
  if (runtime->class_count <= classId)
    return FALSE;
  return runtime->class_array[classId].class_id == classId;
}

JSValue JS_GetProxyTarget(JSValue value) {
  JSObject* p = JS_VALUE_GET_OBJ(value);
  return p->u.proxy_data->target;
}
