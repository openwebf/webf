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

#ifndef QUICKJS_JS_ASYNC_GENERATOR_H
#define QUICKJS_JS_ASYNC_GENERATOR_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "../types.h"


typedef enum JSAsyncGeneratorStateEnum {
  JS_ASYNC_GENERATOR_STATE_SUSPENDED_START,
  JS_ASYNC_GENERATOR_STATE_SUSPENDED_YIELD,
  JS_ASYNC_GENERATOR_STATE_SUSPENDED_YIELD_STAR,
  JS_ASYNC_GENERATOR_STATE_EXECUTING,
  JS_ASYNC_GENERATOR_STATE_AWAITING_RETURN,
  JS_ASYNC_GENERATOR_STATE_COMPLETED,
} JSAsyncGeneratorStateEnum;

typedef struct JSAsyncGeneratorRequest {
  struct list_head link;
  /* completion */
  int completion_type; /* GEN_MAGIC_x */
  JSValue result;
  /* promise capability */
  JSValue promise;
  JSValue resolving_funcs[2];
} JSAsyncGeneratorRequest;

typedef struct JSAsyncGeneratorData {
  JSObject *generator; /* back pointer to the object (const) */
  JSAsyncGeneratorStateEnum state;
  JSAsyncFunctionState func_state;
  struct list_head queue; /* list of JSAsyncGeneratorRequest.link */
} JSAsyncGeneratorData;

void js_async_generator_free(JSRuntime *rt,
                                    JSAsyncGeneratorData *s);
void js_async_generator_finalizer(JSRuntime *rt, JSValue obj);
void js_async_generator_mark(JSRuntime *rt, JSValueConst val,
                                    JS_MarkFunc *mark_func);

int js_async_generator_resolve_function_create(JSContext *ctx,
                                                      JSValueConst generator,
                                                      JSValue *resolving_funcs,
                                                      BOOL is_resume_next);
int js_async_generator_await(JSContext *ctx,
                                    JSAsyncGeneratorData *s,
                                    JSValueConst value);
void js_async_generator_resolve_or_reject(JSContext *ctx,
                                                 JSAsyncGeneratorData *s,
                                                 JSValueConst result,
                                                 int is_reject);

void js_async_generator_resolve(JSContext *ctx,
                                       JSAsyncGeneratorData *s,
                                       JSValueConst value,
                                       BOOL done);

void js_async_generator_reject(JSContext *ctx,
                                      JSAsyncGeneratorData *s,
                                      JSValueConst exception);

void js_async_generator_complete(JSContext *ctx,
                                        JSAsyncGeneratorData *s);

int js_async_generator_completed_return(JSContext *ctx,
                                               JSAsyncGeneratorData *s,
                                               JSValueConst value);

void js_async_generator_resume_next(JSContext *ctx,
                                           JSAsyncGeneratorData *s);
/* magic = GEN_MAGIC_x */
JSValue js_async_generator_next(JSContext *ctx, JSValueConst this_val,
                                       int argc, JSValueConst *argv,
                                       int magic);

JSValue js_async_generator_function_call(JSContext *ctx, JSValueConst func_obj,
                                                JSValueConst this_obj,
                                                int argc, JSValueConst *argv,
                                                int flags);


#endif
