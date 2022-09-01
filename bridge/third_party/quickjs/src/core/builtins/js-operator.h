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

#ifndef QUICKJS_JS_OPERATOR_H
#define QUICKJS_JS_OPERATOR_H

#include "quickjs/cutils.h"
#include "quickjs/quickjs.h"
#include "../types.h"

typedef struct JSAsyncFromSyncIteratorData {
  JSValue sync_iter;
  JSValue next_method;
} JSAsyncFromSyncIteratorData;

void js_for_in_iterator_finalizer(JSRuntime* rt, JSValue val);
void js_for_in_iterator_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

void js_for_in_iterator_finalizer(JSRuntime* rt, JSValue val);
void js_for_in_iterator_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

JSValue JS_GetIterator2(JSContext* ctx, JSValueConst obj, JSValueConst method);
JSValue JS_CreateAsyncFromSyncIterator(JSContext* ctx, JSValueConst sync_iter);
JSValue JS_GetIterator(JSContext* ctx, JSValueConst obj, BOOL is_async);
JSValue JS_IteratorGetCompleteValue(JSContext* ctx, JSValueConst obj, BOOL* pdone);

/* return *pdone = 2 if the iterator object is not parsed */
JSValue JS_IteratorNext2(JSContext* ctx, JSValueConst enum_obj, JSValueConst method, int argc, JSValueConst* argv, int* pdone);
JSValue JS_IteratorNext(JSContext* ctx, JSValueConst enum_obj, JSValueConst method, int argc, JSValueConst* argv, BOOL* pdone);
/* return < 0 in case of exception */
int JS_IteratorClose(JSContext* ctx, JSValueConst enum_obj, BOOL is_exception_pending);
/* obj -> enum_rec (3 slots) */
__exception int js_for_of_start(JSContext* ctx, JSValue* sp, BOOL is_async);
double js_pow(double a, double b);
JSValue js_throw_type_error(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_build_rest(JSContext* ctx, int first, int argc, JSValueConst* argv);
JSValue build_for_in_iterator(JSContext* ctx, JSValue obj);
/* obj -> enum_obj */
__exception int js_for_in_start(JSContext* ctx, JSValue* sp);
/* enum_obj -> enum_obj value done */
__exception int js_for_in_next(JSContext* ctx, JSValue* sp);
__exception int js_for_of_next(JSContext* ctx, JSValue* sp, int offset);

BOOL js_strict_eq2(JSContext* ctx, JSValue op1, JSValue op2, JSStrictEqModeEnum eq_mode);
BOOL js_strict_eq(JSContext* ctx, JSValue op1, JSValue op2);
BOOL js_same_value(JSContext* ctx, JSValueConst op1, JSValueConst op2);
BOOL js_same_value_zero(JSContext* ctx, JSValueConst op1, JSValueConst op2);
no_inline int js_strict_eq_slow(JSContext* ctx, JSValue* sp, BOOL is_neq);
__exception int js_operator_in(JSContext* ctx, JSValue* sp);
__exception int js_has_unscopable(JSContext* ctx, JSValueConst obj, JSAtom atom);
__exception int js_operator_instanceof(JSContext* ctx, JSValue* sp);
__exception int js_operator_typeof(JSContext* ctx, JSValueConst op1);
__exception int js_operator_delete(JSContext* ctx, JSValue* sp);

__exception int js_iterator_get_value_done(JSContext* ctx, JSValue* sp);

#endif