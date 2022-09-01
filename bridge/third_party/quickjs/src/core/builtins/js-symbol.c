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

#include "js-symbol.h"
#include "../exception.h"
#include "../string.h"
#include "../types.h"
#include "js-string.h"

/* Symbol */

JSValue js_symbol_constructor(JSContext *ctx, JSValueConst new_target,
                                     int argc, JSValueConst *argv)
{
  JSValue str;
  JSString *p;

  if (!JS_IsUndefined(new_target))
    return JS_ThrowTypeError(ctx, "not a constructor");
  if (argc == 0 || JS_IsUndefined(argv[0])) {
    p = NULL;
  } else {
    str = JS_ToString(ctx, argv[0]);
    if (JS_IsException(str))
      return JS_EXCEPTION;
    p = JS_VALUE_GET_STRING(str);
  }
  return JS_NewSymbol(ctx, p, JS_ATOM_TYPE_SYMBOL);
}

JSValue js_thisSymbolValue(JSContext *ctx, JSValueConst this_val)
{
  if (JS_VALUE_GET_TAG(this_val) == JS_TAG_SYMBOL)
    return JS_DupValue(ctx, this_val);

  if (JS_VALUE_GET_TAG(this_val) == JS_TAG_OBJECT) {
    JSObject *p = JS_VALUE_GET_OBJ(this_val);
    if (p->class_id == JS_CLASS_SYMBOL) {
      if (JS_VALUE_GET_TAG(p->u.object_data) == JS_TAG_SYMBOL)
        return JS_DupValue(ctx, p->u.object_data);
    }
  }
  return JS_ThrowTypeError(ctx, "not a symbol");
}

JSValue js_symbol_toString(JSContext *ctx, JSValueConst this_val,
                                  int argc, JSValueConst *argv)
{
  JSValue val, ret;
  val = js_thisSymbolValue(ctx, this_val);
  if (JS_IsException(val))
    return val;
  /* XXX: use JS_ToStringInternal() with a flags */
  ret = js_string_constructor(ctx, JS_UNDEFINED, 1, (JSValueConst *)&val);
  JS_FreeValue(ctx, val);
  return ret;
}

JSValue js_symbol_valueOf(JSContext *ctx, JSValueConst this_val,
                                 int argc, JSValueConst *argv)
{
  return js_thisSymbolValue(ctx, this_val);
}

JSValue js_symbol_get_description(JSContext *ctx, JSValueConst this_val)
{
  JSValue val, ret;
  JSAtomStruct *p;

  val = js_thisSymbolValue(ctx, this_val);
  if (JS_IsException(val))
    return val;
  p = JS_VALUE_GET_PTR(val);
  if (p->len == 0 && p->is_wide_char != 0) {
    ret = JS_UNDEFINED;
  } else {
    ret = JS_AtomToString(ctx, js_get_atom_index(ctx->rt, p));
  }
  JS_FreeValue(ctx, val);
  return ret;
}

JSValue js_symbol_for(JSContext *ctx, JSValueConst this_val,
                             int argc, JSValueConst *argv)
{
  JSValue str;

  str = JS_ToString(ctx, argv[0]);
  if (JS_IsException(str))
    return JS_EXCEPTION;
  return JS_NewSymbol(ctx, JS_VALUE_GET_STRING(str), JS_ATOM_TYPE_GLOBAL_SYMBOL);
}

JSValue js_symbol_keyFor(JSContext *ctx, JSValueConst this_val,
                                int argc, JSValueConst *argv)
{
  JSAtomStruct *p;

  if (!JS_IsSymbol(argv[0]))
    return JS_ThrowTypeError(ctx, "not a symbol");
  p = JS_VALUE_GET_PTR(argv[0]);
  if (p->atom_type != JS_ATOM_TYPE_GLOBAL_SYMBOL)
    return JS_UNDEFINED;
  return JS_DupValue(ctx, JS_MKPTR(JS_TAG_STRING, p));
}