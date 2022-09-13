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

#ifndef QUICKJS_JS_PROXY_H
#define QUICKJS_JS_PROXY_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"

int js_proxy_isExtensible(JSContext *ctx, JSValueConst obj);
int js_proxy_preventExtensions(JSContext *ctx, JSValueConst obj);
int js_proxy_has(JSContext *ctx, JSValueConst obj, JSAtom atom);
JSValue js_proxy_get(JSContext *ctx, JSValueConst obj, JSAtom atom,
                            JSValueConst receiver);
int js_proxy_set(JSContext *ctx, JSValueConst obj, JSAtom atom,
                        JSValueConst value, JSValueConst receiver, int flags);
JSValue js_create_desc(JSContext *ctx, JSValueConst val,
                              JSValueConst getter, JSValueConst setter,
                              int flags);
int js_proxy_get_own_property(JSContext *ctx, JSPropertyDescriptor *pdesc,
                                     JSValueConst obj, JSAtom prop);
int js_proxy_define_own_property(JSContext *ctx, JSValueConst obj,
                                        JSAtom prop, JSValueConst val,
                                        JSValueConst getter, JSValueConst setter,
                                        int flags);
int js_proxy_delete_property(JSContext *ctx, JSValueConst obj,
                                    JSAtom atom);
/* return the index of the property or -1 if not found */
int find_prop_key(const JSPropertyEnum *tab, int n, JSAtom atom);
int js_proxy_get_own_property_names(JSContext *ctx,
                                           JSPropertyEnum **ptab,
                                           uint32_t *plen,
                                           JSValueConst obj);
JSValue js_proxy_call_constructor(JSContext *ctx, JSValueConst func_obj,
                                         JSValueConst new_target,
                                         int argc, JSValueConst *argv);
JSValue js_proxy_call(JSContext *ctx, JSValueConst func_obj,
                             JSValueConst this_obj,
                             int argc, JSValueConst *argv, int flags);
int js_proxy_isArray(JSContext *ctx, JSValueConst obj);
JSValue js_proxy_constructor(JSContext *ctx, JSValueConst this_val,
                                    int argc, JSValueConst *argv);
JSValue js_proxy_revoke(JSContext *ctx, JSValueConst this_val,
                               int argc, JSValueConst *argv, int magic,
                               JSValue *func_data);
JSValue js_proxy_revoke_constructor(JSContext *ctx,
                                           JSValueConst proxy_obj);
JSValue js_proxy_revocable(JSContext *ctx, JSValueConst this_val,
                                  int argc, JSValueConst *argv);


JSValue js_proxy_getPrototypeOf(JSContext *ctx, JSValueConst obj);
int js_proxy_setPrototypeOf(JSContext *ctx, JSValueConst obj,
                                   JSValueConst proto_val, BOOL throw_flag);

#endif