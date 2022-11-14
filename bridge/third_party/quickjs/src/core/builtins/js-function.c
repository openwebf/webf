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

#include "js-function.h"
#include "../convertion.h"
#include "../exception.h"
#include "../function.h"
#include "../gc.h"
#include "../object.h"
#include "../runtime.h"
#include "../string.h"
#include "../types.h"
#include "js-closures.h"
#include "js-operator.h"

void js_c_function_finalizer(JSRuntime* rt, JSValue val) {
  JSObject* p = JS_VALUE_GET_OBJ(val);

  if (p->u.cfunc.realm)
    JS_FreeContext(p->u.cfunc.realm);
}

void js_c_function_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) {
  JSObject* p = JS_VALUE_GET_OBJ(val);

  if (p->u.cfunc.realm)
    mark_func(rt, &p->u.cfunc.realm->header);
}

void js_bytecode_function_finalizer(JSRuntime* rt, JSValue val) {
  JSObject *p1, *p = JS_VALUE_GET_OBJ(val);
  JSFunctionBytecode* b;
  JSVarRef** var_refs;
  int i;

  p1 = p->u.func.home_object;
  if (p1) {
    JS_FreeValueRT(rt, JS_MKPTR(JS_TAG_OBJECT, p1));
  }
  b = p->u.func.function_bytecode;
  if (b) {
    var_refs = p->u.func.var_refs;
    if (var_refs) {
      for (i = 0; i < b->closure_var_count; i++)
        free_var_ref(rt, var_refs[i]);
      js_free_rt(rt, var_refs);
    }
    JS_FreeValueRT(rt, JS_MKPTR(JS_TAG_FUNCTION_BYTECODE, b));
  }
}

void js_bytecode_function_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) {
  JSObject* p = JS_VALUE_GET_OBJ(val);
  JSVarRef** var_refs = p->u.func.var_refs;
  JSFunctionBytecode* b = p->u.func.function_bytecode;
  int i;

  if (p->u.func.home_object) {
    JS_MarkValue(rt, JS_MKPTR(JS_TAG_OBJECT, p->u.func.home_object), mark_func);
  }
  if (b) {
    if (var_refs) {
      for (i = 0; i < b->closure_var_count; i++) {
        JSVarRef* var_ref = var_refs[i];
        if (var_ref && var_ref->is_detached) {
          mark_func(rt, &var_ref->header);
        }
      }
    }
    /* must mark the function bytecode because template objects may be
       part of a cycle */
    JS_MarkValue(rt, JS_MKPTR(JS_TAG_FUNCTION_BYTECODE, b), mark_func);
  }
}

void js_bound_function_finalizer(JSRuntime* rt, JSValue val) {
  JSObject* p = JS_VALUE_GET_OBJ(val);
  JSBoundFunction* bf = p->u.bound_function;
  int i;

  JS_FreeValueRT(rt, bf->func_obj);
  JS_FreeValueRT(rt, bf->this_val);
  for (i = 0; i < bf->argc; i++) {
    JS_FreeValueRT(rt, bf->argv[i]);
  }
  js_free_rt(rt, bf);
}

void js_bound_function_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) {
  JSObject* p = JS_VALUE_GET_OBJ(val);
  JSBoundFunction* bf = p->u.bound_function;
  int i;

  JS_MarkValue(rt, bf->func_obj, mark_func);
  JS_MarkValue(rt, bf->this_val, mark_func);
  for (i = 0; i < bf->argc; i++)
    JS_MarkValue(rt, bf->argv[i], mark_func);
}

void free_arg_list(JSContext* ctx, JSValue* tab, uint32_t len) {
  uint32_t i;
  for (i = 0; i < len; i++) {
    JS_FreeValue(ctx, tab[i]);
  }
  js_free(ctx, tab);
}

JSValue js_function_proto(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  return JS_UNDEFINED;
}

/* XXX: add a specific eval mode so that Function("}), ({") is rejected */
JSValue js_function_constructor(JSContext* ctx,
                                       JSValueConst new_target,
                                       int argc,
                                       JSValueConst* argv,
                                       int magic) {
  JSFunctionKindEnum func_kind = magic;
  int i, n, ret;
  JSValue s, proto, obj = JS_UNDEFINED;
  StringBuffer b_s, *b = &b_s;

  string_buffer_init(ctx, b, 0);
  string_buffer_putc8(b, '(');

  if (func_kind == JS_FUNC_ASYNC || func_kind == JS_FUNC_ASYNC_GENERATOR) {
    string_buffer_puts8(b, "async ");
  }
  string_buffer_puts8(b, "function");

  if (func_kind == JS_FUNC_GENERATOR || func_kind == JS_FUNC_ASYNC_GENERATOR) {
    string_buffer_putc8(b, '*');
  }
  string_buffer_puts8(b, " anonymous(");

  n = argc - 1;
  for (i = 0; i < n; i++) {
    if (i != 0) {
      string_buffer_putc8(b, ',');
    }
    if (string_buffer_concat_value(b, argv[i]))
      goto fail;
  }
  string_buffer_puts8(b, "\n) {\n");
  if (n >= 0) {
    if (string_buffer_concat_value(b, argv[n]))
      goto fail;
  }
  string_buffer_puts8(b, "\n})");
  s = string_buffer_end(b);
  if (JS_IsException(s))
    goto fail1;

  obj = JS_EvalObject(ctx, ctx->global_obj, s, JS_EVAL_TYPE_INDIRECT, -1);
  JS_FreeValue(ctx, s);
  if (JS_IsException(obj))
    goto fail1;
  if (!JS_IsUndefined(new_target)) {
    /* set the prototype */
    proto = JS_GetProperty(ctx, new_target, JS_ATOM_prototype);
    if (JS_IsException(proto))
      goto fail1;
    if (!JS_IsObject(proto)) {
      JSContext* realm;
      JS_FreeValue(ctx, proto);
      realm = JS_GetFunctionRealm(ctx, new_target);
      if (!realm)
        goto fail1;
      proto = JS_DupValue(ctx, realm->class_proto[func_kind_to_class_id[func_kind]]);
    }
    ret = JS_SetPrototypeInternal(ctx, obj, proto, TRUE);
    JS_FreeValue(ctx, proto);
    if (ret < 0)
      goto fail1;
  }
  return obj;

fail:
  string_buffer_free(b);
fail1:
  JS_FreeValue(ctx, obj);
  return JS_EXCEPTION;
}

__exception int js_get_length32(JSContext* ctx, uint32_t* pres, JSValueConst obj) {
  JSValue len_val;
  len_val = JS_GetProperty(ctx, obj, JS_ATOM_length);
  if (JS_IsException(len_val)) {
    *pres = 0;
    return -1;
  }
  return JS_ToUint32Free(ctx, pres, len_val);
}

__exception int js_get_length64(JSContext* ctx, int64_t* pres, JSValueConst obj) {
  JSValue len_val;
  len_val = JS_GetProperty(ctx, obj, JS_ATOM_length);
  if (JS_IsException(len_val)) {
    *pres = 0;
    return -1;
  }
  return JS_ToLengthFree(ctx, pres, len_val);
}

/* XXX: should use ValueArray */
JSValue* build_arg_list(JSContext* ctx, uint32_t* plen, JSValueConst array_arg) {
  uint32_t len, i;
  JSValue *tab, ret;
  JSObject* p;

  if (JS_VALUE_GET_TAG(array_arg) != JS_TAG_OBJECT) {
    JS_ThrowTypeError(ctx, "not a object");
    return NULL;
  }
  if (js_get_length32(ctx, &len, array_arg))
    return NULL;
  if (len > JS_MAX_LOCAL_VARS) {
    JS_ThrowInternalError(ctx, "too many arguments");
    return NULL;
  }
  /* avoid allocating 0 bytes */
  tab = js_mallocz(ctx, sizeof(tab[0]) * max_uint32(1, len));
  if (!tab)
    return NULL;
  p = JS_VALUE_GET_OBJ(array_arg);
  if ((p->class_id == JS_CLASS_ARRAY || p->class_id == JS_CLASS_ARGUMENTS) && p->fast_array &&
      len == p->u.array.count) {
    for (i = 0; i < len; i++) {
      tab[i] = JS_DupValue(ctx, p->u.array.u.values[i]);
    }
  } else {
    for (i = 0; i < len; i++) {
      ret = JS_GetPropertyUint32(ctx, array_arg, i);
      if (JS_IsException(ret)) {
        free_arg_list(ctx, tab, i);
        return NULL;
      }
      tab[i] = ret;
    }
  }
  *plen = len;
  return tab;
}

void js_function_set_properties(JSContext* ctx, JSValueConst func_obj, JSAtom name, int len) {
  /* ES6 feature non compatible with ES5.1: length is configurable */
  JS_DefinePropertyValue(ctx, func_obj, JS_ATOM_length, JS_NewInt32(ctx, len), JS_PROP_CONFIGURABLE);
  JS_DefinePropertyValue(ctx, func_obj, JS_ATOM_name, JS_AtomToString(ctx, name), JS_PROP_CONFIGURABLE);
}

/* magic value: 0 = normal apply, 1 = apply for constructor, 2 =
   Reflect.apply */
JSValue js_function_apply(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic) {
  JSValueConst this_arg, array_arg;
  uint32_t len;
  JSValue *tab, ret;

  if (check_function(ctx, this_val))
    return JS_EXCEPTION;
  this_arg = argv[0];
  array_arg = argv[1];
  if ((JS_VALUE_GET_TAG(array_arg) == JS_TAG_UNDEFINED || JS_VALUE_GET_TAG(array_arg) == JS_TAG_NULL) && magic != 2) {
    return JS_Call(ctx, this_val, this_arg, 0, NULL);
  }
  tab = build_arg_list(ctx, &len, array_arg);
  if (!tab)
    return JS_EXCEPTION;
  if (magic & 1) {
    ret = JS_CallConstructor2(ctx, this_val, this_arg, len, (JSValueConst*)tab);
  } else {
    ret = JS_Call(ctx, this_val, this_arg, len, (JSValueConst*)tab);
  }
  free_arg_list(ctx, tab, len);
  return ret;
}

JSValue js_function_call(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc <= 0) {
    return JS_Call(ctx, this_val, JS_UNDEFINED, 0, NULL);
  } else {
    return JS_Call(ctx, this_val, argv[0], argc - 1, argv + 1);
  }
}

JSValue js_function_bind(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSBoundFunction* bf;
  JSValue func_obj, name1, len_val;
  JSObject* p;
  int arg_count, i, ret;

  if (check_function(ctx, this_val))
    return JS_EXCEPTION;

  func_obj = JS_NewObjectProtoClass(ctx, ctx->function_proto, JS_CLASS_BOUND_FUNCTION);
  if (JS_IsException(func_obj))
    return JS_EXCEPTION;
  p = JS_VALUE_GET_OBJ(func_obj);
  p->is_constructor = JS_IsConstructor(ctx, this_val);
  arg_count = max_int(0, argc - 1);
  bf = js_malloc(ctx, sizeof(*bf) + arg_count * sizeof(JSValue));
  if (!bf)
    goto exception;
  bf->func_obj = JS_DupValue(ctx, this_val);
  bf->this_val = JS_DupValue(ctx, argv[0]);
  bf->argc = arg_count;
  for (i = 0; i < arg_count; i++) {
    bf->argv[i] = JS_DupValue(ctx, argv[i + 1]);
  }
  p->u.bound_function = bf;

  /* XXX: the spec could be simpler by only using GetOwnProperty */
  ret = JS_GetOwnProperty(ctx, NULL, this_val, JS_ATOM_length);
  if (ret < 0)
    goto exception;
  if (!ret) {
    len_val = JS_NewInt32(ctx, 0);
  } else {
    len_val = JS_GetProperty(ctx, this_val, JS_ATOM_length);
    if (JS_IsException(len_val))
      goto exception;
    if (JS_VALUE_GET_TAG(len_val) == JS_TAG_INT) {
      /* most common case */
      int len1 = JS_VALUE_GET_INT(len_val);
      if (len1 <= arg_count)
        len1 = 0;
      else
        len1 -= arg_count;
      len_val = JS_NewInt32(ctx, len1);
    } else if (JS_VALUE_GET_NORM_TAG(len_val) == JS_TAG_FLOAT64) {
      double d = JS_VALUE_GET_FLOAT64(len_val);
      if (isnan(d)) {
        d = 0.0;
      } else {
        d = trunc(d);
        if (d <= (double)arg_count)
          d = 0.0;
        else
          d -= (double)arg_count; /* also converts -0 to +0 */
      }
      len_val = JS_NewFloat64(ctx, d);
    } else {
      JS_FreeValue(ctx, len_val);
      len_val = JS_NewInt32(ctx, 0);
    }
  }
  JS_DefinePropertyValue(ctx, func_obj, JS_ATOM_length, len_val, JS_PROP_CONFIGURABLE);

  name1 = JS_GetProperty(ctx, this_val, JS_ATOM_name);
  if (JS_IsException(name1))
    goto exception;
  if (!JS_IsString(name1)) {
    JS_FreeValue(ctx, name1);
    name1 = JS_AtomToString(ctx, JS_ATOM_empty_string);
  }
  name1 = JS_ConcatString3(ctx, "bound ", name1, "");
  if (JS_IsException(name1))
    goto exception;
  JS_DefinePropertyValue(ctx, func_obj, JS_ATOM_name, name1, JS_PROP_CONFIGURABLE);
  return func_obj;
exception:
  JS_FreeValue(ctx, func_obj);
  return JS_EXCEPTION;
}

JSValue js_function_toString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSObject* p;
  JSFunctionKindEnum func_kind = JS_FUNC_NORMAL;

  if (check_function(ctx, this_val))
    return JS_EXCEPTION;

  p = JS_VALUE_GET_OBJ(this_val);
  if (js_class_has_bytecode(p->class_id)) {
    JSFunctionBytecode* b = p->u.func.function_bytecode;
    if (b->has_debug && b->debug.source) {
      return JS_NewStringLen(ctx, b->debug.source, b->debug.source_len);
    }
    func_kind = b->func_kind;
  }
  {
    JSValue name;
    const char *pref, *suff;

    switch (func_kind) {
      default:
      case JS_FUNC_NORMAL:
        pref = "function ";
        break;
      case JS_FUNC_GENERATOR:
        pref = "function *";
        break;
      case JS_FUNC_ASYNC:
        pref = "async function ";
        break;
      case JS_FUNC_ASYNC_GENERATOR:
        pref = "async function *";
        break;
    }
    suff = "() {\n    [native code]\n}";
    name = JS_GetProperty(ctx, this_val, JS_ATOM_name);
    if (JS_IsUndefined(name))
      name = JS_AtomToString(ctx, JS_ATOM_empty_string);
    return JS_ConcatString3(ctx, pref, name, suff);
  }
}

JSValue js_function_hasInstance(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  int ret;
  ret = JS_OrdinaryIsInstanceOf(ctx, argv[0], this_val);
  if (ret < 0)
    return JS_EXCEPTION;
  else
    return JS_NewBool(ctx, ret);
}

/* XXX: not 100% compatible, but mozilla seems to use a similar
   implementation to ensure that caller in non strict mode does not
   throw (ES5 compatibility) */
JSValue js_function_proto_caller(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSFunctionBytecode* b = JS_GetFunctionBytecode(this_val);
  if (!b || (b->js_mode & JS_MODE_STRICT) || !b->has_prototype) {
    return js_throw_type_error(ctx, this_val, 0, NULL);
  }
  return JS_UNDEFINED;
}

JSValue js_function_proto_fileName(JSContext* ctx, JSValueConst this_val) {
  JSFunctionBytecode* b = JS_GetFunctionBytecode(this_val);
  if (b && b->has_debug) {
    return JS_AtomToString(ctx, b->debug.filename);
  }
  return JS_UNDEFINED;
}

JSValue js_function_proto_lineNumber(JSContext* ctx, JSValueConst this_val) {
  JSFunctionBytecode* b = JS_GetFunctionBytecode(this_val);
  if (b && b->has_debug) {
    return JS_NewInt32(ctx, b->debug.line_num);
  }
  return JS_UNDEFINED;
}

JSValue js_function_proto_columnNumber(JSContext *ctx, JSValueConst this_val) {
  JSFunctionBytecode* b = JS_GetFunctionBytecode(this_val);
  if (b && b->has_debug) {
    return JS_NewInt32(ctx, b->debug.column_num);
  }
  return JS_UNDEFINED;
}

int js_arguments_define_own_property(JSContext* ctx,
                                            JSValueConst this_obj,
                                            JSAtom prop,
                                            JSValueConst val,
                                            JSValueConst getter,
                                            JSValueConst setter,
                                            int flags) {
  JSObject* p;
  uint32_t idx;
  p = JS_VALUE_GET_OBJ(this_obj);
  /* convert to normal array when redefining an existing numeric field */
  if (p->fast_array && JS_AtomIsArrayIndex(ctx, &idx, prop) && idx < p->u.array.count) {
    if (convert_fast_array_to_array(ctx, p))
      return -1;
  }
  /* run the default define own property */
  return JS_DefineProperty(ctx, this_obj, prop, val, getter, setter, flags | JS_PROP_NO_EXOTIC);
}

JSValue js_build_arguments(JSContext* ctx, int argc, JSValueConst* argv) {
  JSValue val, *tab;
  JSProperty* pr;
  JSObject* p;
  int i;

  val = JS_NewObjectProtoClass(ctx, ctx->class_proto[JS_CLASS_OBJECT], JS_CLASS_ARGUMENTS);
  if (JS_IsException(val))
    return val;
  p = JS_VALUE_GET_OBJ(val);

  /* add the length field (cannot fail) */
  pr = add_property(ctx, p, JS_ATOM_length, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  pr->u.value = JS_NewInt32(ctx, argc);

  /* initialize the fast array part */
  tab = NULL;
  if (argc > 0) {
    tab = js_malloc(ctx, sizeof(tab[0]) * argc);
    if (!tab) {
      JS_FreeValue(ctx, val);
      return JS_EXCEPTION;
    }
    for (i = 0; i < argc; i++) {
      tab[i] = JS_DupValue(ctx, argv[i]);
    }
  }
  p->u.array.u.values = tab;
  p->u.array.count = argc;

  JS_DefinePropertyValue(ctx, val, JS_ATOM_Symbol_iterator, JS_DupValue(ctx, ctx->array_proto_values),
                         JS_PROP_CONFIGURABLE | JS_PROP_WRITABLE);
  /* add callee property to throw a TypeError in strict mode */
  JS_DefineProperty(ctx, val, JS_ATOM_callee, JS_UNDEFINED, ctx->throw_type_error, ctx->throw_type_error,
                    JS_PROP_HAS_GET | JS_PROP_HAS_SET);
  return val;
}

/* legacy arguments object: add references to the function arguments */
JSValue js_build_mapped_arguments(JSContext* ctx,
                                         int argc,
                                         JSValueConst* argv,
                                         JSStackFrame* sf,
                                         int arg_count) {
  JSValue val;
  JSProperty* pr;
  JSObject* p;
  int i;

  val = JS_NewObjectProtoClass(ctx, ctx->class_proto[JS_CLASS_OBJECT], JS_CLASS_MAPPED_ARGUMENTS);
  if (JS_IsException(val))
    return val;
  p = JS_VALUE_GET_OBJ(val);

  /* add the length field (cannot fail) */
  pr = add_property(ctx, p, JS_ATOM_length, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  pr->u.value = JS_NewInt32(ctx, argc);

  for (i = 0; i < arg_count; i++) {
    JSVarRef* var_ref;
    var_ref = get_var_ref(ctx, sf, i, TRUE);
    if (!var_ref)
      goto fail;
    pr = add_property(ctx, p, __JS_AtomFromUInt32(i), JS_PROP_C_W_E | JS_PROP_VARREF);
    if (!pr) {
      free_var_ref(ctx->rt, var_ref);
      goto fail;
    }
    pr->u.var_ref = var_ref;
  }

  /* the arguments not mapped to the arguments of the function can
     be normal properties */
  for (i = arg_count; i < argc; i++) {
    if (JS_DefinePropertyValueUint32(ctx, val, i, JS_DupValue(ctx, argv[i]), JS_PROP_C_W_E) < 0)
      goto fail;
  }

  JS_DefinePropertyValue(ctx, val, JS_ATOM_Symbol_iterator, JS_DupValue(ctx, ctx->array_proto_values),
                         JS_PROP_CONFIGURABLE | JS_PROP_WRITABLE);
  /* callee returns this function in non strict mode */
  JS_DefinePropertyValue(ctx, val, JS_ATOM_callee, JS_DupValue(ctx, ctx->rt->current_stack_frame->cur_func),
                         JS_PROP_CONFIGURABLE | JS_PROP_WRITABLE);
  return val;
fail:
  JS_FreeValue(ctx, val);
  return JS_EXCEPTION;
}


/* return NULL without exception if not a function or no bytecode */
JSFunctionBytecode *JS_GetFunctionBytecode(JSValueConst val)
{
  JSObject *p;
  if (JS_VALUE_GET_TAG(val) != JS_TAG_OBJECT)
    return NULL;
  p = JS_VALUE_GET_OBJ(val);
  if (!js_class_has_bytecode(p->class_id))
    return NULL;
  return p->u.func.function_bytecode;
}

void js_method_set_home_object(JSContext *ctx, JSValueConst func_obj,
                                      JSValueConst home_obj)
{
  JSObject *p, *p1;
  JSFunctionBytecode *b;

  if (JS_VALUE_GET_TAG(func_obj) != JS_TAG_OBJECT)
    return;
  p = JS_VALUE_GET_OBJ(func_obj);
  if (!js_class_has_bytecode(p->class_id))
    return;
  b = p->u.func.function_bytecode;
  if (b->need_home_object) {
    p1 = p->u.func.home_object;
    if (p1) {
      JS_FreeValue(ctx, JS_MKPTR(JS_TAG_OBJECT, p1));
    }
    if (JS_VALUE_GET_TAG(home_obj) == JS_TAG_OBJECT)
      p1 = JS_VALUE_GET_OBJ(JS_DupValue(ctx, home_obj));
    else
      p1 = NULL;
    p->u.func.home_object = p1;
  }
}

JSValue js_get_function_name(JSContext *ctx, JSAtom name)
{
  JSValue name_str;

  name_str = JS_AtomToString(ctx, name);
  if (JS_AtomSymbolHasDescription(ctx, name)) {
    name_str = JS_ConcatString3(ctx, "[", name_str, "]");
  }
  return name_str;
}

/* Modify the name of a method according to the atom and
   'flags'. 'flags' is a bitmask of JS_PROP_HAS_GET and
   JS_PROP_HAS_SET. Also set the home object of the method.
   Return < 0 if exception. */
int js_method_set_properties(JSContext *ctx, JSValueConst func_obj,
                                    JSAtom name, int flags, JSValueConst home_obj)
{
  JSValue name_str;

  name_str = js_get_function_name(ctx, name);
  if (flags & JS_PROP_HAS_GET) {
    name_str = JS_ConcatString3(ctx, "get ", name_str, "");
  } else if (flags & JS_PROP_HAS_SET) {
    name_str = JS_ConcatString3(ctx, "set ", name_str, "");
  }
  if (JS_IsException(name_str))
    return -1;
  if (JS_DefinePropertyValue(ctx, func_obj, JS_ATOM_name, name_str,
                             JS_PROP_CONFIGURABLE) < 0)
    return -1;
  js_method_set_home_object(ctx, func_obj, home_obj);
  return 0;
}
