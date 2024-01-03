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

#include "js-math.h"

/* Math */

/* precondition: a and b are not NaN */
double js_fmin(double a, double b)
{
  if (a == 0 && b == 0) {
    JSFloat64Union a1, b1;
    a1.d = a;
    b1.d = b;
    a1.u64 |= b1.u64;
    return a1.d;
  } else {
    return fmin(a, b);
  }
}

/* precondition: a and b are not NaN */
double js_fmax(double a, double b)
{
  if (a == 0 && b == 0) {
    JSFloat64Union a1, b1;
    a1.d = a;
    b1.d = b;
    a1.u64 &= b1.u64;
    return a1.d;
  } else {
    return fmax(a, b);
  }
}

JSValue js_math_min_max(JSContext *ctx, JSValueConst this_val,
                               int argc, JSValueConst *argv, int magic)
{
  BOOL is_max = magic;
  double r, a;
  int i;
  uint32_t tag;

  if (unlikely(argc == 0)) {
    return __JS_NewFloat64(ctx, is_max ? -INFINITY : INFINITY);
  }

  tag = JS_VALUE_GET_TAG(argv[0]);
  if (tag == JS_TAG_INT) {
    int a1, r1 = JS_VALUE_GET_INT(argv[0]);
    for(i = 1; i < argc; i++) {
      tag = JS_VALUE_GET_TAG(argv[i]);
      if (tag != JS_TAG_INT) {
        r = r1;
        goto generic_case;
      }
      a1 = JS_VALUE_GET_INT(argv[i]);
      if (is_max)
        r1 = max_int(r1, a1);
      else
        r1 = min_int(r1, a1);

    }
    return JS_NewInt32(ctx, r1);
  } else {
    if (JS_ToFloat64(ctx, &r, argv[0]))
      return JS_EXCEPTION;
    i = 1;
  generic_case:
    while (i < argc) {
      if (JS_ToFloat64(ctx, &a, argv[i]))
        return JS_EXCEPTION;
      if (!isnan(r)) {
        if (isnan(a)) {
          r = a;
        } else {
          if (is_max)
            r = js_fmax(r, a);
          else
            r = js_fmin(r, a);
        }
      }
      i++;
    }
    return JS_NewFloat64(ctx, r);
  }
}

double js_math_sign(double a)
{
  if (isnan(a) || a == 0.0)
    return a;
  if (a < 0)
    return -1;
  else
    return 1;
}

double js_math_round(double a)
{
  JSFloat64Union u;
  uint64_t frac_mask, one;
  unsigned int e, s;

  u.d = a;
  e = (u.u64 >> 52) & 0x7ff;
  if (e < 1023) {
    /* abs(a) < 1 */
    if (e == (1023 - 1) && u.u64 != 0xbfe0000000000000) {
      /* abs(a) > 0.5 or a = 0.5: return +/-1.0 */
      u.u64 = (u.u64 & ((uint64_t)1 << 63)) | ((uint64_t)1023 << 52);
    } else {
      /* return +/-0.0 */
      u.u64 &= (uint64_t)1 << 63;
    }
  } else if (e < (1023 + 52)) {
    s = u.u64 >> 63;
    one = (uint64_t)1 << (52 - (e - 1023));
    frac_mask = one - 1;
    u.u64 += (one >> 1) - s;
    u.u64 &= ~frac_mask; /* truncate to an integer */
  }
  /* otherwise: abs(a) >= 2^52, or NaN, +/-Infinity: no change */
  return u.d;
}

JSValue js_math_hypot(JSContext *ctx, JSValueConst this_val,
                             int argc, JSValueConst *argv)
{
  double r, a;
  int i;

  r = 0;
  if (argc > 0) {
    if (JS_ToFloat64(ctx, &r, argv[0]))
      return JS_EXCEPTION;
    if (argc == 1) {
      r = fabs(r);
    } else {
      /* use the built-in function to minimize precision loss */
      for (i = 1; i < argc; i++) {
        if (JS_ToFloat64(ctx, &a, argv[i]))
          return JS_EXCEPTION;
        r = hypot(r, a);
      }
    }
  }
  return JS_NewFloat64(ctx, r);
}

double js_math_fround(double a)
{
  return (float)a;
}

JSValue js_math_imul(JSContext *ctx, JSValueConst this_val,
                            int argc, JSValueConst *argv)
{
  int a, b;

  if (JS_ToInt32(ctx, &a, argv[0]))
    return JS_EXCEPTION;
  if (JS_ToInt32(ctx, &b, argv[1]))
    return JS_EXCEPTION;
  /* purposely ignoring overflow */
  return JS_NewInt32(ctx, a * b);
}

JSValue js_math_clz32(JSContext *ctx, JSValueConst this_val,
                             int argc, JSValueConst *argv)
{
  uint32_t a, r;

  if (JS_ToUint32(ctx, &a, argv[0]))
    return JS_EXCEPTION;
  if (a == 0)
    r = 32;
  else
    r = clz32(a);
  return JS_NewInt32(ctx, r);
}

/* xorshift* random number generator by Marsaglia */
uint64_t xorshift64star(uint64_t *pstate)
{
  uint64_t x;
  x = *pstate;
  x ^= x >> 12;
  x ^= x << 25;
  x ^= x >> 27;
  *pstate = x;
  return x * 0x2545F4914F6CDD1D;
}

void js_random_init(JSContext *ctx)
{
  struct timeval tv;
  gettimeofday(&tv, NULL);
  ctx->random_state = ((int64_t)tv.tv_sec * 1000000) + tv.tv_usec;
  /* the state must be non zero */
  if (ctx->random_state == 0)
    ctx->random_state = 1;
}

JSValue js_math_random(JSContext *ctx, JSValueConst this_val,
                              int argc, JSValueConst *argv)
{
  JSFloat64Union u;
  uint64_t v;

  v = xorshift64star(&ctx->random_state);
  /* 1.0 <= u.d < 2 */
  u.u64 = ((uint64_t)0x3ff << 52) | (v >> 12);
  return __JS_NewFloat64(ctx, u.d - 1.0);
}

