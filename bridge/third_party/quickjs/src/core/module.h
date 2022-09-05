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

#ifndef QUICKJS_MODULE_H
#define QUICKJS_MODULE_H

#include "quickjs/quickjs.h"
#include "types.h"

typedef struct JSResolveEntry {
  JSModuleDef *module;
  JSAtom name;
} JSResolveEntry;

typedef struct JSResolveState {
  JSResolveEntry *array;
  int size;
  int count;
} JSResolveState;

/* 'name' is freed */
JSModuleDef *js_new_module_def(JSContext *ctx, JSAtom name);

void js_mark_module_def(JSRuntime *rt, JSModuleDef *m,
                               JS_MarkFunc *mark_func);

int add_req_module_entry(JSContext *ctx, JSModuleDef *m,
                                JSAtom module_name);

JSExportEntry *find_export_entry(JSContext *ctx, JSModuleDef *m,
                                        JSAtom export_name);

char *js_default_module_normalize_name(JSContext *ctx,
                                              const char *base_name,
                                              const char *name);

JSModuleDef *js_find_loaded_module(JSContext *ctx, JSAtom name);

/* return NULL in case of exception (e.g. module could not be loaded) */
JSModuleDef *js_host_resolve_imported_module(JSContext *ctx,
                                                    const char *base_cname,
                                                    const char *cname1);

JSModuleDef *js_host_resolve_imported_module_atom(JSContext *ctx,
                                                         JSAtom base_module_name,
                                                         JSAtom module_name1);

int js_create_module_function(JSContext *ctx, JSModuleDef *m);

/* Load all the required modules for module 'm' */
int js_resolve_module(JSContext *ctx, JSModuleDef *m);

/* Prepare a module to be executed by resolving all the imported
   variables. */
int js_link_module(JSContext *ctx, JSModuleDef *m);

/* Run the <eval> function of the module and of all its requested
   modules. */
JSValue js_evaluate_module(JSContext *ctx, JSModuleDef *m);

JSValue js_dynamic_import(JSContext *ctx, JSValueConst specifier);

#endif