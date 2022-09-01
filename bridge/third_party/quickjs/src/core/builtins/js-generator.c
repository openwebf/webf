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

#include "js-generator.h"
#include "../exception.h"
#include "../function.h"
#include "../object.h"
#include "js-async-function.h"
#include "quickjs/cutils.h"

/* Generators */
void free_generator_stack_rt(JSRuntime *rt, JSGeneratorData *s)
{
  if (s->state == JS_GENERATOR_STATE_COMPLETED)
    return;
  async_func_free(rt, &s->func_state);
  s->state = JS_GENERATOR_STATE_COMPLETED;
}

void js_generator_finalizer(JSRuntime *rt, JSValue obj)
{
  JSGeneratorData *s = JS_GetOpaque(obj, JS_CLASS_GENERATOR);

  if (s) {
    free_generator_stack_rt(rt, s);
    js_free_rt(rt, s);
  }
}

void free_generator_stack(JSContext *ctx, JSGeneratorData *s)
{
  free_generator_stack_rt(ctx->rt, s);
}

void js_generator_mark(JSRuntime *rt, JSValueConst val,
                              JS_MarkFunc *mark_func)
{
  JSObject *p = JS_VALUE_GET_OBJ(val);
  JSGeneratorData *s = p->u.generator_data;

  if (!s || s->state == JS_GENERATOR_STATE_COMPLETED)
    return;
  async_func_mark(rt, &s->func_state, mark_func);
}

JSValue js_generator_next(JSContext *ctx, JSValueConst this_val,
                                 int argc, JSValueConst *argv,
                                 BOOL *pdone, int magic)
{
  JSGeneratorData *s = JS_GetOpaque(this_val, JS_CLASS_GENERATOR);
  JSStackFrame *sf;
  JSValue ret, func_ret;

  *pdone = TRUE;
  if (!s)
    return JS_ThrowTypeError(ctx, "not a generator");
  sf = &s->func_state.frame;
  switch(s->state) {
    default:
    case JS_GENERATOR_STATE_SUSPENDED_START:
      if (magic == GEN_MAGIC_NEXT) {
        goto exec_no_arg;
      } else {
        free_generator_stack(ctx, s);
        goto done;
      }
      break;
    case JS_GENERATOR_STATE_SUSPENDED_YIELD_STAR:
    case JS_GENERATOR_STATE_SUSPENDED_YIELD:
      /* cur_sp[-1] was set to JS_UNDEFINED in the previous call */
      ret = JS_DupValue(ctx, argv[0]);
      if (magic == GEN_MAGIC_THROW &&
          s->state == JS_GENERATOR_STATE_SUSPENDED_YIELD) {
        JS_Throw(ctx, ret);
        s->func_state.throw_flag = TRUE;
      } else {
        sf->cur_sp[-1] = ret;
        sf->cur_sp[0] = JS_NewInt32(ctx, magic);
        sf->cur_sp++;
      exec_no_arg:
        s->func_state.throw_flag = FALSE;
      }
      s->state = JS_GENERATOR_STATE_EXECUTING;
      func_ret = async_func_resume(ctx, &s->func_state);
      s->state = JS_GENERATOR_STATE_SUSPENDED_YIELD;
      if (JS_IsException(func_ret)) {
        /* finalize the execution in case of exception */
        free_generator_stack(ctx, s);
        return func_ret;
      }
      if (JS_VALUE_GET_TAG(func_ret) == JS_TAG_INT) {
        /* get the returned yield value at the top of the stack */
        ret = sf->cur_sp[-1];
        sf->cur_sp[-1] = JS_UNDEFINED;
        if (JS_VALUE_GET_INT(func_ret) == FUNC_RET_YIELD_STAR) {
          s->state = JS_GENERATOR_STATE_SUSPENDED_YIELD_STAR;
          /* return (value, done) object */
          *pdone = 2;
        } else {
          *pdone = FALSE;
        }
      } else {
        /* end of iterator */
        ret = sf->cur_sp[-1];
        sf->cur_sp[-1] = JS_UNDEFINED;
        JS_FreeValue(ctx, func_ret);
        free_generator_stack(ctx, s);
      }
      break;
    case JS_GENERATOR_STATE_COMPLETED:
    done:
      /* execution is finished */
      switch(magic) {
        default:
        case GEN_MAGIC_NEXT:
          ret = JS_UNDEFINED;
          break;
        case GEN_MAGIC_RETURN:
          ret = JS_DupValue(ctx, argv[0]);
          break;
        case GEN_MAGIC_THROW:
          ret = JS_Throw(ctx, JS_DupValue(ctx, argv[0]));
          break;
      }
      break;
    case JS_GENERATOR_STATE_EXECUTING:
      ret = JS_ThrowTypeError(ctx, "cannot invoke a running generator");
      break;
  }
  return ret;
}

JSValue js_generator_function_call(JSContext *ctx, JSValueConst func_obj,
                                          JSValueConst this_obj,
                                          int argc, JSValueConst *argv,
                                          int flags)
{
  JSValue obj, func_ret;
  JSGeneratorData *s;

  s = js_mallocz(ctx, sizeof(*s));
  if (!s)
    return JS_EXCEPTION;
  s->state = JS_GENERATOR_STATE_SUSPENDED_START;
  if (async_func_init(ctx, &s->func_state, func_obj, this_obj, argc, argv)) {
    s->state = JS_GENERATOR_STATE_COMPLETED;
    goto fail;
  }

  /* execute the function up to 'OP_initial_yield' */
  func_ret = async_func_resume(ctx, &s->func_state);
  if (JS_IsException(func_ret))
    goto fail;
  JS_FreeValue(ctx, func_ret);

  obj = js_create_from_ctor(ctx, func_obj, JS_CLASS_GENERATOR);
  if (JS_IsException(obj))
    goto fail;
  JS_SetOpaque(obj, s);
  return obj;
fail:
  free_generator_stack_rt(ctx->rt, s);
  js_free(ctx, s);
  return JS_EXCEPTION;
}
