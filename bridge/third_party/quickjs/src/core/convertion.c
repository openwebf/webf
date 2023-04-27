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

#include "convertion.h"
#include "builtins/js-big-num.h"
#include "exception.h"
#include "function.h"
#include "quickjs/libregexp.h"
#include "string.h"

static JSValue JS_ToNumberHintFree(JSContext* ctx, JSValue val, JSToNumberHintEnum flag);

int skip_spaces(const char* pc) {
  const uint8_t *p, *p_next, *p_start;
  uint32_t c;

  p = p_start = (const uint8_t*)pc;
  for (;;) {
    c = *p;
    if (c < 128) {
      if (!((c >= 0x09 && c <= 0x0d) || (c == 0x20)))
        break;
      p++;
    } else {
      c = unicode_from_utf8(p, UTF8_CHAR_LEN_MAX, &p_next);
      if (!lre_is_space(c))
        break;
      p = p_next;
    }
  }
  return p - p_start;
}

JSValue JS_ToPrimitiveFree(JSContext* ctx, JSValue val, int hint) {
  int i;
  BOOL force_ordinary;

  JSAtom method_name;
  JSValue method, ret;
  if (JS_VALUE_GET_TAG(val) != JS_TAG_OBJECT)
    return val;
  force_ordinary = hint & HINT_FORCE_ORDINARY;
  hint &= ~HINT_FORCE_ORDINARY;
  if (!force_ordinary) {
    method = JS_GetProperty(ctx, val, JS_ATOM_Symbol_toPrimitive);
    if (JS_IsException(method))
      goto exception;
    /* ECMA says *If exoticToPrim is not undefined* but tests in
       test262 use null as a non callable converter */
    if (!JS_IsUndefined(method) && !JS_IsNull(method)) {
      JSAtom atom;
      JSValue arg;
      switch (hint) {
        case HINT_STRING:
          atom = JS_ATOM_string;
          break;
        case HINT_NUMBER:
          atom = JS_ATOM_number;
          break;
        default:
        case HINT_NONE:
          atom = JS_ATOM_default;
          break;
      }
      arg = JS_AtomToString(ctx, atom);
      ret = JS_CallFree(ctx, method, val, 1, (JSValueConst*)&arg);
      JS_FreeValue(ctx, arg);
      if (JS_IsException(ret))
        goto exception;
      JS_FreeValue(ctx, val);
      if (JS_VALUE_GET_TAG(ret) != JS_TAG_OBJECT)
        return ret;
      JS_FreeValue(ctx, ret);
      return JS_ThrowTypeError(ctx, "toPrimitive");
    }
  }
  if (hint != HINT_STRING)
    hint = HINT_NUMBER;
  for (i = 0; i < 2; i++) {
    if ((i ^ hint) == 0) {
      method_name = JS_ATOM_toString;
    } else {
      method_name = JS_ATOM_valueOf;
    }
    method = JS_GetProperty(ctx, val, method_name);
    if (JS_IsException(method))
      goto exception;
    if (JS_IsFunction(ctx, method)) {
      ret = JS_CallFree(ctx, method, val, 0, NULL);
      if (JS_IsException(ret))
        goto exception;
      if (JS_VALUE_GET_TAG(ret) != JS_TAG_OBJECT) {
        JS_FreeValue(ctx, val);
        return ret;
      }
      JS_FreeValue(ctx, ret);
    } else {
      JS_FreeValue(ctx, method);
    }
  }
  JS_ThrowTypeError(ctx, "toPrimitive");
exception:
  JS_FreeValue(ctx, val);
  return JS_EXCEPTION;
}

JSValue JS_ToPrimitive(JSContext* ctx, JSValueConst val, int hint) {
  return JS_ToPrimitiveFree(ctx, JS_DupValue(ctx, val), hint);
}

__exception int JS_ToArrayLengthFree(JSContext* ctx, uint32_t* plen, JSValue val, BOOL is_array_ctor) {
  uint32_t tag, len;

  tag = JS_VALUE_GET_TAG(val);
  switch (tag) {
    case JS_TAG_INT:
    case JS_TAG_BOOL:
    case JS_TAG_NULL: {
      int v;
      v = JS_VALUE_GET_INT(val);
      if (v < 0)
        goto fail;
      len = v;
    } break;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT:
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      bf_t a;
      BOOL res;
      bf_get_int32((int32_t*)&len, &p->num, BF_GET_INT_MOD);
      bf_init(ctx->bf_ctx, &a);
      bf_set_ui(&a, len);
      res = bf_cmp_eq(&a, &p->num);
      bf_delete(&a);
      JS_FreeValue(ctx, val);
      if (!res)
        goto fail;
    } break;
#endif
    default:
      if (JS_TAG_IS_FLOAT64(tag)) {
        double d;
        d = JS_VALUE_GET_FLOAT64(val);
        len = (uint32_t)d;
        if (len != d)
          goto fail;
      } else {
        uint32_t len1;

        if (is_array_ctor) {
          val = JS_ToNumberFree(ctx, val);
          if (JS_IsException(val))
            return -1;
          /* cannot recurse because val is a number */
          if (JS_ToArrayLengthFree(ctx, &len, val, TRUE))
            return -1;
        } else {
          /* legacy behavior: must do the conversion twice and compare */
          if (JS_ToUint32(ctx, &len, val)) {
            JS_FreeValue(ctx, val);
            return -1;
          }
          val = JS_ToNumberFree(ctx, val);
          if (JS_IsException(val))
            return -1;
          /* cannot recurse because val is a number */
          if (JS_ToArrayLengthFree(ctx, &len1, val, FALSE))
            return -1;
          if (len1 != len) {
          fail:
            JS_ThrowRangeError(ctx, "invalid array length");
            return -1;
          }
        }
      }
      break;
  }
  *plen = len;
  return 0;
}

JSValue JS_ToNumber(JSContext* ctx, JSValueConst val) {
  return JS_ToNumberFree(ctx, JS_DupValue(ctx, val));
}

JSValue JS_ToNumberFree(JSContext* ctx, JSValue val) {
  return JS_ToNumberHintFree(ctx, val, TON_FLAG_NUMBER);
}

JSValue JS_ToNumericFree(JSContext* ctx, JSValue val) {
  return JS_ToNumberHintFree(ctx, val, TON_FLAG_NUMERIC);
}

JSValue JS_ToNumeric(JSContext* ctx, JSValueConst val) {
  return JS_ToNumericFree(ctx, JS_DupValue(ctx, val));
}

static JSValue JS_ToNumberHintFree(JSContext* ctx, JSValue val, JSToNumberHintEnum flag) {
  uint32_t tag;
  JSValue ret;

redo:
  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_DECIMAL:
      if (flag != TON_FLAG_NUMERIC) {
        JS_FreeValue(ctx, val);
        return JS_ThrowTypeError(ctx, "cannot convert bigdecimal to number");
      }
      ret = val;
      break;
    case JS_TAG_BIG_INT:
      if (flag != TON_FLAG_NUMERIC) {
        JS_FreeValue(ctx, val);
        return JS_ThrowTypeError(ctx, "cannot convert bigint to number");
      }
      ret = val;
      break;
    case JS_TAG_BIG_FLOAT:
      if (flag != TON_FLAG_NUMERIC) {
        JS_FreeValue(ctx, val);
        return JS_ThrowTypeError(ctx, "cannot convert bigfloat to number");
      }
      ret = val;
      break;
#endif
    case JS_TAG_FLOAT64:
    case JS_TAG_INT:
    case JS_TAG_EXCEPTION:
      ret = val;
      break;
    case JS_TAG_BOOL:
    case JS_TAG_NULL:
      ret = JS_NewInt32(ctx, JS_VALUE_GET_INT(val));
      break;
    case JS_TAG_UNDEFINED:
      ret = JS_NAN;
      break;
    case JS_TAG_OBJECT:
      val = JS_ToPrimitiveFree(ctx, val, HINT_NUMBER);
      if (JS_IsException(val))
        return JS_EXCEPTION;
      goto redo;
    case JS_TAG_STRING: {
      const char* str;
      const char* p;
      size_t len;

      str = JS_ToCStringLen(ctx, &len, val);
      JS_FreeValue(ctx, val);
      if (!str)
        return JS_EXCEPTION;
      p = str;
      p += skip_spaces(p);
      if ((p - str) == len) {
        ret = JS_NewInt32(ctx, 0);
      } else {
        int flags = ATOD_ACCEPT_BIN_OCT;
        ret = js_atof(ctx, p, &p, 0, flags);
        if (!JS_IsException(ret)) {
          p += skip_spaces(p);
          if ((p - str) != len) {
            JS_FreeValue(ctx, ret);
            ret = JS_NAN;
          }
        }
      }
      JS_FreeCString(ctx, str);
    } break;
    case JS_TAG_SYMBOL:
      JS_FreeValue(ctx, val);
      return JS_ThrowTypeError(ctx, "cannot convert symbol to number");
    default:
      JS_FreeValue(ctx, val);
      ret = JS_NAN;
      break;
  }
  return ret;
}

__exception int __JS_ToFloat64Free(JSContext* ctx, double* pres, JSValue val) {
  double d;
  uint32_t tag;

  val = JS_ToNumberFree(ctx, val);
  if (JS_IsException(val)) {
    *pres = JS_FLOAT64_NAN;
    return -1;
  }
  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
    case JS_TAG_INT:
      d = JS_VALUE_GET_INT(val);
      break;
    case JS_TAG_FLOAT64:
      d = JS_VALUE_GET_FLOAT64(val);
      break;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT:
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      /* XXX: there can be a double rounding issue with some
         primitives (such as JS_ToUint8ClampFree()), but it is
         not critical to fix it. */
      bf_get_float64(&p->num, &d, BF_RNDN);
      JS_FreeValue(ctx, val);
    } break;
#endif
    default:
      abort();
  }
  *pres = d;
  return 0;
}

int JS_ToFloat64(JSContext* ctx, double* pres, JSValueConst val) {
  return JS_ToFloat64Free(ctx, pres, JS_DupValue(ctx, val));
}

/* same as JS_ToNumber() but return 0 in case of NaN/Undefined */
__maybe_unused JSValue JS_ToIntegerFree(JSContext* ctx, JSValue val) {
  uint32_t tag;
  JSValue ret;

redo:
  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
    case JS_TAG_INT:
    case JS_TAG_BOOL:
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      ret = JS_NewInt32(ctx, JS_VALUE_GET_INT(val));
      break;
    case JS_TAG_FLOAT64: {
      double d = JS_VALUE_GET_FLOAT64(val);
      if (isnan(d)) {
        ret = JS_NewInt32(ctx, 0);
      } else {
        /* convert -0 to +0 */
        d = trunc(d) + 0.0;
        ret = JS_NewFloat64(ctx, d);
      }
    } break;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_FLOAT: {
      bf_t a_s, *a, r_s, *r = &r_s;
      BOOL is_nan;

      a = JS_ToBigFloat(ctx, &a_s, val);
      if (!bf_is_finite(a)) {
        is_nan = bf_is_nan(a);
        if (is_nan)
          ret = JS_NewInt32(ctx, 0);
        else
          ret = JS_DupValue(ctx, val);
      } else {
        ret = JS_NewBigInt(ctx);
        if (!JS_IsException(ret)) {
          r = JS_GetBigInt(ret);
          bf_set(r, a);
          bf_rint(r, BF_RNDZ);
          ret = JS_CompactBigInt(ctx, ret);
        }
      }
      if (a == &a_s)
        bf_delete(a);
      JS_FreeValue(ctx, val);
    } break;
#endif
    default:
      val = JS_ToNumberFree(ctx, val);
      if (JS_IsException(val))
        return val;
      goto redo;
  }
  return ret;
}

/* Note: the integer value is satured to 32 bits */
int JS_ToInt32SatFree(JSContext* ctx, int* pres, JSValue val) {
  uint32_t tag;
  int ret;

redo:
  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
    case JS_TAG_INT:
    case JS_TAG_BOOL:
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      ret = JS_VALUE_GET_INT(val);
      break;
    case JS_TAG_EXCEPTION:
      *pres = 0;
      return -1;
    case JS_TAG_FLOAT64: {
      double d = JS_VALUE_GET_FLOAT64(val);
      if (isnan(d)) {
        ret = 0;
      } else {
        if (d < INT32_MIN)
          ret = INT32_MIN;
        else if (d > INT32_MAX)
          ret = INT32_MAX;
        else
          ret = (int)d;
      }
    } break;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      bf_get_int32(&ret, &p->num, 0);
      JS_FreeValue(ctx, val);
    } break;
#endif
    default:
      val = JS_ToNumberFree(ctx, val);
      if (JS_IsException(val)) {
        *pres = 0;
        return -1;
      }
      goto redo;
  }
  *pres = ret;
  return 0;
}

int JS_ToInt32Sat(JSContext* ctx, int* pres, JSValueConst val) {
  return JS_ToInt32SatFree(ctx, pres, JS_DupValue(ctx, val));
}

int JS_ToInt32Clamp(JSContext* ctx, int* pres, JSValueConst val, int min, int max, int min_offset) {
  int res = JS_ToInt32SatFree(ctx, pres, JS_DupValue(ctx, val));
  if (res == 0) {
    if (*pres < min) {
      *pres += min_offset;
      if (*pres < min)
        *pres = min;
    } else {
      if (*pres > max)
        *pres = max;
    }
  }
  return res;
}

int JS_ToInt64SatFree(JSContext* ctx, int64_t* pres, JSValue val) {
  uint32_t tag;

redo:
  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
    case JS_TAG_INT:
    case JS_TAG_BOOL:
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      *pres = JS_VALUE_GET_INT(val);
      return 0;
    case JS_TAG_EXCEPTION:
      *pres = 0;
      return -1;
    case JS_TAG_FLOAT64: {
      double d = JS_VALUE_GET_FLOAT64(val);
      if (isnan(d)) {
        *pres = 0;
      } else {
        if (d < INT64_MIN)
          *pres = INT64_MIN;
        else if (d > INT64_MAX)
          *pres = INT64_MAX;
        else
          *pres = (int64_t)d;
      }
    }
      return 0;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      bf_get_int64(pres, &p->num, 0);
      JS_FreeValue(ctx, val);
    }
      return 0;
#endif
    default:
      val = JS_ToNumberFree(ctx, val);
      if (JS_IsException(val)) {
        *pres = 0;
        return -1;
      }
      goto redo;
  }
}

int JS_ToInt64Sat(JSContext* ctx, int64_t* pres, JSValueConst val) {
  return JS_ToInt64SatFree(ctx, pres, JS_DupValue(ctx, val));
}

int JS_ToInt64Clamp(JSContext* ctx, int64_t* pres, JSValueConst val, int64_t min, int64_t max, int64_t neg_offset) {
  int res = JS_ToInt64SatFree(ctx, pres, JS_DupValue(ctx, val));
  if (res == 0) {
    if (*pres < 0)
      *pres += neg_offset;
    if (*pres < min)
      *pres = min;
    else if (*pres > max)
      *pres = max;
  }
  return res;
}

/* Same as JS_ToInt32Free() but with a 64 bit result. Return (<0, 0)
   in case of exception */
int JS_ToInt64Free(JSContext* ctx, int64_t* pres, JSValue val) {
  uint32_t tag;
  int64_t ret;

redo:
  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
    case JS_TAG_INT:
    case JS_TAG_BOOL:
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      ret = JS_VALUE_GET_INT(val);
      break;
    case JS_TAG_FLOAT64: {
      JSFloat64Union u;
      double d;
      int e;
      d = JS_VALUE_GET_FLOAT64(val);
      u.d = d;
      /* we avoid doing fmod(x, 2^64) */
      e = (u.u64 >> 52) & 0x7ff;
      if (likely(e <= (1023 + 62))) {
        /* fast case */
        ret = (int64_t)d;
      } else if (e <= (1023 + 62 + 53)) {
        uint64_t v;
        /* remainder modulo 2^64 */
        v = (u.u64 & (((uint64_t)1 << 52) - 1)) | ((uint64_t)1 << 52);
        ret = v << ((e - 1023) - 52);
        /* take the sign into account */
        if (u.u64 >> 63)
          ret = -ret;
      } else {
        ret = 0; /* also handles NaN and +inf */
      }
    } break;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      bf_get_int64(&ret, &p->num, BF_GET_INT_MOD);
      JS_FreeValue(ctx, val);
    } break;
#endif
    default:
      val = JS_ToNumberFree(ctx, val);
      if (JS_IsException(val)) {
        *pres = 0;
        return -1;
      }
      goto redo;
  }
  *pres = ret;
  return 0;
}

int JS_ToInt64(JSContext* ctx, int64_t* pres, JSValueConst val) {
  return JS_ToInt64Free(ctx, pres, JS_DupValue(ctx, val));
}

int JS_ToInt64Ext(JSContext* ctx, int64_t* pres, JSValueConst val) {
  if (JS_IsBigInt(ctx, val))
    return JS_ToBigInt64(ctx, pres, val);
  else
    return JS_ToInt64(ctx, pres, val);
}

/* return (<0, 0) in case of exception */
int JS_ToInt32Free(JSContext* ctx, int32_t* pres, JSValue val) {
  uint32_t tag;
  int32_t ret;

redo:
  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
    case JS_TAG_INT:
    case JS_TAG_BOOL:
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      ret = JS_VALUE_GET_INT(val);
      break;
    case JS_TAG_FLOAT64: {
      JSFloat64Union u;
      double d;
      int e;
      d = JS_VALUE_GET_FLOAT64(val);
      u.d = d;
      /* we avoid doing fmod(x, 2^32) */
      e = (u.u64 >> 52) & 0x7ff;
      if (likely(e <= (1023 + 30))) {
        /* fast case */
        ret = (int32_t)d;
      } else if (e <= (1023 + 30 + 53)) {
        uint64_t v;
        /* remainder modulo 2^32 */
        v = (u.u64 & (((uint64_t)1 << 52) - 1)) | ((uint64_t)1 << 52);
        v = v << ((e - 1023) - 52 + 32);
        ret = v >> 32;
        /* take the sign into account */
        if (u.u64 >> 63)
          ret = -ret;
      } else {
        ret = 0; /* also handles NaN and +inf */
      }
    } break;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      bf_get_int32(&ret, &p->num, BF_GET_INT_MOD);
      JS_FreeValue(ctx, val);
    } break;
#endif
    default:
      val = JS_ToNumberFree(ctx, val);
      if (JS_IsException(val)) {
        *pres = 0;
        return -1;
      }
      goto redo;
  }
  *pres = ret;
  return 0;
}

int JS_ToInt32(JSContext* ctx, int32_t* pres, JSValueConst val) {
  return JS_ToInt32Free(ctx, pres, JS_DupValue(ctx, val));
}

int JS_ToUint8ClampFree(JSContext* ctx, int32_t* pres, JSValue val) {
  uint32_t tag;
  int res;

redo:
  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
    case JS_TAG_INT:
    case JS_TAG_BOOL:
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      res = JS_VALUE_GET_INT(val);
#ifdef CONFIG_BIGNUM
    int_clamp:
#endif
      res = max_int(0, min_int(255, res));
      break;
    case JS_TAG_FLOAT64: {
      double d = JS_VALUE_GET_FLOAT64(val);
      if (isnan(d)) {
        res = 0;
      } else {
        if (d < 0)
          res = 0;
        else if (d > 255)
          res = 255;
        else
          res = lrint(d);
      }
    } break;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      bf_t r_s, *r = &r_s;
      bf_init(ctx->bf_ctx, r);
      bf_set(r, &p->num);
      bf_rint(r, BF_RNDN);
      bf_get_int32(&res, r, 0);
      bf_delete(r);
      JS_FreeValue(ctx, val);
    }
      goto int_clamp;
#endif
    default:
      val = JS_ToNumberFree(ctx, val);
      if (JS_IsException(val)) {
        *pres = 0;
        return -1;
      }
      goto redo;
  }
  *pres = res;
  return 0;
}

int JS_ToBoolFree(JSContext* ctx, JSValue val) {
  uint32_t tag = JS_VALUE_GET_TAG(val);
  switch (tag) {
    case JS_TAG_INT:
      return JS_VALUE_GET_INT(val) != 0;
    case JS_TAG_BOOL:
    case JS_TAG_NULL:
    case JS_TAG_UNDEFINED:
      return JS_VALUE_GET_INT(val);
    case JS_TAG_EXCEPTION:
      return -1;
    case JS_TAG_STRING: {
      BOOL ret = JS_VALUE_GET_STRING(val)->len != 0;
      JS_FreeValue(ctx, val);
      return ret;
    }
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT:
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      BOOL ret;
      ret = p->num.expn != BF_EXP_ZERO && p->num.expn != BF_EXP_NAN;
      JS_FreeValue(ctx, val);
      return ret;
    }
    case JS_TAG_BIG_DECIMAL: {
      JSBigDecimal* p = JS_VALUE_GET_PTR(val);
      BOOL ret;
      ret = p->num.expn != BF_EXP_ZERO && p->num.expn != BF_EXP_NAN;
      JS_FreeValue(ctx, val);
      return ret;
    }
#endif
    case JS_TAG_OBJECT: {
      JSObject* p = JS_VALUE_GET_OBJ(val);
      BOOL ret;
      ret = !p->is_HTMLDDA;
      JS_FreeValue(ctx, val);
      return ret;
    } break;
    default:
      if (JS_TAG_IS_FLOAT64(tag)) {
        double d = JS_VALUE_GET_FLOAT64(val);
        return !isnan(d) && d != 0;
      } else {
        JS_FreeValue(ctx, val);
        return TRUE;
      }
  }
}

int JS_ToBool(JSContext* ctx, JSValueConst val) {
  return JS_ToBoolFree(ctx, JS_DupValue(ctx, val));
}

/* XXX: remove */
double js_strtod(const char* p, int radix, BOOL is_float) {
  double d;
  int c;

  if (!is_float || radix != 10) {
    uint64_t n_max, n;
    int int_exp, is_neg;

    is_neg = 0;
    if (*p == '-') {
      is_neg = 1;
      p++;
    }

    /* skip leading zeros */
    while (*p == '0')
      p++;
    n = 0;
    if (radix == 10)
      n_max = ((uint64_t)-1 - 9) / 10; /* most common case */
    else
      n_max = ((uint64_t)-1 - (radix - 1)) / radix;
    /* XXX: could be more precise */
    int_exp = 0;
    while (*p != '\0') {
      c = to_digit((uint8_t)*p);
      if (c >= radix)
        break;
      if (n <= n_max) {
        n = n * radix + c;
      } else {
        int_exp++;
      }
      p++;
    }
    d = n;
    if (int_exp != 0) {
      d *= pow(radix, int_exp);
    }
    if (is_neg)
      d = -d;
  } else {
    d = strtod(p, NULL);
  }
  return d;
}

#ifdef CONFIG_BIGNUM
JSValue js_string_to_bigint(JSContext* ctx, const char* buf, int radix, int flags, slimb_t* pexponent) {
  bf_t a_s, *a = &a_s;
  int ret;
  JSValue val;
  val = JS_NewBigInt(ctx);
  if (JS_IsException(val))
    return val;
  a = JS_GetBigInt(val);
  ret = bf_atof(a, buf, NULL, radix, BF_PREC_INF, BF_RNDZ);
  if (ret & BF_ST_MEM_ERROR) {
    JS_FreeValue(ctx, val);
    return JS_ThrowOutOfMemory(ctx);
  }
  val = JS_CompactBigInt1(ctx, val, (flags & ATOD_MODE_BIGINT) != 0);
  return val;
}

JSValue js_string_to_bigfloat(JSContext* ctx, const char* buf, int radix, int flags, slimb_t* pexponent) {
  bf_t* a;
  int ret;
  JSValue val;

  val = JS_NewBigFloat(ctx);
  if (JS_IsException(val))
    return val;
  a = JS_GetBigFloat(val);
  if (flags & ATOD_ACCEPT_SUFFIX) {
    /* return the exponent to get infinite precision */
    ret = bf_atof2(a, pexponent, buf, NULL, radix, BF_PREC_INF, BF_RNDZ | BF_ATOF_EXPONENT);
  } else {
    ret = bf_atof(a, buf, NULL, radix, ctx->fp_env.prec, ctx->fp_env.flags);
  }
  if (ret & BF_ST_MEM_ERROR) {
    JS_FreeValue(ctx, val);
    return JS_ThrowOutOfMemory(ctx);
  }
  return val;
}

JSValue js_string_to_bigdecimal(JSContext* ctx, const char* buf, int radix, int flags, slimb_t* pexponent) {
  bfdec_t* a;
  int ret;
  JSValue val;

  val = JS_NewBigDecimal(ctx);
  if (JS_IsException(val))
    return val;
  a = JS_GetBigDecimal(val);
  ret = bfdec_atof(a, buf, NULL, BF_PREC_INF, BF_RNDZ | BF_ATOF_NO_NAN_INF);
  if (ret & BF_ST_MEM_ERROR) {
    JS_FreeValue(ctx, val);
    return JS_ThrowOutOfMemory(ctx);
  }
  return val;
}

#endif

/* return an exception in case of memory error. Return JS_NAN if
   invalid syntax */
#ifdef CONFIG_BIGNUM
JSValue js_atof2(JSContext* ctx, const char* str, const char** pp, int radix, int flags, slimb_t* pexponent)
#else
JSValue js_atof(JSContext* ctx, const char* str, const char** pp, int radix, int flags)
#endif
{
  const char *p, *p_start;
  int sep, is_neg;
  BOOL is_float, has_legacy_octal;
  int atod_type = flags & ATOD_TYPE_MASK;
  char buf1[64], *buf;
  int i, j, len;
  BOOL buf_allocated = FALSE;
  JSValue val;

  /* optional separator between digits */
  sep = (flags & ATOD_ACCEPT_UNDERSCORES) ? '_' : 256;
  has_legacy_octal = FALSE;

  p = str;
  p_start = p;
  is_neg = 0;
  if (p[0] == '+') {
    p++;
    p_start++;
    if (!(flags & ATOD_ACCEPT_PREFIX_AFTER_SIGN))
      goto no_radix_prefix;
  } else if (p[0] == '-') {
    p++;
    p_start++;
    is_neg = 1;
    if (!(flags & ATOD_ACCEPT_PREFIX_AFTER_SIGN))
      goto no_radix_prefix;
  }
  if (p[0] == '0') {
    if ((p[1] == 'x' || p[1] == 'X') && (radix == 0 || radix == 16)) {
      p += 2;
      radix = 16;
    } else if ((p[1] == 'o' || p[1] == 'O') && radix == 0 && (flags & ATOD_ACCEPT_BIN_OCT)) {
      p += 2;
      radix = 8;
    } else if ((p[1] == 'b' || p[1] == 'B') && radix == 0 && (flags & ATOD_ACCEPT_BIN_OCT)) {
      p += 2;
      radix = 2;
    } else if ((p[1] >= '0' && p[1] <= '9') && radix == 0 && (flags & ATOD_ACCEPT_LEGACY_OCTAL)) {
      int i;
      has_legacy_octal = TRUE;
      sep = 256;
      for (i = 1; (p[i] >= '0' && p[i] <= '7'); i++)
        continue;
      if (p[i] == '8' || p[i] == '9')
        goto no_prefix;
      p += 1;
      radix = 8;
    } else {
      goto no_prefix;
    }
    /* there must be a digit after the prefix */
    if (to_digit((uint8_t)*p) >= radix)
      goto fail;
  no_prefix:;
  } else {
  no_radix_prefix:
    if (!(flags & ATOD_INT_ONLY) && (atod_type == ATOD_TYPE_FLOAT64 || atod_type == ATOD_TYPE_BIG_FLOAT) && strstart(p, "Infinity", &p)) {
#ifdef CONFIG_BIGNUM
      if (atod_type == ATOD_TYPE_BIG_FLOAT) {
        bf_t* a;
        val = JS_NewBigFloat(ctx);
        if (JS_IsException(val))
          goto done;
        a = JS_GetBigFloat(val);
        bf_set_inf(a, is_neg);
      } else
#endif
      {
        double d = INFINITY;
        if (is_neg)
          d = -d;
        val = JS_NewFloat64(ctx, d);
      }
      goto done;
    }
  }
  if (radix == 0)
    radix = 10;
  is_float = FALSE;
  p_start = p;
  while (to_digit((uint8_t)*p) < radix || (*p == sep && (radix != 10 || p != p_start + 1 || p[-1] != '0') && to_digit((uint8_t)p[1]) < radix)) {
    p++;
  }
  if (!(flags & ATOD_INT_ONLY)) {
    if (*p == '.' && (p > p_start || to_digit((uint8_t)p[1]) < radix)) {
      is_float = TRUE;
      p++;
      if (*p == sep)
        goto fail;
      while (to_digit((uint8_t)*p) < radix || (*p == sep && to_digit((uint8_t)p[1]) < radix))
        p++;
    }
    if (p > p_start && (((*p == 'e' || *p == 'E') && radix == 10) || ((*p == 'p' || *p == 'P') && (radix == 2 || radix == 8 || radix == 16)))) {
      const char* p1 = p + 1;
      is_float = TRUE;
      if (*p1 == '+') {
        p1++;
      } else if (*p1 == '-') {
        p1++;
      }
      if (is_digit((uint8_t)*p1)) {
        p = p1 + 1;
        while (is_digit((uint8_t)*p) || (*p == sep && is_digit((uint8_t)p[1])))
          p++;
      }
    }
  }
  if (p == p_start)
    goto fail;

  buf = buf1;
  buf_allocated = FALSE;
  len = p - p_start;
  if (unlikely((len + 2) > sizeof(buf1))) {
    buf = js_malloc_rt(ctx->rt, len + 2); /* no exception raised */
    if (!buf)
      goto mem_error;
    buf_allocated = TRUE;
  }
  /* remove the separators and the radix prefixes */
  j = 0;
  if (is_neg)
    buf[j++] = '-';
  for (i = 0; i < len; i++) {
    if (p_start[i] != '_')
      buf[j++] = p_start[i];
  }
  buf[j] = '\0';

#ifdef CONFIG_BIGNUM
  if (flags & ATOD_ACCEPT_SUFFIX) {
    if (*p == 'n') {
      p++;
      atod_type = ATOD_TYPE_BIG_INT;
    } else if (*p == 'l') {
      p++;
      atod_type = ATOD_TYPE_BIG_FLOAT;
    } else if (*p == 'm') {
      p++;
      atod_type = ATOD_TYPE_BIG_DECIMAL;
    } else {
      if (flags & ATOD_MODE_BIGINT) {
        if (!is_float)
          atod_type = ATOD_TYPE_BIG_INT;
        if (has_legacy_octal)
          goto fail;
      } else {
        if (is_float && radix != 10)
          goto fail;
      }
    }
  } else {
    if (atod_type == ATOD_TYPE_FLOAT64) {
      if (flags & ATOD_MODE_BIGINT) {
        if (!is_float)
          atod_type = ATOD_TYPE_BIG_INT;
        if (has_legacy_octal)
          goto fail;
      } else {
        if (is_float && radix != 10)
          goto fail;
      }
    }
  }

  switch (atod_type) {
    case ATOD_TYPE_FLOAT64: {
      double d;
      d = js_strtod(buf, radix, is_float);
      /* return int or float64 */
      val = JS_NewFloat64(ctx, d);
    } break;
    case ATOD_TYPE_BIG_INT:
      if (has_legacy_octal || is_float)
        goto fail;
      val = ctx->rt->bigint_ops.from_string(ctx, buf, radix, flags, NULL);
      break;
    case ATOD_TYPE_BIG_FLOAT:
      if (has_legacy_octal)
        goto fail;
      val = ctx->rt->bigfloat_ops.from_string(ctx, buf, radix, flags, pexponent);
      break;
    case ATOD_TYPE_BIG_DECIMAL:
      if (radix != 10)
        goto fail;
      val = ctx->rt->bigdecimal_ops.from_string(ctx, buf, radix, flags, NULL);
      break;
    default:
      abort();
  }
#else
  {
    double d;
    (void)has_legacy_octal;
    if (is_float && radix != 10)
      goto fail;
    d = js_strtod(buf, radix, is_float);
    val = JS_NewFloat64(ctx, d);
  }
#endif

done:
  if (buf_allocated)
    js_free_rt(ctx->rt, buf);
  if (pp)
    *pp = p;
  return val;
fail:
  val = JS_NAN;
  goto done;
mem_error:
  val = JS_ThrowOutOfMemory(ctx);
  goto done;
}

#ifdef CONFIG_BIGNUM
JSValue js_atof(JSContext* ctx, const char* str, const char** pp, int radix, int flags) {
  return js_atof2(ctx, str, pp, radix, flags, NULL);
}
#endif

BOOL is_safe_integer(double d) {
  return isfinite(d) && floor(d) == d && fabs(d) <= (double)MAX_SAFE_INTEGER;
}

int JS_ToIndex(JSContext* ctx, uint64_t* plen, JSValueConst val) {
  int64_t v;
  if (JS_ToInt64Sat(ctx, &v, val))
    return -1;
  if (v < 0 || v > MAX_SAFE_INTEGER) {
    JS_ThrowRangeError(ctx, "invalid array index");
    *plen = 0;
    return -1;
  }
  *plen = v;
  return 0;
}

/* convert a value to a length between 0 and MAX_SAFE_INTEGER.
   return -1 for exception */
__exception int JS_ToLengthFree(JSContext* ctx, int64_t* plen, JSValue val) {
  int res = JS_ToInt64Clamp(ctx, plen, val, 0, MAX_SAFE_INTEGER, 0);
  JS_FreeValue(ctx, val);
  return res;
}

/* Note: can return an exception */
int JS_NumberIsInteger(JSContext* ctx, JSValueConst val) {
  double d;
  if (!JS_IsNumber(val))
    return FALSE;
  if (unlikely(JS_ToFloat64(ctx, &d, val)))
    return -1;
  return isfinite(d) && floor(d) == d;
}

BOOL JS_NumberIsNegativeOrMinusZero(JSContext* ctx, JSValueConst val) {
  uint32_t tag;

  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
    case JS_TAG_INT: {
      int v;
      v = JS_VALUE_GET_INT(val);
      return (v < 0);
    }
    case JS_TAG_FLOAT64: {
      JSFloat64Union u;
      u.d = JS_VALUE_GET_FLOAT64(val);
      return (u.u64 >> 63);
    }
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      /* Note: integer zeros are not necessarily positive */
      return p->num.sign && !bf_is_zero(&p->num);
    }
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      return p->num.sign;
    } break;
    case JS_TAG_BIG_DECIMAL: {
      JSBigDecimal* p = JS_VALUE_GET_PTR(val);
      return p->num.sign;
    } break;
#endif
    default:
      return FALSE;
  }
}

#ifdef CONFIG_BIGNUM

JSValue js_bigint_to_string1(JSContext* ctx, JSValueConst val, int radix) {
  JSValue ret;
  bf_t a_s, *a;
  char* str;
  int saved_sign;

  a = JS_ToBigInt(ctx, &a_s, val);
  if (!a)
    return JS_EXCEPTION;
  saved_sign = a->sign;
  if (a->expn == BF_EXP_ZERO)
    a->sign = 0;
  str = bf_ftoa(NULL, a, radix, 0, BF_RNDZ | BF_FTOA_FORMAT_FRAC | BF_FTOA_JS_QUIRKS);
  a->sign = saved_sign;
  JS_FreeBigInt(ctx, a, &a_s);
  if (!str)
    return JS_ThrowOutOfMemory(ctx);
  ret = JS_NewString(ctx, str);
  bf_free(ctx->bf_ctx, str);
  return ret;
}

JSValue js_bigint_to_string(JSContext* ctx, JSValueConst val) {
  return js_bigint_to_string1(ctx, val, 10);
}

JSValue js_ftoa(JSContext* ctx, JSValueConst val1, int radix, limb_t prec, bf_flags_t flags) {
  JSValue val, ret;
  bf_t a_s, *a;
  char* str;
  int saved_sign;

  val = JS_ToNumeric(ctx, val1);
  if (JS_IsException(val))
    return val;
  a = JS_ToBigFloat(ctx, &a_s, val);
  saved_sign = a->sign;
  if (a->expn == BF_EXP_ZERO)
    a->sign = 0;
  flags |= BF_FTOA_JS_QUIRKS;
  if ((flags & BF_FTOA_FORMAT_MASK) == BF_FTOA_FORMAT_FREE_MIN) {
    /* Note: for floating point numbers with a radix which is not
       a power of two, the current precision is used to compute
       the number of digits. */
    if ((radix & (radix - 1)) != 0) {
      bf_t r_s, *r = &r_s;
      int prec, flags1;
      /* must round first */
      if (JS_VALUE_GET_TAG(val) == JS_TAG_BIG_FLOAT) {
        prec = ctx->fp_env.prec;
        flags1 = ctx->fp_env.flags & (BF_FLAG_SUBNORMAL | (BF_EXP_BITS_MASK << BF_EXP_BITS_SHIFT));
      } else {
        prec = 53;
        flags1 = bf_set_exp_bits(11) | BF_FLAG_SUBNORMAL;
      }
      bf_init(ctx->bf_ctx, r);
      bf_set(r, a);
      bf_round(r, prec, flags1 | BF_RNDN);
      str = bf_ftoa(NULL, r, radix, prec, flags1 | flags);
      bf_delete(r);
    } else {
      str = bf_ftoa(NULL, a, radix, BF_PREC_INF, flags);
    }
  } else {
    str = bf_ftoa(NULL, a, radix, prec, flags);
  }
  a->sign = saved_sign;
  if (a == &a_s)
    bf_delete(a);
  JS_FreeValue(ctx, val);
  if (!str)
    return JS_ThrowOutOfMemory(ctx);
  ret = JS_NewString(ctx, str);
  bf_free(ctx->bf_ctx, str);
  return ret;
}

JSValue js_bigfloat_to_string(JSContext* ctx, JSValueConst val) {
  return js_ftoa(ctx, val, 10, 0, BF_RNDN | BF_FTOA_FORMAT_FREE_MIN);
}

JSValue js_bigdecimal_to_string1(JSContext* ctx, JSValueConst val, limb_t prec, int flags) {
  JSValue ret;
  bfdec_t* a;
  char* str;
  int saved_sign;

  a = JS_ToBigDecimal(ctx, val);
  saved_sign = a->sign;
  if (a->expn == BF_EXP_ZERO)
    a->sign = 0;
  str = bfdec_ftoa(NULL, a, prec, flags | BF_FTOA_JS_QUIRKS);
  a->sign = saved_sign;
  if (!str)
    return JS_ThrowOutOfMemory(ctx);
  ret = JS_NewString(ctx, str);
  bf_free(ctx->bf_ctx, str);
  return ret;
}

JSValue js_bigdecimal_to_string(JSContext* ctx, JSValueConst val) {
  return js_bigdecimal_to_string1(ctx, val, 0, BF_RNDZ | BF_FTOA_FORMAT_FREE);
}

#endif /* CONFIG_BIGNUM */

/* 2 <= base <= 36 */
char* i64toa(char* buf_end, int64_t n, unsigned int base) {
  char* q = buf_end;
  int digit, is_neg;

  is_neg = 0;
  if (n < 0) {
    is_neg = 1;
    n = -n;
  }
  *--q = '\0';
  do {
    digit = (uint64_t)n % base;
    n = (uint64_t)n / base;
    if (digit < 10)
      digit += '0';
    else
      digit += 'a' - 10;
    *--q = digit;
  } while (n != 0);
  if (is_neg)
    *--q = '-';
  return q;
}

/* buf1 contains the printf result */
void js_ecvt1(double d, int n_digits, int* decpt, int* sign, char* buf, int rounding_mode, char* buf1, int buf1_size) {
  if (rounding_mode != FE_TONEAREST)
    fesetround(rounding_mode);
  snprintf(buf1, buf1_size, "%+.*e", n_digits - 1, d);
  if (rounding_mode != FE_TONEAREST)
    fesetround(FE_TONEAREST);
  *sign = (buf1[0] == '-');
  /* mantissa */
  buf[0] = buf1[1];
  if (n_digits > 1)
    memcpy(buf + 1, buf1 + 3, n_digits - 1);
  buf[n_digits] = '\0';
  /* exponent */
  *decpt = atoi(buf1 + n_digits + 2 + (n_digits > 1)) + 1;
}

/* needed because ecvt usually limits the number of digits to
   17. Return the number of digits. */
int js_ecvt(double d, int n_digits, int* decpt, int* sign, char* buf, BOOL is_fixed) {
  int rounding_mode;
  char buf_tmp[JS_DTOA_BUF_SIZE];

  if (!is_fixed) {
    unsigned int n_digits_min, n_digits_max;
    /* find the minimum amount of digits (XXX: inefficient but simple) */
    n_digits_min = 1;
    n_digits_max = 17;
    while (n_digits_min < n_digits_max) {
      n_digits = (n_digits_min + n_digits_max) / 2;
      js_ecvt1(d, n_digits, decpt, sign, buf, FE_TONEAREST, buf_tmp, sizeof(buf_tmp));
      if (strtod(buf_tmp, NULL) == d) {
        /* no need to keep the trailing zeros */
        while (n_digits >= 2 && buf[n_digits - 1] == '0')
          n_digits--;
        n_digits_max = n_digits;
      } else {
        n_digits_min = n_digits + 1;
      }
    }
    n_digits = n_digits_max;
    rounding_mode = FE_TONEAREST;
  } else {
    rounding_mode = FE_TONEAREST;
#ifdef CONFIG_PRINTF_RNDN
    {
      char buf1[JS_DTOA_BUF_SIZE], buf2[JS_DTOA_BUF_SIZE];
      int decpt1, sign1, decpt2, sign2;
      /* The JS rounding is specified as round to nearest ties away
         from zero (RNDNA), but in printf the "ties" case is not
         specified (for example it is RNDN for glibc, RNDNA for
         Windows), so we must round manually. */
      js_ecvt1(d, n_digits + 1, &decpt1, &sign1, buf1, FE_TONEAREST, buf_tmp, sizeof(buf_tmp));
      /* XXX: could use 2 digits to reduce the average running time */
      if (buf1[n_digits] == '5') {
        js_ecvt1(d, n_digits + 1, &decpt1, &sign1, buf1, FE_DOWNWARD, buf_tmp, sizeof(buf_tmp));
        js_ecvt1(d, n_digits + 1, &decpt2, &sign2, buf2, FE_UPWARD, buf_tmp, sizeof(buf_tmp));
        if (memcmp(buf1, buf2, n_digits + 1) == 0 && decpt1 == decpt2) {
          /* exact result: round away from zero */
          if (sign1)
            rounding_mode = FE_DOWNWARD;
          else
            rounding_mode = FE_UPWARD;
        }
      }
    }
#endif /* CONFIG_PRINTF_RNDN */
  }
  js_ecvt1(d, n_digits, decpt, sign, buf, rounding_mode, buf_tmp, sizeof(buf_tmp));
  return n_digits;
}

int js_fcvt1(char* buf, int buf_size, double d, int n_digits, int rounding_mode) {
  int n;
  if (rounding_mode != FE_TONEAREST)
    fesetround(rounding_mode);
  n = snprintf(buf, buf_size, "%.*f", n_digits, d);
  if (rounding_mode != FE_TONEAREST)
    fesetround(FE_TONEAREST);
  assert(n < buf_size);
  return n;
}

void js_fcvt(char* buf, int buf_size, double d, int n_digits) {
  int rounding_mode;
  rounding_mode = FE_TONEAREST;
#ifdef CONFIG_PRINTF_RNDN
  {
    int n1, n2;
    char buf1[JS_DTOA_BUF_SIZE];
    char buf2[JS_DTOA_BUF_SIZE];

    /* The JS rounding is specified as round to nearest ties away from
       zero (RNDNA), but in printf the "ties" case is not specified
       (for example it is RNDN for glibc, RNDNA for Windows), so we
       must round manually. */
    n1 = js_fcvt1(buf1, sizeof(buf1), d, n_digits + 1, FE_TONEAREST);
    rounding_mode = FE_TONEAREST;
    /* XXX: could use 2 digits to reduce the average running time */
    if (buf1[n1 - 1] == '5') {
      n1 = js_fcvt1(buf1, sizeof(buf1), d, n_digits + 1, FE_DOWNWARD);
      n2 = js_fcvt1(buf2, sizeof(buf2), d, n_digits + 1, FE_UPWARD);
      if (n1 == n2 && memcmp(buf1, buf2, n1) == 0) {
        /* exact result: round away from zero */
        if (buf1[0] == '-')
          rounding_mode = FE_DOWNWARD;
        else
          rounding_mode = FE_UPWARD;
      }
    }
  }
#endif /* CONFIG_PRINTF_RNDN */
  js_fcvt1(buf, buf_size, d, n_digits, rounding_mode);
}

/* XXX: slow and maybe not fully correct. Use libbf when it is fast enough.
   XXX: radix != 10 is only supported for small integers
*/
void js_dtoa1(char* buf, double d, int radix, int n_digits, int flags) {
  char* q;

  if (!isfinite(d)) {
    if (isnan(d)) {
      strcpy(buf, "NaN");
    } else {
      q = buf;
      if (d < 0)
        *q++ = '-';
      strcpy(q, "Infinity");
    }
  } else if (flags == JS_DTOA_VAR_FORMAT) {
    int64_t i64;
    char buf1[70], *ptr;
    i64 = (int64_t)d;
    if (d != i64 || i64 > MAX_SAFE_INTEGER || i64 < -MAX_SAFE_INTEGER)
      goto generic_conv;
    /* fast path for integers */
    ptr = i64toa(buf1 + sizeof(buf1), i64, radix);
    strcpy(buf, ptr);
  } else {
    if (d == 0.0)
      d = 0.0; /* convert -0 to 0 */
    if (flags == JS_DTOA_FRAC_FORMAT) {
      js_fcvt(buf, JS_DTOA_BUF_SIZE, d, n_digits);
    } else {
      char buf1[JS_DTOA_BUF_SIZE];
      int sign, decpt, k, n, i, p, n_max;
      BOOL is_fixed;
    generic_conv:
      is_fixed = ((flags & 3) == JS_DTOA_FIXED_FORMAT);
      if (is_fixed) {
        n_max = n_digits;
      } else {
        n_max = 21;
      }
      /* the number has k digits (k >= 1) */
      k = js_ecvt(d, n_digits, &decpt, &sign, buf1, is_fixed);
      n = decpt; /* d=10^(n-k)*(buf1) i.e. d= < x.yyyy 10^(n-1) */
      q = buf;
      if (sign)
        *q++ = '-';
      if (flags & JS_DTOA_FORCE_EXP)
        goto force_exp;
      if (n >= 1 && n <= n_max) {
        if (k <= n) {
          memcpy(q, buf1, k);
          q += k;
          for (i = 0; i < (n - k); i++)
            *q++ = '0';
          *q = '\0';
        } else {
          /* k > n */
          memcpy(q, buf1, n);
          q += n;
          *q++ = '.';
          for (i = 0; i < (k - n); i++)
            *q++ = buf1[n + i];
          *q = '\0';
        }
      } else if (n >= -5 && n <= 0) {
        *q++ = '0';
        *q++ = '.';
        for (i = 0; i < -n; i++)
          *q++ = '0';
        memcpy(q, buf1, k);
        q += k;
        *q = '\0';
      } else {
      force_exp:
        /* exponential notation */
        *q++ = buf1[0];
        if (k > 1) {
          *q++ = '.';
          for (i = 1; i < k; i++)
            *q++ = buf1[i];
        }
        *q++ = 'e';
        p = n - 1;
        if (p >= 0)
          *q++ = '+';
        sprintf(q, "%d", p);
      }
    }
  }
}

JSValue js_dtoa(JSContext* ctx, double d, int radix, int n_digits, int flags) {
  char buf[JS_DTOA_BUF_SIZE];
  js_dtoa1(buf, d, radix, n_digits, flags);
  return JS_NewString(ctx, buf);
}

JSValue JS_ToStringInternal(JSContext* ctx, JSValueConst val, BOOL is_ToPropertyKey) {
  uint32_t tag;
  const char* str;
  char buf[32];

  tag = JS_VALUE_GET_NORM_TAG(val);
  switch (tag) {
    case JS_TAG_STRING:
      return JS_DupValue(ctx, val);
    case JS_TAG_INT:
      snprintf(buf, sizeof(buf), "%d", JS_VALUE_GET_INT(val));
      str = buf;
      goto new_string;
    case JS_TAG_BOOL:
      return JS_AtomToString(ctx, JS_VALUE_GET_BOOL(val) ? JS_ATOM_true : JS_ATOM_false);
    case JS_TAG_NULL:
      return JS_AtomToString(ctx, JS_ATOM_null);
    case JS_TAG_UNDEFINED:
      return JS_AtomToString(ctx, JS_ATOM_undefined);
    case JS_TAG_EXCEPTION:
      return JS_EXCEPTION;
    case JS_TAG_OBJECT: {
      JSValue val1, ret;
      val1 = JS_ToPrimitive(ctx, val, HINT_STRING);
      if (JS_IsException(val1))
        return val1;
      ret = JS_ToStringInternal(ctx, val1, is_ToPropertyKey);
      JS_FreeValue(ctx, val1);
      return ret;
    } break;
    case JS_TAG_FUNCTION_BYTECODE:
      str = "[function bytecode]";
      goto new_string;
    case JS_TAG_SYMBOL:
      if (is_ToPropertyKey) {
        return JS_DupValue(ctx, val);
      } else {
        return JS_ThrowTypeError(ctx, "cannot convert symbol to string");
      }
    case JS_TAG_FLOAT64:
      return js_dtoa(ctx, JS_VALUE_GET_FLOAT64(val), 10, 0, JS_DTOA_VAR_FORMAT);
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT:
      return ctx->rt->bigint_ops.to_string(ctx, val);
    case JS_TAG_BIG_FLOAT:
      return ctx->rt->bigfloat_ops.to_string(ctx, val);
    case JS_TAG_BIG_DECIMAL:
      return ctx->rt->bigdecimal_ops.to_string(ctx, val);
#endif
    default:
      str = "[unsupported type]";
    new_string:
      return JS_NewString(ctx, str);
  }
}

JSValue JS_ToString(JSContext* ctx, JSValueConst val) {
  return JS_ToStringInternal(ctx, val, FALSE);
}

JSValue JS_ToStringFree(JSContext* ctx, JSValue val) {
  JSValue ret;
  ret = JS_ToString(ctx, val);
  JS_FreeValue(ctx, val);
  return ret;
}

JSValue JS_ToLocaleStringFree(JSContext* ctx, JSValue val) {
  if (JS_IsUndefined(val) || JS_IsNull(val))
    return JS_ToStringFree(ctx, val);
  return JS_InvokeFree(ctx, val, JS_ATOM_toLocaleString, 0, NULL);
}

JSValue JS_ToPropertyKey(JSContext* ctx, JSValueConst val) {
  return JS_ToStringInternal(ctx, val, TRUE);
}

JSValue JS_ToStringCheckObject(JSContext* ctx, JSValueConst val) {
  uint32_t tag = JS_VALUE_GET_TAG(val);
  if (tag == JS_TAG_NULL || tag == JS_TAG_UNDEFINED)
    return JS_ThrowTypeError(ctx, "null or undefined are forbidden");
  return JS_ToString(ctx, val);
}

JSValue JS_ToQuotedString(JSContext* ctx, JSValueConst val1) {
  JSValue val;
  JSString* p;
  int i;
  uint32_t c;
  StringBuffer b_s, *b = &b_s;
  char buf[16];

  val = JS_ToStringCheckObject(ctx, val1);
  if (JS_IsException(val))
    return val;
  p = JS_VALUE_GET_STRING(val);

  if (string_buffer_init(ctx, b, p->len + 2))
    goto fail;

  if (string_buffer_putc8(b, '\"'))
    goto fail;
  for (i = 0; i < p->len;) {
    c = string_getc(p, &i);
    switch (c) {
      case '\t':
        c = 't';
        goto quote;
      case '\r':
        c = 'r';
        goto quote;
      case '\n':
        c = 'n';
        goto quote;
      case '\b':
        c = 'b';
        goto quote;
      case '\f':
        c = 'f';
        goto quote;
      case '\"':
      case '\\':
      quote:
        if (string_buffer_putc8(b, '\\'))
          goto fail;
        if (string_buffer_putc8(b, c))
          goto fail;
        break;
      default:
        if (c < 32 || (c >= 0xd800 && c < 0xe000)) {
          snprintf(buf, sizeof(buf), "\\u%04x", c);
          if (string_buffer_puts8(b, buf))
            goto fail;
        } else {
          if (string_buffer_putc(b, c))
            goto fail;
        }
        break;
    }
  }
  if (string_buffer_putc8(b, '\"'))
    goto fail;
  JS_FreeValue(ctx, val);
  return string_buffer_end(b);
fail:
  JS_FreeValue(ctx, val);
  string_buffer_free(b);
  return JS_EXCEPTION;
}
