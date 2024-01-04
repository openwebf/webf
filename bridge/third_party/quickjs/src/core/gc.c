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

#include "gc.h"
#include "builtins/js-async-function.h"
#include "builtins/js-map.h"
#include "builtins/js-proxy.h"
#include "bytecode.h"
#include "malloc.h"
#include "module.h"
#include "object.h"
#include "parser.h"
#include "runtime.h"
#include "shape.h"
#include "string.h"

__maybe_unused void JS_DumpObjectHeader(JSRuntime* rt) {
  printf("%14s %4s %4s %14s %10s %s\n", "ADDRESS", "REFS", "SHRF", "PROTO", "CLASS", "PROPS");
}

/* for debug only: dump an object without side effect */
__maybe_unused void JS_DumpObject(JSRuntime* rt, JSObject* p) {
  uint32_t i;
  char atom_buf[ATOM_GET_STR_BUF_SIZE];
  JSShape* sh;
  JSShapeProperty* prs;
  JSProperty* pr;
  BOOL is_first = TRUE;

  /* XXX: should encode atoms with special characters */
  sh = p->shape; /* the shape can be NULL while freeing an object */
  printf("%14p %4d ", (void*)p, p->header.ref_count);
  if (sh) {
    printf("%3d%c %14p ", sh->header.ref_count, " *"[sh->is_hashed], (void*)sh -> proto);
  } else {
    printf("%3s  %14s ", "-", "-");
  }
  printf("%10s ", JS_AtomGetStrRT(rt, atom_buf, sizeof(atom_buf), rt->class_array[p->class_id].class_name));
  if (p->is_exotic && p->fast_array) {
    printf("[ ");
    for (i = 0; i < p->u.array.count; i++) {
      if (i != 0)
        printf(", ");
      switch (p->class_id) {
        case JS_CLASS_ARRAY:
        case JS_CLASS_ARGUMENTS:
          JS_DumpValueShort(rt, p->u.array.u.values[i]);
          break;
        case JS_CLASS_UINT8C_ARRAY:
        case JS_CLASS_INT8_ARRAY:
        case JS_CLASS_UINT8_ARRAY:
        case JS_CLASS_INT16_ARRAY:
        case JS_CLASS_UINT16_ARRAY:
        case JS_CLASS_INT32_ARRAY:
        case JS_CLASS_UINT32_ARRAY:
#ifdef CONFIG_BIGNUM
        case JS_CLASS_BIG_INT64_ARRAY:
        case JS_CLASS_BIG_UINT64_ARRAY:
#endif
        case JS_CLASS_FLOAT32_ARRAY:
        case JS_CLASS_FLOAT64_ARRAY: {
          int size = 1 << typed_array_size_log2(p->class_id);
          const uint8_t* b = p->u.array.u.uint8_ptr + i * size;
          while (size-- > 0)
            printf("%02X", *b++);
        } break;
      }
    }
    printf(" ] ");
  }

  if (sh) {
    printf("{ ");
    for (i = 0, prs = get_shape_prop(sh); i < sh->prop_count; i++, prs++) {
      if (prs->atom != JS_ATOM_NULL) {
        pr = &p->prop[i];
        if (!is_first)
          printf(", ");
        printf("%s: ", JS_AtomGetStrRT(rt, atom_buf, sizeof(atom_buf), prs->atom));
        if ((prs->flags & JS_PROP_TMASK) == JS_PROP_GETSET) {
          printf("[getset %p %p]", (void*)pr->u.getset.getter, (void*)pr->u.getset.setter);
        } else if ((prs->flags & JS_PROP_TMASK) == JS_PROP_VARREF) {
          printf("[varref %p]", (void*)pr->u.var_ref);
        } else if ((prs->flags & JS_PROP_TMASK) == JS_PROP_AUTOINIT) {
          printf("[autoinit %p %d %p]", (void*)js_autoinit_get_realm(pr), js_autoinit_get_id(pr), (void*)pr->u.init.opaque);
        } else {
          JS_DumpValueShort(rt, pr->u.value);
        }
        is_first = FALSE;
      }
    }
    printf(" }");
  }

  if (js_class_has_bytecode(p->class_id)) {
    JSFunctionBytecode* b = p->u.func.function_bytecode;
    JSVarRef** var_refs;
    if (b->closure_var_count) {
      var_refs = p->u.func.var_refs;
      printf(" Closure:");
      for (i = 0; i < b->closure_var_count; i++) {
        printf(" ");
        JS_DumpValueShort(rt, var_refs[i]->value);
      }
      if (p->u.func.home_object) {
        printf(" HomeObject: ");
        JS_DumpValueShort(rt, JS_MKPTR(JS_TAG_OBJECT, p->u.func.home_object));
      }
    }
  }
  printf("\n");
}

__maybe_unused void JS_DumpGCObject(JSRuntime* rt, JSGCObjectHeader* p) {
  if (p->gc_obj_type == JS_GC_OBJ_TYPE_JS_OBJECT) {
    JS_DumpObject(rt, (JSObject*)p);
  } else {
    printf("%14p %4d ", (void*)p, p->ref_count);
    switch (p->gc_obj_type) {
      case JS_GC_OBJ_TYPE_FUNCTION_BYTECODE:
        printf("[function bytecode]");
        break;
      case JS_GC_OBJ_TYPE_SHAPE:
        printf("[shape]");
        break;
      case JS_GC_OBJ_TYPE_VAR_REF:
        printf("[var_ref]");
        break;
      case JS_GC_OBJ_TYPE_ASYNC_FUNCTION:
        printf("[async_function]");
        break;
      case JS_GC_OBJ_TYPE_JS_CONTEXT:
        printf("[js_context]");
        break;
      default:
        printf("[unknown %d]", p->gc_obj_type);
        break;
    }
    printf("\n");
  }
}

/* return -1 if exception (proxy case) or TRUE/FALSE */
int JS_IsArray(JSContext* ctx, JSValueConst val) {
  JSObject* p;
  if (JS_VALUE_GET_TAG(val) == JS_TAG_OBJECT) {
    p = JS_VALUE_GET_OBJ(val);
    if (unlikely(p->class_id == JS_CLASS_PROXY))
      return js_proxy_isArray(ctx, val);
    else
      return p->class_id == JS_CLASS_ARRAY;
  } else {
    return FALSE;
  }
}

__maybe_unused void JS_DumpValueShort(JSRuntime* rt, JSValueConst val) {
  uint32_t tag = JS_VALUE_GET_NORM_TAG(val);
  const char* str;

  switch (tag) {
    case JS_TAG_INT:
      printf("%d", JS_VALUE_GET_INT(val));
      break;
    case JS_TAG_BOOL:
      if (JS_VALUE_GET_BOOL(val))
        str = "true";
      else
        str = "false";
      goto print_str;
    case JS_TAG_NULL:
      str = "null";
      goto print_str;
    case JS_TAG_EXCEPTION:
      str = "exception";
      goto print_str;
    case JS_TAG_UNINITIALIZED:
      str = "uninitialized";
      goto print_str;
    case JS_TAG_UNDEFINED:
      str = "undefined";
    print_str:
      printf("%s", str);
      break;
    case JS_TAG_FLOAT64:
      printf("%.14g", JS_VALUE_GET_FLOAT64(val));
      break;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      char* str;
      str = bf_ftoa(NULL, &p->num, 10, 0, BF_RNDZ | BF_FTOA_FORMAT_FRAC);
      printf("%sn", str);
      bf_realloc(&rt->bf_ctx, str, 0);
    } break;
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* p = JS_VALUE_GET_PTR(val);
      char* str;
      str = bf_ftoa(NULL, &p->num, 16, BF_PREC_INF, BF_RNDZ | BF_FTOA_FORMAT_FREE | BF_FTOA_ADD_PREFIX);
      printf("%sl", str);
      bf_free(&rt->bf_ctx, str);
    } break;
    case JS_TAG_BIG_DECIMAL: {
      JSBigDecimal* p = JS_VALUE_GET_PTR(val);
      char* str;
      str = bfdec_ftoa(NULL, &p->num, BF_PREC_INF, BF_RNDZ | BF_FTOA_FORMAT_FREE);
      printf("%sm", str);
      bf_free(&rt->bf_ctx, str);
    } break;
#endif
    case JS_TAG_STRING: {
      JSString* p;
      p = JS_VALUE_GET_STRING(val);
      JS_DumpString(rt, p);
    } break;
    case JS_TAG_FUNCTION_BYTECODE: {
      JSFunctionBytecode* b = JS_VALUE_GET_PTR(val);
      char buf[ATOM_GET_STR_BUF_SIZE];
      printf("[bytecode %s]", JS_AtomGetStrRT(rt, buf, sizeof(buf), b->func_name));
    } break;
    case JS_TAG_OBJECT: {
      JSObject* p = JS_VALUE_GET_OBJ(val);
      JSAtom atom = rt->class_array[p->class_id].class_name;
      char atom_buf[ATOM_GET_STR_BUF_SIZE];
      printf("[%s %p]", JS_AtomGetStrRT(rt, atom_buf, sizeof(atom_buf), atom), (void*)p);
    } break;
    case JS_TAG_SYMBOL: {
      JSAtomStruct* p = JS_VALUE_GET_PTR(val);
      char atom_buf[ATOM_GET_STR_BUF_SIZE];
      printf("Symbol(%s)", JS_AtomGetStrRT(rt, atom_buf, sizeof(atom_buf), js_get_atom_index(rt, p)));
    } break;
    case JS_TAG_MODULE:
      printf("[module]");
      break;
    default:
      printf("[unknown tag %d]", tag);
      break;
  }
}

__maybe_unused void JS_DumpValue(JSContext* ctx, JSValueConst val) {
  JS_DumpValueShort(ctx->rt, val);
}

__maybe_unused void JS_PrintValue(JSContext* ctx, const char* str, JSValueConst val) {
  printf("%s=", str);
  JS_DumpValueShort(ctx->rt, val);
  printf("\n");
}

void js_object_list_init(JSObjectList* s) {
  memset(s, 0, sizeof(*s));
}

uint32_t js_object_list_get_hash(JSObject* p, uint32_t hash_size) {
  return ((uintptr_t)p * 3163) & (hash_size - 1);
}

int js_object_list_resize_hash(JSContext* ctx, JSObjectList* s, uint32_t new_hash_size) {
  JSObjectListEntry* e;
  uint32_t i, h, *new_hash_table;

  new_hash_table = js_malloc(ctx, sizeof(new_hash_table[0]) * new_hash_size);
  if (!new_hash_table)
    return -1;
  js_free(ctx, s->hash_table);
  s->hash_table = new_hash_table;
  s->hash_size = new_hash_size;

  for (i = 0; i < s->hash_size; i++) {
    s->hash_table[i] = -1;
  }
  for (i = 0; i < s->object_count; i++) {
    e = &s->object_tab[i];
    h = js_object_list_get_hash(e->obj, s->hash_size);
    e->hash_next = s->hash_table[h];
    s->hash_table[h] = i;
  }
  return 0;
}

/* the reference count of 'obj' is not modified. Return 0 if OK, -1 if
   memory error */
int js_object_list_add(JSContext* ctx, JSObjectList* s, JSObject* obj) {
  JSObjectListEntry* e;
  uint32_t h, new_hash_size;

  if (js_resize_array(ctx, (void*)&s->object_tab, sizeof(s->object_tab[0]), &s->object_size, s->object_count + 1))
    return -1;
  if (unlikely((s->object_count + 1) >= s->hash_size)) {
    new_hash_size = max_uint32(s->hash_size, 4);
    while (new_hash_size <= s->object_count)
      new_hash_size *= 2;
    if (js_object_list_resize_hash(ctx, s, new_hash_size))
      return -1;
  }
  e = &s->object_tab[s->object_count++];
  h = js_object_list_get_hash(obj, s->hash_size);
  e->obj = obj;
  e->hash_next = s->hash_table[h];
  s->hash_table[h] = s->object_count - 1;
  return 0;
}

/* return -1 if not present or the object index */
int js_object_list_find(JSContext* ctx, JSObjectList* s, JSObject* obj) {
  JSObjectListEntry* e;
  uint32_t h, p;

  /* must test empty size because there is no hash table */
  if (s->object_count == 0)
    return -1;
  h = js_object_list_get_hash(obj, s->hash_size);
  p = s->hash_table[h];
  while (p != -1) {
    e = &s->object_tab[p];
    if (e->obj == obj)
      return p;
    p = e->hash_next;
  }
  return -1;
}

void js_object_list_end(JSContext* ctx, JSObjectList* s) {
  js_free(ctx, s->object_tab);
  js_free(ctx, s->hash_table);
}

/* indicate that the object may be part of a function prototype cycle */
void set_cycle_flag(JSContext* ctx, JSValueConst obj) {}

void remove_gc_object(JSGCObjectHeader* h) {
  list_del(&h->link);
}

void free_var_ref(JSRuntime* rt, JSVarRef* var_ref) {
  if (var_ref) {
    assert(var_ref->header.ref_count > 0);
    if (--var_ref->header.ref_count == 0) {
      if (var_ref->is_detached) {
        JS_FreeValueRT(rt, var_ref->value);
        remove_gc_object(&var_ref->header);
      } else {
        list_del(&var_ref->header.link); /* still on the stack */
      }
      js_free_rt(rt, var_ref);
    }
  }
}

void free_object(JSRuntime* rt, JSObject* p) {
  int i;
  JSClassFinalizer* finalizer;
  JSShape* sh;
  JSShapeProperty* pr;

  p->free_mark = 1; /* used to tell the object is invalid when
                       freeing cycles */
  /* free all the fields */
  sh = p->shape;
  pr = get_shape_prop(sh);
  for (i = 0; i < sh->prop_count; i++) {
    free_property(rt, &p->prop[i], pr->flags);
    pr++;
  }
  js_free_rt(rt, p->prop);
  /* as an optimization we destroy the shape immediately without
     putting it in gc_zero_ref_count_list */
  js_free_shape(rt, sh);

  /* fail safe */
  p->shape = NULL;
  p->prop = NULL;

  if (unlikely(p->first_weak_ref)) {
    reset_weak_ref(rt, p);
  }

  finalizer = rt->class_array[p->class_id].finalizer;
  if (finalizer)
    (*finalizer)(rt, JS_MKPTR(JS_TAG_OBJECT, p));

  /* fail safe */
  p->class_id = 0;
  p->u.opaque = NULL;
  p->u.func.var_refs = NULL;
  p->u.func.home_object = NULL;

  remove_gc_object(&p->header);
  if (rt->gc_phase == JS_GC_PHASE_REMOVE_CYCLES && p->header.ref_count != 0) {
    list_add_tail(&p->header.link, &rt->gc_zero_ref_count_list);
  } else {
    js_free_rt(rt, p);
  }
}

void free_gc_object(JSRuntime* rt, JSGCObjectHeader* gp) {
  switch (gp->gc_obj_type) {
    case JS_GC_OBJ_TYPE_JS_OBJECT:
      free_object(rt, (JSObject*)gp);
      break;
    case JS_GC_OBJ_TYPE_FUNCTION_BYTECODE:
      free_function_bytecode(rt, (JSFunctionBytecode*)gp);
      break;
    default:
      abort();
  }
}

void free_zero_refcount(JSRuntime* rt) {
  struct list_head* el;
  JSGCObjectHeader* p;

  rt->gc_phase = JS_GC_PHASE_DECREF;
  for (;;) {
    el = rt->gc_zero_ref_count_list.next;
    if (el == &rt->gc_zero_ref_count_list)
      break;
    p = list_entry(el, JSGCObjectHeader, link);
    assert(p->ref_count == 0);
    free_gc_object(rt, p);
  }
  rt->gc_phase = JS_GC_PHASE_NONE;
}

/* called with the ref_count of 'v' reaches zero. */
void __JS_FreeValueRT(JSRuntime* rt, JSValue v) {
  uint32_t tag = JS_VALUE_GET_TAG(v);

#ifdef DUMP_FREE
  {
    printf("Freeing ");
    if (tag == JS_TAG_OBJECT) {
      JS_DumpObject(rt, JS_VALUE_GET_OBJ(v));
    } else {
      JS_DumpValueShort(rt, v);
      printf("\n");
    }
  }
#endif

  switch (tag) {
    case JS_TAG_STRING: {
      JSString* p = JS_VALUE_GET_STRING(v);
      if (p->atom_type) {
        JS_FreeAtomStruct(rt, p);
      } else {
#ifdef DUMP_LEAKS
        list_del(&p->link);
#endif
        js_free_rt(rt, p);
      }
    } break;
    case JS_TAG_OBJECT:
    case JS_TAG_FUNCTION_BYTECODE: {
      JSGCObjectHeader* p = JS_VALUE_GET_PTR(v);
      if (rt->gc_phase != JS_GC_PHASE_REMOVE_CYCLES) {
        list_del(&p->link);
        list_add(&p->link, &rt->gc_zero_ref_count_list);
        if (rt->gc_phase == JS_GC_PHASE_NONE) {
          free_zero_refcount(rt);
        }
      }
    } break;
    case JS_TAG_MODULE:
      abort(); /* never freed here */
      break;
#ifdef CONFIG_BIGNUM
    case JS_TAG_BIG_INT:
    case JS_TAG_BIG_FLOAT: {
      JSBigFloat* bf = JS_VALUE_GET_PTR(v);
      bf_delete(&bf->num);
      js_free_rt(rt, bf);
    } break;
    case JS_TAG_BIG_DECIMAL: {
      JSBigDecimal* bf = JS_VALUE_GET_PTR(v);
      bfdec_delete(&bf->num);
      js_free_rt(rt, bf);
    } break;
#endif
    case JS_TAG_SYMBOL: {
      JSAtomStruct* p = JS_VALUE_GET_PTR(v);
      JS_FreeAtomStruct(rt, p);
    } break;
    default:
      printf("__JS_FreeValue: unknown tag=%d\n", tag);
      abort();
  }
}

void __JS_FreeValue(JSContext* ctx, JSValue v) {
  __JS_FreeValueRT(ctx->rt, v);
}

/* garbage collection */

void add_gc_object(JSRuntime* rt, JSGCObjectHeader* h, JSGCObjectTypeEnum type) {
  h->mark = 0;
  h->gc_obj_type = type;
  list_add_tail(&h->link, &rt->gc_obj_list);
}

void JS_MarkValue(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) {
  if (JS_VALUE_HAS_REF_COUNT(val)) {
    switch (JS_VALUE_GET_TAG(val)) {
      case JS_TAG_OBJECT:
      case JS_TAG_FUNCTION_BYTECODE:
        mark_func(rt, JS_VALUE_GET_PTR(val));
        break;
      default:
        break;
    }
  }
}

/* XXX: would be more efficient with separate module lists */
void js_free_modules(JSContext* ctx, JSFreeModuleEnum flag) {
  struct list_head *el, *el1;
  list_for_each_safe(el, el1, &ctx->loaded_modules) {
    JSModuleDef* m = list_entry(el, JSModuleDef, link);
    if (flag == JS_FREE_MODULE_ALL || (flag == JS_FREE_MODULE_NOT_RESOLVED && !m->resolved) || (flag == JS_FREE_MODULE_NOT_EVALUATED && !m->evaluated)) {
      js_free_module_def(ctx, m);
    }
  }
}

JSContext* JS_DupContext(JSContext* ctx) {
  ctx->header.ref_count++;
  return ctx;
}

/* used by the GC */
void JS_MarkContext(JSRuntime* rt, JSContext* ctx, JS_MarkFunc* mark_func) {
  int i;
  struct list_head* el;

  /* modules are not seen by the GC, so we directly mark the objects
     referenced by each module */
  list_for_each(el, &ctx->loaded_modules) {
    JSModuleDef* m = list_entry(el, JSModuleDef, link);
    js_mark_module_def(rt, m, mark_func);
  }

  JS_MarkValue(rt, ctx->global_obj, mark_func);
  JS_MarkValue(rt, ctx->global_var_obj, mark_func);

  JS_MarkValue(rt, ctx->throw_type_error, mark_func);
  JS_MarkValue(rt, ctx->eval_obj, mark_func);

  JS_MarkValue(rt, ctx->array_proto_values, mark_func);
  for (i = 0; i < JS_NATIVE_ERROR_COUNT; i++) {
    JS_MarkValue(rt, ctx->native_error_proto[i], mark_func);
  }
  for (i = 0; i < rt->class_count; i++) {
    JS_MarkValue(rt, ctx->class_proto[i], mark_func);
  }
  JS_MarkValue(rt, ctx->iterator_proto, mark_func);
  JS_MarkValue(rt, ctx->async_iterator_proto, mark_func);
  JS_MarkValue(rt, ctx->promise_ctor, mark_func);
  JS_MarkValue(rt, ctx->array_ctor, mark_func);
  JS_MarkValue(rt, ctx->regexp_ctor, mark_func);
  JS_MarkValue(rt, ctx->function_ctor, mark_func);
  JS_MarkValue(rt, ctx->function_proto, mark_func);

  if (ctx->array_shape)
    mark_func(rt, &ctx->array_shape->header);
}

void mark_children(JSRuntime* rt, JSGCObjectHeader* gp, JS_MarkFunc* mark_func) {
  switch (gp->gc_obj_type) {
    case JS_GC_OBJ_TYPE_JS_OBJECT: {
      JSObject* p = (JSObject*)gp;
      JSShapeProperty* prs;
      JSShape* sh;
      int i;
      sh = p->shape;
      mark_func(rt, &sh->header);
      /* mark all the fields */
      prs = get_shape_prop(sh);
      for (i = 0; i < sh->prop_count; i++) {
        JSProperty* pr = &p->prop[i];
        if (prs->atom != JS_ATOM_NULL) {
          if (prs->flags & JS_PROP_TMASK) {
            if ((prs->flags & JS_PROP_TMASK) == JS_PROP_GETSET) {
              if (pr->u.getset.getter)
                mark_func(rt, &pr->u.getset.getter->header);
              if (pr->u.getset.setter)
                mark_func(rt, &pr->u.getset.setter->header);
            } else if ((prs->flags & JS_PROP_TMASK) == JS_PROP_VARREF) {
              if (pr->u.var_ref->is_detached) {
                /* Note: the tag does not matter
                   provided it is a GC object */
                mark_func(rt, &pr->u.var_ref->header);
              }
            } else if ((prs->flags & JS_PROP_TMASK) == JS_PROP_AUTOINIT) {
              js_autoinit_mark(rt, pr, mark_func);
            }
          } else {
            JS_MarkValue(rt, pr->u.value, mark_func);
          }
        }
        prs++;
      }

      if (p->class_id != JS_CLASS_OBJECT) {
        JSClassGCMark* gc_mark;
        gc_mark = rt->class_array[p->class_id].gc_mark;
        if (gc_mark)
          gc_mark(rt, JS_MKPTR(JS_TAG_OBJECT, p), mark_func);
      }
    } break;
    case JS_GC_OBJ_TYPE_FUNCTION_BYTECODE:
      /* the template objects can be part of a cycle */
      {
        int i, j;
        InlineCacheRingItem *buffer;
        JSFunctionBytecode* b = (JSFunctionBytecode*)gp;
        for (i = 0; i < b->cpool_count; i++) {
          JS_MarkValue(rt, b->cpool[i], mark_func);
        }
        if (b->realm)
          mark_func(rt, &b->realm->header);
        if (b->ic) {
          for (i = 0; i < b->ic->count; i++) {
            buffer = b->ic->cache[i].buffer;
            for (j = 0; j < IC_CACHE_ITEM_CAPACITY; j++) {
              if (buffer[j].shape)
                mark_func(rt, &buffer[j].shape->header);
              if (buffer[j].proto)
                mark_func(rt, &buffer[j].proto->header);
            }
          }
        }
      }
      break;
    case JS_GC_OBJ_TYPE_VAR_REF: {
      JSVarRef* var_ref = (JSVarRef*)gp;
      /* only detached variable referenced are taken into account */
      assert(var_ref->is_detached);
      JS_MarkValue(rt, *var_ref->pvalue, mark_func);
    } break;
    case JS_GC_OBJ_TYPE_ASYNC_FUNCTION: {
      JSAsyncFunctionData* s = (JSAsyncFunctionData*)gp;
      if (s->is_active)
        async_func_mark(rt, &s->func_state, mark_func);
      JS_MarkValue(rt, s->resolving_funcs[0], mark_func);
      JS_MarkValue(rt, s->resolving_funcs[1], mark_func);
    } break;
    case JS_GC_OBJ_TYPE_SHAPE: {
      JSShape* sh = (JSShape*)gp;
      if (sh->proto != NULL) {
        mark_func(rt, &sh->proto->header);
      }
    } break;
    case JS_GC_OBJ_TYPE_JS_CONTEXT: {
      JSContext* ctx = (JSContext*)gp;
      JS_MarkContext(rt, ctx, mark_func);
    } break;
    default:
      abort();
  }
}

void gc_decref_child(JSRuntime* rt, JSGCObjectHeader* p) {
  assert(p->ref_count > 0);
  p->ref_count--;
  if (p->ref_count == 0 && p->mark == 1) {
    list_del(&p->link);
    list_add_tail(&p->link, &rt->tmp_obj_list);
  }
}

void gc_decref(JSRuntime* rt) {
  struct list_head *el, *el1;
  JSGCObjectHeader* p;

  init_list_head(&rt->tmp_obj_list);

  /* decrement the refcount of all the children of all the GC
     objects and move the GC objects with zero refcount to
     tmp_obj_list */
  list_for_each_safe(el, el1, &rt->gc_obj_list) {
    p = list_entry(el, JSGCObjectHeader, link);
    assert(p->mark == 0);
    mark_children(rt, p, gc_decref_child);
    p->mark = 1;
    if (p->ref_count == 0) {
      list_del(&p->link);
      list_add_tail(&p->link, &rt->tmp_obj_list);
    }
  }
}

void gc_scan_incref_child(JSRuntime* rt, JSGCObjectHeader* p) {
  p->ref_count++;
  if (p->ref_count == 1) {
    /* ref_count was 0: remove from tmp_obj_list and add at the
       end of gc_obj_list */
    list_del(&p->link);
    list_add_tail(&p->link, &rt->gc_obj_list);
    p->mark = 0; /* reset the mark for the next GC call */
  }
}

void gc_scan_incref_child2(JSRuntime* rt, JSGCObjectHeader* p) {
  p->ref_count++;
}

void gc_scan(JSRuntime* rt) {
  struct list_head* el;
  JSGCObjectHeader* p;

  /* keep the objects with a refcount > 0 and their children. */
  list_for_each(el, &rt->gc_obj_list) {
    p = list_entry(el, JSGCObjectHeader, link);
    assert(p->ref_count > 0);
    p->mark = 0; /* reset the mark for the next GC call */
    mark_children(rt, p, gc_scan_incref_child);
  }

  /* restore the refcount of the objects to be deleted. */
  list_for_each(el, &rt->tmp_obj_list) {
    p = list_entry(el, JSGCObjectHeader, link);
    mark_children(rt, p, gc_scan_incref_child2);
  }
}

void gc_free_cycles(JSRuntime* rt) {
  struct list_head *el, *el1;
  JSGCObjectHeader* p;
#ifdef DUMP_GC_FREE
  BOOL header_done = FALSE;
#endif

  rt->gc_phase = JS_GC_PHASE_REMOVE_CYCLES;

  for (;;) {
    el = rt->tmp_obj_list.next;
    if (el == &rt->tmp_obj_list)
      break;
    p = list_entry(el, JSGCObjectHeader, link);
    /* Only need to free the GC object associated with JS
       values. The rest will be automatically removed because they
       must be referenced by them. */
    switch (p->gc_obj_type) {
      case JS_GC_OBJ_TYPE_JS_OBJECT:
      case JS_GC_OBJ_TYPE_FUNCTION_BYTECODE:
#ifdef DUMP_GC_FREE
        if (!header_done) {
          printf("Freeing cycles:\n");
          JS_DumpObjectHeader(rt);
          header_done = TRUE;
        }
        JS_DumpGCObject(rt, p);
#endif
        free_gc_object(rt, p);
        break;
      default:
        list_del(&p->link);
        list_add_tail(&p->link, &rt->gc_zero_ref_count_list);
        break;
    }
  }
  rt->gc_phase = JS_GC_PHASE_NONE;

  list_for_each_safe(el, el1, &rt->gc_zero_ref_count_list) {
    p = list_entry(el, JSGCObjectHeader, link);
    assert(p->gc_obj_type == JS_GC_OBJ_TYPE_JS_OBJECT || p->gc_obj_type == JS_GC_OBJ_TYPE_FUNCTION_BYTECODE);
    js_free_rt(rt, p);
  }

  init_list_head(&rt->gc_zero_ref_count_list);
}

void JS_RunGC(JSRuntime* rt) {
  /* decrement the reference of the children of each object. mark =
     1 after this pass. */
  gc_decref(rt);

  /* keep the GC objects with a non zero refcount and their childs */
  gc_scan(rt);

  /* free the GC objects in a cycle */
  gc_free_cycles(rt);
}

/* Return false if not an object or if the object has already been
   freed (zombie objects are visible in finalizers when freeing
   cycles). */
BOOL JS_IsLiveObject(JSRuntime* rt, JSValueConst obj) {
  JSObject* p;
  if (!JS_IsObject(obj))
    return FALSE;
  p = JS_VALUE_GET_OBJ(obj);
  return !p->free_mark;
}