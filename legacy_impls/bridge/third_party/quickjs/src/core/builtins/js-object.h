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

#ifndef QUICKJS_JS_OBJECT_H
#define QUICKJS_JS_OBJECT_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "quickjs/list.h"
#include "../types.h"

JSValue JS_ToObject(JSContext* ctx, JSValueConst val);
JSValue JS_ToObjectFree(JSContext* ctx, JSValue val);
int js_obj_to_desc(JSContext* ctx, JSPropertyDescriptor* d, JSValueConst desc);
__exception int JS_DefinePropertyDesc(JSContext* ctx, JSValueConst obj, JSAtom prop, JSValueConst desc, int flags);
__exception int JS_ObjectDefineProperties(JSContext* ctx, JSValueConst obj, JSValueConst properties);
JSValue js_object_constructor(JSContext* ctx, JSValueConst new_target, int argc, JSValueConst* argv);
JSValue js_object_create(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_getPrototypeOf(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
JSValue js_object_setPrototypeOf(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
/* magic = 1 if called as Reflect.defineProperty */
JSValue js_object_defineProperty(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
JSValue js_object_defineProperties(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
/* magic = 1 if called as __defineSetter__ */
JSValue js_object___defineGetter__(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
JSValue js_object_getOwnPropertyDescriptor(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int magic);
JSValue js_object_getOwnPropertyDescriptors(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_getOwnPropertyNames(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_getOwnPropertySymbols(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_keys(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int kind);
JSValue js_object_isExtensible(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int reflect);
JSValue js_object_preventExtensions(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int reflect);
JSValue js_object_hasOwnProperty(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_valueOf(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_toString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_toLocaleString(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_assign(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_seal(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int freeze_flag);
JSValue js_object_isSealed(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv, int is_frozen);
JSValue js_object_fromEntries(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_hasOwn(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
/* return an empty string if not an object */
JSValue js_object___getClass(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_is(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue JS_SpeciesConstructor(JSContext* ctx, JSValueConst obj, JSValueConst defaultConstructor);
JSValue js_object_get___proto__(JSContext* ctx, JSValueConst this_val);
JSValue js_object_set___proto__(JSContext* ctx, JSValueConst this_val, JSValueConst proto);
JSValue js_object_isPrototypeOf(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object_propertyIsEnumerable(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
JSValue js_object___lookupGetter__(JSContext* ctx,
                                          JSValueConst this_val,
                                          int argc,
                                          JSValueConst* argv,
                                          int setter);

void js_object_data_finalizer(JSRuntime* rt, JSValue val);
void js_object_data_mark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func);

#endif