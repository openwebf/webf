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

#include "js-string.h"
#include "../convertion.h"
#include "../exception.h"
#include "../function.h"
#include "../object.h"
#include "../string.h"
#include "../types.h"
#include "js-function.h"
#include "js-object.h"
#include "js-array.h"
#include "quickjs/libregexp.h"

/* String */

int js_string_get_own_property(JSContext* ctx, JSPropertyDescriptor* desc, JSValueConst obj, JSAtom prop) {
  JSObject* p;
  JSString* p1;
  uint32_t idx, ch;

  /* This is a class exotic method: obj class_id is JS_CLASS_STRING */
  if (__JS_AtomIsTaggedInt(prop)) {
    p = JS_VALUE_GET_OBJ(obj);
    if (JS_VALUE_GET_TAG(p->u.object_data) == JS_TAG_STRING) {
      p1 = JS_VALUE_GET_STRING(p->u.object_data);
      idx = __JS_AtomToUInt32(prop);
      if (idx < p1->len) {
        if (desc) {
          if (p1->is_wide_char)
            ch = p1->u.str16[idx];
          else
            ch = p1->u.str8[idx];
          desc->flags = JS_PROP_ENUMERABLE;
          desc->value = js_new_string_char(ctx, ch);
          desc->getter = JS_UNDEFINED;
          desc->setter = JS_UNDEFINED;
        }
        return TRUE;
      }
    }
  }
  return FALSE;
}

int js_string_define_own_property(JSContext* ctx, JSValueConst this_obj, JSAtom prop, JSValueConst val, JSValueConst getter, JSValueConst setter, int flags) {
  uint32_t idx;
  JSObject* p;
  JSString *p1, *p2;

  if (__JS_AtomIsTaggedInt(prop)) {
    idx = __JS_AtomToUInt32(prop);
    p = JS_VALUE_GET_OBJ(this_obj);
    if (JS_VALUE_GET_TAG(p->u.object_data) != JS_TAG_STRING)
      goto def;
    p1 = JS_VALUE_GET_STRING(p->u.object_data);
    if (idx >= p1->len)
      goto def;
    if (!check_define_prop_flags(JS_PROP_ENUMERABLE, flags))
      goto fail;
    /* check that the same value is configured */
    if (flags & JS_PROP_HAS_VALUE) {
      if (JS_VALUE_GET_TAG(val) != JS_TAG_STRING)
        goto fail;
      p2 = JS_VALUE_GET_STRING(val);
      if (p2->len != 1)
        goto fail;
      if (string_get(p1, idx) != string_get(p2, 0)) {
      fail:
        return JS_ThrowTypeErrorOrFalse(ctx, flags, "property is not configurable");
      }
    }
    return TRUE;
  } else {
  def:
    return JS_DefineProperty(ctx, this_obj, prop, val, getter, setter, flags | JS_PROP_NO_EXOTIC);
  }
}

int js_string_delete_property(JSContext* ctx, JSValueConst obj, JSAtom prop) {
  uint32_t idx;

  if (__JS_AtomIsTaggedInt(prop)) {
    idx = __JS_AtomToUInt32(prop);
    if (idx < js_string_obj_get_length(ctx, obj)) {
      return FALSE;
    }
  }
  return TRUE;
}

static const JSClassExoticMethods js_string_exotic_methods = {
    .get_own_property = js_string_get_own_property,
    .define_own_property = js_string_define_own_property,
    .delete_property = js_string_delete_property,
};

JSValue js_string_constructor(JSContext* ctx, JSValueConst new_target, int argc, JSValueConst* argv) {
  JSValue val, obj;
  if (argc == 0) {
    val = JS_AtomToString(ctx, JS_ATOM_empty_string);
  } else {
    if (JS_IsUndefined(new_target) && JS_IsSymbol(argv[0])) {
      JSAtomStruct* p = JS_VALUE_GET_PTR(argv[0]);
      val = JS_ConcatString3(ctx, "Symbol(", JS_AtomToString(ctx, js_get_atom_index(ctx->rt, p)), ")");
    } else {
      val = JS_ToString(ctx, argv[0]);
    }
    if (JS_IsException(val))
      return val;
  }
  if (!JS_IsUndefined(new_target)) {
    JSString* p1 = JS_VALUE_GET_STRING(val);

    obj = js_create_from_ctor(ctx, new_target, JS_CLASS_STRING);
    if (!JS_IsException(obj)) {
      JS_SetObjectData(ctx, obj, val);
      JS_DefinePropertyValue(ctx, obj, JS_ATOM_length, JS_NewInt32(ctx, p1->len), 0);
    }
    return obj;
  } else {
    return val;
  }
}

JSValue js_thisStringValue(JSContext* ctx, JSValueConst this_val) {
  if (JS_VALUE_GET_TAG(this_val) == JS_TAG_STRING)
    return JS_DupValue(ctx, this_val);

  if (JS_VALUE_GET_TAG(this_val) == JS_TAG_OBJECT) {
    JSObject* p = JS_VALUE_GET_OBJ(this_val);
    if (p->class_id == JS_CLASS_STRING) {
      if (JS_VALUE_GET_TAG(p->u.object_data) == JS_TAG_STRING)
        return JS_DupValue(ctx, p->u.object_data);
    }
  }
  return JS_ThrowTypeError(ctx, "not a string");
}

JSValue js_string_fromCharCode(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  int i;
  StringBuffer b_s, *b = &b_s;

  string_buffer_init(ctx, b, argc);

  for (i = 0; i < argc; i++) {
    int32_t c;
    if (JS_ToInt32(ctx, &c, argv[i]) || string_buffer_putc16(b, c & 0xffff)) {
      string_buffer_free(b);
      return JS_EXCEPTION;
    }
  }
  return string_buffer_end(b);
}

JSValue js_string_fromCodePoint(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  double d;
  int i, c;
  StringBuffer b_s, *b = &b_s;

  /* XXX: could pre-compute string length if all arguments are JS_TAG_INT */

  if (string_buffer_init(ctx, b, argc))
    goto fail;
  for (i = 0; i < argc; i++) {
    if (JS_VALUE_GET_TAG(argv[i]) == JS_TAG_INT) {
      c = JS_VALUE_GET_INT(argv[i]);
      if (c < 0 || c > 0x10ffff)
        goto range_error;
    } else {
      if (JS_ToFloat64(ctx, &d, argv[i]))
        goto fail;
      if (d < 0 || d > 0x10ffff || (c = (int)d) != d)
        goto range_error;
    }
    if (string_buffer_putc(b, c))
      goto fail;
  }
  return string_buffer_end(b);

range_error:
  JS_ThrowRangeError(ctx, "invalid code point");
fail:
  string_buffer_free(b);
  return JS_EXCEPTION;
}

JSValue js_string_raw(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  // raw(temp,...a)
  JSValue cooked, val, raw;
  StringBuffer b_s, *b = &b_s;
  int64_t i, n;

  string_buffer_init(ctx, b, 0);
  raw = JS_UNDEFINED;
  cooked = JS_ToObject(ctx, argv[0]);
  if (JS_IsException(cooked))
    goto exception;
  raw = JS_ToObjectFree(ctx, JS_GetProperty(ctx, cooked, JS_ATOM_raw));
  if (JS_IsException(raw))
    goto exception;
  if (js_get_length64(ctx, &n, raw) < 0)
    goto exception;

  for (i = 0; i < n; i++) {
    val = JS_ToStringFree(ctx, JS_GetPropertyInt64(ctx, raw, i));
    if (JS_IsException(val))
      goto exception;
    string_buffer_concat_value_free(b, val);
    if (i < n - 1 && i + 1 < argc) {
      if (string_buffer_concat_value(b, argv[i + 1]))
        goto exception;
    }
  }
  JS_FreeValue(ctx, cooked);
  JS_FreeValue(ctx, raw);
  return string_buffer_end(b);

exception:
  JS_FreeValue(ctx, cooked);
  JS_FreeValue(ctx, raw);
  string_buffer_free(b);
  return JS_EXCEPTION;
}

/* only used in test262 */
JSValue js_string_codePointRange(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  uint32_t start, end, i, n;
  StringBuffer b_s, *b = &b_s;

  if (JS_ToUint32(ctx, &start, argv[0]) || JS_ToUint32(ctx, &end, argv[1]))
    return JS_EXCEPTION;
  end = min_uint32(end, 0x10ffff + 1);

  if (start > end) {
    start = end;
  }
  n = end - start;
  if (end > 0x10000) {
    n += end - max_uint32(start, 0x10000);
  }
  if (string_buffer_init2(ctx, b, n, end >= 0x100))
    return JS_EXCEPTION;
  for (i = start; i < end; i++) {
    string_buffer_putc(b, i);
  }
  return string_buffer_end(b);
}

#if 0
JSValue js_string___isSpace(JSContext *ctx, JSValueConst this_val,
                                   int argc, JSValueConst *argv)
{
    int c;
    if (JS_ToInt32(ctx, &c, argv[0]))
        return JS_EXCEPTION;
    return JS_NewBool(ctx, lre_is_space(c));
}
#endif

JSValue js_string_charCodeAt(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue val, ret;
  JSString* p;
  int idx, c;

  val = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(val))
    return val;
  p = JS_VALUE_GET_STRING(val);
  if (JS_ToInt32Sat(ctx, &idx, argv[0])) {
    JS_FreeValue(ctx, val);
    return JS_EXCEPTION;
  }
  if (idx < 0 || idx >= p->len) {
    ret = JS_NAN;
  } else {
    if (p->is_wide_char)
      c = p->u.str16[idx];
    else
      c = p->u.str8[idx];
    ret = JS_NewInt32(ctx, c);
  }
  JS_FreeValue(ctx, val);
  return ret;
}

JSValue js_string_charAt(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue val, ret;
  JSString* p;
  int idx, c;

  val = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(val))
    return val;
  p = JS_VALUE_GET_STRING(val);
  if (JS_ToInt32Sat(ctx, &idx, argv[0])) {
    JS_FreeValue(ctx, val);
    return JS_EXCEPTION;
  }
  if (idx < 0 || idx >= p->len) {
    ret = js_new_string8(ctx, NULL, 0);
  } else {
    if (p->is_wide_char)
      c = p->u.str16[idx];
    else
      c = p->u.str8[idx];
    ret = js_new_string_char(ctx, c);
  }
  JS_FreeValue(ctx, val);
  return ret;
}

JSValue js_string_codePointAt(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue val, ret;
  JSString* p;
  int idx, c;

  val = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(val))
    return val;
  p = JS_VALUE_GET_STRING(val);
  if (JS_ToInt32Sat(ctx, &idx, argv[0])) {
    JS_FreeValue(ctx, val);
    return JS_EXCEPTION;
  }
  if (idx < 0 || idx >= p->len) {
    ret = JS_UNDEFINED;
  } else {
    c = string_getc(p, &idx);
    ret = JS_NewInt32(ctx, c);
  }
  JS_FreeValue(ctx, val);
  return ret;
}

JSValue js_string_concat(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue r;
  int i;

  /* XXX: Use more efficient method */
  /* XXX: This method is OK if r has a single refcount */
  /* XXX: should use string_buffer? */
  r = JS_ToStringCheckObject(ctx, this_val);
  for (i = 0; i < argc; i++) {
    if (JS_IsException(r))
      break;
    r = JS_ConcatString(ctx, r, JS_DupValue(ctx, argv[i]));
  }
  return r;
}

int string_cmp(JSString* p1, JSString* p2, int x1, int x2, int len) {
  int i, c1, c2;
  for (i = 0; i < len; i++) {
    if ((c1 = string_get(p1, x1 + i)) != (c2 = string_get(p2, x2 + i)))
      return c1 - c2;
  }
  return 0;
}

int string_indexof_char(JSString* p, int c, int from) {
  /* assuming 0 <= from <= p->len */
  int i, len = p->len;
  if (p->is_wide_char) {
    for (i = from; i < len; i++) {
      if (p->u.str16[i] == c)
        return i;
    }
  } else {
    if ((c & ~0xff) == 0) {
      for (i = from; i < len; i++) {
        if (p->u.str8[i] == (uint8_t)c)
          return i;
      }
    }
  }
  return -1;
}

int string_indexof(JSString* p1, JSString* p2, int from) {
  /* assuming 0 <= from <= p1->len */
  int c, i, j, len1 = p1->len, len2 = p2->len;
  if (len2 == 0)
    return from;
  for (i = from, c = string_get(p2, 0); i + len2 <= len1; i = j + 1) {
    j = string_indexof_char(p1, c, i);
    if (j < 0 || j + len2 > len1)
      break;
    if (!string_cmp(p1, p2, j + 1, 1, len2 - 1))
      return j;
  }
  return -1;
}

int64_t string_advance_index(JSString* p, int64_t index, BOOL unicode) {
  if (!unicode || index >= p->len || !p->is_wide_char) {
    index++;
  } else {
    int index32 = (int)index;
    string_getc(p, &index32);
    index = index32;
  }
  return index;
}

JSValue js_string_indexOf(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int lastIndexOf) {
  JSValue str, v;
  int i, len, v_len, pos, start, stop, ret, inc;
  JSString* p;
  JSString* p1;

  str = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(str))
    return str;
  v = JS_ToString(ctx, argv[0]);
  if (JS_IsException(v))
    goto fail;
  p = JS_VALUE_GET_STRING(str);
  p1 = JS_VALUE_GET_STRING(v);
  len = p->len;
  v_len = p1->len;
  if (lastIndexOf) {
    pos = len - v_len;
    if (argc > 1) {
      double d;
      if (JS_ToFloat64(ctx, &d, argv[1]))
        goto fail;
      if (!isnan(d)) {
        if (d <= 0)
          pos = 0;
        else if (d < pos)
          pos = d;
      }
    }
    start = pos;
    stop = 0;
    inc = -1;
  } else {
    pos = 0;
    if (argc > 1) {
      if (JS_ToInt32Clamp(ctx, &pos, argv[1], 0, len, 0))
        goto fail;
    }
    start = pos;
    stop = len - v_len;
    inc = 1;
  }
  ret = -1;
  if (len >= v_len && inc * (stop - start) >= 0) {
    for (i = start;; i += inc) {
      if (!string_cmp(p, p1, i, 0, v_len)) {
        ret = i;
        break;
      }
      if (i == stop)
        break;
    }
  }
  JS_FreeValue(ctx, str);
  JS_FreeValue(ctx, v);
  return JS_NewInt32(ctx, ret);

fail:
  JS_FreeValue(ctx, str);
  JS_FreeValue(ctx, v);
  return JS_EXCEPTION;
}

/* return < 0 if exception or TRUE/FALSE */
int js_is_regexp(JSContext* ctx, JSValueConst obj);

JSValue js_string_includes(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic) {
  JSValue str, v = JS_UNDEFINED;
  int i, len, v_len, pos, start, stop, ret;
  JSString* p;
  JSString* p1;

  str = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(str))
    return str;
  ret = js_is_regexp(ctx, argv[0]);
  if (ret) {
    if (ret > 0)
      JS_ThrowTypeError(ctx, "regex not supported");
    goto fail;
  }
  v = JS_ToString(ctx, argv[0]);
  if (JS_IsException(v))
    goto fail;
  p = JS_VALUE_GET_STRING(str);
  p1 = JS_VALUE_GET_STRING(v);
  len = p->len;
  v_len = p1->len;
  pos = (magic == 2) ? len : 0;
  if (argc > 1 && !JS_IsUndefined(argv[1])) {
    if (JS_ToInt32Clamp(ctx, &pos, argv[1], 0, len, 0))
      goto fail;
  }
  len -= v_len;
  ret = 0;
  if (magic == 0) {
    start = pos;
    stop = len;
  } else {
    if (magic == 1) {
      if (pos > len)
        goto done;
    } else {
      pos -= v_len;
    }
    start = stop = pos;
  }
  if (start >= 0 && start <= stop) {
    for (i = start;; i++) {
      if (!string_cmp(p, p1, i, 0, v_len)) {
        ret = 1;
        break;
      }
      if (i == stop)
        break;
    }
  }
done:
  JS_FreeValue(ctx, str);
  JS_FreeValue(ctx, v);
  return JS_NewBool(ctx, ret);

fail:
  JS_FreeValue(ctx, str);
  JS_FreeValue(ctx, v);
  return JS_EXCEPTION;
}

int check_regexp_g_flag(JSContext* ctx, JSValueConst regexp) {
  int ret;
  JSValue flags;

  ret = js_is_regexp(ctx, regexp);
  if (ret < 0)
    return -1;
  if (ret) {
    flags = JS_GetProperty(ctx, regexp, JS_ATOM_flags);
    if (JS_IsException(flags))
      return -1;
    if (JS_IsUndefined(flags) || JS_IsNull(flags)) {
      JS_ThrowTypeError(ctx, "cannot convert to object");
      return -1;
    }
    flags = JS_ToStringFree(ctx, flags);
    if (JS_IsException(flags))
      return -1;
    ret = string_indexof_char(JS_VALUE_GET_STRING(flags), 'g', 0);
    JS_FreeValue(ctx, flags);
    if (ret < 0) {
      JS_ThrowTypeError(ctx, "regexp must have the 'g' flag");
      return -1;
    }
  }
  return 0;
}

JSValue js_string_match(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int atom) {
  // match(rx), search(rx), matchAll(rx)
  // atom is JS_ATOM_Symbol_match, JS_ATOM_Symbol_search, or JS_ATOM_Symbol_matchAll
  JSValueConst O = this_val, regexp = argv[0], args[2];
  JSValue matcher, S, rx, result, str;
  int args_len;

  if (JS_IsUndefined(O) || JS_IsNull(O))
    return JS_ThrowTypeError(ctx, "cannot convert to object");

  if (!JS_IsUndefined(regexp) && !JS_IsNull(regexp)) {
    matcher = JS_GetProperty(ctx, regexp, atom);
    if (JS_IsException(matcher))
      return JS_EXCEPTION;
    if (atom == JS_ATOM_Symbol_matchAll) {
      if (check_regexp_g_flag(ctx, regexp) < 0) {
        JS_FreeValue(ctx, matcher);
        return JS_EXCEPTION;
      }
    }
    if (!JS_IsUndefined(matcher) && !JS_IsNull(matcher)) {
      return JS_CallFree(ctx, matcher, regexp, 1, &O);
    }
  }
  S = JS_ToString(ctx, O);
  if (JS_IsException(S))
    return JS_EXCEPTION;
  args_len = 1;
  args[0] = regexp;
  str = JS_UNDEFINED;
  if (atom == JS_ATOM_Symbol_matchAll) {
    str = JS_NewString(ctx, "g");
    if (JS_IsException(str))
      goto fail;
    args[args_len++] = str;
  }
  rx = JS_CallConstructor(ctx, ctx->regexp_ctor, args_len, args);
  JS_FreeValue(ctx, str);
  if (JS_IsException(rx)) {
  fail:
    JS_FreeValue(ctx, S);
    return JS_EXCEPTION;
  }
  result = JS_InvokeFree(ctx, rx, atom, 1, (JSValueConst*)&S);
  JS_FreeValue(ctx, S);
  return result;
}

JSValue js_string___GetSubstitution(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  // GetSubstitution(matched, str, position, captures, namedCaptures, rep)
  JSValueConst matched, str, captures, namedCaptures, rep;
  JSValue capture, name, s;
  uint32_t position, len, matched_len, captures_len;
  int i, j, j0, k, k1;
  int c, c1;
  StringBuffer b_s, *b = &b_s;
  JSString *sp, *rp;

  matched = argv[0];
  str = argv[1];
  captures = argv[3];
  namedCaptures = argv[4];
  rep = argv[5];

  if (!JS_IsString(rep) || !JS_IsString(str))
    return JS_ThrowTypeError(ctx, "not a string");

  sp = JS_VALUE_GET_STRING(str);
  rp = JS_VALUE_GET_STRING(rep);

  string_buffer_init(ctx, b, 0);

  captures_len = 0;
  if (!JS_IsUndefined(captures)) {
    if (js_get_length32(ctx, &captures_len, captures))
      goto exception;
  }
  if (js_get_length32(ctx, &matched_len, matched))
    goto exception;
  if (JS_ToUint32(ctx, &position, argv[2]) < 0)
    goto exception;

  len = rp->len;
  i = 0;
  for (;;) {
    j = string_indexof_char(rp, '$', i);
    if (j < 0 || j + 1 >= len)
      break;
    string_buffer_concat(b, rp, i, j);
    j0 = j++;
    c = string_get(rp, j++);
    if (c == '$') {
      string_buffer_putc8(b, '$');
    } else if (c == '&') {
      if (string_buffer_concat_value(b, matched))
        goto exception;
    } else if (c == '`') {
      string_buffer_concat(b, sp, 0, position);
    } else if (c == '\'') {
      string_buffer_concat(b, sp, position + matched_len, sp->len);
    } else if (c >= '0' && c <= '9') {
      k = c - '0';
      if (j < len) {
        c1 = string_get(rp, j);
        if (c1 >= '0' && c1 <= '9') {
          /* This behavior is specified in ES6 and refined in ECMA 2019 */
          /* ECMA 2019 does not have the extra test, but
             Test262 S15.5.4.11_A3_T1..3 require this behavior */
          k1 = k * 10 + c1 - '0';
          if (k1 >= 1 && k1 < captures_len) {
            k = k1;
            j++;
          }
        }
      }
      if (k >= 1 && k < captures_len) {
        s = JS_GetPropertyInt64(ctx, captures, k);
        if (JS_IsException(s))
          goto exception;
        if (!JS_IsUndefined(s)) {
          if (string_buffer_concat_value_free(b, s))
            goto exception;
        }
      } else {
        goto norep;
      }
    } else if (c == '<' && !JS_IsUndefined(namedCaptures)) {
      k = string_indexof_char(rp, '>', j);
      if (k < 0)
        goto norep;
      name = js_sub_string(ctx, rp, j, k);
      if (JS_IsException(name))
        goto exception;
      capture = JS_GetPropertyValue(ctx, namedCaptures, name);
      if (JS_IsException(capture))
        goto exception;
      if (!JS_IsUndefined(capture)) {
        if (string_buffer_concat_value_free(b, capture))
          goto exception;
      }
      j = k + 1;
    } else {
    norep:
      string_buffer_concat(b, rp, j0, j);
    }
    i = j;
  }
  string_buffer_concat(b, rp, i, rp->len);
  return string_buffer_end(b);
exception:
  string_buffer_free(b);
  return JS_EXCEPTION;
}

JSValue js_string_replace(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int is_replaceAll) {
  // replace(rx, rep)
  JSValueConst O = this_val, searchValue = argv[0], replaceValue = argv[1];
  JSValueConst args[6];
  JSValue str, search_str, replaceValue_str, repl_str;
  JSString *sp, *searchp;
  StringBuffer b_s, *b = &b_s;
  int pos, functionalReplace, endOfLastMatch;
  BOOL is_first;

  if (JS_IsUndefined(O) || JS_IsNull(O))
    return JS_ThrowTypeError(ctx, "cannot convert to object");

  search_str = JS_UNDEFINED;
  replaceValue_str = JS_UNDEFINED;
  repl_str = JS_UNDEFINED;

  if (!JS_IsUndefined(searchValue) && !JS_IsNull(searchValue)) {
    JSValue replacer;
    if (is_replaceAll) {
      if (check_regexp_g_flag(ctx, searchValue) < 0)
        return JS_EXCEPTION;
    }
    replacer = JS_GetProperty(ctx, searchValue, JS_ATOM_Symbol_replace);
    if (JS_IsException(replacer))
      return JS_EXCEPTION;
    if (!JS_IsUndefined(replacer) && !JS_IsNull(replacer)) {
      args[0] = O;
      args[1] = replaceValue;
      return JS_CallFree(ctx, replacer, searchValue, 2, args);
    }
  }
  string_buffer_init(ctx, b, 0);

  str = JS_ToString(ctx, O);
  if (JS_IsException(str))
    goto exception;
  search_str = JS_ToString(ctx, searchValue);
  if (JS_IsException(search_str))
    goto exception;
  functionalReplace = JS_IsFunction(ctx, replaceValue);
  if (!functionalReplace) {
    replaceValue_str = JS_ToString(ctx, replaceValue);
    if (JS_IsException(replaceValue_str))
      goto exception;
  }

  sp = JS_VALUE_GET_STRING(str);
  searchp = JS_VALUE_GET_STRING(search_str);
  endOfLastMatch = 0;
  is_first = TRUE;
  for (;;) {
    if (unlikely(searchp->len == 0)) {
      if (is_first)
        pos = 0;
      else if (endOfLastMatch >= sp->len)
        pos = -1;
      else
        pos = endOfLastMatch + 1;
    } else {
      pos = string_indexof(sp, searchp, endOfLastMatch);
    }
    if (pos < 0) {
      if (is_first) {
        string_buffer_free(b);
        JS_FreeValue(ctx, search_str);
        JS_FreeValue(ctx, replaceValue_str);
        return str;
      } else {
        break;
      }
    }
    if (functionalReplace) {
      args[0] = search_str;
      args[1] = JS_NewInt32(ctx, pos);
      args[2] = str;
      repl_str = JS_ToStringFree(ctx, JS_Call(ctx, replaceValue, JS_UNDEFINED, 3, args));
    } else {
      args[0] = search_str;
      args[1] = str;
      args[2] = JS_NewInt32(ctx, pos);
      args[3] = JS_UNDEFINED;
      args[4] = JS_UNDEFINED;
      args[5] = replaceValue_str;
      repl_str = js_string___GetSubstitution(ctx, JS_UNDEFINED, 6, args);
    }
    if (JS_IsException(repl_str))
      goto exception;

    string_buffer_concat(b, sp, endOfLastMatch, pos);
    string_buffer_concat_value_free(b, repl_str);
    endOfLastMatch = pos + searchp->len;
    is_first = FALSE;
    if (!is_replaceAll)
      break;
  }
  string_buffer_concat(b, sp, endOfLastMatch, sp->len);
  JS_FreeValue(ctx, search_str);
  JS_FreeValue(ctx, replaceValue_str);
  JS_FreeValue(ctx, str);
  return string_buffer_end(b);

exception:
  string_buffer_free(b);
  JS_FreeValue(ctx, search_str);
  JS_FreeValue(ctx, replaceValue_str);
  JS_FreeValue(ctx, str);
  return JS_EXCEPTION;
}

JSValue js_string_split(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  // split(sep, limit)
  JSValueConst O = this_val, separator = argv[0], limit = argv[1];
  JSValueConst args[2];
  JSValue S, A, R, T;
  uint32_t lim, lengthA;
  int64_t p, q, s, r, e;
  JSString *sp, *rp;

  if (JS_IsUndefined(O) || JS_IsNull(O))
    return JS_ThrowTypeError(ctx, "cannot convert to object");

  S = JS_UNDEFINED;
  A = JS_UNDEFINED;
  R = JS_UNDEFINED;

  if (!JS_IsUndefined(separator) && !JS_IsNull(separator)) {
    JSValue splitter;
    splitter = JS_GetProperty(ctx, separator, JS_ATOM_Symbol_split);
    if (JS_IsException(splitter))
      return JS_EXCEPTION;
    if (!JS_IsUndefined(splitter) && !JS_IsNull(splitter)) {
      args[0] = O;
      args[1] = limit;
      return JS_CallFree(ctx, splitter, separator, 2, args);
    }
  }
  S = JS_ToString(ctx, O);
  if (JS_IsException(S))
    goto exception;
  A = JS_NewArray(ctx);
  if (JS_IsException(A))
    goto exception;
  lengthA = 0;
  if (JS_IsUndefined(limit)) {
    lim = 0xffffffff;
  } else {
    if (JS_ToUint32(ctx, &lim, limit) < 0)
      goto exception;
  }
  sp = JS_VALUE_GET_STRING(S);
  s = sp->len;
  R = JS_ToString(ctx, separator);
  if (JS_IsException(R))
    goto exception;
  rp = JS_VALUE_GET_STRING(R);
  r = rp->len;
  p = 0;
  if (lim == 0)
    goto done;
  if (JS_IsUndefined(separator))
    goto add_tail;
  if (s == 0) {
    if (r != 0)
      goto add_tail;
    goto done;
  }
  q = p;
  for (q = p; (q += !r) <= s - r - !r; q = p = e + r) {
    e = string_indexof(sp, rp, q);
    if (e < 0)
      break;
    T = js_sub_string(ctx, sp, p, e);
    if (JS_IsException(T))
      goto exception;
    if (JS_CreateDataPropertyUint32(ctx, A, lengthA++, T, 0) < 0)
      goto exception;
    if (lengthA == lim)
      goto done;
  }
add_tail:
  T = js_sub_string(ctx, sp, p, s);
  if (JS_IsException(T))
    goto exception;
  if (JS_CreateDataPropertyUint32(ctx, A, lengthA++, T, 0) < 0)
    goto exception;
done:
  JS_FreeValue(ctx, S);
  JS_FreeValue(ctx, R);
  return A;

exception:
  JS_FreeValue(ctx, A);
  JS_FreeValue(ctx, S);
  JS_FreeValue(ctx, R);
  return JS_EXCEPTION;
}

JSValue js_string_substring(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue str, ret;
  int a, b, start, end;
  JSString* p;

  str = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(str))
    return str;
  p = JS_VALUE_GET_STRING(str);
  if (JS_ToInt32Clamp(ctx, &a, argv[0], 0, p->len, 0)) {
    JS_FreeValue(ctx, str);
    return JS_EXCEPTION;
  }
  b = p->len;
  if (!JS_IsUndefined(argv[1])) {
    if (JS_ToInt32Clamp(ctx, &b, argv[1], 0, p->len, 0)) {
      JS_FreeValue(ctx, str);
      return JS_EXCEPTION;
    }
  }
  if (a < b) {
    start = a;
    end = b;
  } else {
    start = b;
    end = a;
  }
  ret = js_sub_string(ctx, p, start, end);
  JS_FreeValue(ctx, str);
  return ret;
}

JSValue js_string_substr(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue str, ret;
  int a, len, n;
  JSString* p;

  str = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(str))
    return str;
  p = JS_VALUE_GET_STRING(str);
  len = p->len;
  if (JS_ToInt32Clamp(ctx, &a, argv[0], 0, len, len)) {
    JS_FreeValue(ctx, str);
    return JS_EXCEPTION;
  }
  n = len - a;
  if (!JS_IsUndefined(argv[1])) {
    if (JS_ToInt32Clamp(ctx, &n, argv[1], 0, len - a, 0)) {
      JS_FreeValue(ctx, str);
      return JS_EXCEPTION;
    }
  }
  ret = js_sub_string(ctx, p, a, a + n);
  JS_FreeValue(ctx, str);
  return ret;
}

JSValue js_string_slice(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue str, ret;
  int len, start, end;
  JSString* p;

  str = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(str))
    return str;
  p = JS_VALUE_GET_STRING(str);
  len = p->len;
  if (JS_ToInt32Clamp(ctx, &start, argv[0], 0, len, len)) {
    JS_FreeValue(ctx, str);
    return JS_EXCEPTION;
  }
  end = len;
  if (!JS_IsUndefined(argv[1])) {
    if (JS_ToInt32Clamp(ctx, &end, argv[1], 0, len, len)) {
      JS_FreeValue(ctx, str);
      return JS_EXCEPTION;
    }
  }
  ret = js_sub_string(ctx, p, start, max_int(end, start));
  JS_FreeValue(ctx, str);
  return ret;
}

JSValue js_string_pad(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int padEnd) {
  JSValue str, v = JS_UNDEFINED;
  StringBuffer b_s, *b = &b_s;
  JSString *p, *p1 = NULL;
  int n, len, c = ' ';

  str = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(str))
    goto fail1;
  if (JS_ToInt32Sat(ctx, &n, argv[0]))
    goto fail2;
  p = JS_VALUE_GET_STRING(str);
  len = p->len;
  if (len >= n)
    return str;
  if (argc > 1 && !JS_IsUndefined(argv[1])) {
    v = JS_ToString(ctx, argv[1]);
    if (JS_IsException(v))
      goto fail2;
    p1 = JS_VALUE_GET_STRING(v);
    if (p1->len == 0) {
      JS_FreeValue(ctx, v);
      return str;
    }
    if (p1->len == 1) {
      c = string_get(p1, 0);
      p1 = NULL;
    }
  }
  if (n > JS_STRING_LEN_MAX) {
    JS_ThrowInternalError(ctx, "string too long");
    goto fail2;
  }
  if (string_buffer_init(ctx, b, n))
    goto fail3;
  n -= len;
  if (padEnd) {
    if (string_buffer_concat(b, p, 0, len))
      goto fail;
  }
  if (p1) {
    while (n > 0) {
      int chunk = min_int(n, p1->len);
      if (string_buffer_concat(b, p1, 0, chunk))
        goto fail;
      n -= chunk;
    }
  } else {
    if (string_buffer_fill(b, c, n))
      goto fail;
  }
  if (!padEnd) {
    if (string_buffer_concat(b, p, 0, len))
      goto fail;
  }
  JS_FreeValue(ctx, v);
  JS_FreeValue(ctx, str);
  return string_buffer_end(b);

fail:
  string_buffer_free(b);
fail3:
  JS_FreeValue(ctx, v);
fail2:
  JS_FreeValue(ctx, str);
fail1:
  return JS_EXCEPTION;
}

JSValue js_string_repeat(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue str;
  StringBuffer b_s, *b = &b_s;
  JSString* p;
  int64_t val;
  int n, len;

  str = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(str))
    goto fail;
  if (JS_ToInt64Sat(ctx, &val, argv[0]))
    goto fail;
  if (val < 0 || val > 2147483647) {
    JS_ThrowRangeError(ctx, "invalid repeat count");
    goto fail;
  }
  n = val;
  p = JS_VALUE_GET_STRING(str);
  len = p->len;
  if (len == 0 || n == 1)
    return str;
  if (val * len > JS_STRING_LEN_MAX) {
    JS_ThrowInternalError(ctx, "string too long");
    goto fail;
  }
  if (string_buffer_init2(ctx, b, n * len, p->is_wide_char))
    goto fail;
  if (len == 1) {
    string_buffer_fill(b, string_get(p, 0), n);
  } else {
    while (n-- > 0) {
      string_buffer_concat(b, p, 0, len);
    }
  }
  JS_FreeValue(ctx, str);
  return string_buffer_end(b);

fail:
  JS_FreeValue(ctx, str);
  return JS_EXCEPTION;
}

JSValue js_string_trim(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic) {
  JSValue str, ret;
  int a, b, len;
  JSString* p;

  str = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(str))
    return str;
  p = JS_VALUE_GET_STRING(str);
  a = 0;
  b = len = p->len;
  if (magic & 1) {
    while (a < len && lre_is_space(string_get(p, a)))
      a++;
  }
  if (magic & 2) {
    while (b > a && lre_is_space(string_get(p, b - 1)))
      b--;
  }
  ret = js_sub_string(ctx, p, a, b);
  JS_FreeValue(ctx, str);
  return ret;
}

JSValue js_string___quote(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  return JS_ToQuotedString(ctx, this_val);
}

/* return 0 if before the first char */
int string_prevc(JSString* p, int* pidx) {
  int idx, c, c1;

  idx = *pidx;
  if (idx <= 0)
    return 0;
  idx--;
  if (p->is_wide_char) {
    c = p->u.str16[idx];
    if (c >= 0xdc00 && c < 0xe000 && idx > 0) {
      c1 = p->u.str16[idx - 1];
      if (c1 >= 0xd800 && c1 <= 0xdc00) {
        c = (((c1 & 0x3ff) << 10) | (c & 0x3ff)) + 0x10000;
        idx--;
      }
    }
  } else {
    c = p->u.str8[idx];
  }
  *pidx = idx;
  return c;
}

BOOL test_final_sigma(JSString* p, int sigma_pos) {
  int k, c1;

  /* before C: skip case ignorable chars and check there is
     a cased letter */
  k = sigma_pos;
  for (;;) {
    c1 = string_prevc(p, &k);
    if (!lre_is_case_ignorable(c1))
      break;
  }
  if (!lre_is_cased(c1))
    return FALSE;

  /* after C: skip case ignorable chars and check there is
     no cased letter */
  k = sigma_pos + 1;
  for (;;) {
    if (k >= p->len)
      return TRUE;
    c1 = string_getc(p, &k);
    if (!lre_is_case_ignorable(c1))
      break;
  }
  return !lre_is_cased(c1);
}

JSValue js_string_localeCompare(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue a, b;
  int cmp;

  a = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(a))
    return JS_EXCEPTION;
  b = JS_ToString(ctx, argv[0]);
  if (JS_IsException(b)) {
    JS_FreeValue(ctx, a);
    return JS_EXCEPTION;
  }
  cmp = js_string_compare(ctx, JS_VALUE_GET_STRING(a), JS_VALUE_GET_STRING(b));
  JS_FreeValue(ctx, a);
  JS_FreeValue(ctx, b);
  return JS_NewInt32(ctx, cmp);
}

JSValue js_string_toLowerCase(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int to_lower) {
  JSValue val;
  StringBuffer b_s, *b = &b_s;
  JSString* p;
  int i, c, j, l;
  uint32_t res[LRE_CC_RES_LEN_MAX];

  val = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(val))
    return val;
  p = JS_VALUE_GET_STRING(val);
  if (p->len == 0)
    return val;
  if (string_buffer_init(ctx, b, p->len))
    goto fail;
  for (i = 0; i < p->len;) {
    c = string_getc(p, &i);
    if (c == 0x3a3 && to_lower && test_final_sigma(p, i - 1)) {
      res[0] = 0x3c2; /* final sigma */
      l = 1;
    } else {
      l = lre_case_conv(res, c, to_lower);
    }
    for (j = 0; j < l; j++) {
      if (string_buffer_putc(b, res[j]))
        goto fail;
    }
  }
  JS_FreeValue(ctx, val);
  return string_buffer_end(b);
fail:
  JS_FreeValue(ctx, val);
  string_buffer_free(b);
  return JS_EXCEPTION;
}

#ifdef CONFIG_ALL_UNICODE

/* return (-1, NULL) if exception, otherwise (len, buf) */
int JS_ToUTF32String(JSContext* ctx, uint32_t** pbuf, JSValueConst val1) {
  JSValue val;
  JSString* p;
  uint32_t* buf;
  int i, j, len;

  val = JS_ToString(ctx, val1);
  if (JS_IsException(val))
    return -1;
  p = JS_VALUE_GET_STRING(val);
  len = p->len;
  /* UTF32 buffer length is len minus the number of correct surrogates pairs */
  buf = js_malloc(ctx, sizeof(buf[0]) * max_int(len, 1));
  if (!buf) {
    JS_FreeValue(ctx, val);
    goto fail;
  }
  for (i = j = 0; i < len;)
    buf[j++] = string_getc(p, &i);
  JS_FreeValue(ctx, val);
  *pbuf = buf;
  return j;
fail:
  *pbuf = NULL;
  return -1;
}

JSValue JS_NewUTF32String(JSContext* ctx, const uint32_t* buf, int len) {
  int i;
  StringBuffer b_s, *b = &b_s;
  if (string_buffer_init(ctx, b, len))
    return JS_EXCEPTION;
  for (i = 0; i < len; i++) {
    if (string_buffer_putc(b, buf[i]))
      goto fail;
  }
  return string_buffer_end(b);
fail:
  string_buffer_free(b);
  return JS_EXCEPTION;
}

JSValue js_string_normalize(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  const char *form, *p;
  size_t form_len;
  int is_compat, buf_len, out_len;
  UnicodeNormalizationEnum n_type;
  JSValue val;
  uint32_t *buf, *out_buf;

  val = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(val))
    return val;
  buf_len = JS_ToUTF32String(ctx, &buf, val);
  JS_FreeValue(ctx, val);
  if (buf_len < 0)
    return JS_EXCEPTION;

  if (argc == 0 || JS_IsUndefined(argv[0])) {
    n_type = UNICODE_NFC;
  } else {
    form = JS_ToCStringLen(ctx, &form_len, argv[0]);
    if (!form)
      goto fail1;
    p = form;
    if (p[0] != 'N' || p[1] != 'F')
      goto bad_form;
    p += 2;
    is_compat = FALSE;
    if (*p == 'K') {
      is_compat = TRUE;
      p++;
    }
    if (*p == 'C' || *p == 'D') {
      n_type = UNICODE_NFC + is_compat * 2 + (*p - 'C');
      if ((p + 1 - form) != form_len)
        goto bad_form;
    } else {
    bad_form:
      JS_FreeCString(ctx, form);
      JS_ThrowRangeError(ctx, "bad normalization form");
    fail1:
      js_free(ctx, buf);
      return JS_EXCEPTION;
    }
    JS_FreeCString(ctx, form);
  }

  out_len = unicode_normalize(&out_buf, buf, buf_len, n_type, ctx->rt, (DynBufReallocFunc*)js_realloc_rt);
  js_free(ctx, buf);
  if (out_len < 0)
    return JS_EXCEPTION;
  val = JS_NewUTF32String(ctx, out_buf, out_len);
  js_free(ctx, out_buf);
  return val;
}
#endif /* CONFIG_ALL_UNICODE */

/* also used for String.prototype.valueOf */
JSValue js_string_toString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  return js_thisStringValue(ctx, this_val);
}

#if 0
JSValue js_string___toStringCheckObject(JSContext *ctx, JSValueConst this_val,
                                               int argc, JSValueConst *argv)
{
    return JS_ToStringCheckObject(ctx, argv[0]);
}

JSValue js_string___toString(JSContext *ctx, JSValueConst this_val,
                                    int argc, JSValueConst *argv)
{
    return JS_ToString(ctx, argv[0]);
}

JSValue js_string___advanceStringIndex(JSContext *ctx, JSValueConst
                                              this_val,
                                              int argc, JSValueConst *argv)
{
    JSValue str;
    int idx;
    BOOL is_unicode;
    JSString *p;

    str = JS_ToString(ctx, argv[0]);
    if (JS_IsException(str))
        return str;
    if (JS_ToInt32Sat(ctx, &idx, argv[1])) {
        JS_FreeValue(ctx, str);
        return JS_EXCEPTION;
    }
    is_unicode = JS_ToBool(ctx, argv[2]);
    p = JS_VALUE_GET_STRING(str);
    if (!is_unicode || (unsigned)idx >= p->len || !p->is_wide_char) {
        idx++;
    } else {
        string_getc(p, &idx);
    }
    JS_FreeValue(ctx, str);
    return JS_NewInt32(ctx, idx);
}
#endif

/* String Iterator */

JSValue js_string_iterator_next(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, BOOL* pdone, int magic) {
  JSArrayIteratorData* it;
  uint32_t idx, c, start;
  JSString* p;

  it = JS_GetOpaque2(ctx, this_val, JS_CLASS_STRING_ITERATOR);
  if (!it) {
    *pdone = FALSE;
    return JS_EXCEPTION;
  }
  if (JS_IsUndefined(it->obj))
    goto done;
  p = JS_VALUE_GET_STRING(it->obj);
  idx = it->idx;
  if (idx >= p->len) {
    JS_FreeValue(ctx, it->obj);
    it->obj = JS_UNDEFINED;
  done:
    *pdone = TRUE;
    return JS_UNDEFINED;
  }

  start = idx;
  c = string_getc(p, (int*)&idx);
  it->idx = idx;
  *pdone = FALSE;
  if (c <= 0xffff) {
    return js_new_string_char(ctx, c);
  } else {
    return js_new_string16(ctx, p->u.str16 + start, 2);
  }
}

JSValue js_string_CreateHTML(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic) {
  JSValue str;
  const JSString* p;
  StringBuffer b_s, *b = &b_s;
  struct {
    const char *tag, *attr;
  } const defs[] = {
      {"a", "name"}, {"big", NULL}, {"blink", NULL}, {"b", NULL},      {"tt", NULL},  {"font", "color"}, {"font", "size"},
      {"i", NULL},   {"a", "href"}, {"small", NULL}, {"strike", NULL}, {"sub", NULL}, {"sup", NULL},
  };

  str = JS_ToStringCheckObject(ctx, this_val);
  if (JS_IsException(str))
    return JS_EXCEPTION;
  string_buffer_init(ctx, b, 7);
  string_buffer_putc8(b, '<');
  string_buffer_puts8(b, defs[magic].tag);
  if (defs[magic].attr) {
    // r += " " + attr + "=\"" + value + "\"";
    JSValue value;
    int i;

    string_buffer_putc8(b, ' ');
    string_buffer_puts8(b, defs[magic].attr);
    string_buffer_puts8(b, "=\"");
    value = JS_ToStringCheckObject(ctx, argv[0]);
    if (JS_IsException(value)) {
      JS_FreeValue(ctx, str);
      string_buffer_free(b);
      return JS_EXCEPTION;
    }
    p = JS_VALUE_GET_STRING(value);
    for (i = 0; i < p->len; i++) {
      int c = string_get(p, i);
      if (c == '"') {
        string_buffer_puts8(b, "&quot;");
      } else {
        string_buffer_putc16(b, c);
      }
    }
    JS_FreeValue(ctx, value);
    string_buffer_putc8(b, '\"');
  }
  // return r + ">" + str + "</" + tag + ">";
  string_buffer_putc8(b, '>');
  string_buffer_concat_value_free(b, str);
  string_buffer_puts8(b, "</");
  string_buffer_puts8(b, defs[magic].tag);
  string_buffer_putc8(b, '>');
  return string_buffer_end(b);
}
