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

#ifndef QUICKJS_JS_STRING_H
#define QUICKJS_JS_STRING_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "../types.h"

/* ES6 Annex B 2.3.2 etc. */
enum {
  magic_string_anchor,
  magic_string_big,
  magic_string_blink,
  magic_string_bold,
  magic_string_fixed,
  magic_string_fontcolor,
  magic_string_fontsize,
  magic_string_italics,
  magic_string_link,
  magic_string_small,
  magic_string_strike,
  magic_string_sub,
  magic_string_sup,
};

int js_string_get_own_property(JSContext* ctx, JSPropertyDescriptor* desc, JSValueConst obj, JSAtom prop);
int js_string_define_own_property(JSContext* ctx, JSValueConst this_obj, JSAtom prop, JSValueConst val, JSValueConst getter, JSValueConst setter, int flags);
int js_string_delete_property(JSContext* ctx, JSValueConst obj, JSAtom prop);
JSValue js_string_constructor(JSContext* ctx, JSValueConst new_target, int argc, JSValueConst* argv);
JSValue js_thisStringValue(JSContext* ctx, JSValueConst this_val) ;
JSValue js_string_fromCharCode(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_fromCodePoint(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_raw(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
/* only used in test262 */
JSValue js_string_codePointRange(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_charCodeAt(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_charAt(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_codePointAt(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_concat(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
int string_cmp(JSString* p1, JSString* p2, int x1, int x2, int len);
int string_indexof_char(JSString* p, int c, int from);
int string_indexof(JSString* p1, JSString* p2, int from);
int64_t string_advance_index(JSString* p, int64_t index, BOOL unicode);
JSValue js_string_indexOf(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int lastIndexOf) ;
int js_is_regexp(JSContext* ctx, JSValueConst obj);;
JSValue js_string_includes(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
int check_regexp_g_flag(JSContext* ctx, JSValueConst regexp);
JSValue js_string_match(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int atom);
JSValue js_string___GetSubstitution(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_replace(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int is_replaceAll);
JSValue js_string_split(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_substring(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_substr(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_slice(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_pad(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int padEnd);
JSValue js_string_repeat(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_trim(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
JSValue js_string___quote(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
int string_prevc(JSString* p, int* pidx);
BOOL test_final_sigma(JSString* p, int sigma_pos);
JSValue js_string_localeCompare(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_toLowerCase(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int to_lower);
JSValue js_string_toString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_string_iterator_next(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, BOOL* pdone, int magic);
JSValue js_string_CreateHTML(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);

#endif