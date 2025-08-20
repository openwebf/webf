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

#ifndef QUICKJS_RUNTIME_H
#define QUICKJS_RUNTIME_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "quickjs/list.h"
#include "types.h"
#include "builtins/js-array.h"
#include "builtins/js-function.h"
#include "builtins/js-object.h"
#include "builtins/js-operator.h"
#include "builtins/js-regexp.h"
#include "function.h"
#include "gc.h"

#if CONFIG_BIGNUM
#include "builtins/js-big-num.h"
#endif

#define JS_BACKTRACE_FLAG_SKIP_FIRST_LEVEL (1 << 0)
/* only taken into account if filename is provided */
#define JS_BACKTRACE_FLAG_SINGLE_LEVEL (1 << 1)

#define DEFINE_GLOBAL_LEX_VAR (1 << 7)
#define DEFINE_GLOBAL_FUNC_VAR (1 << 6)

typedef struct JSClassShortDef {
  JSAtom class_name;
  JSClassFinalizer* finalizer;
  JSClassGCMark* gc_mark;
} JSClassShortDef;

static const JSClassExoticMethods js_arguments_exotic_methods;
static const JSClassExoticMethods js_string_exotic_methods;
static const JSClassExoticMethods js_proxy_exotic_methods;
static const JSClassExoticMethods js_module_ns_exotic_methods;

static JSClassShortDef const js_std_class_def[] = {
    {JS_ATOM_Object, NULL, NULL},                                                           /* JS_CLASS_OBJECT */
    {JS_ATOM_Array, js_array_finalizer, js_array_mark},                                     /* JS_CLASS_ARRAY */
    {JS_ATOM_Error, NULL, NULL},                                                            /* JS_CLASS_ERROR */
    {JS_ATOM_Number, js_object_data_finalizer, js_object_data_mark},                        /* JS_CLASS_NUMBER */
    {JS_ATOM_String, js_object_data_finalizer, js_object_data_mark},                        /* JS_CLASS_STRING */
    {JS_ATOM_Boolean, js_object_data_finalizer, js_object_data_mark},                       /* JS_CLASS_BOOLEAN */
    {JS_ATOM_Symbol, js_object_data_finalizer, js_object_data_mark},                        /* JS_CLASS_SYMBOL */
    {JS_ATOM_Arguments, js_array_finalizer, js_array_mark},                                 /* JS_CLASS_ARGUMENTS */
    {JS_ATOM_Arguments, NULL, NULL},                                                        /* JS_CLASS_MAPPED_ARGUMENTS */
    {JS_ATOM_Date, js_object_data_finalizer, js_object_data_mark},                          /* JS_CLASS_DATE */
    {JS_ATOM_Object, NULL, NULL},                                                           /* JS_CLASS_MODULE_NS */
    {JS_ATOM_Function, js_c_function_finalizer, js_c_function_mark},                        /* JS_CLASS_C_FUNCTION */
    {JS_ATOM_Function, js_bytecode_function_finalizer, js_bytecode_function_mark},          /* JS_CLASS_BYTECODE_FUNCTION */
    {JS_ATOM_Function, js_bound_function_finalizer, js_bound_function_mark},                /* JS_CLASS_BOUND_FUNCTION */
    {JS_ATOM_Function, js_c_function_data_finalizer, js_c_function_data_mark},              /* JS_CLASS_C_FUNCTION_DATA */
    {JS_ATOM_GeneratorFunction, js_bytecode_function_finalizer, js_bytecode_function_mark}, /* JS_CLASS_GENERATOR_FUNCTION */
    {JS_ATOM_ForInIterator, js_for_in_iterator_finalizer, js_for_in_iterator_mark},         /* JS_CLASS_FOR_IN_ITERATOR */
    {JS_ATOM_RegExp, js_regexp_finalizer, NULL},                                            /* JS_CLASS_REGEXP */
    {JS_ATOM_ArrayBuffer, js_array_buffer_finalizer, NULL},                                 /* JS_CLASS_ARRAY_BUFFER */
    {JS_ATOM_SharedArrayBuffer, js_array_buffer_finalizer, NULL},                           /* JS_CLASS_SHARED_ARRAY_BUFFER */
    {JS_ATOM_Uint8ClampedArray, js_typed_array_finalizer, js_typed_array_mark},             /* JS_CLASS_UINT8C_ARRAY */
    {JS_ATOM_Int8Array, js_typed_array_finalizer, js_typed_array_mark},                     /* JS_CLASS_INT8_ARRAY */
    {JS_ATOM_Uint8Array, js_typed_array_finalizer, js_typed_array_mark},                    /* JS_CLASS_UINT8_ARRAY */
    {JS_ATOM_Int16Array, js_typed_array_finalizer, js_typed_array_mark},                    /* JS_CLASS_INT16_ARRAY */
    {JS_ATOM_Uint16Array, js_typed_array_finalizer, js_typed_array_mark},                   /* JS_CLASS_UINT16_ARRAY */
    {JS_ATOM_Int32Array, js_typed_array_finalizer, js_typed_array_mark},                    /* JS_CLASS_INT32_ARRAY */
    {JS_ATOM_Uint32Array, js_typed_array_finalizer, js_typed_array_mark},                   /* JS_CLASS_UINT32_ARRAY */
#ifdef CONFIG_BIGNUM
    {JS_ATOM_BigInt64Array, js_typed_array_finalizer, js_typed_array_mark},  /* JS_CLASS_BIG_INT64_ARRAY */
    {JS_ATOM_BigUint64Array, js_typed_array_finalizer, js_typed_array_mark}, /* JS_CLASS_BIG_UINT64_ARRAY */
#endif
    {JS_ATOM_Float32Array, js_typed_array_finalizer, js_typed_array_mark}, /* JS_CLASS_FLOAT32_ARRAY */
    {JS_ATOM_Float64Array, js_typed_array_finalizer, js_typed_array_mark}, /* JS_CLASS_FLOAT64_ARRAY */
    {JS_ATOM_DataView, js_typed_array_finalizer, js_typed_array_mark},     /* JS_CLASS_DATAVIEW */
#ifdef CONFIG_BIGNUM
    {JS_ATOM_BigInt, js_object_data_finalizer, js_object_data_mark},        /* JS_CLASS_BIG_INT */
    {JS_ATOM_BigFloat, js_object_data_finalizer, js_object_data_mark},      /* JS_CLASS_BIG_FLOAT */
    {JS_ATOM_BigFloatEnv, js_float_env_finalizer, NULL},                    /* JS_CLASS_FLOAT_ENV */
    {JS_ATOM_BigDecimal, js_object_data_finalizer, js_object_data_mark},    /* JS_CLASS_BIG_DECIMAL */
    {JS_ATOM_OperatorSet, js_operator_set_finalizer, js_operator_set_mark}, /* JS_CLASS_OPERATOR_SET */
#endif
    {JS_ATOM_Map, js_map_finalizer, js_map_mark},                                                          /* JS_CLASS_MAP */
    {JS_ATOM_Set, js_map_finalizer, js_map_mark},                                                          /* JS_CLASS_SET */
    {JS_ATOM_WeakMap, js_map_finalizer, js_map_mark},                                                      /* JS_CLASS_WEAKMAP */
    {JS_ATOM_WeakSet, js_map_finalizer, js_map_mark},                                                      /* JS_CLASS_WEAKSET */
    {JS_ATOM_Map_Iterator, js_map_iterator_finalizer, js_map_iterator_mark},                               /* JS_CLASS_MAP_ITERATOR */
    {JS_ATOM_Set_Iterator, js_map_iterator_finalizer, js_map_iterator_mark},                               /* JS_CLASS_SET_ITERATOR */
    {JS_ATOM_Array_Iterator, js_array_iterator_finalizer, js_array_iterator_mark},                         /* JS_CLASS_ARRAY_ITERATOR */
    {JS_ATOM_String_Iterator, js_array_iterator_finalizer, js_array_iterator_mark},                        /* JS_CLASS_STRING_ITERATOR */
    {JS_ATOM_RegExp_String_Iterator, js_regexp_string_iterator_finalizer, js_regexp_string_iterator_mark}, /* JS_CLASS_REGEXP_STRING_ITERATOR */
    {JS_ATOM_Generator, js_generator_finalizer, js_generator_mark},                                        /* JS_CLASS_GENERATOR */
};

static inline BOOL is_strict_mode(JSContext* ctx) {
  JSStackFrame* sf = ctx->rt->current_stack_frame;
  return (sf && (sf->js_mode & JS_MODE_STRICT));
};

#ifdef CONFIG_BIGNUM
static inline BOOL is_math_mode(JSContext* ctx) {
  JSStackFrame* sf = ctx->rt->current_stack_frame;
  return (sf && (sf->js_mode & JS_MODE_MATH));
}
#endif

int js_update_property_flags(JSContext* ctx, JSObject* p, JSShapeProperty** pprs, int flags);
BOOL js_class_has_bytecode(JSClassID class_id);

/* set the new value and free the old value after (freeing the value
   can reallocate the object data) */
static inline void set_value(JSContext* ctx, JSValue* pval, JSValue new_val) {
  JSValue old_val;
  old_val = *pval;
  *pval = new_val;
  JS_FreeValue(ctx, old_val);
}

void dbuf_put_leb128(DynBuf* s, uint32_t v);
void dbuf_put_sleb128(DynBuf* s, int32_t v1);
int get_leb128(uint32_t* pval, const uint8_t* buf, const uint8_t* buf_end);
int get_sleb128(int32_t* pval, const uint8_t* buf, const uint8_t* buf_end);
int find_line_num(JSContext* ctx, JSFunctionBytecode* b, uint32_t pc_value);
int find_column_num(JSContext* ctx, JSFunctionBytecode* b, uint32_t pc_value);

/* in order to avoid executing arbitrary code during the stack trace
   generation, we only look at simple 'name' properties containing a
   string. */
const char* get_func_name(JSContext* ctx, JSValueConst func);

/* if filename != NULL, an additional level is added with the filename
   and line number information (used for parse error). */
void build_backtrace(JSContext* ctx, JSValueConst error_obj, const char* filename, int line_num, int column_num, int backtrace_flags);
BOOL is_backtrace_needed(JSContext* ctx, JSValueConst obj);

/* return -1 (exception) or TRUE/FALSE */
int JS_SetPrototypeInternal(JSContext* ctx, JSValueConst obj, JSValueConst proto_val, BOOL throw_flag);
/* Only works for primitive types, otherwise return JS_NULL. */
JSValueConst JS_GetPrototypePrimitive(JSContext* ctx, JSValueConst val);
int JS_DeletePropertyInt64(JSContext* ctx, JSValueConst obj, int64_t idx, int flags);
JSValue JS_GetPrototypeFree(JSContext* ctx, JSValue obj);

JSValue JS_ThrowSyntaxErrorVarRedeclaration(JSContext* ctx, JSAtom prop);
int JS_CheckDefineGlobalVar(JSContext* ctx, JSAtom prop, int flags);
int JS_DefineGlobalVar(JSContext* ctx, JSAtom prop, int def_flags);
int JS_DefineGlobalFunction(JSContext* ctx, JSAtom prop, JSValueConst func, int def_flags);

JSValue JS_GetGlobalVar(JSContext* ctx, JSAtom prop, BOOL throw_ref_error);
/* construct a reference to a global variable */
int JS_GetGlobalVarRef(JSContext* ctx, JSAtom prop, JSValue* sp);
/* use for strict variable access: test if the variable exists */
int JS_CheckGlobalVar(JSContext* ctx, JSAtom prop);
/* flag = 0: normal variable write
   flag = 1: initialize lexical variable
   flag = 2: normal variable write, strict check was done before
*/
int JS_SetGlobalVar(JSContext* ctx, JSAtom prop, JSValue val, int flag);

void JS_SetIsHTMLDDA(JSContext* ctx, JSValueConst obj);
static inline BOOL JS_IsHTMLDDA(JSContext* ctx, JSValueConst obj) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return FALSE;
  p = JS_VALUE_GET_OBJ(obj);
  return p->is_HTMLDDA;
};

/* compute the property flags. For each flag: (JS_PROP_HAS_x forces
   it, otherwise def_flags is used)
   Note: makes assumption about the bit pattern of the flags
*/
int get_prop_flags(int flags, int def_flags);

/* set the array length and remove the array elements if necessary. */
int set_array_length(JSContext* ctx, JSObject* p, JSValue val, int flags);
/* WARNING: 'p' must be a typed array. Works even if the array buffer
   is detached */
uint32_t typed_array_get_length(JSContext* ctx, JSObject* p);
/* Preconditions: 'p' must be of class JS_CLASS_ARRAY, p->fast_array =
   TRUE and p->extensible = TRUE */
int add_fast_array_element(JSContext* ctx, JSObject* p, JSValue val, int flags);

int JS_CreateProperty(JSContext* ctx, JSObject* p, JSAtom prop, JSValueConst val, JSValueConst getter, JSValueConst setter, int flags);

/* return TRUE, FALSE or (-1) in case of exception */
int JS_OrdinaryIsInstanceOf(JSContext* ctx, JSValueConst val, JSValueConst obj);

JSContext* js_autoinit_get_realm(JSProperty* pr);
JSAutoInitIDEnum js_autoinit_get_id(JSProperty* pr);
void js_autoinit_free(JSRuntime* rt, JSProperty* pr);
void js_autoinit_mark(JSRuntime* rt, JSProperty* pr, JS_MarkFunc* mark_func);

no_inline __exception int __js_poll_interrupts(JSContext* ctx);
static inline __exception int js_poll_interrupts(JSContext* ctx) {
  if (unlikely(--ctx->interrupt_counter <= 0)) {
    return __js_poll_interrupts(ctx);
  } else {
    return 0;
  }
}

int check_function(JSContext* ctx, JSValueConst obj);
JSValue JS_EvalObject(JSContext* ctx, JSValueConst this_obj, JSValueConst val, int flags, int scope_idx);
int check_exception_free(JSContext* ctx, JSValue obj);
JSAtom find_atom(JSContext* ctx, const char* name);
JSValue JS_InstantiateFunctionListItem2(JSContext* ctx, JSObject* p, JSAtom atom, void* opaque);
int JS_InstantiateFunctionListItem(JSContext* ctx, JSValueConst obj, JSAtom atom, const JSCFunctionListEntry* e);
/* Note: 'func_obj' is not necessarily a constructor */
void JS_SetConstructor2(JSContext* ctx, JSValueConst func_obj, JSValueConst proto, int proto_flags, int ctor_flags);

JSValueConst JS_NewGlobalCConstructor(JSContext* ctx, const char* name, JSCFunction* func, int length, JSValueConst proto);

JSValue iterator_to_array(JSContext* ctx, JSValueConst items);
/* only valid inside C functions */
JSValueConst JS_GetActiveFunction(JSContext* ctx);
JSValue js_error_constructor(JSContext* ctx, JSValueConst new_target, int argc, JSValueConst* argv, int magic);
JSValue js_aggregate_error_constructor(JSContext* ctx, JSValueConst errors);
JSValue js_error_toString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
void JS_NewGlobalCConstructor2(JSContext* ctx, JSValue func_obj, const char* name, JSValueConst proto);
JSValueConst JS_NewGlobalCConstructorOnly(JSContext* ctx, const char* name, JSCFunction* func, int length, JSValueConst proto);
JSValue js_global_eval(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_global_isNaN(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_global_isFinite(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
int string_get_hex(JSString* p, int k, int n);
int init_class_range(JSRuntime* rt, JSClassShortDef const* tab, int start, int count);
/* the indirection is needed to make 'eval' optional */
JSValue JS_EvalInternal(JSContext* ctx, JSValueConst this_obj, const char* input, size_t input_len, const char* filename, int flags, int scope_idx);
JSValue JS_EvalFunctionInternal(JSContext* ctx, JSValue fun_obj, JSValueConst this_obj, JSVarRef** var_refs, JSStackFrame* sf);

#endif
