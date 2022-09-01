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

#ifndef QUICKJS_JS_ASYNC_FUNCTION_H
#define QUICKJS_JS_ASYNC_FUNCTION_H

#include "quickjs/quickjs.h"
#include "../types.h"

JSValue async_func_resume(JSContext *ctx, JSAsyncFunctionState *s);
__exception int async_func_init(JSContext *ctx, JSAsyncFunctionState *s,
                                       JSValueConst func_obj, JSValueConst this_obj,
                                       int argc, JSValueConst *argv);
void async_func_free(JSRuntime *rt, JSAsyncFunctionState *s);
void async_func_mark(JSRuntime *rt, JSAsyncFunctionState *s,
                            JS_MarkFunc *mark_func);

void js_async_function_terminate(JSRuntime *rt, JSAsyncFunctionData *s);
void js_async_function_free0(JSRuntime *rt, JSAsyncFunctionData *s);
void js_async_function_free(JSRuntime *rt, JSAsyncFunctionData *s);
void js_async_function_resolve_finalizer(JSRuntime *rt, JSValue val);
void js_async_function_resolve_mark(JSRuntime *rt, JSValueConst val,
                                           JS_MarkFunc *mark_func);
int js_async_function_resolve_create(JSContext *ctx,
                                            JSAsyncFunctionData *s,
                                            JSValue *resolving_funcs);
void js_async_function_resume(JSContext *ctx, JSAsyncFunctionData *s);
JSValue js_async_function_resolve_call(JSContext *ctx,
                                              JSValueConst func_obj,
                                              JSValueConst this_obj,
                                              int argc, JSValueConst *argv,
                                              int flags);
JSValue js_async_function_call(JSContext *ctx, JSValueConst func_obj,
                                      JSValueConst this_obj,
                                      int argc, JSValueConst *argv, int flags);

#endif