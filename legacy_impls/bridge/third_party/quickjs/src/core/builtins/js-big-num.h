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

#ifndef QUICKJS_JS_BIG_NUM_H
#define QUICKJS_JS_BIG_NUM_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "../types.h"

#if CONFIG_BIGNUM
#include "quickjs/libbf.h"

JSValue JS_NewBigInt(JSContext *ctx);
JSValue JS_NewBigInt64_1(JSContext *ctx, int64_t v);

no_inline __exception int js_binary_arith_slow(JSContext *ctx, JSValue *sp,
                                               OPCodeEnum op);
no_inline __exception int js_unary_arith_slow(JSContext *ctx,
                                              JSValue *sp,
                                              OPCodeEnum op);
__exception int js_post_inc_slow(JSContext *ctx,
                                 JSValue *sp, OPCodeEnum op);
no_inline int js_not_slow(JSContext *ctx, JSValue *sp);
int js_binary_arith_bigfloat(JSContext *ctx, OPCodeEnum op,
                             JSValue *pres, JSValue op1, JSValue op2);
int js_binary_arith_bigint(JSContext *ctx, OPCodeEnum op,
                           JSValue *pres, JSValue op1, JSValue op2);
int js_bfdec_pow(bfdec_t *r, const bfdec_t *a, const bfdec_t *b);
int js_binary_arith_bigdecimal(JSContext *ctx, OPCodeEnum op,
                               JSValue *pres, JSValue op1, JSValue op2);
no_inline __exception int js_binary_logic_slow(JSContext *ctx,
                                               JSValue *sp,
                                               OPCodeEnum op);
/* Note: also used for bigint */
int js_compare_bigfloat(JSContext *ctx, OPCodeEnum op,
                        JSValue op1, JSValue op2);
int js_compare_bigdecimal(JSContext *ctx, OPCodeEnum op,
                          JSValue op1, JSValue op2);
no_inline int js_relational_slow(JSContext *ctx, JSValue *sp,
                                 OPCodeEnum op);
no_inline __exception int js_eq_slow(JSContext *ctx, JSValue *sp,
                                     BOOL is_neq);
no_inline int js_shr_slow(JSContext *ctx, JSValue *sp);
JSValue js_mul_pow10_to_float64(JSContext *ctx, const bf_t *a,
                                int64_t exponent);
no_inline int js_mul_pow10(JSContext *ctx, JSValue *sp);
JSBigFloat *js_new_bf(JSContext *ctx);
void js_float_env_finalizer(JSRuntime *rt, JSValue val);
JSValue JS_NewBigFloat(JSContext *ctx);
static inline bf_t *JS_GetBigFloat(JSValueConst val)
{
  JSBigFloat *p = JS_VALUE_GET_PTR(val);
  return &p->num;
}
JSValue JS_NewBigDecimal(JSContext *ctx);
static inline bfdec_t *JS_GetBigDecimal(JSValueConst val)
{
  JSBigDecimal *p = JS_VALUE_GET_PTR(val);
  return &p->num;
}
JSValue JS_NewBigInt(JSContext *ctx);
static inline bf_t *JS_GetBigInt(JSValueConst val) {
  JSBigFloat *p = JS_VALUE_GET_PTR(val);
  return &p->num;
}
JSValue JS_CompactBigInt1(JSContext *ctx, JSValue val,
                          BOOL convert_to_safe_integer);
no_inline __exception int js_add_slow(JSContext *ctx, JSValue *sp);
JSValue JS_CompactBigInt(JSContext *ctx, JSValue val);
int JS_ToBigInt64Free(JSContext *ctx, int64_t *pres, JSValue val);
bf_t *JS_ToBigInt(JSContext *ctx, bf_t *buf, JSValueConst val);
__maybe_unused JSValue JS_ToBigIntValueFree(JSContext *ctx, JSValue val);
void JS_FreeBigInt(JSContext *ctx, bf_t *a, bf_t *buf);
bf_t *JS_ToBigFloat(JSContext *ctx, bf_t *buf, JSValueConst val);
JSValue JS_ToBigDecimalFree(JSContext *ctx, JSValue val,
                            BOOL allow_null_or_undefined);
bfdec_t *JS_ToBigDecimal(JSContext *ctx, JSValueConst val);

#else

no_inline __exception int js_unary_arith_slow(JSContext *ctx,
                                                     JSValue *sp,
                                                     OPCodeEnum op);
__exception int js_post_inc_slow(JSContext *ctx,
                                        JSValue *sp, OPCodeEnum op);
no_inline __exception int js_add_slow(JSContext *ctx, JSValue *sp);
no_inline __exception int js_binary_arith_slow(JSContext *ctx, JSValue *sp,
                                                      OPCodeEnum op);
no_inline __exception int js_binary_logic_slow(JSContext *ctx,
                                                      JSValue *sp,
                                                      OPCodeEnum op);
no_inline int js_not_slow(JSContext *ctx, JSValue *sp);
no_inline int js_relational_slow(JSContext *ctx, JSValue *sp,
                                        OPCodeEnum op);
no_inline __exception int js_eq_slow(JSContext *ctx, JSValue *sp,
                                            BOOL is_neq);
no_inline int js_shr_slow(JSContext *ctx, JSValue *sp);
#endif


#endif