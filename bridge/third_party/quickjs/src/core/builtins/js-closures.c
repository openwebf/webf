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

#include "js-closures.h"
#include "../gc.h"
#include "../object.h"
#include "js-function.h"
#include "quickjs/list.h"

JSVarRef *get_var_ref(JSContext *ctx, JSStackFrame *sf,
                             int var_idx, BOOL is_arg)
{
  JSVarRef *var_ref;
  struct list_head *el;

  list_for_each(el, &sf->var_ref_list) {
    var_ref = list_entry(el, JSVarRef, header.link);
    if (var_ref->var_idx == var_idx && var_ref->is_arg == is_arg) {
      var_ref->header.ref_count++;
      return var_ref;
    }
  }
  /* create a new one */
  var_ref = js_malloc(ctx, sizeof(JSVarRef));
  if (!var_ref)
    return NULL;
  var_ref->header.ref_count = 1;
  var_ref->is_detached = FALSE;
  var_ref->is_arg = is_arg;
  var_ref->var_idx = var_idx;
  list_add_tail(&var_ref->header.link, &sf->var_ref_list);
  if (is_arg)
    var_ref->pvalue = &sf->arg_buf[var_idx];
  else
    var_ref->pvalue = &sf->var_buf[var_idx];
  var_ref->value = JS_UNDEFINED;
  return var_ref;
}

JSValue js_closure2(JSContext *ctx, JSValue func_obj,
                           JSFunctionBytecode *b,
                           JSVarRef **cur_var_refs,
                           JSStackFrame *sf)
{
  JSObject *p;
  JSVarRef **var_refs;
  int i;

  p = JS_VALUE_GET_OBJ(func_obj);
  p->u.func.function_bytecode = b;
  p->u.func.home_object = NULL;
  p->u.func.var_refs = NULL;
  if (b->closure_var_count) {
    var_refs = js_mallocz(ctx, sizeof(var_refs[0]) * b->closure_var_count);
    if (!var_refs)
      goto fail;
    p->u.func.var_refs = var_refs;
    for(i = 0; i < b->closure_var_count; i++) {
      JSClosureVar *cv = &b->closure_var[i];
      JSVarRef *var_ref;
      if (cv->is_local) {
        /* reuse the existing variable reference if it already exists */
        var_ref = get_var_ref(ctx, sf, cv->var_idx, cv->is_arg);
        if (!var_ref)
          goto fail;
      } else {
        var_ref = cur_var_refs[cv->var_idx];
        var_ref->header.ref_count++;
      }
      var_refs[i] = var_ref;
    }
  }
  return func_obj;
fail:
  /* bfunc is freed when func_obj is freed */
  JS_FreeValue(ctx, func_obj);
  return JS_EXCEPTION;
}


JSValue js_closure(JSContext *ctx, JSValue bfunc,
                          JSVarRef **cur_var_refs,
                          JSStackFrame *sf)
{
  JSFunctionBytecode *b;
  JSValue func_obj;
  JSAtom name_atom;

  b = JS_VALUE_GET_PTR(bfunc);
  func_obj = JS_NewObjectClass(ctx, func_kind_to_class_id[b->func_kind]);
  if (JS_IsException(func_obj)) {
    JS_FreeValue(ctx, bfunc);
    return JS_EXCEPTION;
  }
  func_obj = js_closure2(ctx, func_obj, b, cur_var_refs, sf);
  if (JS_IsException(func_obj)) {
    /* bfunc has been freed */
    goto fail;
  }
  name_atom = b->func_name;
  if (name_atom == JS_ATOM_NULL)
    name_atom = JS_ATOM_empty_string;
  js_function_set_properties(ctx, func_obj, name_atom,
                             b->defined_arg_count);

  if (b->func_kind & JS_FUNC_GENERATOR) {
    JSValue proto;
    int proto_class_id;
    /* generators have a prototype field which is used as
       prototype for the generator object */
    if (b->func_kind == JS_FUNC_ASYNC_GENERATOR)
      proto_class_id = JS_CLASS_ASYNC_GENERATOR;
    else
      proto_class_id = JS_CLASS_GENERATOR;
    proto = JS_NewObjectProto(ctx, ctx->class_proto[proto_class_id]);
    if (JS_IsException(proto))
      goto fail;
    JS_DefinePropertyValue(ctx, func_obj, JS_ATOM_prototype, proto,
                           JS_PROP_WRITABLE);
  } else if (b->has_prototype) {
    /* add the 'prototype' property: delay instantiation to avoid
       creating cycles for every javascript function. The prototype
       object is created on the fly when first accessed */
    JS_SetConstructorBit(ctx, func_obj, TRUE);
    JS_DefineAutoInitProperty(ctx, func_obj, JS_ATOM_prototype,
                              JS_AUTOINIT_ID_PROTOTYPE, NULL,
                              JS_PROP_WRITABLE);
  }
  return func_obj;
fail:
  /* bfunc is freed when func_obj is freed */
  JS_FreeValue(ctx, func_obj);
  return JS_EXCEPTION;
}

void close_lexical_var(JSContext *ctx, JSStackFrame *sf, int idx, int is_arg)
{
  struct list_head *el, *el1;
  JSVarRef *var_ref;
  int var_idx = idx;

  list_for_each_safe(el, el1, &sf->var_ref_list) {
    var_ref = list_entry(el, JSVarRef, header.link);
    if (var_idx == var_ref->var_idx && var_ref->is_arg == is_arg) {
      var_ref->value = JS_DupValue(ctx, sf->var_buf[var_idx]);
      var_ref->pvalue = &var_ref->value;
      list_del(&var_ref->header.link);
      /* the reference is no longer to a local variable */
      var_ref->is_detached = TRUE;
      add_gc_object(ctx->rt, &var_ref->header, JS_GC_OBJ_TYPE_VAR_REF);
    }
  }
}


void close_var_refs(JSRuntime* rt, JSStackFrame* sf) {
  struct list_head *el, *el1;
  JSVarRef* var_ref;
  int var_idx;

  list_for_each_safe(el, el1, &sf->var_ref_list) {
    var_ref = list_entry(el, JSVarRef, header.link);
    var_idx = var_ref->var_idx;
    if (var_ref->is_arg)
      var_ref->value = JS_DupValueRT(rt, sf->arg_buf[var_idx]);
    else
      var_ref->value = JS_DupValueRT(rt, sf->var_buf[var_idx]);
    var_ref->pvalue = &var_ref->value;
    /* the reference is no longer to a local variable */
    var_ref->is_detached = TRUE;
    add_gc_object(rt, &var_ref->header, JS_GC_OBJ_TYPE_VAR_REF);
  }
}