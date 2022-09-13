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

#include "js-boolean.h"
#include "../exception.h"
#include "../object.h"

/* Boolean */
JSValue js_boolean_constructor(JSContext* ctx, JSValueConst new_target, int argc, JSValueConst* argv) {
  JSValue val, obj;
  val = JS_NewBool(ctx, JS_ToBool(ctx, argv[0]));
  if (!JS_IsUndefined(new_target)) {
    obj = js_create_from_ctor(ctx, new_target, JS_CLASS_BOOLEAN);
    if (!JS_IsException(obj))
      JS_SetObjectData(ctx, obj, val);
    return obj;
  } else {
    return val;
  }
}

JSValue js_thisBooleanValue(JSContext* ctx, JSValueConst this_val) {
  if (JS_VALUE_GET_TAG(this_val) == JS_TAG_BOOL)
    return JS_DupValue(ctx, this_val);

  if (JS_VALUE_GET_TAG(this_val) == JS_TAG_OBJECT) {
    JSObject* p = JS_VALUE_GET_OBJ(this_val);
    if (p->class_id == JS_CLASS_BOOLEAN) {
      if (JS_VALUE_GET_TAG(p->u.object_data) == JS_TAG_BOOL)
        return p->u.object_data;
    }
  }
  return JS_ThrowTypeError(ctx, "not a boolean");
}

JSValue js_boolean_toString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  JSValue val = js_thisBooleanValue(ctx, this_val);
  if (JS_IsException(val))
    return val;
  return JS_AtomToString(ctx, JS_VALUE_GET_BOOL(val) ? JS_ATOM_true : JS_ATOM_false);
}

JSValue js_boolean_valueOf(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  return js_thisBooleanValue(ctx, this_val);
}
