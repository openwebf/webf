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

#ifndef QUICKJS_JS_FUNCTION_H
#define QUICKJS_JS_FUNCTION_H

#include "quickjs/quickjs.h"
#include "../types.h"

#define GLOBAL_VAR_OFFSET 0x40000000
#define ARGUMENT_VAR_OFFSET 0x20000000

static const uint16_t func_kind_to_class_id[] = {
    [JS_FUNC_NORMAL] = JS_CLASS_BYTECODE_FUNCTION,
    [JS_FUNC_GENERATOR] = JS_CLASS_GENERATOR_FUNCTION,
    [JS_FUNC_ASYNC] = JS_CLASS_ASYNC_FUNCTION,
    [JS_FUNC_ASYNC_GENERATOR] = JS_CLASS_ASYNC_GENERATOR_FUNCTION,
};

JSValue js_function_apply(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
JSValue js_function_proto_caller(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
/* magic value: 0 = normal apply, 1 = apply for constructor, 2 =
   Reflect.apply */
JSValue js_function_apply(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
JSValue js_function_call(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_function_bind(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_function_toString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_function_hasInstance(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
/* XXX: not 100% compatible, but mozilla seems to use a similar
   implementation to ensure that caller in non strict mode does not
   throw (ES5 compatibility) */
JSValue js_function_proto_caller(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_function_proto_fileName(JSContext* ctx, JSValueConst this_val);
JSValue js_function_proto_lineNumber(JSContext* ctx, JSValueConst this_val);
JSValue js_function_proto_columnNumber(JSContext *ctx, JSValueConst this_val);

void js_c_function_finalizer(JSRuntime* rt, JSValue val);
void js_c_function_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

void js_bytecode_function_finalizer(JSRuntime* rt, JSValue val);
void js_bytecode_function_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

void js_bound_function_finalizer(JSRuntime* rt, JSValue val);
void js_bound_function_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

void free_arg_list(JSContext* ctx, JSValue* tab, uint32_t len);
JSValue js_function_proto(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

/* XXX: add a specific eval mode so that Function("}), ({") is rejected */
JSValue js_function_constructor(JSContext* ctx,
                                       JSValueConst new_target,
                                       int argc,
                                       JSValueConst* argv,
                                       int magic);
__exception int js_get_length32(JSContext* ctx, uint32_t* pres, JSValueConst obj);
__exception int js_get_length64(JSContext* ctx, int64_t* pres, JSValueConst obj);
/* XXX: should use ValueArray */
JSValue* build_arg_list(JSContext* ctx, uint32_t* plen, JSValueConst array_arg);

void js_function_set_properties(JSContext *ctx, JSValueConst func_obj,
                                       JSAtom name, int len);

int js_arguments_define_own_property(JSContext* ctx,
                                            JSValueConst this_obj,
                                            JSAtom prop,
                                            JSValueConst val,
                                            JSValueConst getter,
                                            JSValueConst setter,
                                            int flags);
JSValue js_build_arguments(JSContext* ctx, int argc, JSValueConst* argv);

/* legacy arguments object: add references to the function arguments */
JSValue js_build_mapped_arguments(JSContext* ctx,
                                         int argc,
                                         JSValueConst* argv,
                                         JSStackFrame* sf,
                                         int arg_count);

/* return NULL without exception if not a function or no bytecode */
JSFunctionBytecode *JS_GetFunctionBytecode(JSValueConst val);

void js_method_set_home_object(JSContext *ctx, JSValueConst func_obj,
                                      JSValueConst home_obj);
JSValue js_get_function_name(JSContext *ctx, JSAtom name);
/* Modify the name of a method according to the atom and
   'flags'. 'flags' is a bitmask of JS_PROP_HAS_GET and
   JS_PROP_HAS_SET. Also set the home object of the method.
   Return < 0 if exception. */
int js_method_set_properties(JSContext *ctx, JSValueConst func_obj,
                                    JSAtom name, int flags, JSValueConst home_obj);


#endif