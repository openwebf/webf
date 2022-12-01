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

#include "exception.h"
#include "builtins/js-function.h"
#include "runtime.h"
#include "string.h"

JSValue JS_NewError(JSContext* ctx) {
  return JS_NewObjectClass(ctx, JS_CLASS_ERROR);
}

JSValue JS_ThrowError2(JSContext* ctx, JSErrorEnum error_num, const char* fmt, va_list ap, BOOL add_backtrace) {
  char buf[256];
  JSValue obj, ret;

  vsnprintf(buf, sizeof(buf), fmt, ap);
  obj = JS_NewObjectProtoClass(ctx, ctx->native_error_proto[error_num], JS_CLASS_ERROR);
  if (unlikely(JS_IsException(obj))) {
    /* out of memory: throw JS_NULL to avoid recursing */
    obj = JS_NULL;
  } else {
    JS_DefinePropertyValue(ctx, obj, JS_ATOM_message, JS_NewString(ctx, buf), JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  }
  if (add_backtrace) {
    build_backtrace(ctx, obj, NULL, 0, 0, 0);
  }
  ret = JS_Throw(ctx, obj);
  return ret;
}

JSValue JS_ThrowError(JSContext* ctx, JSErrorEnum error_num, const char* fmt, va_list ap) {
  JSRuntime* rt = ctx->rt;
  JSStackFrame* sf;
  BOOL add_backtrace;

  /* the backtrace is added later if called from a bytecode function */
  sf = rt->current_stack_frame;
  add_backtrace = !rt->in_out_of_memory && (!sf || (JS_GetFunctionBytecode(sf->cur_func) == NULL));
  return JS_ThrowError2(ctx, error_num, fmt, ap, add_backtrace);
}

JSValue __attribute__((format(printf, 2, 3))) JS_ThrowSyntaxError(JSContext* ctx, const char* fmt, ...) {
  JSValue val;
  va_list ap;

  va_start(ap, fmt);
  val = JS_ThrowError(ctx, JS_SYNTAX_ERROR, fmt, ap);
  va_end(ap);
  return val;
}

JSValue __attribute__((format(printf, 2, 3))) JS_ThrowTypeError(JSContext* ctx, const char* fmt, ...) {
  JSValue val;
  va_list ap;

  va_start(ap, fmt);
  val = JS_ThrowError(ctx, JS_TYPE_ERROR, fmt, ap);
  va_end(ap);
  return val;
}

int __attribute__((format(printf, 3, 4)))
JS_ThrowTypeErrorOrFalse(JSContext* ctx, int flags, const char* fmt, ...) {
  va_list ap;

  if ((flags & JS_PROP_THROW) || ((flags & JS_PROP_THROW_STRICT) && is_strict_mode(ctx))) {
    va_start(ap, fmt);
    JS_ThrowError(ctx, JS_TYPE_ERROR, fmt, ap);
    va_end(ap);
    return -1;
  } else {
    return FALSE;
  }
}

/* never use it directly */
JSValue __attribute__((format(printf, 3, 4)))
__JS_ThrowTypeErrorAtom(JSContext* ctx, JSAtom atom, const char* fmt, ...) {
  char buf[ATOM_GET_STR_BUF_SIZE];
  return JS_ThrowTypeError(ctx, fmt, JS_AtomGetStr(ctx, buf, sizeof(buf), atom));
}

/* never use it directly */
JSValue __attribute__((format(printf, 3, 4)))
__JS_ThrowSyntaxErrorAtom(JSContext* ctx, JSAtom atom, const char* fmt, ...) {
  char buf[ATOM_GET_STR_BUF_SIZE];
  return JS_ThrowSyntaxError(ctx, fmt, JS_AtomGetStr(ctx, buf, sizeof(buf), atom));
}

/* WARNING: obj is freed */
JSValue JS_Throw(JSContext *ctx, JSValue obj)
{
  JSRuntime *rt = ctx->rt;
  JS_FreeValue(ctx, rt->current_exception);
  rt->current_exception = obj;
#if ENABLE_DEBUGGER
  js_debugger_exception(ctx);
#endif
  return JS_EXCEPTION;
}

/* return the pending exception (cannot be called twice). */
JSValue JS_GetException(JSContext *ctx)
{
  JSValue val;
  JSRuntime *rt = ctx->rt;
  val = rt->current_exception;
  rt->current_exception = JS_NULL;
  return val;
}

JSValue JS_ThrowTypeErrorPrivateNotFound(JSContext *ctx, JSAtom atom)
{
  return JS_ThrowTypeErrorAtom(ctx, "private class field '%s' does not exist",
                               atom);
}

int JS_ThrowTypeErrorReadOnly(JSContext* ctx, int flags, JSAtom atom) {
  if ((flags & JS_PROP_THROW) || ((flags & JS_PROP_THROW_STRICT) && is_strict_mode(ctx))) {
    JS_ThrowTypeErrorAtom(ctx, "'%s' is read-only", atom);
    return -1;
  } else {
    return FALSE;
  }
}

JSValue __attribute__((format(printf, 2, 3))) JS_ThrowReferenceError(JSContext* ctx, const char* fmt, ...) {
  JSValue val;
  va_list ap;

  va_start(ap, fmt);
  val = JS_ThrowError(ctx, JS_REFERENCE_ERROR, fmt, ap);
  va_end(ap);
  return val;
}

JSValue __attribute__((format(printf, 2, 3))) JS_ThrowRangeError(JSContext* ctx, const char* fmt, ...) {
  JSValue val;
  va_list ap;

  va_start(ap, fmt);
  val = JS_ThrowError(ctx, JS_RANGE_ERROR, fmt, ap);
  va_end(ap);
  return val;
}

JSValue __attribute__((format(printf, 2, 3))) JS_ThrowInternalError(JSContext* ctx, const char* fmt, ...) {
  JSValue val;
  va_list ap;

  va_start(ap, fmt);
  val = JS_ThrowError(ctx, JS_INTERNAL_ERROR, fmt, ap);
  va_end(ap);
  return val;
}

JSValue JS_ThrowOutOfMemory(JSContext* ctx) {
  JSRuntime* rt = ctx->rt;
  if (!rt->in_out_of_memory) {
    rt->in_out_of_memory = TRUE;
    JS_ThrowInternalError(ctx, "out of memory");
    rt->in_out_of_memory = FALSE;
  }
  return JS_EXCEPTION;
}

JSValue JS_ThrowStackOverflow(JSContext* ctx) {
  return JS_ThrowInternalError(ctx, "stack overflow");
}

JSValue JS_ThrowTypeErrorNotAnObject(JSContext* ctx) {
  return JS_ThrowTypeError(ctx, "not an object");
}

JSValue JS_ThrowTypeErrorNotASymbol(JSContext* ctx) {
  return JS_ThrowTypeError(ctx, "not a symbol");
}

JSValue JS_ThrowReferenceErrorNotDefined(JSContext* ctx, JSAtom name) {
  char buf[ATOM_GET_STR_BUF_SIZE];
  return JS_ThrowReferenceError(ctx, "'%s' is not defined", JS_AtomGetStr(ctx, buf, sizeof(buf), name));
}

JSValue JS_ThrowReferenceErrorUninitialized(JSContext* ctx, JSAtom name) {
  char buf[ATOM_GET_STR_BUF_SIZE];
  return JS_ThrowReferenceError(ctx, "%s is not initialized",
                                name == JS_ATOM_NULL ? "lexical variable" : JS_AtomGetStr(ctx, buf, sizeof(buf), name));
}

JSValue JS_ThrowReferenceErrorUninitialized2(JSContext* ctx, JSFunctionBytecode* b, int idx, BOOL is_ref) {
  JSAtom atom = JS_ATOM_NULL;
  if (is_ref) {
    atom = b->closure_var[idx].var_name;
  } else {
    /* not present if the function is stripped and contains no eval() */
    if (b->vardefs)
      atom = b->vardefs[b->arg_count + idx].var_name;
  }
  return JS_ThrowReferenceErrorUninitialized(ctx, atom);
}

JSValue JS_ThrowTypeErrorInvalidClass(JSContext* ctx, int class_id) {
  JSRuntime* rt = ctx->rt;
  JSAtom name;
  name = rt->class_array[class_id].class_name;
  return JS_ThrowTypeErrorAtom(ctx, "%s object expected", name);
}

BOOL JS_IsError(JSContext* ctx, JSValueConst val) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(val) != JS_TAG_OBJECT)
    return FALSE;
  p = JS_VALUE_GET_OBJ(val);
  return (p->class_id == JS_CLASS_ERROR);
}

/* used to avoid catching interrupt exceptions */
BOOL JS_IsUncatchableError(JSContext* ctx, JSValueConst val) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(val) != JS_TAG_OBJECT)
    return FALSE;
  p = JS_VALUE_GET_OBJ(val);
  return p->class_id == JS_CLASS_ERROR && p->is_uncatchable_error;
}

void JS_SetUncatchableError(JSContext* ctx, JSValueConst val, BOOL flag) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(val) != JS_TAG_OBJECT)
    return;
  p = JS_VALUE_GET_OBJ(val);
  if (p->class_id == JS_CLASS_ERROR)
    p->is_uncatchable_error = flag;
}

void JS_ResetUncatchableError(JSContext* ctx) {
  JS_SetUncatchableError(ctx, ctx->rt->current_exception, FALSE);
}