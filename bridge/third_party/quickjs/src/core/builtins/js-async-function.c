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

#include "js-async-function.h"
#include "../exception.h"
#include "../function.h"
#include "../gc.h"
#include "js-closures.h"
#include "js-promise.h"
#include "quickjs/cutils.h"
#include "quickjs/list.h"

/* JSAsyncFunctionState (used by generator and async functions) */
__exception int async_func_init(JSContext *ctx, JSAsyncFunctionState *s,
                                       JSValueConst func_obj, JSValueConst this_obj,
                                       int argc, JSValueConst *argv)
{
  JSObject *p;
  JSFunctionBytecode *b;
  JSStackFrame *sf;
  int local_count, i, arg_buf_len, n;

  sf = &s->frame;
  init_list_head(&sf->var_ref_list);
  p = JS_VALUE_GET_OBJ(func_obj);
  b = p->u.func.function_bytecode;
  sf->js_mode = b->js_mode;
  sf->cur_pc = b->byte_code_buf;
  arg_buf_len = max_int(b->arg_count, argc);
  local_count = arg_buf_len + b->var_count + b->stack_size;
  sf->arg_buf = js_malloc(ctx, sizeof(JSValue) * max_int(local_count, 1));
  if (!sf->arg_buf)
    return -1;
  sf->cur_func = JS_DupValue(ctx, func_obj);
  s->this_val = JS_DupValue(ctx, this_obj);
  s->argc = argc;
  sf->arg_count = arg_buf_len;
  sf->var_buf = sf->arg_buf + arg_buf_len;
  sf->cur_sp = sf->var_buf + b->var_count;
  for(i = 0; i < argc; i++)
    sf->arg_buf[i] = JS_DupValue(ctx, argv[i]);
  n = arg_buf_len + b->var_count;
  for(i = argc; i < n; i++)
    sf->arg_buf[i] = JS_UNDEFINED;
  return 0;
}

void async_func_mark(JSRuntime *rt, JSAsyncFunctionState *s,
                            JS_MarkFunc *mark_func)
{
  JSStackFrame *sf;
  JSValue *sp;

  sf = &s->frame;
  JS_MarkValue(rt, sf->cur_func, mark_func);
  JS_MarkValue(rt, s->this_val, mark_func);
  if (sf->cur_sp) {
    /* if the function is running, cur_sp is not known so we
       cannot mark the stack. Marking the variables is not needed
       because a running function cannot be part of a removable
       cycle */
    for(sp = sf->arg_buf; sp < sf->cur_sp; sp++)
      JS_MarkValue(rt, *sp, mark_func);
  }
}

void async_func_free(JSRuntime *rt, JSAsyncFunctionState *s)
{
  JSStackFrame *sf;
  JSValue *sp;

  sf = &s->frame;

  /* close the closure variables. */
  close_var_refs(rt, sf);

  if (sf->arg_buf) {
    /* cannot free the function if it is running */
    assert(sf->cur_sp != NULL);
    for(sp = sf->arg_buf; sp < sf->cur_sp; sp++) {
      JS_FreeValueRT(rt, *sp);
    }
    js_free_rt(rt, sf->arg_buf);
  }
  JS_FreeValueRT(rt, sf->cur_func);
  JS_FreeValueRT(rt, s->this_val);
}

JSValue async_func_resume(JSContext *ctx, JSAsyncFunctionState *s)
{
  JSValue func_obj;

  if (js_check_stack_overflow(ctx->rt, 0))
    return JS_ThrowStackOverflow(ctx);

  /* the tag does not matter provided it is not an object */
  func_obj = JS_MKPTR(JS_TAG_INT, s);
  return JS_CallInternal(ctx, func_obj, s->this_val, JS_UNDEFINED,
                         s->argc, s->frame.arg_buf, JS_CALL_FLAG_GENERATOR);
}



/* AsyncFunction */

void js_async_function_terminate(JSRuntime *rt, JSAsyncFunctionData *s)
{
  if (s->is_active) {
    async_func_free(rt, &s->func_state);
    s->is_active = FALSE;
  }
}

void js_async_function_free0(JSRuntime *rt, JSAsyncFunctionData *s)
{
  js_async_function_terminate(rt, s);
  JS_FreeValueRT(rt, s->resolving_funcs[0]);
  JS_FreeValueRT(rt, s->resolving_funcs[1]);
  remove_gc_object(&s->header);
  js_free_rt(rt, s);
}

void js_async_function_free(JSRuntime *rt, JSAsyncFunctionData *s)
{
  if (--s->header.ref_count == 0) {
    js_async_function_free0(rt, s);
  }
}

void js_async_function_resolve_finalizer(JSRuntime *rt, JSValue val)
{
  JSObject *p = JS_VALUE_GET_OBJ(val);
  JSAsyncFunctionData *s = p->u.async_function_data;
  if (s) {
    js_async_function_free(rt, s);
  }
}

void js_async_function_resolve_mark(JSRuntime *rt, JSValueConst val,
                                           JS_MarkFunc *mark_func)
{
  JSObject *p = JS_VALUE_GET_OBJ(val);
  JSAsyncFunctionData *s = p->u.async_function_data;
  if (s) {
    mark_func(rt, &s->header);
  }
}

int js_async_function_resolve_create(JSContext *ctx,
                                            JSAsyncFunctionData *s,
                                            JSValue *resolving_funcs)
{
  int i;
  JSObject *p;

  for(i = 0; i < 2; i++) {
    resolving_funcs[i] =
        JS_NewObjectProtoClass(ctx, ctx->function_proto,
                               JS_CLASS_ASYNC_FUNCTION_RESOLVE + i);
    if (JS_IsException(resolving_funcs[i])) {
      if (i == 1)
        JS_FreeValue(ctx, resolving_funcs[0]);
      return -1;
    }
    p = JS_VALUE_GET_OBJ(resolving_funcs[i]);
    s->header.ref_count++;
    p->u.async_function_data = s;
  }
  return 0;
}

void js_async_function_resume(JSContext *ctx, JSAsyncFunctionData *s)
{
  JSValue func_ret, ret2;

  func_ret = async_func_resume(ctx, &s->func_state);
  if (JS_IsException(func_ret)) {
    JSValue error;
  fail:
    error = JS_GetException(ctx);
    ret2 = JS_Call(ctx, s->resolving_funcs[1], JS_UNDEFINED,
                   1, (JSValueConst *)&error);
    JS_FreeValue(ctx, error);
    js_async_function_terminate(ctx->rt, s);
    JS_FreeValue(ctx, ret2); /* XXX: what to do if exception ? */
  } else {
    JSValue value;
    value = s->func_state.frame.cur_sp[-1];
    s->func_state.frame.cur_sp[-1] = JS_UNDEFINED;
    if (JS_IsUndefined(func_ret)) {
      /* function returned */
      ret2 = JS_Call(ctx, s->resolving_funcs[0], JS_UNDEFINED,
                     1, (JSValueConst *)&value);
      JS_FreeValue(ctx, ret2); /* XXX: what to do if exception ? */
      JS_FreeValue(ctx, value);
      js_async_function_terminate(ctx->rt, s);
    } else {
      JSValue promise, resolving_funcs[2], resolving_funcs1[2];
      int i, res;

      /* await */
      JS_FreeValue(ctx, func_ret); /* not used */
      promise = js_promise_resolve(ctx, ctx->promise_ctor,
                                   1, (JSValueConst *)&value, 0);
      JS_FreeValue(ctx, value);
      if (JS_IsException(promise))
        goto fail;
      if (js_async_function_resolve_create(ctx, s, resolving_funcs)) {
        JS_FreeValue(ctx, promise);
        goto fail;
      }

      /* Note: no need to create 'thrownawayCapability' as in
         the spec */
      for(i = 0; i < 2; i++)
        resolving_funcs1[i] = JS_UNDEFINED;
      res = perform_promise_then(ctx, promise,
                                 (JSValueConst *)resolving_funcs,
                                 (JSValueConst *)resolving_funcs1);
      JS_FreeValue(ctx, promise);
      for(i = 0; i < 2; i++)
        JS_FreeValue(ctx, resolving_funcs[i]);
      if (res)
        goto fail;
    }
  }
}

JSValue js_async_function_resolve_call(JSContext *ctx,
                                              JSValueConst func_obj,
                                              JSValueConst this_obj,
                                              int argc, JSValueConst *argv,
                                              int flags)
{
  JSObject *p = JS_VALUE_GET_OBJ(func_obj);
  JSAsyncFunctionData *s = p->u.async_function_data;
  BOOL is_reject = p->class_id - JS_CLASS_ASYNC_FUNCTION_RESOLVE;
  JSValueConst arg;

  if (argc > 0)
    arg = argv[0];
  else
    arg = JS_UNDEFINED;
  s->func_state.throw_flag = is_reject;
  if (is_reject) {
    JS_Throw(ctx, JS_DupValue(ctx, arg));
  } else {
    /* return value of await */
    s->func_state.frame.cur_sp[-1] = JS_DupValue(ctx, arg);
  }
  js_async_function_resume(ctx, s);
  return JS_UNDEFINED;
}

JSValue js_async_function_call(JSContext *ctx, JSValueConst func_obj,
                                      JSValueConst this_obj,
                                      int argc, JSValueConst *argv, int flags)
{
  JSValue promise;
  JSAsyncFunctionData *s;

  s = js_mallocz(ctx, sizeof(*s));
  if (!s)
    return JS_EXCEPTION;
  s->header.ref_count = 1;
  add_gc_object(ctx->rt, &s->header, JS_GC_OBJ_TYPE_ASYNC_FUNCTION);
  s->is_active = FALSE;
  s->resolving_funcs[0] = JS_UNDEFINED;
  s->resolving_funcs[1] = JS_UNDEFINED;

  promise = JS_NewPromiseCapability(ctx, s->resolving_funcs);
  if (JS_IsException(promise))
    goto fail;

  if (async_func_init(ctx, &s->func_state, func_obj, this_obj, argc, argv)) {
  fail:
    JS_FreeValue(ctx, promise);
    js_async_function_free(ctx->rt, s);
    return JS_EXCEPTION;
  }
  s->is_active = TRUE;

  js_async_function_resume(ctx, s);

  js_async_function_free(ctx->rt, s);

  return promise;
}
