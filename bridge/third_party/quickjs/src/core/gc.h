/*
 * QuickJS Javascript Engine
 *
 * Copyright (c) 2017-2021 Fabrice Bellard
 * Copyright (c) 2017-2021 Charlie Gordon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef QUICKJS_GC_H
#define QUICKJS_GC_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "quickjs/list.h"
#include "types.h"

/* object list */

typedef struct {
  JSObject* obj;
  uint32_t hash_next; /* -1 if no next entry */
} JSObjectListEntry;

/* XXX: reuse it to optimize weak references */
typedef struct {
  JSObjectListEntry* object_tab;
  int object_count;
  int object_size;
  uint32_t* hash_table;
  uint32_t hash_size;
} JSObjectList;

typedef enum JSFreeModuleEnum {
  JS_FREE_MODULE_ALL,
  JS_FREE_MODULE_NOT_RESOLVED,
  JS_FREE_MODULE_NOT_EVALUATED,
} JSFreeModuleEnum;

void js_object_list_init(JSObjectList* s);
uint32_t js_object_list_get_hash(JSObject* p, uint32_t hash_size);
int js_object_list_resize_hash(JSContext* ctx, JSObjectList* s, uint32_t new_hash_size);
/* the reference count of 'obj' is not modified. Return 0 if OK, -1 if
   memory error */
int js_object_list_add(JSContext* ctx, JSObjectList* s, JSObject* obj);

/* return -1 if not present or the object index */
int js_object_list_find(JSContext* ctx, JSObjectList* s, JSObject* obj);

void js_object_list_end(JSContext* ctx, JSObjectList* s);
void free_gc_object(JSRuntime* rt, JSGCObjectHeader* gp);
void free_zero_refcount(JSRuntime* rt);

/* XXX: would be more efficient with separate module lists */
void js_free_modules(JSContext* ctx, JSFreeModuleEnum flag);

__maybe_unused void JS_DumpObjectHeader(JSRuntime* rt);
__maybe_unused void JS_DumpObject(JSRuntime* rt, JSObject* p);
__maybe_unused void JS_DumpGCObject(JSRuntime* rt, JSGCObjectHeader* p);
__maybe_unused void JS_DumpValueShort(JSRuntime* rt, JSValueConst val);
__maybe_unused void JS_DumpValue(JSContext* ctx, JSValueConst val);
__maybe_unused void JS_PrintValue(JSContext* ctx, const char* str, JSValueConst val);

/* used by the GC */
void JS_MarkContext(JSRuntime* rt, JSContext* ctx, JS_MarkFunc* mark_func);

void mark_children(JSRuntime* rt, JSGCObjectHeader* gp, JS_MarkFunc* mark_func);
void gc_decref_child(JSRuntime* rt, JSGCObjectHeader* p);
void gc_decref(JSRuntime* rt);
void gc_scan_incref_child(JSRuntime* rt, JSGCObjectHeader* p);
void gc_scan_incref_child2(JSRuntime* rt, JSGCObjectHeader* p);
void gc_scan(JSRuntime* rt);
void gc_free_cycles(JSRuntime* rt);

    void free_var_ref(JSRuntime* rt, JSVarRef* var_ref);
void free_object(JSRuntime* rt, JSObject* p);
void add_gc_object(JSRuntime* rt, JSGCObjectHeader* h, JSGCObjectTypeEnum type);
void set_cycle_flag(JSContext* ctx, JSValueConst obj);
void remove_gc_object(JSGCObjectHeader* h);
void js_regexp_finalizer(JSRuntime* rt, JSValue val);
void js_array_buffer_finalizer(JSRuntime* rt, JSValue val);
void js_typed_array_finalizer(JSRuntime* rt, JSValue val);
void js_typed_array_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);
void js_proxy_finalizer(JSRuntime* rt, JSValue val);
void js_proxy_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);
void js_map_finalizer(JSRuntime* rt, JSValue val);
void js_map_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);
void js_map_iterator_finalizer(JSRuntime* rt, JSValue val);
void js_map_iterator_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

void js_regexp_string_iterator_finalizer(JSRuntime* rt, JSValue val);
void js_regexp_string_iterator_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);
void js_generator_finalizer(JSRuntime* rt, JSValue obj);
void js_generator_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);
void js_promise_finalizer(JSRuntime* rt, JSValue val);
void js_promise_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);
void js_promise_resolve_function_finalizer(JSRuntime* rt, JSValue val);
void js_promise_resolve_function_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);
#ifdef CONFIG_BIGNUM
void js_operator_set_finalizer(JSRuntime* rt, JSValue val);
void js_operator_set_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);
#endif

#endif
