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

#ifndef QUICKJS_FUNCTION_H
#define QUICKJS_FUNCTION_H

#include <malloc.h>
#include "quickjs/cutils.h"
#include "quickjs/quickjs.h"
#include "types.h"

#define JS_CALL_FLAG_COPY_ARGV (1 << 1)
#define JS_CALL_FLAG_GENERATOR (1 << 2)

#define OP_DEFINE_METHOD_METHOD 0
#define OP_DEFINE_METHOD_GETTER 1
#define OP_DEFINE_METHOD_SETTER 2
#define OP_DEFINE_METHOD_ENUMERABLE 4

#define JS_THROW_VAR_RO 0
#define JS_THROW_VAR_REDECL 1
#define JS_THROW_VAR_UNINITIALIZED 2
#define JS_THROW_ERROR_DELETE_SUPER 3
#define JS_THROW_ERROR_ITERATOR_THROW 4

typedef struct JSCFunctionDataRecord {
  JSCFunctionData* func;
  uint8_t length;
  uint8_t data_len;
  uint16_t magic;
  JSValue data[0];
} JSCFunctionDataRecord;

/* argument of OP_special_object */
typedef enum {
  OP_SPECIAL_OBJECT_ARGUMENTS,
  OP_SPECIAL_OBJECT_MAPPED_ARGUMENTS,
  OP_SPECIAL_OBJECT_THIS_FUNC,
  OP_SPECIAL_OBJECT_NEW_TARGET,
  OP_SPECIAL_OBJECT_HOME_OBJECT,
  OP_SPECIAL_OBJECT_VAR_OBJECT,
  OP_SPECIAL_OBJECT_IMPORT_META,
} OPSpecialObjectEnum;

#define FUNC_RET_AWAIT 0
#define FUNC_RET_YIELD 1
#define FUNC_RET_YIELD_STAR 2

#if !defined(CONFIG_STACK_CHECK)
/* no stack limitation */
static inline uintptr_t js_get_stack_pointer(void) {
  return 0;
}

static inline BOOL js_check_stack_overflow(JSRuntime* rt, size_t alloca_size) {
  return FALSE;
}
#else
/* Note: OS and CPU dependent */
static inline uintptr_t js_get_stack_pointer(void) {
  #ifdef _MSC_VER
    return _AddressOfReturnAddress();
  #else
    return (uintptr_t)__builtin_frame_address(0);
  #endif
}

static inline BOOL js_check_stack_overflow(JSRuntime* rt, size_t alloca_size) {
  uintptr_t sp;
  sp = js_get_stack_pointer() - alloca_size;
  return unlikely(sp < rt->stack_limit);
}
#endif

JSValue js_call_c_function(JSContext* ctx,
                                  JSValueConst func_obj,
                                  JSValueConst this_obj,
                                  int argc,
                                  JSValueConst* argv,
                                  int flags);
JSValue js_call_bound_function(JSContext* ctx,
                                      JSValueConst func_obj,
                                      JSValueConst this_obj,
                                      int argc,
                                      JSValueConst* argv,
                                      int flags);
JSValue JS_CallInternal(JSContext* ctx,
                               JSValueConst func_obj,
                               JSValueConst this_obj,
                               JSValueConst new_target,
                               int argc,
                               JSValue* argv,
                               int flags);
JSValue JS_CallConstructorInternal(JSContext* ctx,
                                          JSValueConst func_obj,
                                          JSValueConst new_target,
                                          int argc,
                                          JSValue* argv,
                                          int flags);
BOOL JS_IsCFunction(JSContext* ctx, JSValueConst val, JSCFunction* func, int magic);

/* Note: at least 'length' arguments will be readable in 'argv' */
JSValue JS_NewCFunction3(JSContext* ctx,
                                JSCFunction* func,
                                const char* name,
                                int length,
                                JSCFunctionEnum cproto,
                                int magic,
                                JSValueConst proto_val);

/* warning: the refcount of the context is not incremented. Return
   NULL in case of exception (case of revoked proxy only) */
JSContext *JS_GetFunctionRealm(JSContext *ctx, JSValueConst func_obj);

JSValue JS_CallFree(JSContext* ctx, JSValue func_obj, JSValueConst this_obj, int argc, JSValueConst* argv);
JSValue JS_InvokeFree(JSContext* ctx, JSValue this_val, JSAtom atom, int argc, JSValueConst* argv);

void js_c_function_data_finalizer(JSRuntime* rt, JSValue val);
void js_c_function_data_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

JSValue js_c_function_data_call(JSContext* ctx,
                                       JSValueConst func_obj,
                                       JSValueConst this_val,
                                       int argc,
                                       JSValueConst* argv,
                                       int flags);

int js_op_define_class(JSContext* ctx,
                              JSValue* sp,
                              JSAtom class_name,
                              int class_flags,
                              JSVarRef** cur_var_refs,
                              JSStackFrame* sf,
                              BOOL is_computed_name);

#endif
