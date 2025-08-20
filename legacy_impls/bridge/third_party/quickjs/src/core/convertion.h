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

#ifndef QUICKJS_CONVERTION_H
#define QUICKJS_CONVERTION_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "types.h"

#define HINT_STRING 0
#define HINT_NUMBER 1
#define HINT_NONE 2
/* don't try Symbol.toPrimitive */
#define HINT_FORCE_ORDINARY (1 << 4)

#define MAX_SAFE_INTEGER (((int64_t)1 << 53) - 1)

/* maximum buffer size for js_dtoa */
#define JS_DTOA_BUF_SIZE 128

/* radix != 10 is only supported with flags = JS_DTOA_VAR_FORMAT */
/* use as many digits as necessary */
#define JS_DTOA_VAR_FORMAT (0 << 0)
/* use n_digits significant digits (1 <= n_digits <= 101) */
#define JS_DTOA_FIXED_FORMAT (1 << 0)
/* force fractional format: [-]dd.dd with n_digits fractional digits */
#define JS_DTOA_FRAC_FORMAT (2 << 0)
/* force exponential notation either in fixed or variable format */
#define JS_DTOA_FORCE_EXP (1 << 2)

typedef enum JSToNumberHintEnum {
  TON_FLAG_NUMBER,
  TON_FLAG_NUMERIC,
} JSToNumberHintEnum;

int skip_spaces(const char* pc);
JSValue JS_ToPrimitiveFree(JSContext* ctx, JSValue val, int hint);
JSValue JS_ToPrimitive(JSContext* ctx, JSValueConst val, int hint);

__exception int JS_ToArrayLengthFree(JSContext* ctx, uint32_t* plen, JSValue val, BOOL is_array_ctor);

JSValue JS_ToNumberFree(JSContext* ctx, JSValue val);
JSValue JS_ToNumericFree(JSContext* ctx, JSValue val);
JSValue JS_ToNumeric(JSContext* ctx, JSValueConst val);
__exception int __JS_ToFloat64Free(JSContext* ctx, double* pres, JSValue val);
/* same as JS_ToNumber() but return 0 in case of NaN/Undefined */
__maybe_unused JSValue JS_ToIntegerFree(JSContext* ctx, JSValue val);
/* Note: the integer value is satured to 32 bits */
int JS_ToInt32SatFree(JSContext* ctx, int* pres, JSValue val);
int JS_ToInt32Sat(JSContext* ctx, int* pres, JSValueConst val);
int JS_ToInt32Clamp(JSContext* ctx, int* pres, JSValueConst val, int min, int max, int min_offset);
int JS_ToInt64SatFree(JSContext* ctx, int64_t* pres, JSValue val);
int JS_ToInt64Sat(JSContext* ctx, int64_t* pres, JSValueConst val);
int JS_ToInt64Clamp(JSContext* ctx, int64_t* pres, JSValueConst val, int64_t min, int64_t max, int64_t neg_offset);
/* Same as JS_ToInt32Free() but with a 64 bit result. Return (<0, 0)
   in case of exception */
int JS_ToInt64Free(JSContext* ctx, int64_t* pres, JSValue val);
JSValue JS_ToNumber(JSContext* ctx, JSValueConst val);

JSValue JS_ToStringFree(JSContext* ctx, JSValue val);
int JS_ToBoolFree(JSContext* ctx, JSValue val);
int JS_ToInt32Free(JSContext* ctx, int32_t* pres, JSValue val);
static inline int JS_ToFloat64Free(JSContext* ctx, double* pres, JSValue val) {
  uint32_t tag;

  tag = JS_VALUE_GET_TAG(val);
  if (tag <= JS_TAG_NULL) {
    *pres = JS_VALUE_GET_INT(val);
    return 0;
  } else if (JS_TAG_IS_FLOAT64(tag)) {
    *pres = JS_VALUE_GET_FLOAT64(val);
    return 0;
  } else {
    return __JS_ToFloat64Free(ctx, pres, val);
  }
}

static inline int JS_ToUint32Free(JSContext* ctx, uint32_t* pres, JSValue val) {
  return JS_ToInt32Free(ctx, (int32_t*)pres, val);
}
int JS_ToUint8ClampFree(JSContext* ctx, int32_t* pres, JSValue val);

static inline int to_digit(int c) {
  if (c >= '0' && c <= '9')
    return c - '0';
  else if (c >= 'A' && c <= 'Z')
    return c - 'A' + 10;
  else if (c >= 'a' && c <= 'z')
    return c - 'a' + 10;
  else
    return 36;
}
/* XXX: remove */
double js_strtod(const char* p, int radix, BOOL is_float);

#ifdef CONFIG_BIGNUM
JSValue js_string_to_bigint(JSContext* ctx, const char* buf, int radix, int flags, slimb_t* pexponent);
JSValue js_string_to_bigfloat(JSContext* ctx, const char* buf, int radix, int flags, slimb_t* pexponent);
JSValue js_string_to_bigdecimal(JSContext* ctx, const char* buf, int radix, int flags, slimb_t* pexponent);
JSValue js_atof(JSContext* ctx, const char* str, const char** pp, int radix, int flags);
JSValue js_atof2(JSContext* ctx, const char* str, const char** pp, int radix, int flags, slimb_t* pexponent);
#else
JSValue js_atof(JSContext* ctx, const char* str, const char** pp, int radix, int flags);
#endif

BOOL is_safe_integer(double d);
/* convert a value to a length between 0 and MAX_SAFE_INTEGER.
   return -1 for exception */
__exception int JS_ToLengthFree(JSContext* ctx, int64_t* plen, JSValue val);
/* Note: can return an exception */
int JS_NumberIsInteger(JSContext* ctx, JSValueConst val);
BOOL JS_NumberIsNegativeOrMinusZero(JSContext* ctx, JSValueConst val);

#ifdef CONFIG_BIGNUM
JSValue js_bigint_to_string1(JSContext* ctx, JSValueConst val, int radix);
JSValue js_bigint_to_string(JSContext* ctx, JSValueConst val);
JSValue js_ftoa(JSContext* ctx, JSValueConst val1, int radix, limb_t prec, bf_flags_t flags);
JSValue js_bigfloat_to_string(JSContext* ctx, JSValueConst val);
JSValue js_bigdecimal_to_string1(JSContext* ctx, JSValueConst val, limb_t prec, int flags);
JSValue js_bigdecimal_to_string(JSContext* ctx, JSValueConst val);
#endif

/* 2 <= base <= 36 */
char* i64toa(char* buf_end, int64_t n, unsigned int base);
/* buf1 contains the printf result */
void js_ecvt1(double d, int n_digits, int* decpt, int* sign, char* buf, int rounding_mode, char* buf1, int buf1_size);

/* needed because ecvt usually limits the number of digits to
   17. Return the number of digits. */
int js_ecvt(double d, int n_digits, int* decpt, int* sign, char* buf, BOOL is_fixed);
int js_fcvt1(char* buf, int buf_size, double d, int n_digits, int rounding_mode);
void js_fcvt(char* buf, int buf_size, double d, int n_digits);

/* XXX: slow and maybe not fully correct. Use libbf when it is fast enough.
   XXX: radix != 10 is only supported for small integers
*/
void js_dtoa1(char* buf, double d, int radix, int n_digits, int flags);
JSValue js_dtoa(JSContext* ctx, double d, int radix, int n_digits, int flags);
JSValue JS_ToStringInternal(JSContext* ctx, JSValueConst val, BOOL is_ToPropertyKey);

JSValue JS_ToLocaleStringFree(JSContext* ctx, JSValue val);
JSValue JS_ToStringCheckObject(JSContext* ctx, JSValueConst val);
JSValue JS_ToQuotedString(JSContext* ctx, JSValueConst val1);

#endif