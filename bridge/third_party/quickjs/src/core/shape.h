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

#ifndef QUICKJS_SHAPE_H
#define QUICKJS_SHAPE_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "types.h"


static inline size_t get_shape_size(size_t hash_size, size_t prop_size) {
  return hash_size * sizeof(uint32_t) + sizeof(JSShape) + prop_size * sizeof(JSShapeProperty);
}

static inline JSShape* get_shape_from_alloc(void* sh_alloc, size_t hash_size) {
  return (JSShape*)(void*)((uint32_t*)sh_alloc + hash_size);
}

static inline uint32_t* prop_hash_end(JSShape* sh) {
  return (uint32_t*)sh;
}

static inline void* get_alloc_from_shape(JSShape* sh) {
  return prop_hash_end(sh) - ((intptr_t)sh->prop_hash_mask + 1);
}

static inline JSShapeProperty* get_shape_prop(JSShape* sh) {
  return sh->prop;
}

int init_shape_hash(JSRuntime* rt);
/* same magic hash multiplier as the Linux kernel */
uint32_t shape_hash(uint32_t h, uint32_t val);
/* truncate the shape hash to 'hash_bits' bits */
uint32_t get_shape_hash(uint32_t h, int hash_bits);
uint32_t shape_initial_hash(JSObject* proto);
int resize_shape_hash(JSRuntime* rt, int new_shape_hash_bits);
void js_shape_hash_link(JSRuntime* rt, JSShape* sh);
void js_shape_hash_unlink(JSRuntime* rt, JSShape* sh);
/* create a new empty shape with prototype 'proto' */
no_inline JSShape* js_new_shape2(JSContext* ctx, JSObject* proto, int hash_size, int prop_size);
JSShape* js_new_shape(JSContext* ctx, JSObject* proto);

/* The shape is cloned. The new shape is not inserted in the shape
   hash table */
JSShape* js_clone_shape(JSContext* ctx, JSShape* sh1);
JSShape* js_dup_shape(JSShape* sh);
void js_free_shape0(JSRuntime* rt, JSShape* sh);
void js_free_shape(JSRuntime* rt, JSShape* sh);
void js_free_shape_null(JSRuntime* rt, JSShape* sh);
/* make space to hold at least 'count' properties */
no_inline int resize_properties(JSContext* ctx, JSShape** psh, JSObject* p, uint32_t count);
/* remove the deleted properties. */
int compact_properties(JSContext* ctx, JSObject* p);
int add_shape_property(JSContext* ctx, JSShape** psh, JSObject* p, JSAtom atom, int prop_flags);
/* find a hashed empty shape matching the prototype. Return NULL if
   not found */
JSShape* find_hashed_shape_proto(JSRuntime* rt, JSObject* proto);
/* find a hashed shape matching sh + (prop, prop_flags). Return NULL if
   not found */
JSShape* find_hashed_shape_prop(JSRuntime* rt, JSShape* sh, JSAtom atom, int prop_flags);;
__maybe_unused void JS_DumpShape(JSRuntime* rt, int i, JSShape* sh);
__maybe_unused void JS_DumpShapes(JSRuntime* rt);
JSValue JS_NewObjectFromShape(JSContext* ctx, JSShape* sh, JSClassID class_id);
/* ensure that the shape can be safely modified */
int js_shape_prepare_update(JSContext* ctx, JSObject* p, JSShapeProperty** pprs);

/* the watch point of shape for prototype inline cache or something else */
int js_shape_delete_watchpoints(JSRuntime *rt, JSShape *shape, void* target);
int js_shape_free_watchpoints(JSRuntime *rt, JSShape *shape);
ICWatchpoint* js_shape_create_watchpoint(JSRuntime *rt, JSShape *shape, intptr_t ptr, JSAtom atom,
                             watchpoint_delete_callback *remove_callback,
                             watchpoint_free_callback *clear_callback);

#endif
