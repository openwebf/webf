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
