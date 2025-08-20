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

#ifndef QUICKJS_JS_ARRAY_H
#define QUICKJS_JS_ARRAY_H

#include "../types.h"
#include "quickjs/cutils.h"
#include "quickjs/quickjs.h"

#define special_every 0
#define special_some 1
#define special_forEach 2
#define special_map 3
#define special_filter 4
#define special_TA 8

#define special_reduce 0
#define special_reduceRight 1

typedef struct JSArrayIteratorData {
  JSValue obj;
  JSIteratorKindEnum kind;
  uint32_t idx;
} JSArrayIteratorData;

JSValue js_create_iterator_result(JSContext* ctx, JSValue val, BOOL done);
JSValue js_array_iterator_next(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, BOOL* pdone, int magic);

JSValue js_create_array_iterator(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
BOOL js_is_fast_array(JSContext* ctx, JSValueConst obj);
/* Access an Array's internal JSValue array if available */
BOOL js_get_fast_array(JSContext* ctx, JSValueConst obj, JSValue** arrpp, uint32_t* countp);

int expand_fast_array(JSContext* ctx, JSObject* p, uint32_t new_len);

int JS_CopySubArray(JSContext* ctx, JSValueConst obj, int64_t to_pos, int64_t from_pos, int64_t count, int dir);
JSValue js_array_constructor(JSContext* ctx, JSValueConst new_target, int argc, JSValueConst* argv);
JSValue js_array_from(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_array_of(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_array_isArray(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_get_this(JSContext* ctx, JSValueConst this_val);
JSValue JS_ArraySpeciesCreate(JSContext* ctx, JSValueConst obj, JSValueConst len_val);
int JS_isConcatSpreadable(JSContext* ctx, JSValueConst obj);
JSValue js_array_concat(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
int js_typed_array_get_length_internal(JSContext* ctx, JSValueConst obj);
JSValue js_typed_array___speciesCreate(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_array_every(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int special);
JSValue js_array_reduce(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int special);
JSValue js_array_fill(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_array_includes(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_array_indexOf(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_array_lastIndexOf(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_array_find(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int findIndex);
JSValue js_array_toString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_array_join(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int toLocaleString);
JSValue js_array_pop(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int shift);
JSValue js_array_push(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int unshift);
JSValue js_array_reverse(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_array_slice(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int splice);
JSValue js_array_copyWithin(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
int64_t JS_FlattenIntoArray(JSContext* ctx, JSValueConst target, JSValueConst source, int64_t sourceLen, int64_t targetIndex, int depth, JSValueConst mapperFunction, JSValueConst thisArg);
JSValue js_array_flatten(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int map);
int js_array_cmp_generic(const void* a, const void* b, void* opaque);
JSValue js_array_sort(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

void js_array_iterator_finalizer(JSRuntime* rt, JSValue val);
void js_array_iterator_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);
JSValue js_create_array(JSContext* ctx, int len, JSValueConst* tab);

__exception int js_append_enumerate(JSContext* ctx, JSValue* sp);

void js_array_finalizer(JSRuntime* rt, JSValue val);
void js_array_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

JSValue js_iterator_proto_iterator(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

#endif