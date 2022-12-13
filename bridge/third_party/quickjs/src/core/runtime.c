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

#include "runtime.h"
#include "builtins/js-array.h"
#include "builtins/js-function.h"
#include "builtins/js-object.h"
#include "builtins/js-proxy.h"
#include "builtins/js-string.h"
#include "exception.h"
#include "function.h"
#include "malloc.h"
#include "string.h"

#if CONFIG_BIGNUM
#include "quickjs/libbf.h"
#endif

#include "builtins/js-big-num.h"
#include "builtins/js-boolean.h"
#include "builtins/js-closures.h"
#include "builtins/js-date.h"
#include "builtins/js-generator.h"
#include "builtins/js-math.h"
#include "builtins/js-number.h"
#include "builtins/js-operator.h"
#include "builtins/js-reflect.h"
#include "builtins/js-symbol.h"
#include "convertion.h"
#include "gc.h"
#include "module.h"
#include "object.h"
#include "parser.h"
#include "shape.h"

static const JSClassExoticMethods js_arguments_exotic_methods = {
    .define_own_property = js_arguments_define_own_property,
};

void dbuf_put_leb128(DynBuf* s, uint32_t v) {
  uint32_t a;
  for (;;) {
    a = v & 0x7f;
    v >>= 7;
    if (v != 0) {
      dbuf_putc(s, a | 0x80);
    } else {
      dbuf_putc(s, a);
      break;
    }
  }
}



void dbuf_put_sleb128(DynBuf* s, int32_t v1) {
  uint32_t v = v1;
  dbuf_put_leb128(s, (2 * v) ^ -(v >> 31));
}

int get_leb128(uint32_t* pval, const uint8_t* buf, const uint8_t* buf_end) {
  const uint8_t* ptr = buf;
  uint32_t v, a, i;
  v = 0;
  for (i = 0; i < 5; i++) {
    if (unlikely(ptr >= buf_end))
      break;
    a = *ptr++;
    v |= (a & 0x7f) << (i * 7);
    if (!(a & 0x80)) {
      *pval = v;
      return ptr - buf;
    }
  }
  *pval = 0;
  return -1;
}

int get_sleb128(int32_t* pval, const uint8_t* buf, const uint8_t* buf_end) {
  int ret;
  uint32_t val;
  ret = get_leb128(&val, buf, buf_end);
  if (ret < 0) {
    *pval = 0;
    return -1;
  }
  *pval = (val >> 1) ^ -(val & 1);
  return ret;
}

int find_line_num(JSContext* ctx, JSFunctionBytecode* b, uint32_t pc_value) {
  const uint8_t *p_end, *p;
  int new_line_num, line_num, pc, v, ret;
  unsigned int op;

  if (!b->has_debug || !b->debug.pc2line_buf) {
    /* function was stripped */
    return -1;
  }

  pc = 0;
  p = b->debug.pc2line_buf;
  p_end = p + b->debug.pc2line_len;
  line_num = b->debug.line_num;
  while (p < p_end) {
    op = *p++;
    if (op == 0) {
      uint32_t val;
      ret = get_leb128(&val, p, p_end);
      if (ret < 0)
        goto fail;
      pc += val;
      p += ret;
      ret = get_sleb128(&v, p, p_end);
      if (ret < 0) {
      fail:
        /* should never happen */
        return b->debug.line_num;
      }
      p += ret;
      new_line_num = line_num + v;
    } else {
      op -= PC2LINE_OP_FIRST;
      pc += (op / PC2LINE_RANGE);
      new_line_num = line_num + (op % PC2LINE_RANGE) + PC2LINE_BASE;
    }

    if (pc_value < pc) {
      return line_num;
    }
    line_num = new_line_num;
  }
  return line_num;
}

int find_column_num(JSContext* ctx, JSFunctionBytecode* b, uint32_t pc_value) {
  const uint8_t* p_end, *p;
  int new_column_num, column_num, pc, v, ret;
  unsigned int op;

  if (!b->has_debug || !b->debug.pc2column_buf) {
    /* function was stripped */
    return -1;
  }

  pc = 0;
  p = b->debug.pc2column_buf;
  p_end = p + b->debug.pc2column_len;
  column_num = b->debug.column_num;
  while (p < p_end) {
    op = *p++;
    if (op == 0) {
      uint32_t val;
      ret = get_leb128(&val, p, p_end);
      if (ret < 0)
        goto fail;
      pc += val;
      p += ret;
      ret = get_sleb128(&v, p, p_end);
      if (ret < 0) {
      fail:
        /* should never happen */
        return b->debug.column_num;
      }
      p += ret;
      new_column_num = column_num + v;
    } else {
      op -= PC2COLUMN_OP_FIRST;
      pc += (op / PC2COLUMN_RANGE);
      new_column_num = column_num + (op % PC2COLUMN_RANGE) + PC2COLUMN_BASE;
    }

    if (pc_value < pc) {
      return column_num;
    }
    column_num = new_column_num;
  }
  return column_num;
}

int js_update_property_flags(JSContext* ctx, JSObject* p, JSShapeProperty** pprs, int flags) {
  if (flags != (*pprs)->flags) {
    if (js_shape_prepare_update(ctx, p, pprs))
      return -1;
    (*pprs)->flags = flags;
  }
  return 0;
}

BOOL js_class_has_bytecode(JSClassID class_id) {
  return (class_id == JS_CLASS_BYTECODE_FUNCTION || class_id == JS_CLASS_GENERATOR_FUNCTION || class_id == JS_CLASS_ASYNC_FUNCTION || class_id == JS_CLASS_ASYNC_GENERATOR_FUNCTION);
}

/* JSClass support */

JSClassID js_class_id_alloc = JS_CLASS_INIT_COUNT;
/* a new class ID is allocated if *pclass_id != 0 */
JSClassID JS_NewClassID(JSClassID* pclass_id) {
  JSClassID class_id;
  /* XXX: make it thread safe */
  class_id = *pclass_id;
  if (class_id == 0) {
    class_id = js_class_id_alloc++;
    *pclass_id = class_id;
  }
  return class_id;
}

BOOL JS_IsRegisteredClass(JSRuntime* rt, JSClassID class_id) {
  return (class_id < rt->class_count && rt->class_array[class_id].class_id != 0);
}

/* create a new object internal class. Return -1 if error, 0 if
   OK. The finalizer can be NULL if none is needed. */
static int JS_NewClass1(JSRuntime* rt, JSClassID class_id, const JSClassDef* class_def, JSAtom name) {
  int new_size, i;
  JSClass *cl, *new_class_array;
  struct list_head* el;

  if (class_id >= (1 << 16))
    return -1;
  if (class_id < rt->class_count && rt->class_array[class_id].class_id != 0)
    return -1;

  if (class_id >= rt->class_count) {
    new_size = max_int(JS_CLASS_INIT_COUNT, max_int(class_id + 1, rt->class_count * 3 / 2));

    /* reallocate the context class prototype array, if any */
    list_for_each(el, &rt->context_list) {
      JSContext* ctx = list_entry(el, JSContext, link);
      JSValue* new_tab;
      new_tab = js_realloc_rt(rt, ctx->class_proto, sizeof(ctx->class_proto[0]) * new_size);
      if (!new_tab)
        return -1;
      for (i = rt->class_count; i < new_size; i++)
        new_tab[i] = JS_NULL;
      ctx->class_proto = new_tab;
    }
    /* reallocate the class array */
    new_class_array = js_realloc_rt(rt, rt->class_array, sizeof(JSClass) * new_size);
    if (!new_class_array)
      return -1;
    memset(new_class_array + rt->class_count, 0, (new_size - rt->class_count) * sizeof(JSClass));
    rt->class_array = new_class_array;
    rt->class_count = new_size;
  }
  cl = &rt->class_array[class_id];
  cl->class_id = class_id;
  cl->class_name = JS_DupAtomRT(rt, name);
  cl->finalizer = class_def->finalizer;
  cl->gc_mark = class_def->gc_mark;
  cl->call = class_def->call;
  cl->exotic = class_def->exotic;
  return 0;
}

int JS_NewClass(JSRuntime* rt, JSClassID class_id, const JSClassDef* class_def) {
  int ret, len;
  JSAtom name;

  len = strlen(class_def->class_name);
  name = __JS_FindAtom(rt, class_def->class_name, len, JS_ATOM_TYPE_STRING);
  if (name == JS_ATOM_NULL) {
    name = __JS_NewAtomInit(rt, class_def->class_name, len, JS_ATOM_TYPE_STRING);
    if (name == JS_ATOM_NULL)
      return -1;
  }
  ret = JS_NewClass1(rt, class_id, class_def, name);
  JS_FreeAtomRT(rt, name);
  return ret;
}

/* return -1 (exception) or TRUE/FALSE */
int JS_SetPrototypeInternal(JSContext* ctx, JSValueConst obj, JSValueConst proto_val, BOOL throw_flag) {
  JSObject *proto, *p, *p1;
  JSShape* sh;

  if (throw_flag) {
    if (JS_VALUE_GET_TAG(obj) == JS_TAG_NULL || JS_VALUE_GET_TAG(obj) == JS_TAG_UNDEFINED)
      goto not_obj;
  } else {
    if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
      goto not_obj;
  }
  p = JS_VALUE_GET_OBJ(obj);
  if (JS_VALUE_GET_TAG(proto_val) != JS_TAG_OBJECT) {
    if (JS_VALUE_GET_TAG(proto_val) != JS_TAG_NULL) {
    not_obj:
      JS_ThrowTypeErrorNotAnObject(ctx);
      return -1;
    }
    proto = NULL;
  } else {
    proto = JS_VALUE_GET_OBJ(proto_val);
  }

  if (throw_flag && JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return TRUE;

  if (unlikely(p->class_id == JS_CLASS_PROXY))
    return js_proxy_setPrototypeOf(ctx, obj, proto_val, throw_flag);
  sh = p->shape;
  if (sh->proto == proto)
    return TRUE;
  if (!p->extensible) {
    if (throw_flag) {
      JS_ThrowTypeError(ctx, "object is not extensible");
      return -1;
    } else {
      return FALSE;
    }
  }
  if (proto) {
    /* check if there is a cycle */
    p1 = proto;
    do {
      if (p1 == p) {
        if (throw_flag) {
          JS_ThrowTypeError(ctx, "circular prototype chain");
          return -1;
        } else {
          return FALSE;
        }
      }
      /* Note: for Proxy objects, proto is NULL */
      p1 = p1->shape->proto;
    } while (p1 != NULL);
    JS_DupValue(ctx, proto_val);
  }

  if (js_shape_prepare_update(ctx, p, NULL))
    return -1;
  sh = p->shape;
  if (sh->proto)
    JS_FreeValue(ctx, JS_MKPTR(JS_TAG_OBJECT, sh->proto));
  sh->proto = proto;
  return TRUE;
}

/* return -1 (exception) or TRUE/FALSE */
int JS_SetPrototype(JSContext* ctx, JSValueConst obj, JSValueConst proto_val) {
  return JS_SetPrototypeInternal(ctx, obj, proto_val, TRUE);
}

/* Only works for primitive types, otherwise return JS_NULL. */
JSValueConst JS_GetPrototypePrimitive(JSContext* ctx, JSValueConst val) {
  switch (JS_VALUE_GET_NORM_TAG(val)) {
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT:
      val = ctx->class_proto[JS_CLASS_BIG_INT];
      break;
    case JS_TAG_BIG_FLOAT:
      val = ctx->class_proto[JS_CLASS_BIG_FLOAT];
      break;
    case JS_TAG_BIG_DECIMAL:
      val = ctx->class_proto[JS_CLASS_BIG_DECIMAL];
      break;
#endif
    case JS_TAG_INT:
    case JS_TAG_FLOAT64:
      val = ctx->class_proto[JS_CLASS_NUMBER];
      break;
    case JS_TAG_BOOL:
      val = ctx->class_proto[JS_CLASS_BOOLEAN];
      break;
    case JS_TAG_STRING:
      val = ctx->class_proto[JS_CLASS_STRING];
      break;
    case JS_TAG_SYMBOL:
      val = ctx->class_proto[JS_CLASS_SYMBOL];
      break;
    case JS_TAG_OBJECT:
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
    default:
      val = JS_NULL;
      break;
  }
  return val;
}

/* Return an Object, JS_NULL or JS_EXCEPTION in case of Proxy object. */
JSValue JS_GetPrototype(JSContext* ctx, JSValueConst obj) {
  JSValue val;
  if (JS_VALUE_GET_TAG(obj) == JS_TAG_OBJECT) {
    JSObject* p;
    p = JS_VALUE_GET_OBJ(obj);
    if (unlikely(p->class_id == JS_CLASS_PROXY)) {
      val = js_proxy_getPrototypeOf(ctx, obj);
    } else {
      p = p->shape->proto;
      if (!p)
        val = JS_NULL;
      else
        val = JS_DupValue(ctx, JS_MKPTR(JS_TAG_OBJECT, p));
    }
  } else {
    val = JS_DupValue(ctx, JS_GetPrototypePrimitive(ctx, obj));
  }
  return val;
}

JSValue JS_GetGlobalVar(JSContext* ctx, JSAtom prop, BOOL throw_ref_error) {
  JSObject* p;
  JSShapeProperty* prs;
  JSProperty* pr;

  /* no exotic behavior is possible in global_var_obj */
  p = JS_VALUE_GET_OBJ(ctx->global_var_obj);
  prs = find_own_property(&pr, p, prop);
  if (prs) {
    /* XXX: should handle JS_PROP_TMASK properties */
    if (unlikely(JS_IsUninitialized(pr->u.value)))
      return JS_ThrowReferenceErrorUninitialized(ctx, prs->atom);
    return JS_DupValue(ctx, pr->u.value);
  }
  return JS_GetPropertyInternal(ctx, ctx->global_obj, prop, ctx->global_obj, throw_ref_error);
}

/* construct a reference to a global variable */
int JS_GetGlobalVarRef(JSContext* ctx, JSAtom prop, JSValue* sp) {
  JSObject* p;
  JSShapeProperty* prs;
  JSProperty* pr;

  /* no exotic behavior is possible in global_var_obj */
  p = JS_VALUE_GET_OBJ(ctx->global_var_obj);
  prs = find_own_property(&pr, p, prop);
  if (prs) {
    /* XXX: should handle JS_PROP_AUTOINIT properties? */
    /* XXX: conformance: do these tests in
       OP_put_var_ref/OP_get_var_ref ? */
    if (unlikely(JS_IsUninitialized(pr->u.value))) {
      JS_ThrowReferenceErrorUninitialized(ctx, prs->atom);
      return -1;
    }
    if (unlikely(!(prs->flags & JS_PROP_WRITABLE))) {
      return JS_ThrowTypeErrorReadOnly(ctx, JS_PROP_THROW, prop);
    }
    sp[0] = JS_DupValue(ctx, ctx->global_var_obj);
  } else {
    int ret;
    ret = JS_HasProperty(ctx, ctx->global_obj, prop);
    if (ret < 0)
      return -1;
    if (ret) {
      sp[0] = JS_DupValue(ctx, ctx->global_obj);
    } else {
      sp[0] = JS_UNDEFINED;
    }
  }
  sp[1] = JS_AtomToValue(ctx, prop);
  return 0;
}

/* use for strict variable access: test if the variable exists */
int JS_CheckGlobalVar(JSContext* ctx, JSAtom prop) {
  JSObject* p;
  JSShapeProperty* prs;
  int ret;

  /* no exotic behavior is possible in global_var_obj */
  p = JS_VALUE_GET_OBJ(ctx->global_var_obj);
  prs = find_own_property1(p, prop);
  if (prs) {
    ret = TRUE;
  } else {
    ret = JS_HasProperty(ctx, ctx->global_obj, prop);
    if (ret < 0)
      return -1;
  }
  return ret;
}

/* flag = 0: normal variable write
   flag = 1: initialize lexical variable
   flag = 2: normal variable write, strict check was done before
*/
int JS_SetGlobalVar(JSContext* ctx, JSAtom prop, JSValue val, int flag) {
  JSObject* p;
  JSShapeProperty* prs;
  JSProperty* pr;
  int flags;

  /* no exotic behavior is possible in global_var_obj */
  p = JS_VALUE_GET_OBJ(ctx->global_var_obj);
  prs = find_own_property(&pr, p, prop);
  if (prs) {
    /* XXX: should handle JS_PROP_AUTOINIT properties? */
    if (flag != 1) {
      if (unlikely(JS_IsUninitialized(pr->u.value))) {
        JS_FreeValue(ctx, val);
        JS_ThrowReferenceErrorUninitialized(ctx, prs->atom);
        return -1;
      }
      if (unlikely(!(prs->flags & JS_PROP_WRITABLE))) {
        JS_FreeValue(ctx, val);
        return JS_ThrowTypeErrorReadOnly(ctx, JS_PROP_THROW, prop);
      }
    }
    set_value(ctx, &pr->u.value, val);
    return 0;
  }
  flags = JS_PROP_THROW_STRICT;
  if (is_strict_mode(ctx))
    flags |= JS_PROP_NO_ADD;
  return JS_SetPropertyInternal(ctx, ctx->global_obj, prop, val, flags);
}

/* return -1, FALSE or TRUE. return FALSE if not configurable or
   invalid object. return -1 in case of exception.
   flags can be 0, JS_PROP_THROW or JS_PROP_THROW_STRICT */
int JS_DeleteProperty(JSContext* ctx, JSValueConst obj, JSAtom prop, int flags) {
  JSValue obj1;
  JSObject* p;
  int res;

  obj1 = JS_ToObject(ctx, obj);
  if (JS_IsException(obj1))
    return -1;
  p = JS_VALUE_GET_OBJ(obj1);
  res = delete_property(ctx, p, prop);
  JS_FreeValue(ctx, obj1);
  if (res != FALSE)
    return res;
  if ((flags & JS_PROP_THROW) || ((flags & JS_PROP_THROW_STRICT) && is_strict_mode(ctx))) {
    JS_ThrowTypeError(ctx, "could not delete property");
    return -1;
  }
  return FALSE;
}

int JS_DeletePropertyInt64(JSContext* ctx, JSValueConst obj, int64_t idx, int flags) {
  JSAtom prop;
  int res;

  if ((uint64_t)idx <= JS_ATOM_MAX_INT) {
    /* fast path for fast arrays */
    return JS_DeleteProperty(ctx, obj, __JS_AtomFromUInt32(idx), flags);
  }
  prop = JS_NewAtomInt64(ctx, idx);
  if (prop == JS_ATOM_NULL)
    return -1;
  res = JS_DeleteProperty(ctx, obj, prop, flags);
  JS_FreeAtom(ctx, prop);
  return res;
}

JSValue JS_GetPrototypeFree(JSContext* ctx, JSValue obj) {
  JSValue obj1;
  obj1 = JS_GetPrototype(ctx, obj);
  JS_FreeValue(ctx, obj);
  return obj1;
}

JSValue JS_ThrowSyntaxErrorVarRedeclaration(JSContext* ctx, JSAtom prop) {
  return JS_ThrowSyntaxErrorAtom(ctx, "redeclaration of '%s'", prop);
}

/* flags is 0, DEFINE_GLOBAL_LEX_VAR or DEFINE_GLOBAL_FUNC_VAR */
/* XXX: could support exotic global object. */
int JS_CheckDefineGlobalVar(JSContext* ctx, JSAtom prop, int flags) {
  JSObject* p;
  JSShapeProperty* prs;

  p = JS_VALUE_GET_OBJ(ctx->global_obj);
  prs = find_own_property1(p, prop);
  /* XXX: should handle JS_PROP_AUTOINIT */
  if (flags & DEFINE_GLOBAL_LEX_VAR) {
    if (prs && !(prs->flags & JS_PROP_CONFIGURABLE))
      goto fail_redeclaration;
  } else {
    if (!prs && !p->extensible)
      goto define_error;
    if (flags & DEFINE_GLOBAL_FUNC_VAR) {
      if (prs) {
        if (!(prs->flags & JS_PROP_CONFIGURABLE) &&
            ((prs->flags & JS_PROP_TMASK) == JS_PROP_GETSET || ((prs->flags & (JS_PROP_WRITABLE | JS_PROP_ENUMERABLE)) != (JS_PROP_WRITABLE | JS_PROP_ENUMERABLE)))) {
        define_error:
          JS_ThrowTypeErrorAtom(ctx, "cannot define variable '%s'", prop);
          return -1;
        }
      }
    }
  }
  /* check if there already is a lexical declaration */
  p = JS_VALUE_GET_OBJ(ctx->global_var_obj);
  prs = find_own_property1(p, prop);
  if (prs) {
  fail_redeclaration:
    JS_ThrowSyntaxErrorVarRedeclaration(ctx, prop);
    return -1;
  }
  return 0;
}

/* def_flags is (0, DEFINE_GLOBAL_LEX_VAR) |
   JS_PROP_CONFIGURABLE | JS_PROP_WRITABLE */
/* XXX: could support exotic global object. */
int JS_DefineGlobalVar(JSContext* ctx, JSAtom prop, int def_flags) {
  JSObject* p;
  JSShapeProperty* prs;
  JSProperty* pr;
  JSValue val;
  int flags;

  if (def_flags & DEFINE_GLOBAL_LEX_VAR) {
    p = JS_VALUE_GET_OBJ(ctx->global_var_obj);
    flags = JS_PROP_ENUMERABLE | (def_flags & JS_PROP_WRITABLE) | JS_PROP_CONFIGURABLE;
    val = JS_UNINITIALIZED;
  } else {
    p = JS_VALUE_GET_OBJ(ctx->global_obj);
    flags = JS_PROP_ENUMERABLE | JS_PROP_WRITABLE | (def_flags & JS_PROP_CONFIGURABLE);
    val = JS_UNDEFINED;
  }
  prs = find_own_property1(p, prop);
  if (prs)
    return 0;
  if (!p->extensible)
    return 0;
  pr = add_property(ctx, p, prop, flags);
  if (unlikely(!pr))
    return -1;
  pr->u.value = val;
  return 0;
}

/* 'def_flags' is 0 or JS_PROP_CONFIGURABLE. */
/* XXX: could support exotic global object. */
int JS_DefineGlobalFunction(JSContext* ctx, JSAtom prop, JSValueConst func, int def_flags) {
  JSObject* p;
  JSShapeProperty* prs;
  int flags;

  p = JS_VALUE_GET_OBJ(ctx->global_obj);
  prs = find_own_property1(p, prop);
  flags = JS_PROP_HAS_VALUE | JS_PROP_THROW;
  if (!prs || (prs->flags & JS_PROP_CONFIGURABLE)) {
    flags |= JS_PROP_ENUMERABLE | JS_PROP_WRITABLE | def_flags | JS_PROP_HAS_CONFIGURABLE | JS_PROP_HAS_WRITABLE | JS_PROP_HAS_ENUMERABLE;
  }
  if (JS_DefineProperty(ctx, ctx->global_obj, prop, func, JS_UNDEFINED, JS_UNDEFINED, flags) < 0)
    return -1;
  return 0;
}

BOOL JS_IsFunction(JSContext* ctx, JSValueConst val) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(val) != JS_TAG_OBJECT)
    return FALSE;
  p = JS_VALUE_GET_OBJ(val);
  switch (p->class_id) {
    case JS_CLASS_BYTECODE_FUNCTION:
      return TRUE;
    case JS_CLASS_PROXY:
      return p->u.proxy_data->is_func;
    default:
      return (ctx->rt->class_array[p->class_id].call != NULL);
  }
}

BOOL JS_SetConstructorBit(JSContext* ctx, JSValueConst func_obj, BOOL val) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(func_obj) != JS_TAG_OBJECT)
    return FALSE;
  p = JS_VALUE_GET_OBJ(func_obj);
  p->is_constructor = val;
  return TRUE;
}

void JS_SetOpaque(JSValue obj, void* opaque) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(obj) == JS_TAG_OBJECT) {
    p = JS_VALUE_GET_OBJ(obj);
    p->u.opaque = opaque;
  }
}

/* return NULL if not an object of class class_id */
void* JS_GetOpaque(JSValueConst obj, JSClassID class_id) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return NULL;
  p = JS_VALUE_GET_OBJ(obj);
  if (p->class_id != class_id)
    return NULL;
  return p->u.opaque;
}

void* JS_GetOpaque2(JSContext* ctx, JSValueConst obj, JSClassID class_id) {
  void* p = JS_GetOpaque(obj, class_id);
  if (unlikely(!p)) {
    JS_ThrowTypeErrorInvalidClass(ctx, class_id);
  }
  return p;
}

JSValue JS_GetGlobalObject(JSContext *ctx)
{
  return JS_DupValue(ctx, ctx->global_obj);
}

JSValue JS_NewCFunctionData(JSContext *ctx, JSCFunctionData *func,
                            int length, int magic, int data_len,
                            JSValueConst *data)
{
  JSCFunctionDataRecord *s;
  JSValue func_obj;
  int i;

  func_obj = JS_NewObjectProtoClass(ctx, ctx->function_proto,
                                    JS_CLASS_C_FUNCTION_DATA);
  if (JS_IsException(func_obj))
    return func_obj;
  s = js_malloc(ctx, sizeof(*s) + data_len * sizeof(JSValue));
  if (!s) {
    JS_FreeValue(ctx, func_obj);
    return JS_EXCEPTION;
  }
  s->func = func;
  s->length = length;
  s->data_len = data_len;
  s->magic = magic;
  for(i = 0; i < data_len; i++)
    s->data[i] = JS_DupValue(ctx, data[i]);
  JS_SetOpaque(func_obj, s);
  js_function_set_properties(ctx, func_obj,
                             JS_ATOM_empty_string, length);
  return func_obj;
}

/* compute the property flags. For each flag: (JS_PROP_HAS_x forces
   it, otherwise def_flags is used)
   Note: makes assumption about the bit pattern of the flags
*/
int get_prop_flags(int flags, int def_flags) {
  int mask;
  mask = (flags >> JS_PROP_HAS_SHIFT) & JS_PROP_C_W_E;
  return (flags & mask) | (def_flags & ~mask);
}


/* set the array length and remove the array elements if necessary. */
int set_array_length(JSContext *ctx, JSObject *p, JSValue val,
                            int flags)
{
  uint32_t len, idx, cur_len;
  int i, ret;

  /* Note: this call can reallocate the properties of 'p' */
  ret = JS_ToArrayLengthFree(ctx, &len, val, FALSE);
  if (ret)
    return -1;
  /* JS_ToArrayLengthFree() must be done before the read-only test */
  if (unlikely(!(p->shape->prop[0].flags & JS_PROP_WRITABLE)))
    return JS_ThrowTypeErrorReadOnly(ctx, flags, JS_ATOM_length);

  if (likely(p->fast_array)) {
    uint32_t old_len = p->u.array.count;
    if (len < old_len) {
      for(i = len; i < old_len; i++) {
        JS_FreeValue(ctx, p->u.array.u.values[i]);
      }
      p->u.array.count = len;
    }
    p->prop[0].u.value = JS_NewUint32(ctx, len);
  } else {
    /* Note: length is always a uint32 because the object is an
       array */
    JS_ToUint32(ctx, &cur_len, p->prop[0].u.value);
    if (len < cur_len) {
      uint32_t d;
      JSShape *sh;
      JSShapeProperty *pr;

      d = cur_len - len;
      sh = p->shape;
      if (d <= sh->prop_count) {
        JSAtom atom;

        /* faster to iterate */
        while (cur_len > len) {
          atom = JS_NewAtomUInt32(ctx, cur_len - 1);
          ret = delete_property(ctx, p, atom);
          JS_FreeAtom(ctx, atom);
          if (unlikely(!ret)) {
            /* unlikely case: property is not
               configurable */
            break;
          }
          cur_len--;
        }
      } else {
        /* faster to iterate thru all the properties. Need two
           passes in case one of the property is not
           configurable */
        cur_len = len;
        for(i = 0, pr = get_shape_prop(sh); i < sh->prop_count;
             i++, pr++) {
          if (pr->atom != JS_ATOM_NULL &&
              JS_AtomIsArrayIndex(ctx, &idx, pr->atom)) {
            if (idx >= cur_len &&
                !(pr->flags & JS_PROP_CONFIGURABLE)) {
              cur_len = idx + 1;
            }
          }
        }

        for(i = 0, pr = get_shape_prop(sh); i < sh->prop_count;
             i++, pr++) {
          if (pr->atom != JS_ATOM_NULL &&
              JS_AtomIsArrayIndex(ctx, &idx, pr->atom)) {
            if (idx >= cur_len) {
              /* remove the property */
              delete_property(ctx, p, pr->atom);
              /* WARNING: the shape may have been modified */
              sh = p->shape;
              pr = get_shape_prop(sh) + i;
            }
          }
        }
      }
    } else {
      cur_len = len;
    }
    set_value(ctx, &p->prop[0].u.value, JS_NewUint32(ctx, cur_len));
    if (unlikely(cur_len > len)) {
      return JS_ThrowTypeErrorOrFalse(ctx, flags, "not configurable");
    }
  }
  return TRUE;
}

/* WARNING: 'p' must be a typed array. Works even if the array buffer
   is detached */
uint32_t typed_array_get_length(JSContext* ctx, JSObject* p) {
  JSTypedArray* ta = p->u.typed_array;
  int size_log2 = typed_array_size_log2(p->class_id);
  return ta->length >> size_log2;
}

/* Preconditions: 'p' must be of class JS_CLASS_ARRAY, p->fast_array =
   TRUE and p->extensible = TRUE */
int add_fast_array_element(JSContext* ctx, JSObject* p, JSValue val, int flags) {
  uint32_t new_len, array_len;
  /* extend the array by one */
  /* XXX: convert to slow array if new_len > 2^31-1 elements */
  new_len = p->u.array.count + 1;
  /* update the length if necessary. We assume that if the length is
     not an integer, then if it >= 2^31.  */
  if (likely(JS_VALUE_GET_TAG(p->prop[0].u.value) == JS_TAG_INT)) {
    array_len = JS_VALUE_GET_INT(p->prop[0].u.value);
    if (new_len > array_len) {
      if (unlikely(!(get_shape_prop(p->shape)->flags & JS_PROP_WRITABLE))) {
        JS_FreeValue(ctx, val);
        return JS_ThrowTypeErrorReadOnly(ctx, flags, JS_ATOM_length);
      }
      p->prop[0].u.value = JS_NewInt32(ctx, new_len);
    }
  }
  if (unlikely(new_len > p->u.array.u1.size)) {
    if (expand_fast_array(ctx, p, new_len)) {
      JS_FreeValue(ctx, val);
      return -1;
    }
  }
  p->u.array.u.values[new_len - 1] = val;
  p->u.array.count = new_len;
  return TRUE;
}

int JS_CreateProperty(JSContext* ctx, JSObject* p, JSAtom prop, JSValueConst val, JSValueConst getter, JSValueConst setter, int flags) {
  JSProperty* pr;
  int ret, prop_flags;

  /* add a new property or modify an existing exotic one */
  if (p->is_exotic) {
    if (p->class_id == JS_CLASS_ARRAY) {
      uint32_t idx, len;

      if (p->fast_array) {
        if (__JS_AtomIsTaggedInt(prop)) {
          idx = __JS_AtomToUInt32(prop);
          if (idx == p->u.array.count) {
            if (!p->extensible)
              goto not_extensible;
            if (flags & (JS_PROP_HAS_GET | JS_PROP_HAS_SET))
              goto convert_to_array;
            prop_flags = get_prop_flags(flags, 0);
            if (prop_flags != JS_PROP_C_W_E)
              goto convert_to_array;
            return add_fast_array_element(ctx, p, JS_DupValue(ctx, val), flags);
          } else {
            goto convert_to_array;
          }
        } else if (JS_AtomIsArrayIndex(ctx, &idx, prop)) {
          /* convert the fast array to normal array */
        convert_to_array:
          if (convert_fast_array_to_array(ctx, p))
            return -1;
          goto generic_array;
        }
      } else if (JS_AtomIsArrayIndex(ctx, &idx, prop)) {
        JSProperty* plen;
        JSShapeProperty* pslen;
      generic_array:
        /* update the length field */
        plen = &p->prop[0];
        JS_ToUint32(ctx, &len, plen->u.value);
        if ((idx + 1) > len) {
          pslen = get_shape_prop(p->shape);
          if (unlikely(!(pslen->flags & JS_PROP_WRITABLE)))
            return JS_ThrowTypeErrorReadOnly(ctx, flags, JS_ATOM_length);
          /* XXX: should update the length after defining
             the property */
          len = idx + 1;
          set_value(ctx, &plen->u.value, JS_NewUint32(ctx, len));
        }
      }
    } else if (p->class_id >= JS_CLASS_UINT8C_ARRAY && p->class_id <= JS_CLASS_FLOAT64_ARRAY) {
      ret = JS_AtomIsNumericIndex(ctx, prop);
      if (ret != 0) {
        if (ret < 0)
          return -1;
        return JS_ThrowTypeErrorOrFalse(ctx, flags, "cannot create numeric index in typed array");
      }
    } else if (!(flags & JS_PROP_NO_EXOTIC)) {
      const JSClassExoticMethods* em = ctx->rt->class_array[p->class_id].exotic;
      if (em) {
        if (em->define_own_property) {
          return em->define_own_property(ctx, JS_MKPTR(JS_TAG_OBJECT, p), prop, val, getter, setter, flags);
        }
        ret = JS_IsExtensible(ctx, JS_MKPTR(JS_TAG_OBJECT, p));
        if (ret < 0)
          return -1;
        if (!ret)
          goto not_extensible;
      }
    }
  }

  if (!p->extensible) {
  not_extensible:
    return JS_ThrowTypeErrorOrFalse(ctx, flags, "object is not extensible");
  }

  if (flags & (JS_PROP_HAS_GET | JS_PROP_HAS_SET)) {
    prop_flags = (flags & (JS_PROP_CONFIGURABLE | JS_PROP_ENUMERABLE)) | JS_PROP_GETSET;
  } else {
    prop_flags = flags & JS_PROP_C_W_E;
  }
  pr = add_property(ctx, p, prop, prop_flags);
  if (unlikely(!pr))
    return -1;
  if (flags & (JS_PROP_HAS_GET | JS_PROP_HAS_SET)) {
    pr->u.getset.getter = NULL;
    if ((flags & JS_PROP_HAS_GET) && JS_IsFunction(ctx, getter)) {
      pr->u.getset.getter = JS_VALUE_GET_OBJ(JS_DupValue(ctx, getter));
    }
    pr->u.getset.setter = NULL;
    if ((flags & JS_PROP_HAS_SET) && JS_IsFunction(ctx, setter)) {
      pr->u.getset.setter = JS_VALUE_GET_OBJ(JS_DupValue(ctx, setter));
    }
  } else {
    if (flags & JS_PROP_HAS_VALUE) {
      pr->u.value = JS_DupValue(ctx, val);
    } else {
      pr->u.value = JS_UNDEFINED;
    }
  }
  return TRUE;
}

/* return TRUE, FALSE or (-1) in case of exception */
int JS_OrdinaryIsInstanceOf(JSContext* ctx, JSValueConst val, JSValueConst obj) {
  JSValue obj_proto;
  JSObject* proto;
  const JSObject *p, *proto1;
  BOOL ret;

  if (!JS_IsFunction(ctx, obj))
    return FALSE;
  p = JS_VALUE_GET_OBJ(obj);
  if (p->class_id == JS_CLASS_BOUND_FUNCTION) {
    JSBoundFunction* s = p->u.bound_function;
    return JS_IsInstanceOf(ctx, val, s->func_obj);
  }

  /* Only explicitly boxed values are instances of constructors */
  if (JS_VALUE_GET_TAG(val) != JS_TAG_OBJECT)
    return FALSE;
  obj_proto = JS_GetProperty(ctx, obj, JS_ATOM_prototype);
  if (JS_VALUE_GET_TAG(obj_proto) != JS_TAG_OBJECT) {
    if (!JS_IsException(obj_proto))
      JS_ThrowTypeError(ctx, "operand 'prototype' property is not an object");
    ret = -1;
    goto done;
  }
  proto = JS_VALUE_GET_OBJ(obj_proto);
  p = JS_VALUE_GET_OBJ(val);
  for (;;) {
    proto1 = p->shape->proto;
    if (!proto1) {
      /* slow case if proxy in the prototype chain */
      if (unlikely(p->class_id == JS_CLASS_PROXY)) {
        JSValue obj1;
        obj1 = JS_DupValue(ctx, JS_MKPTR(JS_TAG_OBJECT, (JSObject*)p));
        for (;;) {
          obj1 = JS_GetPrototypeFree(ctx, obj1);
          if (JS_IsException(obj1)) {
            ret = -1;
            break;
          }
          if (JS_IsNull(obj1)) {
            ret = FALSE;
            break;
          }
          if (proto == JS_VALUE_GET_OBJ(obj1)) {
            JS_FreeValue(ctx, obj1);
            ret = TRUE;
            break;
          }
          /* must check for timeout to avoid infinite loop */
          if (js_poll_interrupts(ctx)) {
            JS_FreeValue(ctx, obj1);
            ret = -1;
            break;
          }
        }
      } else {
        ret = FALSE;
      }
      break;
    }
    p = proto1;
    if (proto == p) {
      ret = TRUE;
      break;
    }
  }
done:
  JS_FreeValue(ctx, obj_proto);
  return ret;
}

JSContext* js_autoinit_get_realm(JSProperty* pr) {
  return (JSContext*)(pr->u.init.realm_and_id & ~3);
}

JSAutoInitIDEnum js_autoinit_get_id(JSProperty* pr) {
  return pr->u.init.realm_and_id & 3;
}

void js_autoinit_free(JSRuntime* rt, JSProperty* pr) {
  JS_FreeContext(js_autoinit_get_realm(pr));
}

void js_autoinit_mark(JSRuntime* rt, JSProperty* pr, JS_MarkFunc* mark_func) {
  mark_func(rt, &js_autoinit_get_realm(pr)->header);
}

/* return TRUE, FALSE or (-1) in case of exception */
int JS_IsInstanceOf(JSContext* ctx, JSValueConst val, JSValueConst obj) {
  JSValue method;

  if (!JS_IsObject(obj))
    goto fail;
  method = JS_GetProperty(ctx, obj, JS_ATOM_Symbol_hasInstance);
  if (JS_IsException(method))
    return -1;
  if (!JS_IsNull(method) && !JS_IsUndefined(method)) {
    JSValue ret;
    ret = JS_CallFree(ctx, method, obj, 1, &val);
    return JS_ToBoolFree(ctx, ret);
  }

  /* legacy case */
  if (!JS_IsFunction(ctx, obj)) {
  fail:
    JS_ThrowTypeError(ctx, "invalid 'instanceof' right operand");
    return -1;
  }
  return JS_OrdinaryIsInstanceOf(ctx, val, obj);
}

/* in order to avoid executing arbitrary code during the stack trace
   generation, we only look at simple 'name' properties containing a
   string. */
const char* get_func_name(JSContext* ctx, JSValueConst func) {
  JSProperty* pr;
  JSShapeProperty* prs;
  JSValueConst val;

  if (JS_VALUE_GET_TAG(func) != JS_TAG_OBJECT)
    return NULL;
  prs = find_own_property(&pr, JS_VALUE_GET_OBJ(func), JS_ATOM_name);
  if (!prs)
    return NULL;
  if ((prs->flags & JS_PROP_TMASK) != JS_PROP_NORMAL)
    return NULL;
  val = pr->u.value;
  if (JS_VALUE_GET_TAG(val) != JS_TAG_STRING)
    return NULL;
  return JS_ToCString(ctx, val);
}

/* if filename != NULL, an additional level is added with the filename
   and line number information (used for parse error). */
void build_backtrace(JSContext* ctx, JSValueConst error_obj, const char* filename, int line_num, int column_num, int backtrace_flags) {
  JSStackFrame* sf;
  JSValue str;
  DynBuf dbuf;
  const char* func_name_str;
  const char* str1;
  JSObject* p;
  BOOL backtrace_barrier;
  int latest_line_num = -1;
  int latest_column_num = -1;

  js_dbuf_init(ctx, &dbuf);
  if (filename) {
    dbuf_printf(&dbuf, "    at %s", filename);
    if (line_num != -1) {
      latest_line_num = line_num;
      dbuf_printf(&dbuf, ":%d", line_num);
    }
    if (column_num != -1) {
      latest_column_num = column_num;
      dbuf_printf(&dbuf, ":%d", column_num);
    }
    dbuf_putc(&dbuf, '\n');
    str = JS_NewString(ctx, filename);
    JS_DefinePropertyValue(ctx, error_obj, JS_ATOM_fileName, str, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
    if (backtrace_flags & JS_BACKTRACE_FLAG_SINGLE_LEVEL)
      goto done;
  }
  for (sf = ctx->rt->current_stack_frame; sf != NULL; sf = sf->prev_frame) {
    if (backtrace_flags & JS_BACKTRACE_FLAG_SKIP_FIRST_LEVEL) {
      backtrace_flags &= ~JS_BACKTRACE_FLAG_SKIP_FIRST_LEVEL;
      continue;
    }
    func_name_str = get_func_name(ctx, sf->cur_func);
    if (!func_name_str || func_name_str[0] == '\0')
      str1 = "<anonymous>";
    else
      str1 = func_name_str;
    dbuf_printf(&dbuf, "    at %s", str1);
    JS_FreeCString(ctx, func_name_str);

    p = JS_VALUE_GET_OBJ(sf->cur_func);
    backtrace_barrier = FALSE;
    if (js_class_has_bytecode(p->class_id)) {
      JSFunctionBytecode* b;
      const char* atom_str;

      b = p->u.func.function_bytecode;
      backtrace_barrier = b->backtrace_barrier;
      if (b->has_debug) {
        line_num = find_line_num(ctx, b, sf->cur_pc - b->byte_code_buf - 1);
        column_num = find_column_num(ctx, b, sf->cur_pc - b->byte_code_buf - 1);
        line_num = line_num == -1 ? b->debug.line_num : line_num;
        column_num = column_num == -1 ? b->debug.column_num : column_num;
        if (column_num != -1) {
          column_num += 1;
        }
        if (latest_line_num == -1) {
          latest_line_num = line_num;
        }
        if (latest_column_num == -1) {
          latest_column_num = column_num;
        }
        atom_str = JS_AtomToCString(ctx, b->debug.filename);
        dbuf_printf(&dbuf, " (%s", atom_str ? atom_str : "<null>");
        JS_FreeCString(ctx, atom_str);
        if (line_num != -1) {
          dbuf_printf(&dbuf, ":%d", line_num);
          if (column_num != -1) {
            dbuf_printf(&dbuf, ":%d", column_num);
          }
        }

        dbuf_putc(&dbuf, ')');
      }
    } else {
      dbuf_printf(&dbuf, " (native)");
    }
    dbuf_putc(&dbuf, '\n');
    /* stop backtrace if JS_EVAL_FLAG_BACKTRACE_BARRIER was used */
    if (backtrace_barrier)
      break;
  }
done:
  dbuf_putc(&dbuf, '\0');
  if (dbuf_error(&dbuf)) {
    str = JS_NULL;
  } else {
    str = JS_NewString(ctx, (char*)dbuf.buf);
  }
  dbuf_free(&dbuf);
  JS_DefinePropertyValue(ctx, error_obj, JS_ATOM_stack, str, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  if (line_num != -1) {
    JS_DefinePropertyValue(ctx, error_obj, JS_ATOM_lineNumber, JS_NewInt32(ctx, latest_line_num), 
      JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
    if (column_num != -1) {
      /** 
       * do not add the corresponding definition 
       * in the 'quickjs-atom.h' file, it will lead to 
       * inaccurate diff positions of the atom table
       */
      int atom = JS_NewAtom(ctx, "columnNumber");
      JS_DefinePropertyValue(ctx, error_obj, atom, JS_NewInt32(ctx, latest_column_num), 
        JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
      JS_FreeAtom(ctx, atom);
    }
  }
}

/* Note: it is important that no exception is returned by this function */
BOOL is_backtrace_needed(JSContext* ctx, JSValueConst obj) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return FALSE;
  p = JS_VALUE_GET_OBJ(obj);
  if (p->class_id != JS_CLASS_ERROR)
    return FALSE;
  if (find_own_property1(p, JS_ATOM_stack))
    return FALSE;
  return TRUE;
}

no_inline __exception int __js_poll_interrupts(JSContext* ctx) {
  JSRuntime* rt = ctx->rt;
  ctx->interrupt_counter = JS_INTERRUPT_COUNTER_INIT;
  if (rt->interrupt_handler) {
    if (rt->interrupt_handler(rt, rt->interrupt_opaque)) {
      /* XXX: should set a specific flag to avoid catching */
      JS_ThrowInternalError(ctx, "interrupted");
      JS_SetUncatchableError(ctx, ctx->rt->current_exception, TRUE);
      return -1;
    }
  }
  return 0;
}

int check_function(JSContext* ctx, JSValueConst obj) {
  if (likely(JS_IsFunction(ctx, obj)))
    return 0;
  JS_ThrowTypeError(ctx, "not a function");
  return -1;
}

int check_exception_free(JSContext* ctx, JSValue obj) {
  JS_FreeValue(ctx, obj);
  return JS_IsException(obj);
}

JSAtom find_atom(JSContext* ctx, const char* name) {
  JSAtom atom;
  int len;

  if (*name == '[') {
    name++;
    len = strlen(name) - 1;
    /* We assume 8 bit non null strings, which is the case for these
       symbols */
    for (atom = JS_ATOM_Symbol_toPrimitive; atom <= JS_ATOM_Symbol_asyncIterator; atom++) {
      JSAtomStruct* p = ctx->rt->atom_array[atom];
      JSString* str = p;
      if (str->len == len && !memcmp(str->u.str8, name, len))
        return JS_DupAtom(ctx, atom);
    }
    abort();
  } else {
    atom = JS_NewAtom(ctx, name);
  }
  return atom;
}

JSValue JS_InstantiateFunctionListItem2(JSContext* ctx, JSObject* p, JSAtom atom, void* opaque) {
  const JSCFunctionListEntry* e = opaque;
  JSValue val;

  switch (e->def_type) {
    case JS_DEF_CFUNC:
      val = JS_NewCFunction2(ctx, e->u.func.cfunc.generic, e->name, e->u.func.length, e->u.func.cproto, e->magic);
      break;
    case JS_DEF_PROP_STRING:
      val = JS_NewAtomString(ctx, e->u.str);
      break;
    case JS_DEF_OBJECT:
      val = JS_NewObject(ctx);
      JS_SetPropertyFunctionList(ctx, val, e->u.prop_list.tab, e->u.prop_list.len);
      break;
    default:
      abort();
  }
  return val;
}

int JS_InstantiateFunctionListItem(JSContext* ctx, JSValueConst obj, JSAtom atom, const JSCFunctionListEntry* e) {
  JSValue val;
  int prop_flags = e->prop_flags;

  switch (e->def_type) {
    case JS_DEF_ALIAS: /* using autoinit for aliases is not safe */
    {
      JSAtom atom1 = find_atom(ctx, e->u.alias.name);
      switch (e->u.alias.base) {
        case -1:
          val = JS_GetProperty(ctx, obj, atom1);
          break;
        case 0:
          val = JS_GetProperty(ctx, ctx->global_obj, atom1);
          break;
        case 1:
          val = JS_GetProperty(ctx, ctx->class_proto[JS_CLASS_ARRAY], atom1);
          break;
        default:
          abort();
      }
      JS_FreeAtom(ctx, atom1);
      if (atom == JS_ATOM_Symbol_toPrimitive) {
        /* Symbol.toPrimitive functions are not writable */
        prop_flags = JS_PROP_CONFIGURABLE;
      } else if (atom == JS_ATOM_Symbol_hasInstance) {
        /* Function.prototype[Symbol.hasInstance] is not writable nor configurable */
        prop_flags = 0;
      }
    } break;
    case JS_DEF_CFUNC:
      if (atom == JS_ATOM_Symbol_toPrimitive) {
        /* Symbol.toPrimitive functions are not writable */
        prop_flags = JS_PROP_CONFIGURABLE;
      } else if (atom == JS_ATOM_Symbol_hasInstance) {
        /* Function.prototype[Symbol.hasInstance] is not writable nor configurable */
        prop_flags = 0;
      }
      JS_DefineAutoInitProperty(ctx, obj, atom, JS_AUTOINIT_ID_PROP, (void*)e, prop_flags);
      return 0;
    case JS_DEF_CGETSET: /* XXX: use autoinit again ? */
    case JS_DEF_CGETSET_MAGIC: {
      JSValue getter, setter;
      char buf[64];

      getter = JS_UNDEFINED;
      if (e->u.getset.get.generic) {
        snprintf(buf, sizeof(buf), "get %s", e->name);
        getter = JS_NewCFunction2(ctx, e->u.getset.get.generic, buf, 0, e->def_type == JS_DEF_CGETSET_MAGIC ? JS_CFUNC_getter_magic : JS_CFUNC_getter, e->magic);
      }
      setter = JS_UNDEFINED;
      if (e->u.getset.set.generic) {
        snprintf(buf, sizeof(buf), "set %s", e->name);
        setter = JS_NewCFunction2(ctx, e->u.getset.set.generic, buf, 1, e->def_type == JS_DEF_CGETSET_MAGIC ? JS_CFUNC_setter_magic : JS_CFUNC_setter, e->magic);
      }
      JS_DefinePropertyGetSet(ctx, obj, atom, getter, setter, prop_flags);
      return 0;
    } break;
    case JS_DEF_PROP_INT32:
      val = JS_NewInt32(ctx, e->u.i32);
      break;
    case JS_DEF_PROP_INT64:
      val = JS_NewInt64(ctx, e->u.i64);
      break;
    case JS_DEF_PROP_DOUBLE:
      val = __JS_NewFloat64(ctx, e->u.f64);
      break;
    case JS_DEF_PROP_UNDEFINED:
      val = JS_UNDEFINED;
      break;
    case JS_DEF_PROP_STRING:
    case JS_DEF_OBJECT:
      JS_DefineAutoInitProperty(ctx, obj, atom, JS_AUTOINIT_ID_PROP, (void*)e, prop_flags);
      return 0;
    default:
      abort();
  }
  JS_DefinePropertyValue(ctx, obj, atom, val, prop_flags);
  return 0;
}

void JS_SetPropertyFunctionList(JSContext* ctx, JSValueConst obj, const JSCFunctionListEntry* tab, int len) {
  int i;

  for (i = 0; i < len; i++) {
    const JSCFunctionListEntry* e = &tab[i];
    JSAtom atom = find_atom(ctx, e->name);
    JS_InstantiateFunctionListItem(ctx, obj, atom, e);
    JS_FreeAtom(ctx, atom);
  }
}

int JS_AddModuleExportList(JSContext* ctx, JSModuleDef* m, const JSCFunctionListEntry* tab, int len) {
  int i;
  for (i = 0; i < len; i++) {
    if (JS_AddModuleExport(ctx, m, tab[i].name))
      return -1;
  }
  return 0;
}

int JS_SetModuleExportList(JSContext* ctx, JSModuleDef* m, const JSCFunctionListEntry* tab, int len) {
  int i;
  JSValue val;

  for (i = 0; i < len; i++) {
    const JSCFunctionListEntry* e = &tab[i];
    switch (e->def_type) {
      case JS_DEF_CFUNC:
        val = JS_NewCFunction2(ctx, e->u.func.cfunc.generic, e->name, e->u.func.length, e->u.func.cproto, e->magic);
        break;
      case JS_DEF_PROP_STRING:
        val = JS_NewString(ctx, e->u.str);
        break;
      case JS_DEF_PROP_INT32:
        val = JS_NewInt32(ctx, e->u.i32);
        break;
      case JS_DEF_PROP_INT64:
        val = JS_NewInt64(ctx, e->u.i64);
        break;
      case JS_DEF_PROP_DOUBLE:
        val = __JS_NewFloat64(ctx, e->u.f64);
        break;
      case JS_DEF_OBJECT:
        val = JS_NewObject(ctx);
        JS_SetPropertyFunctionList(ctx, val, e->u.prop_list.tab, e->u.prop_list.len);
        break;
      default:
        abort();
    }
    if (JS_SetModuleExport(ctx, m, e->name, val))
      return -1;
  }
  return 0;
}

/* Note: 'func_obj' is not necessarily a constructor */
void JS_SetConstructor2(JSContext* ctx, JSValueConst func_obj, JSValueConst proto, int proto_flags, int ctor_flags) {
  JS_DefinePropertyValue(ctx, func_obj, JS_ATOM_prototype, JS_DupValue(ctx, proto), proto_flags);
  JS_DefinePropertyValue(ctx, proto, JS_ATOM_constructor, JS_DupValue(ctx, func_obj), ctor_flags);
  set_cycle_flag(ctx, func_obj);
  set_cycle_flag(ctx, proto);
}

void JS_SetConstructor(JSContext* ctx, JSValueConst func_obj, JSValueConst proto) {
  JS_SetConstructor2(ctx, func_obj, proto, 0, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
}

JSValue iterator_to_array(JSContext* ctx, JSValueConst items) {
  JSValue iter, next_method = JS_UNDEFINED;
  JSValue v, r = JS_UNDEFINED;
  int64_t k;
  BOOL done;

  iter = JS_GetIterator(ctx, items, FALSE);
  if (JS_IsException(iter))
    goto exception;
  next_method = JS_GetProperty(ctx, iter, JS_ATOM_next);
  if (JS_IsException(next_method))
    goto exception;
  r = JS_NewArray(ctx);
  if (JS_IsException(r))
    goto exception;
  for (k = 0;; k++) {
    v = JS_IteratorNext(ctx, iter, next_method, 0, NULL, &done);
    if (JS_IsException(v))
      goto exception_close;
    if (done)
      break;
    if (JS_DefinePropertyValueInt64(ctx, r, k, v, JS_PROP_C_W_E | JS_PROP_THROW) < 0)
      goto exception_close;
  }
done:
  JS_FreeValue(ctx, next_method);
  JS_FreeValue(ctx, iter);
  return r;
exception_close:
  JS_IteratorClose(ctx, iter, TRUE);
exception:
  JS_FreeValue(ctx, r);
  r = JS_EXCEPTION;
  goto done;
}

/* only valid inside C functions */
JSValueConst JS_GetActiveFunction(JSContext* ctx) {
  return ctx->rt->current_stack_frame->cur_func;
}

JSValue js_error_constructor(JSContext* ctx, JSValueConst new_target, int argc, JSValueConst* argv, int magic) {
  JSValue obj, msg, proto;
  JSValueConst message;

  if (JS_IsUndefined(new_target))
    new_target = JS_GetActiveFunction(ctx);
  proto = JS_GetProperty(ctx, new_target, JS_ATOM_prototype);
  if (JS_IsException(proto))
    return proto;
  if (!JS_IsObject(proto)) {
    JSContext* realm;
    JSValueConst proto1;

    JS_FreeValue(ctx, proto);
    realm = JS_GetFunctionRealm(ctx, new_target);
    if (!realm)
      return JS_EXCEPTION;
    if (magic < 0) {
      proto1 = realm->class_proto[JS_CLASS_ERROR];
    } else {
      proto1 = realm->native_error_proto[magic];
    }
    proto = JS_DupValue(ctx, proto1);
  }
  obj = JS_NewObjectProtoClass(ctx, proto, JS_CLASS_ERROR);
  JS_FreeValue(ctx, proto);
  if (JS_IsException(obj))
    return obj;
  if (magic == JS_AGGREGATE_ERROR) {
    message = argv[1];
  } else {
    message = argv[0];
  }

  if (!JS_IsUndefined(message)) {
    msg = JS_ToString(ctx, message);
    if (unlikely(JS_IsException(msg)))
      goto exception;
    JS_DefinePropertyValue(ctx, obj, JS_ATOM_message, msg, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  }

  if (magic == JS_AGGREGATE_ERROR) {
    JSValue error_list = iterator_to_array(ctx, argv[0]);
    if (JS_IsException(error_list))
      goto exception;
    JS_DefinePropertyValue(ctx, obj, JS_ATOM_errors, error_list, JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  }

  /* skip the Error() function in the backtrace */
  build_backtrace(ctx, obj, NULL, 0, 0, JS_BACKTRACE_FLAG_SKIP_FIRST_LEVEL);
  return obj;
exception:
  JS_FreeValue(ctx, obj);
  return JS_EXCEPTION;
}

JSValue js_aggregate_error_constructor(JSContext* ctx, JSValueConst errors) {
  JSValue obj;

  obj = JS_NewObjectProtoClass(ctx, ctx->native_error_proto[JS_AGGREGATE_ERROR], JS_CLASS_ERROR);
  if (JS_IsException(obj))
    return obj;
  JS_DefinePropertyValue(ctx, obj, JS_ATOM_errors, JS_DupValue(ctx, errors), JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  return obj;
}

JSValue js_error_toString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue name, msg;

  if (!JS_IsObject(this_val))
    return JS_ThrowTypeErrorNotAnObject(ctx);
  name = JS_GetProperty(ctx, this_val, JS_ATOM_name);
  if (JS_IsUndefined(name))
    name = JS_AtomToString(ctx, JS_ATOM_Error);
  else
    name = JS_ToStringFree(ctx, name);
  if (JS_IsException(name))
    return JS_EXCEPTION;

  msg = JS_GetProperty(ctx, this_val, JS_ATOM_message);
  if (JS_IsUndefined(msg))
    msg = JS_AtomToString(ctx, JS_ATOM_empty_string);
  else
    msg = JS_ToStringFree(ctx, msg);
  if (JS_IsException(msg)) {
    JS_FreeValue(ctx, name);
    return JS_EXCEPTION;
  }
  if (!JS_IsEmptyString(name) && !JS_IsEmptyString(msg))
    name = JS_ConcatString3(ctx, "", name, ": ");
  return JS_ConcatString(ctx, name, msg);
}

static const JSCFunctionListEntry js_error_proto_funcs[] = {
    JS_CFUNC_DEF("toString", 0, js_error_toString),
    JS_PROP_STRING_DEF("name", "Error", JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE),
    JS_PROP_STRING_DEF("message", "", JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE),
};

void JS_NewGlobalCConstructor2(JSContext* ctx, JSValue func_obj, const char* name, JSValueConst proto) {
  JS_DefinePropertyValueStr(ctx, ctx->global_obj, name, JS_DupValue(ctx, func_obj), JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
  JS_SetConstructor(ctx, func_obj, proto);
  JS_FreeValue(ctx, func_obj);
}

JSValueConst JS_NewGlobalCConstructor(JSContext* ctx, const char* name, JSCFunction* func, int length, JSValueConst proto) {
  JSValue func_obj;
  func_obj = JS_NewCFunction2(ctx, func, name, length, JS_CFUNC_constructor_or_func, 0);
  JS_NewGlobalCConstructor2(ctx, func_obj, name, proto);
  return func_obj;
}

JSValueConst JS_NewGlobalCConstructorOnly(JSContext* ctx, const char* name, JSCFunction* func, int length, JSValueConst proto) {
  JSValue func_obj;
  func_obj = JS_NewCFunction2(ctx, func, name, length, JS_CFUNC_constructor, 0);
  JS_NewGlobalCConstructor2(ctx, func_obj, name, proto);
  return func_obj;
}

void* JS_GetRuntimeOpaque(JSRuntime* rt) {
  return rt->user_opaque;
}

void JS_SetRuntimeOpaque(JSRuntime* rt, void* opaque) {
  rt->user_opaque = opaque;
}

void JS_SetMemoryLimit(JSRuntime* rt, size_t limit) {
  rt->malloc_state.malloc_limit = limit;
}

void JS_SetInterruptHandler(JSRuntime* rt, JSInterruptHandler* cb, void* opaque) {
  rt->interrupt_handler = cb;
  rt->interrupt_opaque = opaque;
}

void JS_SetCanBlock(JSRuntime* rt, BOOL can_block) {
  rt->can_block = can_block;
}

void JS_SetSharedArrayBufferFunctions(JSRuntime* rt, const JSSharedArrayBufferFunctions* sf) {
  rt->sab_funcs = *sf;
}

/* return 0 if OK, < 0 if exception */
int JS_EnqueueJob(JSContext* ctx, JSJobFunc* job_func, int argc, JSValueConst* argv) {
  JSRuntime* rt = ctx->rt;
  JSJobEntry* e;
  int i;

  e = js_malloc(ctx, sizeof(*e) + argc * sizeof(JSValue));
  if (!e)
    return -1;
  e->ctx = ctx;
  e->job_func = job_func;
  e->argc = argc;
  for (i = 0; i < argc; i++) {
    e->argv[i] = JS_DupValue(ctx, argv[i]);
  }
  list_add_tail(&e->link, &rt->job_list);
  return 0;
}

BOOL JS_IsJobPending(JSRuntime* rt) {
  return !list_empty(&rt->job_list);
}

/* return < 0 if exception, 0 if no job pending, 1 if a job was
   executed successfully. the context of the job is stored in '*pctx' */
int JS_ExecutePendingJob(JSRuntime* rt, JSContext** pctx) {
  JSContext* ctx;
  JSJobEntry* e;
  JSValue res;
  int i, ret;

  if (list_empty(&rt->job_list)) {
    *pctx = NULL;
    return 0;
  }

  /* get the first pending job and execute it */
  e = list_entry(rt->job_list.next, JSJobEntry, link);
  list_del(&e->link);
  ctx = e->ctx;
  res = e->job_func(e->ctx, e->argc, (JSValueConst*)e->argv);
  for (i = 0; i < e->argc; i++)
    JS_FreeValue(ctx, e->argv[i]);
  if (JS_IsException(res))
    ret = -1;
  else
    ret = 1;
  JS_FreeValue(ctx, res);
  js_free(ctx, e);
  *pctx = ctx;
  return ret;
}

void JS_SetClassProto(JSContext* ctx, JSClassID class_id, JSValue obj) {
  JSRuntime* rt = ctx->rt;
  assert(class_id < rt->class_count);
  set_value(ctx, &ctx->class_proto[class_id], obj);
}

JSValue JS_GetClassProto(JSContext* ctx, JSClassID class_id) {
  JSRuntime* rt = ctx->rt;
  assert(class_id < rt->class_count);
  return JS_DupValue(ctx, ctx->class_proto[class_id]);
}

static JSObject* get_proto_obj(JSValueConst proto_val) {
  if (JS_VALUE_GET_TAG(proto_val) != JS_TAG_OBJECT)
    return NULL;
  else
    return JS_VALUE_GET_OBJ(proto_val);
}

JSValue JS_NewArray(JSContext* ctx) {
  return JS_NewObjectFromShape(ctx, js_dup_shape(ctx->array_shape), JS_CLASS_ARRAY);
}

/* WARNING: proto must be an object or JS_NULL */
JSValue JS_NewObjectProtoClass(JSContext* ctx, JSValueConst proto_val, JSClassID class_id) {
  JSShape* sh;
  JSObject* proto;

  proto = get_proto_obj(proto_val);
  sh = find_hashed_shape_proto(ctx->rt, proto);
  if (likely(sh)) {
    sh = js_dup_shape(sh);
  } else {
    sh = js_new_shape(ctx, proto);
    if (!sh)
      return JS_EXCEPTION;
  }
  return JS_NewObjectFromShape(ctx, sh, class_id);
}

JSValue js_global_eval(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  return JS_EvalObject(ctx, ctx->global_obj, argv[0], JS_EVAL_TYPE_INDIRECT, -1);
}

JSValue js_global_isNaN(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  double d;

  /* XXX: does this work for bigfloat? */
  if (unlikely(JS_ToFloat64(ctx, &d, argv[0])))
    return JS_EXCEPTION;
  return JS_NewBool(ctx, isnan(d));
}

JSValue js_global_isFinite(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  BOOL res;
  double d;
  if (unlikely(JS_ToFloat64(ctx, &d, argv[0])))
    return JS_EXCEPTION;
  res = isfinite(d);
  return JS_NewBool(ctx, res);
}

static const char* const native_error_name[JS_NATIVE_ERROR_COUNT] = {
    "EvalError", "RangeError", "ReferenceError", "SyntaxError", "TypeError", "URIError", "InternalError", "AggregateError",
};

/* URI handling */

int string_get_hex(JSString* p, int k, int n) {
  int c = 0, h;
  while (n-- > 0) {
    if ((h = from_hex(string_get(p, k++))) < 0)
      return -1;
    c = (c << 4) | h;
  }
  return c;
}

static int isURIReserved(int c) {
  return c < 0x100 && memchr(";/?:@&=+$,#", c, sizeof(";/?:@&=+$,#") - 1) != NULL;
}

static int __attribute__((format(printf, 2, 3))) js_throw_URIError(JSContext* ctx, const char* fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  JS_ThrowError(ctx, JS_URI_ERROR, fmt, ap);
  va_end(ap);
  return -1;
}

static int hex_decode(JSContext* ctx, JSString* p, int k) {
  int c;

  if (k >= p->len || string_get(p, k) != '%')
    return js_throw_URIError(ctx, "expecting %%");
  if (k + 2 >= p->len || (c = string_get_hex(p, k + 1, 2)) < 0)
    return js_throw_URIError(ctx, "expecting hex digit");

  return c;
}

static JSValue js_global_decodeURI(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int isComponent) {
  JSValue str;
  StringBuffer b_s, *b = &b_s;
  JSString* p;
  int k, c, c1, n, c_min;

  str = JS_ToString(ctx, argv[0]);
  if (JS_IsException(str))
    return str;

  string_buffer_init(ctx, b, 0);

  p = JS_VALUE_GET_STRING(str);
  for (k = 0; k < p->len;) {
    c = string_get(p, k);
    if (c == '%') {
      c = hex_decode(ctx, p, k);
      if (c < 0)
        goto fail;
      k += 3;
      if (c < 0x80) {
        if (!isComponent && isURIReserved(c)) {
          c = '%';
          k -= 2;
        }
      } else {
        /* Decode URI-encoded UTF-8 sequence */
        if (c >= 0xc0 && c <= 0xdf) {
          n = 1;
          c_min = 0x80;
          c &= 0x1f;
        } else if (c >= 0xe0 && c <= 0xef) {
          n = 2;
          c_min = 0x800;
          c &= 0xf;
        } else if (c >= 0xf0 && c <= 0xf7) {
          n = 3;
          c_min = 0x10000;
          c &= 0x7;
        } else {
          n = 0;
          c_min = 1;
          c = 0;
        }
        while (n-- > 0) {
          c1 = hex_decode(ctx, p, k);
          if (c1 < 0)
            goto fail;
          k += 3;
          if ((c1 & 0xc0) != 0x80) {
            c = 0;
            break;
          }
          c = (c << 6) | (c1 & 0x3f);
        }
        if (c < c_min || c > 0x10FFFF || (c >= 0xd800 && c < 0xe000)) {
          js_throw_URIError(ctx, "malformed UTF-8");
          goto fail;
        }
      }
    } else {
      k++;
    }
    string_buffer_putc(b, c);
  }
  JS_FreeValue(ctx, str);
  return string_buffer_end(b);

fail:
  JS_FreeValue(ctx, str);
  string_buffer_free(b);
  return JS_EXCEPTION;
}

static int isUnescaped(int c) {
  static char const unescaped_chars[] =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      "abcdefghijklmnopqrstuvwxyz"
      "0123456789"
      "@*_+-./";
  return c < 0x100 && memchr(unescaped_chars, c, sizeof(unescaped_chars) - 1);
}

static int isURIUnescaped(int c, int isComponent) {
  return c < 0x100 &&
         ((c >= 0x61 && c <= 0x7a) || (c >= 0x41 && c <= 0x5a) || (c >= 0x30 && c <= 0x39) || memchr("-_.!~*'()", c, sizeof("-_.!~*'()") - 1) != NULL || (!isComponent && isURIReserved(c)));
}

static int encodeURI_hex(StringBuffer* b, int c) {
  uint8_t buf[6];
  int n = 0;
  const char* hex = "0123456789ABCDEF";

  buf[n++] = '%';
  if (c >= 256) {
    buf[n++] = 'u';
    buf[n++] = hex[(c >> 12) & 15];
    buf[n++] = hex[(c >> 8) & 15];
  }
  buf[n++] = hex[(c >> 4) & 15];
  buf[n++] = hex[(c >> 0) & 15];
  return string_buffer_write8(b, buf, n);
}

static JSValue js_global_encodeURI(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int isComponent) {
  JSValue str;
  StringBuffer b_s, *b = &b_s;
  JSString* p;
  int k, c, c1;

  str = JS_ToString(ctx, argv[0]);
  if (JS_IsException(str))
    return str;

  p = JS_VALUE_GET_STRING(str);
  string_buffer_init(ctx, b, p->len);
  for (k = 0; k < p->len;) {
    c = string_get(p, k);
    k++;
    if (isURIUnescaped(c, isComponent)) {
      string_buffer_putc16(b, c);
    } else {
      if (c >= 0xdc00 && c <= 0xdfff) {
        js_throw_URIError(ctx, "invalid character");
        goto fail;
      } else if (c >= 0xd800 && c <= 0xdbff) {
        if (k >= p->len) {
          js_throw_URIError(ctx, "expecting surrogate pair");
          goto fail;
        }
        c1 = string_get(p, k);
        k++;
        if (c1 < 0xdc00 || c1 > 0xdfff) {
          js_throw_URIError(ctx, "expecting surrogate pair");
          goto fail;
        }
        c = (((c & 0x3ff) << 10) | (c1 & 0x3ff)) + 0x10000;
      }
      if (c < 0x80) {
        encodeURI_hex(b, c);
      } else {
        /* XXX: use C UTF-8 conversion ? */
        if (c < 0x800) {
          encodeURI_hex(b, (c >> 6) | 0xc0);
        } else {
          if (c < 0x10000) {
            encodeURI_hex(b, (c >> 12) | 0xe0);
          } else {
            encodeURI_hex(b, (c >> 18) | 0xf0);
            encodeURI_hex(b, ((c >> 12) & 0x3f) | 0x80);
          }
          encodeURI_hex(b, ((c >> 6) & 0x3f) | 0x80);
        }
        encodeURI_hex(b, (c & 0x3f) | 0x80);
      }
    }
  }
  JS_FreeValue(ctx, str);
  return string_buffer_end(b);

fail:
  JS_FreeValue(ctx, str);
  string_buffer_free(b);
  return JS_EXCEPTION;
}

static JSValue js_global_escape(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue str;
  StringBuffer b_s, *b = &b_s;
  JSString* p;
  int i, len, c;

  str = JS_ToString(ctx, argv[0]);
  if (JS_IsException(str))
    return str;

  p = JS_VALUE_GET_STRING(str);
  string_buffer_init(ctx, b, p->len);
  for (i = 0, len = p->len; i < len; i++) {
    c = string_get(p, i);
    if (isUnescaped(c)) {
      string_buffer_putc16(b, c);
    } else {
      encodeURI_hex(b, c);
    }
  }
  JS_FreeValue(ctx, str);
  return string_buffer_end(b);
}

static JSValue js_global_unescape(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue str;
  StringBuffer b_s, *b = &b_s;
  JSString* p;
  int i, len, c, n;

  str = JS_ToString(ctx, argv[0]);
  if (JS_IsException(str))
    return str;

  string_buffer_init(ctx, b, 0);
  p = JS_VALUE_GET_STRING(str);
  for (i = 0, len = p->len; i < len; i++) {
    c = string_get(p, i);
    if (c == '%') {
      if (i + 6 <= len && string_get(p, i + 1) == 'u' && (n = string_get_hex(p, i + 2, 4)) >= 0) {
        c = n;
        i += 6 - 1;
      } else if (i + 3 <= len && (n = string_get_hex(p, i + 1, 2)) >= 0) {
        c = n;
        i += 3 - 1;
      }
    }
    string_buffer_putc16(b, c);
  }
  JS_FreeValue(ctx, str);
  return string_buffer_end(b);
}

/* Minimum amount of objects to be able to compile code and display
   error messages. No JSAtom should be allocated by this function. */
static void JS_AddIntrinsicBasicObjects(JSContext* ctx) {
  JSValue proto;
  int i;

  ctx->class_proto[JS_CLASS_OBJECT] = JS_NewObjectProto(ctx, JS_NULL);
  ctx->function_proto = JS_NewCFunction3(ctx, js_function_proto, "", 0, JS_CFUNC_generic, 0, ctx->class_proto[JS_CLASS_OBJECT]);
  ctx->class_proto[JS_CLASS_BYTECODE_FUNCTION] = JS_DupValue(ctx, ctx->function_proto);
  ctx->class_proto[JS_CLASS_ERROR] = JS_NewObject(ctx);
#if 0
    /* these are auto-initialized from js_error_proto_funcs,
       but delaying might be a problem */
    JS_DefinePropertyValue(ctx, ctx->class_proto[JS_CLASS_ERROR], JS_ATOM_name,
                           JS_AtomToString(ctx, JS_ATOM_Error),
                           JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
    JS_DefinePropertyValue(ctx, ctx->class_proto[JS_CLASS_ERROR], JS_ATOM_message,
                           JS_AtomToString(ctx, JS_ATOM_empty_string),
                           JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
#endif
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_ERROR], js_error_proto_funcs, countof(js_error_proto_funcs));

  for (i = 0; i < JS_NATIVE_ERROR_COUNT; i++) {
    proto = JS_NewObjectProto(ctx, ctx->class_proto[JS_CLASS_ERROR]);
    JS_DefinePropertyValue(ctx, proto, JS_ATOM_name, JS_NewAtomString(ctx, native_error_name[i]), JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
    JS_DefinePropertyValue(ctx, proto, JS_ATOM_message, JS_AtomToString(ctx, JS_ATOM_empty_string), JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);
    ctx->native_error_proto[i] = proto;
  }

  /* the array prototype is an array */
  ctx->class_proto[JS_CLASS_ARRAY] = JS_NewObjectProtoClass(ctx, ctx->class_proto[JS_CLASS_OBJECT], JS_CLASS_ARRAY);

  ctx->array_shape = js_new_shape2(ctx, get_proto_obj(ctx->class_proto[JS_CLASS_ARRAY]), JS_PROP_INITIAL_HASH_SIZE, 1);
  add_shape_property(ctx, &ctx->array_shape, NULL, JS_ATOM_length, JS_PROP_WRITABLE | JS_PROP_LENGTH);

  /* XXX: could test it on first context creation to ensure that no
     new atoms are created in JS_AddIntrinsicBasicObjects(). It is
     necessary to avoid useless renumbering of atoms after
     JS_EvalBinary() if it is done just after
     JS_AddIntrinsicBasicObjects(). */
  //    assert(ctx->rt->atom_count == JS_ATOM_END);
}

/* Objects */
static const JSCFunctionListEntry js_object_funcs[] = {
    JS_CFUNC_DEF("create", 2, js_object_create),
    JS_CFUNC_MAGIC_DEF("getPrototypeOf", 1, js_object_getPrototypeOf, 0),
    JS_CFUNC_DEF("setPrototypeOf", 2, js_object_setPrototypeOf),
    JS_CFUNC_MAGIC_DEF("defineProperty", 3, js_object_defineProperty, 0),
    JS_CFUNC_DEF("defineProperties", 2, js_object_defineProperties),
    JS_CFUNC_DEF("getOwnPropertyNames", 1, js_object_getOwnPropertyNames),
    JS_CFUNC_DEF("getOwnPropertySymbols", 1, js_object_getOwnPropertySymbols),
    JS_CFUNC_MAGIC_DEF("keys", 1, js_object_keys, JS_ITERATOR_KIND_KEY),
    JS_CFUNC_MAGIC_DEF("values", 1, js_object_keys, JS_ITERATOR_KIND_VALUE),
    JS_CFUNC_MAGIC_DEF("entries", 1, js_object_keys, JS_ITERATOR_KIND_KEY_AND_VALUE),
    JS_CFUNC_MAGIC_DEF("isExtensible", 1, js_object_isExtensible, 0),
    JS_CFUNC_MAGIC_DEF("preventExtensions", 1, js_object_preventExtensions, 0),
    JS_CFUNC_MAGIC_DEF("getOwnPropertyDescriptor", 2, js_object_getOwnPropertyDescriptor, 0),
    JS_CFUNC_DEF("getOwnPropertyDescriptors", 1, js_object_getOwnPropertyDescriptors),
    JS_CFUNC_DEF("is", 2, js_object_is),
    JS_CFUNC_DEF("assign", 2, js_object_assign),
    JS_CFUNC_MAGIC_DEF("seal", 1, js_object_seal, 0),
    JS_CFUNC_MAGIC_DEF("freeze", 1, js_object_seal, 1),
    JS_CFUNC_MAGIC_DEF("isSealed", 1, js_object_isSealed, 0),
    JS_CFUNC_MAGIC_DEF("isFrozen", 1, js_object_isSealed, 1),
    JS_CFUNC_DEF("__getClass", 1, js_object___getClass),
    // JS_CFUNC_DEF("__isObject", 1, js_object___isObject ),
    // JS_CFUNC_DEF("__isConstructor", 1, js_object___isConstructor ),
    // JS_CFUNC_DEF("__toObject", 1, js_object___toObject ),
    // JS_CFUNC_DEF("__setOwnProperty", 3, js_object___setOwnProperty ),
    // JS_CFUNC_DEF("__toPrimitive", 2, js_object___toPrimitive ),
    // JS_CFUNC_DEF("__toPropertyKey", 1, js_object___toPropertyKey ),
    // JS_CFUNC_DEF("__speciesConstructor", 2, js_object___speciesConstructor ),
    // JS_CFUNC_DEF("__isSameValueZero", 2, js_object___isSameValueZero ),
    // JS_CFUNC_DEF("__getObjectData", 1, js_object___getObjectData ),
    // JS_CFUNC_DEF("__setObjectData", 2, js_object___setObjectData ),
    JS_CFUNC_DEF("fromEntries", 1, js_object_fromEntries),
    JS_CFUNC_DEF("hasOwn", 2, js_object_hasOwn),
};

static const JSCFunctionListEntry js_object_proto_funcs[] = {
    JS_CFUNC_DEF("toString", 0, js_object_toString),
    JS_CFUNC_DEF("toLocaleString", 0, js_object_toLocaleString),
    JS_CFUNC_DEF("valueOf", 0, js_object_valueOf),
    JS_CFUNC_DEF("hasOwnProperty", 1, js_object_hasOwnProperty),
    JS_CFUNC_DEF("isPrototypeOf", 1, js_object_isPrototypeOf),
    JS_CFUNC_DEF("propertyIsEnumerable", 1, js_object_propertyIsEnumerable),
    JS_CGETSET_DEF("__proto__", js_object_get___proto__, js_object_set___proto__),
    JS_CFUNC_MAGIC_DEF("__defineGetter__", 2, js_object___defineGetter__, 0),
    JS_CFUNC_MAGIC_DEF("__defineSetter__", 2, js_object___defineGetter__, 1),
    JS_CFUNC_MAGIC_DEF("__lookupGetter__", 1, js_object___lookupGetter__, 0),
    JS_CFUNC_MAGIC_DEF("__lookupSetter__", 1, js_object___lookupGetter__, 1),
};

/* Function class */

static const JSCFunctionListEntry js_function_proto_funcs[] = {
    JS_CFUNC_DEF("call", 1, js_function_call),
    JS_CFUNC_MAGIC_DEF("apply", 2, js_function_apply, 0),
    JS_CFUNC_DEF("bind", 1, js_function_bind),
    JS_CFUNC_DEF("toString", 0, js_function_toString),
    JS_CFUNC_DEF("[Symbol.hasInstance]", 1, js_function_hasInstance),
    JS_CGETSET_DEF("fileName", js_function_proto_fileName, NULL),
    JS_CGETSET_DEF("lineNumber", js_function_proto_lineNumber, NULL),
    JS_CGETSET_DEF("columnNumber", js_function_proto_columnNumber, NULL),
};

/* Array */
static const JSCFunctionListEntry js_array_proto_funcs[] = {
    JS_CFUNC_DEF("concat", 1, js_array_concat),
    JS_CFUNC_MAGIC_DEF("every", 1, js_array_every, special_every),
    JS_CFUNC_MAGIC_DEF("some", 1, js_array_every, special_some),
    JS_CFUNC_MAGIC_DEF("forEach", 1, js_array_every, special_forEach),
    JS_CFUNC_MAGIC_DEF("map", 1, js_array_every, special_map),
    JS_CFUNC_MAGIC_DEF("filter", 1, js_array_every, special_filter),
    JS_CFUNC_MAGIC_DEF("reduce", 1, js_array_reduce, special_reduce),
    JS_CFUNC_MAGIC_DEF("reduceRight", 1, js_array_reduce, special_reduceRight),
    JS_CFUNC_DEF("fill", 1, js_array_fill),
    JS_CFUNC_MAGIC_DEF("find", 1, js_array_find, 0),
    JS_CFUNC_MAGIC_DEF("findIndex", 1, js_array_find, 1),
    JS_CFUNC_DEF("indexOf", 1, js_array_indexOf),
    JS_CFUNC_DEF("lastIndexOf", 1, js_array_lastIndexOf),
    JS_CFUNC_DEF("includes", 1, js_array_includes),
    JS_CFUNC_MAGIC_DEF("join", 1, js_array_join, 0),
    JS_CFUNC_DEF("toString", 0, js_array_toString),
    JS_CFUNC_MAGIC_DEF("toLocaleString", 0, js_array_join, 1),
    JS_CFUNC_MAGIC_DEF("pop", 0, js_array_pop, 0),
    JS_CFUNC_MAGIC_DEF("push", 1, js_array_push, 0),
    JS_CFUNC_MAGIC_DEF("shift", 0, js_array_pop, 1),
    JS_CFUNC_MAGIC_DEF("unshift", 1, js_array_push, 1),
    JS_CFUNC_DEF("reverse", 0, js_array_reverse),
    JS_CFUNC_DEF("sort", 1, js_array_sort),
    JS_CFUNC_MAGIC_DEF("slice", 2, js_array_slice, 0),
    JS_CFUNC_MAGIC_DEF("splice", 2, js_array_slice, 1),
    JS_CFUNC_DEF("copyWithin", 2, js_array_copyWithin),
    JS_CFUNC_MAGIC_DEF("flatMap", 1, js_array_flatten, 1),
    JS_CFUNC_MAGIC_DEF("flat", 0, js_array_flatten, 0),
    JS_CFUNC_MAGIC_DEF("values", 0, js_create_array_iterator, JS_ITERATOR_KIND_VALUE),
    JS_ALIAS_DEF("[Symbol.iterator]", "values"),
    JS_CFUNC_MAGIC_DEF("keys", 0, js_create_array_iterator, JS_ITERATOR_KIND_KEY),
    JS_CFUNC_MAGIC_DEF("entries", 0, js_create_array_iterator, JS_ITERATOR_KIND_KEY_AND_VALUE),
};

static const JSCFunctionListEntry js_array_funcs[] = {
    JS_CFUNC_DEF("isArray", 1, js_array_isArray),
    JS_CFUNC_DEF("from", 1, js_array_from),
    JS_CFUNC_DEF("of", 0, js_array_of),
    JS_CGETSET_DEF("[Symbol.species]", js_get_this, NULL),
};

static const JSCFunctionListEntry js_iterator_proto_funcs[] = {
    JS_CFUNC_DEF("[Symbol.iterator]", 0, js_iterator_proto_iterator),
};

static const JSCFunctionListEntry js_array_iterator_proto_funcs[] = {
    JS_ITERATOR_NEXT_DEF("next", 0, js_array_iterator_next, 0),
    JS_PROP_STRING_DEF("[Symbol.toStringTag]", "Array Iterator", JS_PROP_CONFIGURABLE),
};

/* Number */
static const JSCFunctionListEntry js_number_funcs[] = {
    /* global ParseInt and parseFloat should be defined already or delayed */
    JS_ALIAS_BASE_DEF("parseInt", "parseInt", 0),
    JS_ALIAS_BASE_DEF("parseFloat", "parseFloat", 0),
    JS_CFUNC_DEF("isNaN", 1, js_number_isNaN),
    JS_CFUNC_DEF("isFinite", 1, js_number_isFinite),
    JS_CFUNC_DEF("isInteger", 1, js_number_isInteger),
    JS_CFUNC_DEF("isSafeInteger", 1, js_number_isSafeInteger),
    JS_PROP_DOUBLE_DEF("MAX_VALUE", 1.7976931348623157e+308, 0),
    JS_PROP_DOUBLE_DEF("MIN_VALUE", 5e-324, 0),
    JS_PROP_DOUBLE_DEF("NaN", NAN, 0),
    JS_PROP_DOUBLE_DEF("NEGATIVE_INFINITY", -INFINITY, 0),
    JS_PROP_DOUBLE_DEF("POSITIVE_INFINITY", INFINITY, 0),
    JS_PROP_DOUBLE_DEF("EPSILON", 2.220446049250313e-16, 0),        /* ES6 */
    JS_PROP_DOUBLE_DEF("MAX_SAFE_INTEGER", 9007199254740991.0, 0),  /* ES6 */
    JS_PROP_DOUBLE_DEF("MIN_SAFE_INTEGER", -9007199254740991.0, 0), /* ES6 */
                                                                    // JS_CFUNC_DEF("__toInteger", 1, js_number___toInteger ),
                                                                    // JS_CFUNC_DEF("__toLength", 1, js_number___toLength ),
};
static const JSCFunctionListEntry js_number_proto_funcs[] = {
    JS_CFUNC_DEF("toExponential", 1, js_number_toExponential),      JS_CFUNC_DEF("toFixed", 1, js_number_toFixed),
    JS_CFUNC_DEF("toPrecision", 1, js_number_toPrecision),          JS_CFUNC_MAGIC_DEF("toString", 1, js_number_toString, 0),
    JS_CFUNC_MAGIC_DEF("toLocaleString", 0, js_number_toString, 1), JS_CFUNC_DEF("valueOf", 0, js_number_valueOf),
};

/* global object */
static const JSCFunctionListEntry js_global_funcs[] = {
    JS_CFUNC_DEF("parseInt", 2, js_parseInt), JS_CFUNC_DEF("parseFloat", 1, js_parseFloat), JS_CFUNC_DEF("isNaN", 1, js_global_isNaN), JS_CFUNC_DEF("isFinite", 1, js_global_isFinite),
    JS_CFUNC_MAGIC_DEF("decodeURI", 1, js_global_decodeURI, 0), JS_CFUNC_MAGIC_DEF("decodeURIComponent", 1, js_global_decodeURI, 1), JS_CFUNC_MAGIC_DEF("encodeURI", 1, js_global_encodeURI, 0),
    JS_CFUNC_MAGIC_DEF("encodeURIComponent", 1, js_global_encodeURI, 1), JS_CFUNC_DEF("escape", 1, js_global_escape), JS_CFUNC_DEF("unescape", 1, js_global_unescape),
    JS_PROP_DOUBLE_DEF("Infinity", 1.0 / 0.0, 0), JS_PROP_DOUBLE_DEF("NaN", NAN, 0), JS_PROP_UNDEFINED_DEF("undefined", 0),

    /* for the 'Date' implementation */
    JS_CFUNC_DEF("__date_clock", 0, js___date_clock),
    // JS_CFUNC_DEF("__date_now", 0, js___date_now ),
    // JS_CFUNC_DEF("__date_getTimezoneOffset", 1, js___date_getTimezoneOffset ),
    // JS_CFUNC_DEF("__date_create", 3, js___date_create ),
};

/* Boolean */
static const JSCFunctionListEntry js_boolean_proto_funcs[] = {
    JS_CFUNC_DEF("toString", 0, js_boolean_toString),
    JS_CFUNC_DEF("valueOf", 0, js_boolean_valueOf),
};

/* String */
static const JSCFunctionListEntry js_string_funcs[] = {
    JS_CFUNC_DEF("fromCharCode", 1, js_string_fromCharCode), JS_CFUNC_DEF("fromCodePoint", 1, js_string_fromCodePoint), JS_CFUNC_DEF("raw", 1, js_string_raw),
    // JS_CFUNC_DEF("__toString", 1, js_string___toString ),
    // JS_CFUNC_DEF("__isSpace", 1, js_string___isSpace ),
    // JS_CFUNC_DEF("__toStringCheckObject", 1, js_string___toStringCheckObject ),
    // JS_CFUNC_DEF("__advanceStringIndex", 3, js_string___advanceStringIndex ),
    // JS_CFUNC_DEF("__GetSubstitution", 6, js_string___GetSubstitution ),
};

static const JSCFunctionListEntry js_string_proto_funcs[] = {
    JS_PROP_INT32_DEF("length", 0, JS_PROP_CONFIGURABLE),
    JS_CFUNC_DEF("charCodeAt", 1, js_string_charCodeAt),
    JS_CFUNC_DEF("charAt", 1, js_string_charAt),
    JS_CFUNC_DEF("concat", 1, js_string_concat),
    JS_CFUNC_DEF("codePointAt", 1, js_string_codePointAt),
    JS_CFUNC_MAGIC_DEF("indexOf", 1, js_string_indexOf, 0),
    JS_CFUNC_MAGIC_DEF("lastIndexOf", 1, js_string_indexOf, 1),
    JS_CFUNC_MAGIC_DEF("includes", 1, js_string_includes, 0),
    JS_CFUNC_MAGIC_DEF("endsWith", 1, js_string_includes, 2),
    JS_CFUNC_MAGIC_DEF("startsWith", 1, js_string_includes, 1),
    JS_CFUNC_MAGIC_DEF("match", 1, js_string_match, JS_ATOM_Symbol_match),
    JS_CFUNC_MAGIC_DEF("matchAll", 1, js_string_match, JS_ATOM_Symbol_matchAll),
    JS_CFUNC_MAGIC_DEF("search", 1, js_string_match, JS_ATOM_Symbol_search),
    JS_CFUNC_DEF("split", 2, js_string_split),
    JS_CFUNC_DEF("substring", 2, js_string_substring),
    JS_CFUNC_DEF("substr", 2, js_string_substr),
    JS_CFUNC_DEF("slice", 2, js_string_slice),
    JS_CFUNC_DEF("repeat", 1, js_string_repeat),
    JS_CFUNC_MAGIC_DEF("replace", 2, js_string_replace, 0),
    JS_CFUNC_MAGIC_DEF("replaceAll", 2, js_string_replace, 1),
    JS_CFUNC_MAGIC_DEF("padEnd", 1, js_string_pad, 1),
    JS_CFUNC_MAGIC_DEF("padStart", 1, js_string_pad, 0),
    JS_CFUNC_MAGIC_DEF("trim", 0, js_string_trim, 3),
    JS_CFUNC_MAGIC_DEF("trimEnd", 0, js_string_trim, 2),
    JS_ALIAS_DEF("trimRight", "trimEnd"),
    JS_CFUNC_MAGIC_DEF("trimStart", 0, js_string_trim, 1),
    JS_ALIAS_DEF("trimLeft", "trimStart"),
    JS_CFUNC_DEF("toString", 0, js_string_toString),
    JS_CFUNC_DEF("valueOf", 0, js_string_toString),
    JS_CFUNC_DEF("__quote", 1, js_string___quote),
    JS_CFUNC_DEF("localeCompare", 1, js_string_localeCompare),
    JS_CFUNC_MAGIC_DEF("toLowerCase", 0, js_string_toLowerCase, 1),
    JS_CFUNC_MAGIC_DEF("toUpperCase", 0, js_string_toLowerCase, 0),
    JS_CFUNC_MAGIC_DEF("toLocaleLowerCase", 0, js_string_toLowerCase, 1),
    JS_CFUNC_MAGIC_DEF("toLocaleUpperCase", 0, js_string_toLowerCase, 0),
    JS_CFUNC_MAGIC_DEF("[Symbol.iterator]", 0, js_create_array_iterator, JS_ITERATOR_KIND_VALUE | 4),
    /* ES6 Annex B 2.3.2 etc. */
    JS_CFUNC_MAGIC_DEF("anchor", 1, js_string_CreateHTML, magic_string_anchor),
    JS_CFUNC_MAGIC_DEF("big", 0, js_string_CreateHTML, magic_string_big),
    JS_CFUNC_MAGIC_DEF("blink", 0, js_string_CreateHTML, magic_string_blink),
    JS_CFUNC_MAGIC_DEF("bold", 0, js_string_CreateHTML, magic_string_bold),
    JS_CFUNC_MAGIC_DEF("fixed", 0, js_string_CreateHTML, magic_string_fixed),
    JS_CFUNC_MAGIC_DEF("fontcolor", 1, js_string_CreateHTML, magic_string_fontcolor),
    JS_CFUNC_MAGIC_DEF("fontsize", 1, js_string_CreateHTML, magic_string_fontsize),
    JS_CFUNC_MAGIC_DEF("italics", 0, js_string_CreateHTML, magic_string_italics),
    JS_CFUNC_MAGIC_DEF("link", 1, js_string_CreateHTML, magic_string_link),
    JS_CFUNC_MAGIC_DEF("small", 0, js_string_CreateHTML, magic_string_small),
    JS_CFUNC_MAGIC_DEF("strike", 0, js_string_CreateHTML, magic_string_strike),
    JS_CFUNC_MAGIC_DEF("sub", 0, js_string_CreateHTML, magic_string_sub),
    JS_CFUNC_MAGIC_DEF("sup", 0, js_string_CreateHTML, magic_string_sup),
};

static const JSCFunctionListEntry js_string_iterator_proto_funcs[] = {
    JS_ITERATOR_NEXT_DEF("next", 0, js_string_iterator_next, 0),
    JS_PROP_STRING_DEF("[Symbol.toStringTag]", "String Iterator", JS_PROP_CONFIGURABLE),
};

#ifdef CONFIG_ALL_UNICODE
static const JSCFunctionListEntry js_string_proto_normalize[] = {
    JS_CFUNC_DEF("normalize", 0, js_string_normalize),
};
#endif

/* Math */
static const JSCFunctionListEntry js_math_funcs[] = {
    JS_CFUNC_MAGIC_DEF("min", 2, js_math_min_max, 0),
    JS_CFUNC_MAGIC_DEF("max", 2, js_math_min_max, 1),
    JS_CFUNC_SPECIAL_DEF("abs", 1, f_f, fabs),
    JS_CFUNC_SPECIAL_DEF("floor", 1, f_f, floor),
    JS_CFUNC_SPECIAL_DEF("ceil", 1, f_f, ceil),
    JS_CFUNC_SPECIAL_DEF("round", 1, f_f, js_math_round),
    JS_CFUNC_SPECIAL_DEF("sqrt", 1, f_f, sqrt),

    JS_CFUNC_SPECIAL_DEF("acos", 1, f_f, acos),
    JS_CFUNC_SPECIAL_DEF("asin", 1, f_f, asin),
    JS_CFUNC_SPECIAL_DEF("atan", 1, f_f, atan),
    JS_CFUNC_SPECIAL_DEF("atan2", 2, f_f_f, atan2),
    JS_CFUNC_SPECIAL_DEF("cos", 1, f_f, cos),
    JS_CFUNC_SPECIAL_DEF("exp", 1, f_f, exp),
    JS_CFUNC_SPECIAL_DEF("log", 1, f_f, log),
    JS_CFUNC_SPECIAL_DEF("pow", 2, f_f_f, js_pow),
    JS_CFUNC_SPECIAL_DEF("sin", 1, f_f, sin),
    JS_CFUNC_SPECIAL_DEF("tan", 1, f_f, tan),
    /* ES6 */
    JS_CFUNC_SPECIAL_DEF("trunc", 1, f_f, trunc),
    JS_CFUNC_SPECIAL_DEF("sign", 1, f_f, js_math_sign),
    JS_CFUNC_SPECIAL_DEF("cosh", 1, f_f, cosh),
    JS_CFUNC_SPECIAL_DEF("sinh", 1, f_f, sinh),
    JS_CFUNC_SPECIAL_DEF("tanh", 1, f_f, tanh),
    JS_CFUNC_SPECIAL_DEF("acosh", 1, f_f, acosh),
    JS_CFUNC_SPECIAL_DEF("asinh", 1, f_f, asinh),
    JS_CFUNC_SPECIAL_DEF("atanh", 1, f_f, atanh),
    JS_CFUNC_SPECIAL_DEF("expm1", 1, f_f, expm1),
    JS_CFUNC_SPECIAL_DEF("log1p", 1, f_f, log1p),
    JS_CFUNC_SPECIAL_DEF("log2", 1, f_f, log2),
    JS_CFUNC_SPECIAL_DEF("log10", 1, f_f, log10),
    JS_CFUNC_SPECIAL_DEF("cbrt", 1, f_f, cbrt),
    JS_CFUNC_DEF("hypot", 2, js_math_hypot),
    JS_CFUNC_DEF("random", 0, js_math_random),
    JS_CFUNC_SPECIAL_DEF("fround", 1, f_f, js_math_fround),
    JS_CFUNC_DEF("imul", 2, js_math_imul),
    JS_CFUNC_DEF("clz32", 1, js_math_clz32),
    JS_PROP_STRING_DEF("[Symbol.toStringTag]", "Math", JS_PROP_CONFIGURABLE),
    JS_PROP_DOUBLE_DEF("E", 2.718281828459045, 0),
    JS_PROP_DOUBLE_DEF("LN10", 2.302585092994046, 0),
    JS_PROP_DOUBLE_DEF("LN2", 0.6931471805599453, 0),
    JS_PROP_DOUBLE_DEF("LOG2E", 1.4426950408889634, 0),
    JS_PROP_DOUBLE_DEF("LOG10E", 0.4342944819032518, 0),
    JS_PROP_DOUBLE_DEF("PI", 3.141592653589793, 0),
    JS_PROP_DOUBLE_DEF("SQRT1_2", 0.7071067811865476, 0),
    JS_PROP_DOUBLE_DEF("SQRT2", 1.4142135623730951, 0),
};

static const JSCFunctionListEntry js_math_obj[] = {
    JS_OBJECT_DEF("Math", js_math_funcs, countof(js_math_funcs), JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE),
};

/* Reflect */
static const JSCFunctionListEntry js_reflect_funcs[] = {
    JS_CFUNC_DEF("apply", 3, js_reflect_apply),
    JS_CFUNC_DEF("construct", 2, js_reflect_construct),
    JS_CFUNC_MAGIC_DEF("defineProperty", 3, js_object_defineProperty, 1),
    JS_CFUNC_DEF("deleteProperty", 2, js_reflect_deleteProperty),
    JS_CFUNC_DEF("get", 2, js_reflect_get),
    JS_CFUNC_MAGIC_DEF("getOwnPropertyDescriptor", 2, js_object_getOwnPropertyDescriptor, 1),
    JS_CFUNC_MAGIC_DEF("getPrototypeOf", 1, js_object_getPrototypeOf, 1),
    JS_CFUNC_DEF("has", 2, js_reflect_has),
    JS_CFUNC_MAGIC_DEF("isExtensible", 1, js_object_isExtensible, 1),
    JS_CFUNC_DEF("ownKeys", 1, js_reflect_ownKeys),
    JS_CFUNC_MAGIC_DEF("preventExtensions", 1, js_object_preventExtensions, 1),
    JS_CFUNC_DEF("set", 3, js_reflect_set),
    JS_CFUNC_DEF("setPrototypeOf", 2, js_reflect_setPrototypeOf),
    JS_PROP_STRING_DEF("[Symbol.toStringTag]", "Reflect", JS_PROP_CONFIGURABLE),
};

static const JSCFunctionListEntry js_reflect_obj[] = {
    JS_OBJECT_DEF("Reflect", js_reflect_funcs, countof(js_reflect_funcs), JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE),
};

/* Symbol */
static const JSCFunctionListEntry js_symbol_proto_funcs[] = {
    JS_CFUNC_DEF("toString", 0, js_symbol_toString),
    JS_CFUNC_DEF("valueOf", 0, js_symbol_valueOf),
    // XXX: should have writable: false
    JS_CFUNC_DEF("[Symbol.toPrimitive]", 1, js_symbol_valueOf),
    JS_PROP_STRING_DEF("[Symbol.toStringTag]", "Symbol", JS_PROP_CONFIGURABLE),
    JS_CGETSET_DEF("description", js_symbol_get_description, NULL),
};

static const JSCFunctionListEntry js_symbol_funcs[] = {
    JS_CFUNC_DEF("for", 1, js_symbol_for),
    JS_CFUNC_DEF("keyFor", 1, js_symbol_keyFor),
};

/* Generator */
static const JSCFunctionListEntry js_generator_function_proto_funcs[] = {
    JS_PROP_STRING_DEF("[Symbol.toStringTag]", "GeneratorFunction", JS_PROP_CONFIGURABLE),
};

static const JSCFunctionListEntry js_generator_proto_funcs[] = {
    JS_ITERATOR_NEXT_DEF("next", 1, js_generator_next, GEN_MAGIC_NEXT),
    JS_ITERATOR_NEXT_DEF("return", 1, js_generator_next, GEN_MAGIC_RETURN),
    JS_ITERATOR_NEXT_DEF("throw", 1, js_generator_next, GEN_MAGIC_THROW),
    JS_PROP_STRING_DEF("[Symbol.toStringTag]", "Generator", JS_PROP_CONFIGURABLE),
};

void JS_AddIntrinsicStringNormalize(JSContext* ctx) {
#ifdef CONFIG_ALL_UNICODE
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_STRING], js_string_proto_normalize, countof(js_string_proto_normalize));
#endif
}

void JS_AddIntrinsicBaseObjects(JSContext* ctx) {
  int i;
  JSValueConst obj, number_obj;
  JSValue obj1;

  ctx->throw_type_error = JS_NewCFunction(ctx, js_throw_type_error, NULL, 0);

  /* add caller and arguments properties to throw a TypeError */
  obj1 = JS_NewCFunction(ctx, js_function_proto_caller, NULL, 0);
  JS_DefineProperty(ctx, ctx->function_proto, JS_ATOM_caller, JS_UNDEFINED, obj1, ctx->throw_type_error, JS_PROP_HAS_GET | JS_PROP_HAS_SET | JS_PROP_HAS_CONFIGURABLE | JS_PROP_CONFIGURABLE);
  JS_DefineProperty(ctx, ctx->function_proto, JS_ATOM_arguments, JS_UNDEFINED, obj1, ctx->throw_type_error, JS_PROP_HAS_GET | JS_PROP_HAS_SET | JS_PROP_HAS_CONFIGURABLE | JS_PROP_CONFIGURABLE);
  JS_FreeValue(ctx, obj1);
  JS_FreeValue(ctx, js_object_seal(ctx, JS_UNDEFINED, 1, (JSValueConst*)&ctx->throw_type_error, 1));

  ctx->global_obj = JS_NewObject(ctx);
  ctx->global_var_obj = JS_NewObjectProto(ctx, JS_NULL);

  /* Object */
  obj = JS_NewGlobalCConstructor(ctx, "Object", js_object_constructor, 1, ctx->class_proto[JS_CLASS_OBJECT]);
  JS_SetPropertyFunctionList(ctx, obj, js_object_funcs, countof(js_object_funcs));
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_OBJECT], js_object_proto_funcs, countof(js_object_proto_funcs));

  /* Function */
  JS_SetPropertyFunctionList(ctx, ctx->function_proto, js_function_proto_funcs, countof(js_function_proto_funcs));
  ctx->function_ctor = JS_NewCFunctionMagic(ctx, js_function_constructor, "Function", 1, JS_CFUNC_constructor_or_func_magic, JS_FUNC_NORMAL);
  JS_NewGlobalCConstructor2(ctx, JS_DupValue(ctx, ctx->function_ctor), "Function", ctx->function_proto);

  /* Error */
  obj1 = JS_NewCFunctionMagic(ctx, js_error_constructor, "Error", 1, JS_CFUNC_constructor_or_func_magic, -1);
  JS_NewGlobalCConstructor2(ctx, obj1, "Error", ctx->class_proto[JS_CLASS_ERROR]);

  for (i = 0; i < JS_NATIVE_ERROR_COUNT; i++) {
    JSValue func_obj;
    int n_args;
    n_args = 1 + (i == JS_AGGREGATE_ERROR);
    func_obj = JS_NewCFunction3(ctx, (JSCFunction*)js_error_constructor, native_error_name[i], n_args, JS_CFUNC_constructor_or_func_magic, i, obj1);
    JS_NewGlobalCConstructor2(ctx, func_obj, native_error_name[i], ctx->native_error_proto[i]);
  }

  /* Iterator prototype */
  ctx->iterator_proto = JS_NewObject(ctx);
  JS_SetPropertyFunctionList(ctx, ctx->iterator_proto, js_iterator_proto_funcs, countof(js_iterator_proto_funcs));

  /* Array */
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_ARRAY], js_array_proto_funcs, countof(js_array_proto_funcs));

  obj = JS_NewGlobalCConstructor(ctx, "Array", js_array_constructor, 1, ctx->class_proto[JS_CLASS_ARRAY]);
  ctx->array_ctor = JS_DupValue(ctx, obj);
  JS_SetPropertyFunctionList(ctx, obj, js_array_funcs, countof(js_array_funcs));

  /* XXX: create auto_initializer */
  {
    /* initialize Array.prototype[Symbol.unscopables] */
    char const unscopables[] =
        "copyWithin"
        "\0"
        "entries"
        "\0"
        "fill"
        "\0"
        "find"
        "\0"
        "findIndex"
        "\0"
        "flat"
        "\0"
        "flatMap"
        "\0"
        "includes"
        "\0"
        "keys"
        "\0"
        "values"
        "\0";
    const char* p = unscopables;
    obj1 = JS_NewObjectProto(ctx, JS_NULL);
    for (p = unscopables; *p; p += strlen(p) + 1) {
      JS_DefinePropertyValueStr(ctx, obj1, p, JS_TRUE, JS_PROP_C_W_E);
    }
    JS_DefinePropertyValue(ctx, ctx->class_proto[JS_CLASS_ARRAY], JS_ATOM_Symbol_unscopables, obj1, JS_PROP_CONFIGURABLE);
  }

  /* needed to initialize arguments[Symbol.iterator] */
  ctx->array_proto_values = JS_GetProperty(ctx, ctx->class_proto[JS_CLASS_ARRAY], JS_ATOM_values);

  ctx->class_proto[JS_CLASS_ARRAY_ITERATOR] = JS_NewObjectProto(ctx, ctx->iterator_proto);
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_ARRAY_ITERATOR], js_array_iterator_proto_funcs, countof(js_array_iterator_proto_funcs));

  /* parseFloat and parseInteger must be defined before Number
     because of the Number.parseFloat and Number.parseInteger
     aliases */
  JS_SetPropertyFunctionList(ctx, ctx->global_obj, js_global_funcs, countof(js_global_funcs));

  /* Number */
  ctx->class_proto[JS_CLASS_NUMBER] = JS_NewObjectProtoClass(ctx, ctx->class_proto[JS_CLASS_OBJECT], JS_CLASS_NUMBER);
  JS_SetObjectData(ctx, ctx->class_proto[JS_CLASS_NUMBER], JS_NewInt32(ctx, 0));
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_NUMBER], js_number_proto_funcs, countof(js_number_proto_funcs));
  number_obj = JS_NewGlobalCConstructor(ctx, "Number", js_number_constructor, 1, ctx->class_proto[JS_CLASS_NUMBER]);
  JS_SetPropertyFunctionList(ctx, number_obj, js_number_funcs, countof(js_number_funcs));

  /* Boolean */
  ctx->class_proto[JS_CLASS_BOOLEAN] = JS_NewObjectProtoClass(ctx, ctx->class_proto[JS_CLASS_OBJECT], JS_CLASS_BOOLEAN);
  JS_SetObjectData(ctx, ctx->class_proto[JS_CLASS_BOOLEAN], JS_NewBool(ctx, FALSE));
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_BOOLEAN], js_boolean_proto_funcs, countof(js_boolean_proto_funcs));
  JS_NewGlobalCConstructor(ctx, "Boolean", js_boolean_constructor, 1, ctx->class_proto[JS_CLASS_BOOLEAN]);

  /* String */
  ctx->class_proto[JS_CLASS_STRING] = JS_NewObjectProtoClass(ctx, ctx->class_proto[JS_CLASS_OBJECT], JS_CLASS_STRING);
  JS_SetObjectData(ctx, ctx->class_proto[JS_CLASS_STRING], JS_AtomToString(ctx, JS_ATOM_empty_string));
  obj = JS_NewGlobalCConstructor(ctx, "String", js_string_constructor, 1, ctx->class_proto[JS_CLASS_STRING]);
  JS_SetPropertyFunctionList(ctx, obj, js_string_funcs, countof(js_string_funcs));
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_STRING], js_string_proto_funcs, countof(js_string_proto_funcs));

  ctx->class_proto[JS_CLASS_STRING_ITERATOR] = JS_NewObjectProto(ctx, ctx->iterator_proto);
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_STRING_ITERATOR], js_string_iterator_proto_funcs, countof(js_string_iterator_proto_funcs));

  /* Math: create as autoinit object */
  js_random_init(ctx);
  JS_SetPropertyFunctionList(ctx, ctx->global_obj, js_math_obj, countof(js_math_obj));

  /* ES6 Reflect: create as autoinit object */
  JS_SetPropertyFunctionList(ctx, ctx->global_obj, js_reflect_obj, countof(js_reflect_obj));

  /* ES6 Symbol */
  ctx->class_proto[JS_CLASS_SYMBOL] = JS_NewObject(ctx);
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_SYMBOL], js_symbol_proto_funcs, countof(js_symbol_proto_funcs));
  obj = JS_NewGlobalCConstructor(ctx, "Symbol", js_symbol_constructor, 0, ctx->class_proto[JS_CLASS_SYMBOL]);
  JS_SetPropertyFunctionList(ctx, obj, js_symbol_funcs, countof(js_symbol_funcs));
  for (i = JS_ATOM_Symbol_toPrimitive; i <= JS_ATOM_Symbol_asyncIterator; i++) {
    char buf[ATOM_GET_STR_BUF_SIZE];
    const char *str, *p;
    str = JS_AtomGetStr(ctx, buf, sizeof(buf), i);
    /* skip "Symbol." */
    p = strchr(str, '.');
    if (p)
      str = p + 1;
    JS_DefinePropertyValueStr(ctx, obj, str, JS_AtomToValue(ctx, i), 0);
  }

  /* ES6 Generator */
  ctx->class_proto[JS_CLASS_GENERATOR] = JS_NewObjectProto(ctx, ctx->iterator_proto);
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_GENERATOR], js_generator_proto_funcs, countof(js_generator_proto_funcs));

  ctx->class_proto[JS_CLASS_GENERATOR_FUNCTION] = JS_NewObjectProto(ctx, ctx->function_proto);
  obj1 = JS_NewCFunctionMagic(ctx, js_function_constructor, "GeneratorFunction", 1, JS_CFUNC_constructor_or_func_magic, JS_FUNC_GENERATOR);
  JS_SetPropertyFunctionList(ctx, ctx->class_proto[JS_CLASS_GENERATOR_FUNCTION], js_generator_function_proto_funcs, countof(js_generator_function_proto_funcs));
  JS_SetConstructor2(ctx, ctx->class_proto[JS_CLASS_GENERATOR_FUNCTION], ctx->class_proto[JS_CLASS_GENERATOR], JS_PROP_CONFIGURABLE, JS_PROP_CONFIGURABLE);
  JS_SetConstructor2(ctx, obj1, ctx->class_proto[JS_CLASS_GENERATOR_FUNCTION], 0, JS_PROP_CONFIGURABLE);
  JS_FreeValue(ctx, obj1);

  /* global properties */
  ctx->eval_obj = JS_NewCFunction(ctx, js_global_eval, "eval", 1);
  JS_DefinePropertyValue(ctx, ctx->global_obj, JS_ATOM_eval, JS_DupValue(ctx, ctx->eval_obj), JS_PROP_WRITABLE | JS_PROP_CONFIGURABLE);

  JS_DefinePropertyValue(ctx, ctx->global_obj, JS_ATOM_globalThis, JS_DupValue(ctx, ctx->global_obj), JS_PROP_CONFIGURABLE | JS_PROP_WRITABLE);
}

void JS_SetRuntimeInfo(JSRuntime* rt, const char* s) {
  if (rt)
    rt->rt_info = s;
}

void JS_FreeRuntime(JSRuntime* rt) {
#if ENABLE_DEBUGGER
  js_debugger_free(rt, &rt->debugger_info);
#endif
  struct list_head *el, *el1;
  int i;

  JS_FreeValueRT(rt, rt->current_exception);

  list_for_each_safe(el, el1, &rt->job_list) {
    JSJobEntry* e = list_entry(el, JSJobEntry, link);
    for (i = 0; i < e->argc; i++)
      JS_FreeValueRT(rt, e->argv[i]);
    js_free_rt(rt, e);
  }
  init_list_head(&rt->job_list);

  JS_RunGC(rt);

#ifdef DUMP_LEAKS
  /* leaking objects */
  {
    BOOL header_done;
    JSGCObjectHeader* p;
    int count;

    /* remove the internal refcounts to display only the object
       referenced externally */
    list_for_each(el, &rt->gc_obj_list) {
      p = list_entry(el, JSGCObjectHeader, link);
      p->mark = 0;
    }
    gc_decref(rt);

    header_done = FALSE;
    list_for_each(el, &rt->gc_obj_list) {
      p = list_entry(el, JSGCObjectHeader, link);
      if (p->ref_count != 0) {
        if (!header_done) {
          printf("Object leaks:\n");
          JS_DumpObjectHeader(rt);
          header_done = TRUE;
        }
        JS_DumpGCObject(rt, p);
      }
    }

    count = 0;
    list_for_each(el, &rt->gc_obj_list) {
      p = list_entry(el, JSGCObjectHeader, link);
      if (p->ref_count == 0) {
        count++;
      }
    }
    if (count != 0)
      printf("Secondary object leaks: %d\n", count);
  }
#endif
  assert(list_empty(&rt->gc_obj_list));

  /* free the classes */
  for (i = 0; i < rt->class_count; i++) {
    JSClass* cl = &rt->class_array[i];
    if (cl->class_id != 0) {
      JS_FreeAtomRT(rt, cl->class_name);
    }
  }
  js_free_rt(rt, rt->class_array);

#ifdef CONFIG_BIGNUM
  bf_context_end(&rt->bf_ctx);
#endif

#ifdef DUMP_LEAKS
  /* only the atoms defined in JS_InitAtoms() should be left */
  {
    BOOL header_done = FALSE;

    for (i = 0; i < rt->atom_size; i++) {
      JSAtomStruct* p = rt->atom_array[i];
      if (!atom_is_free(p) /* && p->str*/) {
        if (i >= JS_ATOM_END || p->header.ref_count != 1) {
          if (!header_done) {
            header_done = TRUE;
            if (rt->rt_info) {
              printf("%s:1: atom leakage:", rt->rt_info);
            } else {
              printf(
                  "Atom leaks:\n"
                  "    %6s %6s %s\n",
                  "ID", "REFCNT", "NAME");
            }
          }
          if (rt->rt_info) {
            printf(" ");
          } else {
            printf("    %6u %6u ", i, p->header.ref_count);
          }
          switch (p->atom_type) {
            case JS_ATOM_TYPE_STRING:
              JS_DumpString(rt, p);
              break;
            case JS_ATOM_TYPE_GLOBAL_SYMBOL:
              printf("Symbol.for(");
              JS_DumpString(rt, p);
              printf(")");
              break;
            case JS_ATOM_TYPE_SYMBOL:
              if (p->hash == JS_ATOM_HASH_SYMBOL) {
                printf("Symbol(");
                JS_DumpString(rt, p);
                printf(")");
              } else {
                printf("Private(");
                JS_DumpString(rt, p);
                printf(")");
              }
              break;
          }
          if (rt->rt_info) {
            printf(":%u", p->header.ref_count);
          } else {
            printf("\n");
          }
        }
      }
    }
    if (rt->rt_info && header_done)
      printf("\n");
  }
#endif

  /* free the atoms */
  for (i = 0; i < rt->atom_size; i++) {
    JSAtomStruct* p = rt->atom_array[i];
    if (!atom_is_free(p)) {
#ifdef DUMP_LEAKS
      list_del(&p->link);
#endif
      js_free_rt(rt, p);
    }
  }
  js_free_rt(rt, rt->atom_array);
  js_free_rt(rt, rt->atom_hash);
  js_free_rt(rt, rt->shape_hash);
#ifdef DUMP_LEAKS
  if (!list_empty(&rt->string_list)) {
    if (rt->rt_info) {
      printf("%s:1: string leakage:", rt->rt_info);
    } else {
      printf(
          "String leaks:\n"
          "    %6s %s\n",
          "REFCNT", "VALUE");
    }
    list_for_each_safe(el, el1, &rt->string_list) {
      JSString* str = list_entry(el, JSString, link);
      if (rt->rt_info) {
        printf(" ");
      } else {
        printf("    %6u ", str->header.ref_count);
      }
      JS_DumpString(rt, str);
      if (rt->rt_info) {
        printf(":%u", str->header.ref_count);
      } else {
        printf("\n");
      }
      list_del(&str->link);
      js_free_rt(rt, str);
    }
    if (rt->rt_info)
      printf("\n");
  }
  {
    JSMallocState* s = &rt->malloc_state;
    if (s->malloc_count > 1) {
      if (rt->rt_info)
        printf("%s:1: ", rt->rt_info);
      printf("Memory leak: %" PRIu64 " bytes lost in %" PRIu64 " block%s\n", (uint64_t)(s->malloc_size - sizeof(JSRuntime)), (uint64_t)(s->malloc_count - 1), &"s"[s->malloc_count == 2]);
    }
  }
#endif

  {
    JSMallocState ms = rt->malloc_state;
    rt->mf.js_free(&ms, rt);
  }
}

JSContext* JS_NewContextRaw(JSRuntime* rt) {
  JSContext* ctx;
  int i;

  ctx = js_mallocz_rt(rt, sizeof(JSContext));
  if (!ctx)
    return NULL;
  ctx->header.ref_count = 1;
  add_gc_object(rt, &ctx->header, JS_GC_OBJ_TYPE_JS_CONTEXT);

  ctx->class_proto = js_malloc_rt(rt, sizeof(ctx->class_proto[0]) * rt->class_count);
  if (!ctx->class_proto) {
    js_free_rt(rt, ctx);
    return NULL;
  }
  ctx->rt = rt;
  list_add_tail(&ctx->link, &rt->context_list);
#ifdef CONFIG_BIGNUM
  ctx->bf_ctx = &rt->bf_ctx;
  ctx->fp_env.prec = 113;
  ctx->fp_env.flags = bf_set_exp_bits(15) | BF_RNDN | BF_FLAG_SUBNORMAL;
#endif
  for (i = 0; i < rt->class_count; i++)
    ctx->class_proto[i] = JS_NULL;
  ctx->array_ctor = JS_NULL;
  ctx->regexp_ctor = JS_NULL;
  ctx->promise_ctor = JS_NULL;
  init_list_head(&ctx->loaded_modules);

  JS_AddIntrinsicBasicObjects(ctx);

#if ENABLE_DEBUGGER
  js_debugger_new_context(ctx);
#endif

  return ctx;
}

JSContext* JS_NewContext(JSRuntime* rt) {
  JSContext* ctx;

  ctx = JS_NewContextRaw(rt);
  if (!ctx)
    return NULL;

  JS_AddIntrinsicBaseObjects(ctx);
  JS_AddIntrinsicDate(ctx);
  JS_AddIntrinsicEval(ctx);
  JS_AddIntrinsicStringNormalize(ctx);
  JS_AddIntrinsicRegExp(ctx);
  JS_AddIntrinsicJSON(ctx);
  JS_AddIntrinsicProxy(ctx);
  JS_AddIntrinsicMapSet(ctx);
  JS_AddIntrinsicTypedArrays(ctx);
  JS_AddIntrinsicPromise(ctx);
#ifdef CONFIG_BIGNUM
  JS_AddIntrinsicBigInt(ctx);
#endif
  return ctx;
}

void* JS_GetContextOpaque(JSContext* ctx) {
  return ctx->user_opaque;
}

void JS_SetContextOpaque(JSContext* ctx, void* opaque) {
  ctx->user_opaque = opaque;
}

void JS_SetIsHTMLDDA(JSContext* ctx, JSValueConst obj) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return;
  p = JS_VALUE_GET_OBJ(obj);
  p->is_HTMLDDA = TRUE;
}

void JS_FreeContext(JSContext* ctx) {
  JSRuntime* rt = ctx->rt;
  int i;

  if (--ctx->header.ref_count > 0)
    return;
  assert(ctx->header.ref_count == 0);

#ifdef DUMP_ATOMS
  JS_DumpAtoms(ctx->rt);
#endif
#ifdef DUMP_SHAPES
  JS_DumpShapes(ctx->rt);
#endif
#ifdef DUMP_OBJECTS
  {
    struct list_head* el;
    JSGCObjectHeader* p;
    printf("JSObjects: {\n");
    JS_DumpObjectHeader(ctx->rt);
    list_for_each(el, &rt->gc_obj_list) {
      p = list_entry(el, JSGCObjectHeader, link);
      JS_DumpGCObject(rt, p);
    }
    printf("}\n");
  }
#endif
#ifdef DUMP_MEM
  {
    JSMemoryUsage stats;
    JS_ComputeMemoryUsage(rt, &stats);
    JS_DumpMemoryUsage(stdout, &stats, rt);
  }
#endif

#if ENABLE_DEBUGGER
  js_debugger_free_context(ctx);
#endif

  js_free_modules(ctx, JS_FREE_MODULE_ALL);

  JS_FreeValue(ctx, ctx->global_obj);
  JS_FreeValue(ctx, ctx->global_var_obj);

  JS_FreeValue(ctx, ctx->throw_type_error);
  JS_FreeValue(ctx, ctx->eval_obj);

  JS_FreeValue(ctx, ctx->array_proto_values);
  for (i = 0; i < JS_NATIVE_ERROR_COUNT; i++) {
    JS_FreeValue(ctx, ctx->native_error_proto[i]);
  }
  for (i = 0; i < rt->class_count; i++) {
    JS_FreeValue(ctx, ctx->class_proto[i]);
  }
  js_free_rt(rt, ctx->class_proto);
  JS_FreeValue(ctx, ctx->iterator_proto);
  JS_FreeValue(ctx, ctx->async_iterator_proto);
  JS_FreeValue(ctx, ctx->promise_ctor);
  JS_FreeValue(ctx, ctx->array_ctor);
  JS_FreeValue(ctx, ctx->regexp_ctor);
  JS_FreeValue(ctx, ctx->function_ctor);
  JS_FreeValue(ctx, ctx->function_proto);

  js_free_shape_null(ctx->rt, ctx->array_shape);

  list_del(&ctx->link);
  remove_gc_object(&ctx->header);
  js_free_rt(ctx->rt, ctx);
}

JSRuntime* JS_GetRuntime(JSContext* ctx) {
  return ctx->rt;
}

static void update_stack_limit(JSRuntime* rt) {
  if (rt->stack_size == 0) {
    rt->stack_limit = 0; /* no limit */
  } else {
    rt->stack_limit = rt->stack_top - rt->stack_size;
  }
}

void JS_SetMaxStackSize(JSRuntime* rt, size_t stack_size) {
  rt->stack_size = stack_size;
  update_stack_limit(rt);
}

void JS_UpdateStackTop(JSRuntime* rt) {
  rt->stack_top = js_get_stack_pointer();
  update_stack_limit(rt);
}

#ifdef CONFIG_BIGNUM
static JSValue JS_ThrowUnsupportedOperation(JSContext* ctx) {
  return JS_ThrowTypeError(ctx, "unsupported operation");
}

static JSValue invalid_to_string(JSContext* ctx, JSValueConst val) {
  return JS_ThrowUnsupportedOperation(ctx);
}

static JSValue invalid_from_string(JSContext* ctx, const char* buf, int radix, int flags, slimb_t* pexponent) {
  return JS_NAN;
}

static int invalid_unary_arith(JSContext* ctx, JSValue* pres, OPCodeEnum op, JSValue op1) {
  JS_FreeValue(ctx, op1);
  JS_ThrowUnsupportedOperation(ctx);
  return -1;
}

static int invalid_binary_arith(JSContext* ctx, OPCodeEnum op, JSValue* pres, JSValue op1, JSValue op2) {
  JS_FreeValue(ctx, op1);
  JS_FreeValue(ctx, op2);
  JS_ThrowUnsupportedOperation(ctx);
  return -1;
}

static JSValue invalid_mul_pow10_to_float64(JSContext* ctx, const bf_t* a, int64_t exponent) {
  return JS_ThrowUnsupportedOperation(ctx);
}

static int invalid_mul_pow10(JSContext* ctx, JSValue* sp) {
  JS_ThrowUnsupportedOperation(ctx);
  return -1;
}

static void set_dummy_numeric_ops(JSNumericOperations* ops) {
  ops->to_string = invalid_to_string;
  ops->from_string = invalid_from_string;
  ops->unary_arith = invalid_unary_arith;
  ops->binary_arith = invalid_binary_arith;
  ops->mul_pow10_to_float64 = invalid_mul_pow10_to_float64;
  ops->mul_pow10 = invalid_mul_pow10;
}

#endif /* CONFIG_BIGNUM */

int init_class_range(JSRuntime* rt, JSClassShortDef const* tab, int start, int count) {
  JSClassDef cm_s, *cm = &cm_s;
  int i, class_id;

  for (i = 0; i < count; i++) {
    class_id = i + start;
    memset(cm, 0, sizeof(*cm));
    cm->finalizer = tab[i].finalizer;
    cm->gc_mark = tab[i].gc_mark;
    if (JS_NewClass1(rt, class_id, cm, tab[i].class_name) < 0)
      return -1;
  }
  return 0;
}

JSRuntime* JS_NewRuntime2(const JSMallocFunctions* mf, void* opaque) {
  JSRuntime* rt;
  JSMallocState ms;

  memset(&ms, 0, sizeof(ms));
  ms.opaque = opaque;
  ms.malloc_limit = -1;

  rt = mf->js_malloc(&ms, sizeof(JSRuntime));
  if (!rt)
    return NULL;
  memset(rt, 0, sizeof(*rt));
  rt->mf = *mf;
  if (!rt->mf.js_malloc_usable_size) {
    /* use dummy function if none provided */
    rt->mf.js_malloc_usable_size = js_malloc_usable_size_unknown;
  }
  rt->malloc_state = ms;
  rt->malloc_gc_threshold = 256 * 1024;

#ifdef CONFIG_BIGNUM
  bf_context_init(&rt->bf_ctx, js_bf_realloc, rt);
  set_dummy_numeric_ops(&rt->bigint_ops);
  set_dummy_numeric_ops(&rt->bigfloat_ops);
  set_dummy_numeric_ops(&rt->bigdecimal_ops);
#endif

  init_list_head(&rt->context_list);
  init_list_head(&rt->gc_obj_list);
  init_list_head(&rt->gc_zero_ref_count_list);
  rt->gc_phase = JS_GC_PHASE_NONE;

#ifdef DUMP_LEAKS
  init_list_head(&rt->string_list);
#endif
  init_list_head(&rt->job_list);

  if (JS_InitAtoms(rt))
    goto fail;

  /* create the object, array and function classes */
  if (init_class_range(rt, js_std_class_def, JS_CLASS_OBJECT, countof(js_std_class_def)) < 0)
    goto fail;
  rt->class_array[JS_CLASS_ARGUMENTS].exotic = &js_arguments_exotic_methods;
  rt->class_array[JS_CLASS_STRING].exotic = &js_string_exotic_methods;
  rt->class_array[JS_CLASS_MODULE_NS].exotic = &js_module_ns_exotic_methods;

  rt->class_array[JS_CLASS_C_FUNCTION].call = js_call_c_function;
  rt->class_array[JS_CLASS_C_FUNCTION_DATA].call = js_c_function_data_call;
  rt->class_array[JS_CLASS_BOUND_FUNCTION].call = js_call_bound_function;
  rt->class_array[JS_CLASS_GENERATOR_FUNCTION].call = js_generator_function_call;
  if (init_shape_hash(rt))
    goto fail;

  rt->stack_size = JS_DEFAULT_STACK_SIZE;
  JS_UpdateStackTop(rt);

  rt->current_exception = JS_NULL;

#if ENABLE_DEBUGGER
  rt->debugger_info.runtime = rt;
#endif

  return rt;
fail:
  JS_FreeRuntime(rt);
  return NULL;
}

/* eval */

void JS_AddIntrinsicEval(JSContext* ctx) {
  ctx->eval_internal = __JS_EvalInternal;
}

static const JSMallocFunctions def_malloc_funcs = {
    js_def_malloc,
    js_def_free,
    js_def_realloc,
#if defined(__APPLE__)
    malloc_size,
#elif defined(_WIN32)
    (size_t(*)(const void*))_msize,
#elif defined(EMSCRIPTEN)
    NULL,
#elif defined(__linux__)
    (size_t(*)(const void*))malloc_usable_size,
#else
    /* change this to `NULL,` if compilation fails */
    malloc_usable_size,
#endif
};

JSRuntime* JS_NewRuntime(void) {
  return JS_NewRuntime2(&def_malloc_funcs, NULL);
}

/* the indirection is needed to make 'eval' optional */
JSValue JS_EvalInternal(JSContext* ctx, JSValueConst this_obj, const char* input, size_t input_len, const char* filename, int flags, int scope_idx) {
  if (unlikely(!ctx->eval_internal)) {
    return JS_ThrowTypeError(ctx, "eval is not supported");
  }
  return ctx->eval_internal(ctx, this_obj, input, input_len, filename, flags, scope_idx);
}

JSValue JS_EvalObject(JSContext* ctx, JSValueConst this_obj, JSValueConst val, int flags, int scope_idx) {
  JSValue ret;
  const char* str;
  size_t len;

  if (!JS_IsString(val))
    return JS_DupValue(ctx, val);
  str = JS_ToCStringLen(ctx, &len, val);
  if (!str)
    return JS_EXCEPTION;
  ret = JS_EvalInternal(ctx, this_obj, str, len, "<input>", flags, scope_idx);
  JS_FreeCString(ctx, str);
  return ret;
}

JSValue JS_EvalThis(JSContext* ctx, JSValueConst this_obj, const char* input, size_t input_len, const char* filename, int eval_flags) {
  int eval_type = eval_flags & JS_EVAL_TYPE_MASK;
  JSValue ret;

  assert(eval_type == JS_EVAL_TYPE_GLOBAL || eval_type == JS_EVAL_TYPE_MODULE);
  ret = JS_EvalInternal(ctx, this_obj, input, input_len, filename, eval_flags, -1);
  return ret;
}

JSValue JS_Eval(JSContext* ctx, const char* input, size_t input_len, const char* filename, int eval_flags) {
  return JS_EvalThis(ctx, ctx->global_obj, input, input_len, filename, eval_flags);
}

JSValue JS_EvalFunctionInternal(JSContext* ctx, JSValue fun_obj, JSValueConst this_obj, JSVarRef** var_refs, JSStackFrame* sf) {
  JSValue ret_val;
  uint32_t tag;

  tag = JS_VALUE_GET_TAG(fun_obj);
  if (tag == JS_TAG_FUNCTION_BYTECODE) {
    fun_obj = js_closure(ctx, fun_obj, var_refs, sf);
    ret_val = JS_CallFree(ctx, fun_obj, this_obj, 0, NULL);
  } else if (tag == JS_TAG_MODULE) {
    JSModuleDef* m;
    m = JS_VALUE_GET_PTR(fun_obj);
    /* the module refcount should be >= 2 */
    JS_FreeValue(ctx, fun_obj);
    if (js_create_module_function(ctx, m) < 0)
      goto fail;
    if (js_link_module(ctx, m) < 0)
      goto fail;
    ret_val = js_evaluate_module(ctx, m);
    if (JS_IsException(ret_val)) {
    fail:
      js_free_modules(ctx, JS_FREE_MODULE_NOT_EVALUATED);
      return JS_EXCEPTION;
    }
  } else {
    JS_FreeValue(ctx, fun_obj);
    ret_val = JS_ThrowTypeError(ctx, "bytecode function expected");
  }
  return ret_val;
}

JSValue JS_EvalFunction(JSContext* ctx, JSValue fun_obj) {
  return JS_EvalFunctionInternal(ctx, fun_obj, ctx->global_obj, NULL, NULL);
}