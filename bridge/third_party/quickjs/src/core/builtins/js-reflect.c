#include "js-reflect.h"
#include "../exception.h"
#include "../object.h"
#include "../runtime.h"
#include "js-function.h"

/* Reflect */
JSValue js_reflect_apply(JSContext *ctx, JSValueConst this_val,
                                int argc, JSValueConst *argv)
{
  return js_function_apply(ctx, argv[0], max_int(0, argc - 1), argv + 1, 2);
}

JSValue js_reflect_construct(JSContext *ctx, JSValueConst this_val,
                                    int argc, JSValueConst *argv)
{
  JSValueConst func, array_arg, new_target;
  JSValue *tab, ret;
  uint32_t len;

  func = argv[0];
  array_arg = argv[1];
  if (argc > 2) {
    new_target = argv[2];
    if (!JS_IsConstructor(ctx, new_target))
      return JS_ThrowTypeError(ctx, "not a constructor");
  } else {
    new_target = func;
  }
  tab = build_arg_list(ctx, &len, array_arg);
  if (!tab)
    return JS_EXCEPTION;
  ret = JS_CallConstructor2(ctx, func, new_target, len, (JSValueConst *)tab);
  free_arg_list(ctx, tab, len);
  return ret;
}

JSValue js_reflect_deleteProperty(JSContext *ctx, JSValueConst this_val,
                                         int argc, JSValueConst *argv)
{
  JSValueConst obj;
  JSAtom atom;
  int ret;

  obj = argv[0];
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return JS_ThrowTypeErrorNotAnObject(ctx);
  atom = JS_ValueToAtom(ctx, argv[1]);
  if (unlikely(atom == JS_ATOM_NULL))
    return JS_EXCEPTION;
  ret = JS_DeleteProperty(ctx, obj, atom, 0);
  JS_FreeAtom(ctx, atom);
  if (ret < 0)
    return JS_EXCEPTION;
  else
    return JS_NewBool(ctx, ret);
}

JSValue js_reflect_get(JSContext *ctx, JSValueConst this_val,
                              int argc, JSValueConst *argv)
{
  JSValueConst obj, prop, receiver;
  JSAtom atom;
  JSValue ret;

  obj = argv[0];
  prop = argv[1];
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return JS_ThrowTypeErrorNotAnObject(ctx);
  if (argc > 2)
    receiver = argv[2];
  else
    receiver = obj;
  atom = JS_ValueToAtom(ctx, prop);
  if (unlikely(atom == JS_ATOM_NULL))
    return JS_EXCEPTION;
  ret = JS_GetPropertyInternal(ctx, obj, atom, receiver, FALSE);
  JS_FreeAtom(ctx, atom);
  return ret;
}

JSValue js_reflect_has(JSContext *ctx, JSValueConst this_val,
                              int argc, JSValueConst *argv)
{
  JSValueConst obj, prop;
  JSAtom atom;
  int ret;

  obj = argv[0];
  prop = argv[1];
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return JS_ThrowTypeErrorNotAnObject(ctx);
  atom = JS_ValueToAtom(ctx, prop);
  if (unlikely(atom == JS_ATOM_NULL))
    return JS_EXCEPTION;
  ret = JS_HasProperty(ctx, obj, atom);
  JS_FreeAtom(ctx, atom);
  if (ret < 0)
    return JS_EXCEPTION;
  else
    return JS_NewBool(ctx, ret);
}

JSValue js_reflect_set(JSContext *ctx, JSValueConst this_val,
                              int argc, JSValueConst *argv)
{
  JSValueConst obj, prop, val, receiver;
  int ret;
  JSAtom atom;

  obj = argv[0];
  prop = argv[1];
  val = argv[2];
  if (argc > 3)
    receiver = argv[3];
  else
    receiver = obj;
  if (JS_VALUE_GET_TAG(obj) != JS_TAG_OBJECT)
    return JS_ThrowTypeErrorNotAnObject(ctx);
  atom = JS_ValueToAtom(ctx, prop);
  if (unlikely(atom == JS_ATOM_NULL))
    return JS_EXCEPTION;
  ret = JS_SetPropertyGeneric(ctx, obj, atom,
                              JS_DupValue(ctx, val), receiver, 0);
  JS_FreeAtom(ctx, atom);
  if (ret < 0)
    return JS_EXCEPTION;
  else
    return JS_NewBool(ctx, ret);
}

JSValue js_reflect_setPrototypeOf(JSContext *ctx, JSValueConst this_val,
                                         int argc, JSValueConst *argv)
{
  int ret;
  ret = JS_SetPrototypeInternal(ctx, argv[0], argv[1], FALSE);
  if (ret < 0)
    return JS_EXCEPTION;
  else
    return JS_NewBool(ctx, ret);
}

JSValue js_reflect_ownKeys(JSContext *ctx, JSValueConst this_val,
                                  int argc, JSValueConst *argv)
{
  if (JS_VALUE_GET_TAG(argv[0]) != JS_TAG_OBJECT)
    return JS_ThrowTypeErrorNotAnObject(ctx);
  return JS_GetOwnPropertyNames2(ctx, argv[0],
                                 JS_GPN_STRING_MASK | JS_GPN_SYMBOL_MASK,
                                 JS_ITERATOR_KIND_KEY);
}
