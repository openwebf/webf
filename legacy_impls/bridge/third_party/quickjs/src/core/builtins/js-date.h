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

#ifndef QUICKJS_JS_DATE_H
#define QUICKJS_JS_DATE_H

#include "quickjs/quickjs.h"
#include "../types.h"

JSValue js___date_clock(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
__exception int JS_ThisTimeValue(JSContext* ctx, double* valp, JSValueConst this_val);
JSValue JS_SetThisTimeValue(JSContext* ctx, JSValueConst this_val, double v);
int64_t days_from_year(int64_t y);
int64_t days_in_year(int64_t y);
/* return the year, update days */
int64_t year_from_days(int64_t *days);
__exception int get_date_fields(JSContext *ctx, JSValueConst obj,
                                       double fields[9], int is_local, int force);
double time_clip(double t);
/* The spec mandates the use of 'double' and it fixes the order
   of the operations */
double set_date_fields(double fields[], int is_local);
JSValue get_date_field(JSContext *ctx, JSValueConst this_val,
                              int argc, JSValueConst *argv, int magic);
JSValue set_date_field(JSContext *ctx, JSValueConst this_val,
                              int argc, JSValueConst *argv, int magic);
/* fmt:
   0: toUTCString: "Tue, 02 Jan 2018 23:04:46 GMT"
   1: toString: "Wed Jan 03 2018 00:05:22 GMT+0100 (CET)"
   2: toISOString: "2018-01-02T23:02:56.927Z"
   3: toLocaleString: "1/2/2018, 11:40:40 PM"
   part: 1=date, 2=time 3=all
   XXX: should use a variant of strftime().
 */
JSValue get_date_string(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
/* OS dependent: return the UTC time in ms since 1970. */
int64_t date_now(void);
JSValue js_date_constructor(JSContext* ctx, JSValueConst new_target, int argc, JSValueConst* argv);
JSValue js_Date_UTC(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
void string_skip_spaces(JSString* sp, int* pp);
void string_skip_non_spaces(JSString* sp, int* pp);
/* parse a numeric field with an optional sign if accept_sign is TRUE */
int string_get_digits(JSString* sp, int* pp, int64_t* pval);
int string_get_signed_digits(JSString* sp, int* pp, int64_t* pval);
/* parse a fixed width numeric field */
int string_get_fixed_width_digits(JSString* sp, int* pp, int n, int64_t* pval);
int string_get_milliseconds(JSString* sp, int* pp, int64_t* pval);
int find_abbrev(JSString* sp, int p, const char* list, int count);
int string_get_month(JSString* sp, int* pp, int64_t* pval);
JSValue js_Date_parse(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_Date_now(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_date_Symbol_toPrimitive(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_date_getTimezoneOffset(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_date_getTime(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_date_setTime(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_date_setYear(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_date_toJSON(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

#endif