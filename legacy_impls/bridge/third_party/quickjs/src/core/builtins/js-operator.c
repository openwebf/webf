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

#include "js-operator.h"

#include "../convertion.h"
#include "../exception.h"
#include "../function.h"
#include "../object.h"
#include "../runtime.h"
#include "../string.h"
#include "js-object.h"

void js_for_in_iterator_finalizer(JSRuntime* rt, JSValue val) {
  JSObject* p = JS_VALUE_GET_OBJ(val);
  JSForInIterator* it = p->u.for_in_iterator;
  JS_FreeValueRT(rt, it->obj);
  js_free_rt(rt, it);
}

void js_for_in_iterator_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) {
  JSObject* p = JS_VALUE_GET_OBJ(val);
  JSForInIterator* it = p->u.for_in_iterator;
  JS_MarkValue(rt, it->obj, mark_func);
}

double js_pow(double a, double b) {
  if (unlikely(!isfinite(b)) && fabs(a) == 1) {
    /* not compatible with IEEE 754 */
    return JS_FLOAT64_NAN;
  } else {
    return pow(a, b);
  }
}

/* XXX: Should take JSValueConst arguments */
BOOL js_strict_eq2(JSContext* ctx, JSValue op1, JSValue op2, JSStrictEqModeEnum eq_mode) {
  BOOL res;
  int tag1, tag2;
  double d1, d2;

  tag1 = JS_VALUE_GET_NORM_TAG(op1);
  tag2 = JS_VALUE_GET_NORM_TAG(op2);
  switch (tag1) {
    case JS_TAG_BOOL:
      if (tag1 != tag2) {
        res = FALSE;
      } else {
        res = JS_VALUE_GET_INT(op1) == JS_VALUE_GET_INT(op2);
        goto done_no_free;
      }
      break;
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      res = (tag1 == tag2);
      break;
    case JS_TAG_STRING: {
      JSString *p1, *p2;
      if (tag1 != tag2) {
        res = FALSE;
      } else {
        p1 = JS_VALUE_GET_STRING(op1);
        p2 = JS_VALUE_GET_STRING(op2);
        res = (js_string_compare(ctx, p1, p2) == 0);
      }
    } break;
    case JS_TAG_SYMBOL: {
      JSAtomStruct *p1, *p2;
      if (tag1 != tag2) {
        res = FALSE;
      } else {
        p1 = JS_VALUE_GET_PTR(op1);
        p2 = JS_VALUE_GET_PTR(op2);
        res = (p1 == p2);
      }
    } break;
    case JS_TAG_OBJECT:
      if (tag1 != tag2)
        res = FALSE;
      else
        res = JS_VALUE_GET_OBJ(op1) == JS_VALUE_GET_OBJ(op2);
      break;
    case JS_TAG_INT:
      d1 = JS_VALUE_GET_INT(op1);
      if (tag2 == JS_TAG_INT) {
        d2 = JS_VALUE_GET_INT(op2);
        goto number_test;
      } else if (tag2 == JS_TAG_FLOAT64) {
        d2 = JS_VALUE_GET_FLOAT64(op2);
        goto number_test;
      } else {
        res = FALSE;
      }
      break;
    case JS_TAG_FLOAT64:
      d1 = JS_VALUE_GET_FLOAT64(op1);
      if (tag2 == JS_TAG_FLOAT64) {
        d2 = JS_VALUE_GET_FLOAT64(op2);
      } else if (tag2 == JS_TAG_INT) {
        d2 = JS_VALUE_GET_INT(op2);
      } else {
        res = FALSE;
        break;
      }
    number_test:
      if (unlikely(eq_mode >= JS_EQ_SAME_VALUE)) {
        JSFloat64Union u1, u2;
        /* NaN is not always normalized, so this test is necessary */
        if (isnan(d1) || isnan(d2)) {
          res = isnan(d1) == isnan(d2);
        } else if (eq_mode == JS_EQ_SAME_VALUE_ZERO) {
          res = (d1 == d2); /* +0 == -0 */
        } else {
          u1.d = d1;
          u2.d = d2;
          res = (u1.u64 == u2.u64); /* +0 != -0 */
        }
      } else {
        res = (d1 == d2); /* if NaN return false and +0 == -0 */
      }
      goto done_no_free;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT: {
      bf_t a_s, *a, b_s, *b;
      if (tag1 != tag2) {
        res = FALSE;
        break;
      }
      a = JS_ToBigFloat(ctx, &a_s, op1);
      b = JS_ToBigFloat(ctx, &b_s, op2);
      res = bf_cmp_eq(a, b);
      if (a == &a_s)
        bf_delete(a);
      if (b == &b_s)
        bf_delete(b);
    } break;
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat *p1, *p2;
      const bf_t *a, *b;
      if (tag1 != tag2) {
        res = FALSE;
        break;
      }
      p1 = JS_VALUE_GET_PTR(op1);
      p2 = JS_VALUE_GET_PTR(op2);
      a = &p1->num;
      b = &p2->num;
      if (unlikely(eq_mode >= JS_EQ_SAME_VALUE)) {
        if (eq_mode == JS_EQ_SAME_VALUE_ZERO && a->expn == BF_EXP_ZERO && b->expn == BF_EXP_ZERO) {
          res = TRUE;
        } else {
          res = (bf_cmp_full(a, b) == 0);
        }
      } else {
        res = bf_cmp_eq(a, b);
      }
    } break;
    case JS_TAG_BIG_DECIMAL: {
      JSBigDecimal *p1, *p2;
      const bfdec_t *a, *b;
      if (tag1 != tag2) {
        res = FALSE;
        break;
      }
      p1 = JS_VALUE_GET_PTR(op1);
      p2 = JS_VALUE_GET_PTR(op2);
      a = &p1->num;
      b = &p2->num;
      res = bfdec_cmp_eq(a, b);
    } break;
#endif
    default:
      res = FALSE;
      break;
  }
  JS_FreeValue(ctx, op1);
  JS_FreeValue(ctx, op2);
done_no_free:
  return res;
}

BOOL js_strict_eq(JSContext* ctx, JSValue op1, JSValue op2) {
  return js_strict_eq2(ctx, op1, op2, JS_EQ_STRICT);
}

BOOL js_same_value(JSContext* ctx, JSValueConst op1, JSValueConst op2) {
  return js_strict_eq2(ctx, JS_DupValue(ctx, op1), JS_DupValue(ctx, op2), JS_EQ_SAME_VALUE);
}

BOOL js_same_value_zero(JSContext* ctx, JSValueConst op1, JSValueConst op2) {
  return js_strict_eq2(ctx, JS_DupValue(ctx, op1), JS_DupValue(ctx, op2), JS_EQ_SAME_VALUE_ZERO);
}

no_inline int js_strict_eq_slow(JSContext* ctx, JSValue* sp, BOOL is_neq) {
  BOOL res;
  res = js_strict_eq(ctx, sp[-2], sp[-1]);
  sp[-2] = JS_NewBool(ctx, res ^ is_neq);
  return 0;
}

__exception int js_operator_in(JSContext* ctx, JSValue* sp) {
  JSValue op1, op2;
  JSAtom atom;
  int ret;

  op1 = sp[-2];
  op2 = sp[-1];

  if (JS_VALUE_GET_TAG(op2) != JS_TAG_OBJECT) {
    JS_ThrowTypeError(ctx, "invalid 'in' operand");
    return -1;
  }
  atom = JS_ValueToAtom(ctx, op1);
  if (unlikely(atom == JS_ATOM_NULL))
    return -1;
  ret = JS_HasProperty(ctx, op2, atom);
  JS_FreeAtom(ctx, atom);
  if (ret < 0)
    return -1;
  JS_FreeValue(ctx, op1);
  JS_FreeValue(ctx, op2);
  sp[-2] = JS_NewBool(ctx, ret);
  return 0;
}

__exception int js_has_unscopable(JSContext* ctx, JSValueConst obj, JSAtom atom) {
  JSValue arr, val;
  int ret;

  arr = JS_GetProperty(ctx, obj, JS_ATOM_Symbol_unscopables);
  if (JS_IsException(arr))
    return -1;
  ret = 0;
  if (JS_IsObject(arr)) {
    val = JS_GetProperty(ctx, arr, atom);
    ret = JS_ToBoolFree(ctx, val);
  }
  JS_FreeValue(ctx, arr);
  return ret;
}

__exception int js_operator_instanceof(JSContext* ctx, JSValue* sp) {
  JSValue op1, op2;
  BOOL ret;

  op1 = sp[-2];
  op2 = sp[-1];
  ret = JS_IsInstanceOf(ctx, op1, op2);
  if (ret < 0)
    return ret;
  JS_FreeValue(ctx, op1);
  JS_FreeValue(ctx, op2);
  sp[-2] = JS_NewBool(ctx, ret);
  return 0;
}

__exception int js_operator_typeof(JSContext* ctx, JSValueConst op1) {
  JSAtom atom;
  uint32_t tag;

  tag = JS_VALUE_GET_NORM_TAG(op1);
  switch (tag) {
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT:
      atom = JS_ATOM_bigint;
      break;
    case JS_TAG_BIG_FLOAT:
      atom = JS_ATOM_bigfloat;
      break;
    case JS_TAG_BIG_DECIMAL:
      atom = JS_ATOM_bigdecimal;
      break;
#endif
    case JS_TAG_INT:
    case JS_TAG_FLOAT64:
      atom = JS_ATOM_number;
      break;
    case JS_TAG_UNDEFINED:
      atom = JS_ATOM_undefined;
      break;
    case JS_TAG_BOOL:
      atom = JS_ATOM_boolean;
      break;
    case JS_TAG_STRING:
      atom = JS_ATOM_string;
      break;
    case JS_TAG_OBJECT: {
      JSObject* p;
      p = JS_VALUE_GET_OBJ(op1);
      if (unlikely(p->is_HTMLDDA))
        atom = JS_ATOM_undefined;
      else if (JS_IsFunction(ctx, op1))
        atom = JS_ATOM_function;
      else
        goto obj_type;
    } break;
    case JS_TAG_NULL:
    obj_type:
      atom = JS_ATOM_object;
      break;
    case JS_TAG_SYMBOL:
      atom = JS_ATOM_symbol;
      break;
    default:
      atom = JS_ATOM_unknown;
      break;
  }
  return atom;
}

__exception int js_operator_delete(JSContext* ctx, JSValue* sp) {
  JSValue op1, op2;
  JSAtom atom;
  int ret;

  op1 = sp[-2];
  op2 = sp[-1];
  atom = JS_ValueToAtom(ctx, op2);
  if (unlikely(atom == JS_ATOM_NULL))
    return -1;
  ret = JS_DeleteProperty(ctx, op1, atom, JS_PROP_THROW_STRICT);
  JS_FreeAtom(ctx, atom);
  if (unlikely(ret < 0))
    return -1;
  JS_FreeValue(ctx, op1);
  JS_FreeValue(ctx, op2);
  sp[-2] = JS_NewBool(ctx, ret);
  return 0;
}

JSValue js_throw_type_error(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  return JS_ThrowTypeError(ctx, "invalid property access");
}

JSValue js_build_rest(JSContext* ctx, int first, int argc, JSValueConst* argv) {
  JSValue val;
  int i, ret;

  val = JS_NewArray(ctx);
  if (JS_IsException(val))
    return val;
  for (i = first; i < argc; i++) {
    ret = JS_DefinePropertyValueUint32(ctx, val, i - first, JS_DupValue(ctx, argv[i]), JS_PROP_C_W_E);
    if (ret < 0) {
      JS_FreeValue(ctx, val);
      return JS_EXCEPTION;
    }
  }
  return val;
}

JSValue build_for_in_iterator(JSContext* ctx, JSValue obj) {
  JSObject* p;
  JSPropertyEnum* tab_atom;
  int i;
  JSValue enum_obj, obj1;
  JSForInIterator* it;
  uint32_t tag, tab_atom_count;

  tag = JS_VALUE_GET_TAG(obj);
  if (tag != JS_TAG_OBJECT && tag != JS_TAG_NULL && tag != JS_TAG_UNDEFINED) {
    obj = JS_ToObjectFree(ctx, obj);
  }

  it = js_malloc(ctx, sizeof(*it));
  if (!it) {
    JS_FreeValue(ctx, obj);
    return JS_EXCEPTION;
  }
  enum_obj = JS_NewObjectProtoClass(ctx, JS_NULL, JS_CLASS_FOR_IN_ITERATOR);
  if (JS_IsException(enum_obj)) {
    js_free(ctx, it);
    JS_FreeValue(ctx, obj);
    return JS_EXCEPTION;
  }
  it->is_array = FALSE;
  it->obj = obj;
  it->idx = 0;
  p = JS_VALUE_GET_OBJ(enum_obj);
  p->u.for_in_iterator = it;

  if (tag == JS_TAG_NULL || tag == JS_TAG_UNDEFINED)
    return enum_obj;

  /* fast path: assume no enumerable properties in the prototype chain */
  obj1 = JS_DupValue(ctx, obj);
  for (;;) {
    obj1 = JS_GetPrototypeFree(ctx, obj1);
    if (JS_IsNull(obj1))
      break;
    if (JS_IsException(obj1))
      goto fail;
    if (JS_GetOwnPropertyNamesInternal(ctx, &tab_atom, &tab_atom_count, JS_VALUE_GET_OBJ(obj1),
                                       JS_GPN_STRING_MASK | JS_GPN_ENUM_ONLY)) {
      JS_FreeValue(ctx, obj1);
      goto fail;
    }
    js_free_prop_enum(ctx, tab_atom, tab_atom_count);
    if (tab_atom_count != 0) {
      JS_FreeValue(ctx, obj1);
      goto slow_path;
    }
    /* must check for timeout to avoid infinite loop */
    if (js_poll_interrupts(ctx)) {
      JS_FreeValue(ctx, obj1);
      goto fail;
    }
  }

  p = JS_VALUE_GET_OBJ(obj);

  if (p->fast_array) {
    JSShape* sh;
    JSShapeProperty* prs;
    /* check that there are no enumerable normal fields */
    sh = p->shape;
    for (i = 0, prs = get_shape_prop(sh); i < sh->prop_count; i++, prs++) {
      if (prs->flags & JS_PROP_ENUMERABLE)
        goto normal_case;
    }
    /* for fast arrays, we only store the number of elements */
    it->is_array = TRUE;
    it->array_length = p->u.array.count;
  } else {
  normal_case:
    if (JS_GetOwnPropertyNamesInternal(ctx, &tab_atom, &tab_atom_count, p, JS_GPN_STRING_MASK | JS_GPN_ENUM_ONLY))
      goto fail;
    for (i = 0; i < tab_atom_count; i++) {
      JS_SetPropertyInternal(ctx, enum_obj, tab_atom[i].atom, JS_NULL, 0, NULL);
    }
    js_free_prop_enum(ctx, tab_atom, tab_atom_count);
  }
  return enum_obj;

slow_path:
  /* non enumerable properties hide the enumerables ones in the
     prototype chain */
  obj1 = JS_DupValue(ctx, obj);
  for (;;) {
    if (JS_GetOwnPropertyNamesInternal(ctx, &tab_atom, &tab_atom_count, JS_VALUE_GET_OBJ(obj1),
                                       JS_GPN_STRING_MASK | JS_GPN_SET_ENUM)) {
      JS_FreeValue(ctx, obj1);
      goto fail;
    }
    for (i = 0; i < tab_atom_count; i++) {
      JS_DefinePropertyValue(ctx, enum_obj, tab_atom[i].atom, JS_NULL,
                             (tab_atom[i].is_enumerable ? JS_PROP_ENUMERABLE : 0));
    }
    js_free_prop_enum(ctx, tab_atom, tab_atom_count);
    obj1 = JS_GetPrototypeFree(ctx, obj1);
    if (JS_IsNull(obj1))
      break;
    if (JS_IsException(obj1))
      goto fail;
    /* must check for timeout to avoid infinite loop */
    if (js_poll_interrupts(ctx)) {
      JS_FreeValue(ctx, obj1);
      goto fail;
    }
  }
  return enum_obj;

fail:
  JS_FreeValue(ctx, enum_obj);
  return JS_EXCEPTION;
}

/* obj -> enum_obj */
__exception int js_for_in_start(JSContext* ctx, JSValue* sp) {
  sp[-1] = build_for_in_iterator(ctx, sp[-1]);
  if (JS_IsException(sp[-1]))
    return -1;
  return 0;
}

/* enum_obj -> enum_obj value done */
__exception int js_for_in_next(JSContext* ctx, JSValue* sp) {
  JSValueConst enum_obj;
  JSObject* p;
  JSAtom prop;
  JSForInIterator* it;
  int ret;

  enum_obj = sp[-1];
  /* fail safe */
  if (JS_VALUE_GET_TAG(enum_obj) != JS_TAG_OBJECT)
    goto done;
  p = JS_VALUE_GET_OBJ(enum_obj);
  if (p->class_id != JS_CLASS_FOR_IN_ITERATOR)
    goto done;
  it = p->u.for_in_iterator;

  for (;;) {
    if (it->is_array) {
      if (it->idx >= it->array_length)
        goto done;
      prop = __JS_AtomFromUInt32(it->idx);
      it->idx++;
    } else {
      JSShape* sh = p->shape;
      JSShapeProperty* prs;
      if (it->idx >= sh->prop_count)
        goto done;
      prs = get_shape_prop(sh) + it->idx;
      prop = prs->atom;
      it->idx++;
      if (prop == JS_ATOM_NULL || !(prs->flags & JS_PROP_ENUMERABLE))
        continue;
    }
    /* check if the property was deleted */
    ret = JS_HasProperty(ctx, it->obj, prop);
    if (ret < 0)
      return ret;
    if (ret)
      break;
  }
  /* return the property */
  sp[0] = JS_AtomToValue(ctx, prop);
  sp[1] = JS_FALSE;
  return 0;
done:
  /* return the end */
  sp[0] = JS_UNDEFINED;
  sp[1] = JS_TRUE;
  return 0;
}

JSValue JS_GetIterator2(JSContext* ctx, JSValueConst obj, JSValueConst method) {
  JSValue enum_obj;

  enum_obj = JS_Call(ctx, method, obj, 0, NULL);
  if (JS_IsException(enum_obj))
    return enum_obj;
  if (!JS_IsObject(enum_obj)) {
    JS_FreeValue(ctx, enum_obj);
    return JS_ThrowTypeErrorNotAnObject(ctx);
  }
  return enum_obj;
}


JSValue JS_CreateAsyncFromSyncIterator(JSContext *ctx,
                                              JSValueConst sync_iter)
{
  JSValue async_iter, next_method;
  JSAsyncFromSyncIteratorData *s;

  next_method = JS_GetProperty(ctx, sync_iter, JS_ATOM_next);
  if (JS_IsException(next_method))
    return JS_EXCEPTION;
  async_iter = JS_NewObjectClass(ctx, JS_CLASS_ASYNC_FROM_SYNC_ITERATOR);
  if (JS_IsException(async_iter)) {
    JS_FreeValue(ctx, next_method);
    return async_iter;
  }
  s = js_mallocz(ctx, sizeof(*s));
  if (!s) {
    JS_FreeValue(ctx, async_iter);
    JS_FreeValue(ctx, next_method);
    return JS_EXCEPTION;
  }
  s->sync_iter = JS_DupValue(ctx, sync_iter);
  s->next_method = next_method;
  JS_SetOpaque(async_iter, s);
  return async_iter;
}

JSValue JS_GetIterator(JSContext* ctx, JSValueConst obj, BOOL is_async) {
  JSValue method, ret, sync_iter;

  if (is_async) {
    method = JS_GetProperty(ctx, obj, JS_ATOM_Symbol_asyncIterator);
    if (JS_IsException(method))
      return method;
    if (JS_IsUndefined(method) || JS_IsNull(method)) {
      method = JS_GetProperty(ctx, obj, JS_ATOM_Symbol_iterator);
      if (JS_IsException(method))
        return method;
      sync_iter = JS_GetIterator2(ctx, obj, method);
      JS_FreeValue(ctx, method);
      if (JS_IsException(sync_iter))
        return sync_iter;
      ret = JS_CreateAsyncFromSyncIterator(ctx, sync_iter);
      JS_FreeValue(ctx, sync_iter);
      return ret;
    }
  } else {
    method = JS_GetProperty(ctx, obj, JS_ATOM_Symbol_iterator);
    if (JS_IsException(method))
      return method;
  }
  if (!JS_IsFunction(ctx, method)) {
    JS_FreeValue(ctx, method);
    return JS_ThrowTypeError(ctx, "value is not iterable");
  }
  ret = JS_GetIterator2(ctx, obj, method);
  JS_FreeValue(ctx, method);
  return ret;
}

/* return *pdone = 2 if the iterator object is not parsed */
JSValue JS_IteratorNext2(JSContext* ctx,
                                JSValueConst enum_obj,
                                JSValueConst method,
                                int argc,
                                JSValueConst* argv,
                                int* pdone) {
  JSValue obj;

  /* fast path for the built-in iterators (avoid creating the
     intermediate result object) */
  if (JS_IsObject(method)) {
    JSObject* p = JS_VALUE_GET_OBJ(method);
    if (p->class_id == JS_CLASS_C_FUNCTION && p->u.cfunc.cproto == JS_CFUNC_iterator_next) {
      JSCFunctionType func;
      JSValueConst args[1];

      /* in case the function expects one argument */
      if (argc == 0) {
        args[0] = JS_UNDEFINED;
        argv = args;
      }
      func = p->u.cfunc.c_function;
      return func.iterator_next(ctx, enum_obj, argc, argv, pdone, p->u.cfunc.magic);
    }
  }
  obj = JS_Call(ctx, method, enum_obj, argc, argv);
  if (JS_IsException(obj))
    goto fail;
  if (!JS_IsObject(obj)) {
    JS_FreeValue(ctx, obj);
    JS_ThrowTypeError(ctx, "iterator must return an object");
    goto fail;
  }
  *pdone = 2;
  return obj;
fail:
  *pdone = FALSE;
  return JS_EXCEPTION;
}

JSValue JS_IteratorNext(JSContext* ctx,
                               JSValueConst enum_obj,
                               JSValueConst method,
                               int argc,
                               JSValueConst* argv,
                               BOOL* pdone) {
  JSValue obj, value, done_val;
  int done;

  obj = JS_IteratorNext2(ctx, enum_obj, method, argc, argv, &done);
  if (JS_IsException(obj))
    goto fail;
  if (done != 2) {
    *pdone = done;
    return obj;
  } else {
    done_val = JS_GetProperty(ctx, obj, JS_ATOM_done);
    if (JS_IsException(done_val))
      goto fail;
    *pdone = JS_ToBoolFree(ctx, done_val);
    value = JS_UNDEFINED;
    if (!*pdone) {
      value = JS_GetProperty(ctx, obj, JS_ATOM_value);
    }
    JS_FreeValue(ctx, obj);
    return value;
  }
fail:
  JS_FreeValue(ctx, obj);
  *pdone = FALSE;
  return JS_EXCEPTION;
}

/* return < 0 in case of exception */
int JS_IteratorClose(JSContext* ctx, JSValueConst enum_obj, BOOL is_exception_pending) {
  JSValue method, ret, ex_obj;
  int res;

  if (is_exception_pending) {
    ex_obj = ctx->rt->current_exception;
    ctx->rt->current_exception = JS_NULL;
    res = -1;
  } else {
    ex_obj = JS_UNDEFINED;
    res = 0;
  }
  method = JS_GetProperty(ctx, enum_obj, JS_ATOM_return);
  if (JS_IsException(method)) {
    res = -1;
    goto done;
  }
  if (JS_IsUndefined(method) || JS_IsNull(method)) {
    goto done;
  }
  ret = JS_CallFree(ctx, method, enum_obj, 0, NULL);
  if (!is_exception_pending) {
    if (JS_IsException(ret)) {
      res = -1;
    } else if (!JS_IsObject(ret)) {
      JS_ThrowTypeErrorNotAnObject(ctx);
      res = -1;
    }
  }
  JS_FreeValue(ctx, ret);
done:
  if (is_exception_pending) {
    JS_Throw(ctx, ex_obj);
  }
  return res;
}

/* obj -> enum_rec (3 slots) */
__exception int js_for_of_start(JSContext* ctx, JSValue* sp, BOOL is_async) {
  JSValue op1, obj, method;
  op1 = sp[-1];
  obj = JS_GetIterator(ctx, op1, is_async);
  if (JS_IsException(obj))
    return -1;
  JS_FreeValue(ctx, op1);
  sp[-1] = obj;
  method = JS_GetProperty(ctx, obj, JS_ATOM_next);
  if (JS_IsException(method))
    return -1;
  sp[0] = method;
  return 0;
}

/* enum_rec [objs] -> enum_rec [objs] value done. There are 'offset'
   objs. If 'done' is true or in case of exception, 'enum_rec' is set
   to undefined. If 'done' is true, 'value' is always set to
   undefined. */
__exception int js_for_of_next(JSContext* ctx, JSValue* sp, int offset) {
  JSValue value = JS_UNDEFINED;
  int done = 1;

  if (likely(!JS_IsUndefined(sp[offset]))) {
    value = JS_IteratorNext(ctx, sp[offset], sp[offset + 1], 0, NULL, &done);
    if (JS_IsException(value))
      done = -1;
    if (done) {
      /* value is JS_UNDEFINED or JS_EXCEPTION */
      /* replace the iteration object with undefined */
      JS_FreeValue(ctx, sp[offset]);
      sp[offset] = JS_UNDEFINED;
      if (done < 0) {
        return -1;
      } else {
        JS_FreeValue(ctx, value);
        value = JS_UNDEFINED;
      }
    }
  }
  sp[0] = value;
  sp[1] = JS_NewBool(ctx, done);
  return 0;
}

JSValue JS_IteratorGetCompleteValue(JSContext* ctx, JSValueConst obj, BOOL* pdone) {
  JSValue done_val, value;
  BOOL done;
  done_val = JS_GetProperty(ctx, obj, JS_ATOM_done);
  if (JS_IsException(done_val))
    goto fail;
  done = JS_ToBoolFree(ctx, done_val);
  value = JS_GetProperty(ctx, obj, JS_ATOM_value);
  if (JS_IsException(value))
    goto fail;
  *pdone = done;
  return value;
fail:
  *pdone = FALSE;
  return JS_EXCEPTION;
}

__exception int js_iterator_get_value_done(JSContext* ctx, JSValue* sp) {
  JSValue obj, value;
  BOOL done;
  obj = sp[-1];
  if (!JS_IsObject(obj)) {
    JS_ThrowTypeError(ctx, "iterator must return an object");
    return -1;
  }
  value = JS_IteratorGetCompleteValue(ctx, obj, &done);
  if (JS_IsException(value))
    return -1;
  JS_FreeValue(ctx, obj);
  sp[-1] = value;
  sp[0] = JS_NewBool(ctx, done);
  return 0;
}