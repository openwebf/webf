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

#ifndef QUICKJS_JS_GENERATOR_H
#define QUICKJS_JS_GENERATOR_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "../types.h"

/* XXX: use enum */
#define GEN_MAGIC_NEXT   0
#define GEN_MAGIC_RETURN 1
#define GEN_MAGIC_THROW  2

typedef enum JSGeneratorStateEnum {
  JS_GENERATOR_STATE_SUSPENDED_START,
  JS_GENERATOR_STATE_SUSPENDED_YIELD,
  JS_GENERATOR_STATE_SUSPENDED_YIELD_STAR,
  JS_GENERATOR_STATE_EXECUTING,
  JS_GENERATOR_STATE_COMPLETED,
} JSGeneratorStateEnum;

typedef struct JSGeneratorData {
  JSGeneratorStateEnum state;
  JSAsyncFunctionState func_state;
} JSGeneratorData;

void free_generator_stack_rt(JSRuntime *rt, JSGeneratorData *s);
void js_generator_finalizer(JSRuntime *rt, JSValue obj);
void free_generator_stack(JSContext *ctx, JSGeneratorData *s);
void js_generator_mark(JSRuntime *rt, JSValueConst val,
                              JS_MarkFunc *mark_func);

JSValue js_generator_next(JSContext *ctx, JSValueConst this_val,
                                 int argc, JSValueConst *argv,
                                 BOOL *pdone, int magic);
JSValue js_generator_function_call(JSContext *ctx, JSValueConst func_obj,
                                          JSValueConst this_obj,
                                          int argc, JSValueConst *argv,
                                          int flags);


#endif