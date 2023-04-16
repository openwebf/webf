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

#include "shape.h"
#include "gc.h"
#include "malloc.h"
#include "object.h"
#include "string.h"

/* Shape support */


int init_shape_hash(JSRuntime* rt) {
  rt->shape_hash_bits = 4; /* 16 shapes */
  rt->shape_hash_size = 1 << rt->shape_hash_bits;
  rt->shape_hash_count = 0;
  rt->shape_hash = js_mallocz_rt(rt, sizeof(rt->shape_hash[0]) * rt->shape_hash_size);
  if (!rt->shape_hash)
    return -1;
  return 0;
}

/* same magic hash multiplier as the Linux kernel */
uint32_t shape_hash(uint32_t h, uint32_t val) {
  return (h + val) * 0x9e370001;
}

/* truncate the shape hash to 'hash_bits' bits */
uint32_t get_shape_hash(uint32_t h, int hash_bits) {
  return h >> (32 - hash_bits);
}

uint32_t shape_initial_hash(JSObject* proto) {
  uint32_t h;
  h = shape_hash(1, (uintptr_t)proto);
  if (sizeof(proto) > 4)
    h = shape_hash(h, (uint64_t)(uintptr_t)proto >> 32);
  return h;
}

int resize_shape_hash(JSRuntime* rt, int new_shape_hash_bits) {
  int new_shape_hash_size, i;
  uint32_t h;
  JSShape **new_shape_hash, *sh, *sh_next;

  new_shape_hash_size = 1 << new_shape_hash_bits;
  new_shape_hash = js_mallocz_rt(rt, sizeof(rt->shape_hash[0]) * new_shape_hash_size);
  if (!new_shape_hash)
    return -1;
  for (i = 0; i < rt->shape_hash_size; i++) {
    for (sh = rt->shape_hash[i]; sh != NULL; sh = sh_next) {
      sh_next = sh->shape_hash_next;
      h = get_shape_hash(sh->hash, new_shape_hash_bits);
      sh->shape_hash_next = new_shape_hash[h];
      new_shape_hash[h] = sh;
    }
  }
  js_free_rt(rt, rt->shape_hash);
  rt->shape_hash_bits = new_shape_hash_bits;
  rt->shape_hash_size = new_shape_hash_size;
  rt->shape_hash = new_shape_hash;
  return 0;
}

void js_shape_hash_link(JSRuntime* rt, JSShape* sh) {
  uint32_t h;
  h = get_shape_hash(sh->hash, rt->shape_hash_bits);
  sh->shape_hash_next = rt->shape_hash[h];
  rt->shape_hash[h] = sh;
  rt->shape_hash_count++;
}

void js_shape_hash_unlink(JSRuntime* rt, JSShape* sh) {
  uint32_t h;
  JSShape** psh;

  h = get_shape_hash(sh->hash, rt->shape_hash_bits);
  psh = &rt->shape_hash[h];
  while (*psh != sh)
    psh = &(*psh)->shape_hash_next;
  *psh = sh->shape_hash_next;
  rt->shape_hash_count--;
}

/* create a new empty shape with prototype 'proto' */
no_inline JSShape* js_new_shape2(JSContext* ctx, JSObject* proto, int hash_size, int prop_size) {
  JSRuntime* rt = ctx->rt;
  void* sh_alloc;
  JSShape* sh;

  /* resize the shape hash table if necessary */
  if (2 * (rt->shape_hash_count + 1) > rt->shape_hash_size) {
    resize_shape_hash(rt, rt->shape_hash_bits + 1);
  }

  sh_alloc = js_malloc(ctx, get_shape_size(hash_size, prop_size));
  if (!sh_alloc)
    return NULL;
  sh = get_shape_from_alloc(sh_alloc, hash_size);
  sh->header.ref_count = 1;
  add_gc_object(rt, &sh->header, JS_GC_OBJ_TYPE_SHAPE);
  if (proto)
    JS_DupValue(ctx, JS_MKPTR(JS_TAG_OBJECT, proto));
  sh->proto = proto;
  memset(prop_hash_end(sh) - hash_size, 0, sizeof(prop_hash_end(sh)[0]) * hash_size);
  sh->prop_hash_mask = hash_size - 1;
  sh->prop_size = prop_size;
  sh->prop_count = 0;
  sh->deleted_prop_count = 0;

  /* insert in the hash table */
  sh->hash = shape_initial_hash(proto);
  sh->is_hashed = TRUE;
  sh->has_small_array_index = FALSE;
  js_shape_hash_link(ctx->rt, sh);
  return sh;
}

JSShape* js_new_shape(JSContext* ctx, JSObject* proto) {
  return js_new_shape2(ctx, proto, JS_PROP_INITIAL_HASH_SIZE, JS_PROP_INITIAL_SIZE);
}

/* The shape is cloned. The new shape is not inserted in the shape
   hash table */
JSShape* js_clone_shape(JSContext* ctx, JSShape* sh1) {
  JSShape* sh;
  void *sh_alloc, *sh_alloc1;
  size_t size;
  JSShapeProperty* pr;
  uint32_t i, hash_size;

  hash_size = sh1->prop_hash_mask + 1;
  size = get_shape_size(hash_size, sh1->prop_size);
  sh_alloc = js_malloc(ctx, size);
  if (!sh_alloc)
    return NULL;
  sh_alloc1 = get_alloc_from_shape(sh1);
  memcpy(sh_alloc, sh_alloc1, size);
  sh = get_shape_from_alloc(sh_alloc, hash_size);
  sh->header.ref_count = 1;
  add_gc_object(ctx->rt, &sh->header, JS_GC_OBJ_TYPE_SHAPE);
  sh->is_hashed = FALSE;
  if (sh->proto) {
    JS_DupValue(ctx, JS_MKPTR(JS_TAG_OBJECT, sh->proto));
  }
  for (i = 0, pr = get_shape_prop(sh); i < sh->prop_count; i++, pr++) {
    JS_DupAtom(ctx, pr->atom);
  }
  return sh;
}

JSShape* js_dup_shape(JSShape* sh) {
  sh->header.ref_count++;
  return sh;
}

void js_free_shape0(JSRuntime* rt, JSShape* sh) {
  uint32_t i;
  JSShapeProperty* pr;

  assert(sh->header.ref_count == 0);
  if (sh->is_hashed)
    js_shape_hash_unlink(rt, sh);
  if (sh->proto != NULL) {
    JS_FreeValueRT(rt, JS_MKPTR(JS_TAG_OBJECT, sh->proto));
  }
  pr = get_shape_prop(sh);
  for (i = 0; i < sh->prop_count; i++) {
    JS_FreeAtomRT(rt, pr->atom);
    pr++;
  }
  remove_gc_object(&sh->header);
  js_free_rt(rt, get_alloc_from_shape(sh));
}

void js_free_shape(JSRuntime* rt, JSShape* sh) {
  if (unlikely(--sh->header.ref_count <= 0)) {
    js_free_shape0(rt, sh);
  }
}

void js_free_shape_null(JSRuntime* rt, JSShape* sh) {
  if (sh)
    js_free_shape(rt, sh);
}

/* make space to hold at least 'count' properties */
no_inline int resize_properties(JSContext* ctx, JSShape** psh, JSObject* p, uint32_t count) {
  JSShape* sh;
  uint32_t new_size, new_hash_size, new_hash_mask, i;
  JSShapeProperty* pr;
  void* sh_alloc;
  intptr_t h;

  sh = *psh;
  new_size = max_int(count, sh->prop_size * 9 / 2);
  /* Reallocate prop array first to avoid crash or size inconsistency
     in case of memory allocation failure */
  if (p) {
    JSProperty* new_prop;
    new_prop = js_realloc(ctx, p->prop, sizeof(new_prop[0]) * new_size);
    if (unlikely(!new_prop))
      return -1;
    p->prop = new_prop;
  }
  new_hash_size = sh->prop_hash_mask + 1;
  while (new_hash_size < new_size)
    new_hash_size = 2 * new_hash_size;
  if (new_hash_size != (sh->prop_hash_mask + 1)) {
    JSShape* old_sh;
    /* resize the hash table and the properties */
    old_sh = sh;
    sh_alloc = js_malloc(ctx, get_shape_size(new_hash_size, new_size));
    if (!sh_alloc)
      return -1;
    sh = get_shape_from_alloc(sh_alloc, new_hash_size);
    list_del(&old_sh->header.link);
    /* copy all the fields and the properties */
    memcpy(sh, old_sh, sizeof(JSShape) + sizeof(sh->prop[0]) * old_sh->prop_count);
    list_add_tail(&sh->header.link, &ctx->rt->gc_obj_list);
    new_hash_mask = new_hash_size - 1;
    sh->prop_hash_mask = new_hash_mask;
    memset(prop_hash_end(sh) - new_hash_size, 0, sizeof(prop_hash_end(sh)[0]) * new_hash_size);
    for (i = 0, pr = sh->prop; i < sh->prop_count; i++, pr++) {
      if (pr->atom != JS_ATOM_NULL) {
        h = ((uintptr_t)pr->atom & new_hash_mask);
        pr->hash_next = prop_hash_end(sh)[-h - 1];
        prop_hash_end(sh)[-h - 1] = i + 1;
      }
    }
    js_free(ctx, get_alloc_from_shape(old_sh));
  } else {
    /* only resize the properties */
    list_del(&sh->header.link);
    sh_alloc = js_realloc(ctx, get_alloc_from_shape(sh), get_shape_size(new_hash_size, new_size));
    if (unlikely(!sh_alloc)) {
      /* insert again in the GC list */
      list_add_tail(&sh->header.link, &ctx->rt->gc_obj_list);
      return -1;
    }
    sh = get_shape_from_alloc(sh_alloc, new_hash_size);
    list_add_tail(&sh->header.link, &ctx->rt->gc_obj_list);
  }
  *psh = sh;
  sh->prop_size = new_size;
  return 0;
}

/* remove the deleted properties. */
int compact_properties(JSContext* ctx, JSObject* p) {
  JSShape *sh, *old_sh;
  void* sh_alloc;
  intptr_t h;
  uint32_t new_hash_size, i, j, new_hash_mask, new_size;
  JSShapeProperty *old_pr, *pr;
  JSProperty *prop, *new_prop;

  sh = p->shape;
  assert(!sh->is_hashed);

  new_size = max_int(JS_PROP_INITIAL_SIZE, sh->prop_count - sh->deleted_prop_count);
  assert(new_size <= sh->prop_size);

  new_hash_size = sh->prop_hash_mask + 1;
  while ((new_hash_size / 2) >= new_size)
    new_hash_size = new_hash_size / 2;
  new_hash_mask = new_hash_size - 1;

  /* resize the hash table and the properties */
  old_sh = sh;
  sh_alloc = js_malloc(ctx, get_shape_size(new_hash_size, new_size));
  if (!sh_alloc)
    return -1;
  sh = get_shape_from_alloc(sh_alloc, new_hash_size);
  list_del(&old_sh->header.link);
  memcpy(sh, old_sh, sizeof(JSShape));
  list_add_tail(&sh->header.link, &ctx->rt->gc_obj_list);

  memset(prop_hash_end(sh) - new_hash_size, 0, sizeof(prop_hash_end(sh)[0]) * new_hash_size);

  j = 0;
  old_pr = old_sh->prop;
  pr = sh->prop;
  prop = p->prop;
  for (i = 0; i < sh->prop_count; i++) {
    if (old_pr->atom != JS_ATOM_NULL) {
      pr->atom = old_pr->atom;
      pr->flags = old_pr->flags;
      h = ((uintptr_t)old_pr->atom & new_hash_mask);
      pr->hash_next = prop_hash_end(sh)[-h - 1];
      prop_hash_end(sh)[-h - 1] = j + 1;
      prop[j] = prop[i];
      j++;
      pr++;
    }
    old_pr++;
  }
  assert(j == (sh->prop_count - sh->deleted_prop_count));
  sh->prop_hash_mask = new_hash_mask;
  sh->prop_size = new_size;
  sh->deleted_prop_count = 0;
  sh->prop_count = j;

  p->shape = sh;
  js_free(ctx, get_alloc_from_shape(old_sh));

  /* reduce the size of the object properties */
  new_prop = js_realloc(ctx, p->prop, sizeof(new_prop[0]) * new_size);
  if (new_prop)
    p->prop = new_prop;
  return 0;
}

int add_shape_property(JSContext* ctx, JSShape** psh, JSObject* p, JSAtom atom, int prop_flags) {
  JSRuntime* rt = ctx->rt;
  JSShape* sh = *psh;
  JSShapeProperty *pr, *prop;
  uint32_t hash_mask, new_shape_hash = 0;
  intptr_t h;

  /* update the shape hash */
  if (sh->is_hashed) {
    js_shape_hash_unlink(rt, sh);
    new_shape_hash = shape_hash(shape_hash(sh->hash, atom), prop_flags);
  }

  if (unlikely(sh->prop_count >= sh->prop_size)) {
    if (resize_properties(ctx, psh, p, sh->prop_count + 1)) {
      /* in case of error, reinsert in the hash table.
         sh is still valid if resize_properties() failed */
      if (sh->is_hashed)
        js_shape_hash_link(rt, sh);
      return -1;
    }
    sh = *psh;
  }
  if (sh->is_hashed) {
    sh->hash = new_shape_hash;
    js_shape_hash_link(rt, sh);
  }
  /* Initialize the new shape property.
     The object property at p->prop[sh->prop_count] is uninitialized */
  prop = get_shape_prop(sh);
  pr = &prop[sh->prop_count++];
  pr->atom = JS_DupAtom(ctx, atom);
  pr->flags = prop_flags;
  sh->has_small_array_index |= __JS_AtomIsTaggedInt(atom);
  /* add in hash table */
  hash_mask = sh->prop_hash_mask;
  h = atom & hash_mask;
  pr->hash_next = prop_hash_end(sh)[-h - 1];
  prop_hash_end(sh)[-h - 1] = sh->prop_count;
  return 0;
}

/* find a hashed empty shape matching the prototype. Return NULL if
   not found */
JSShape* find_hashed_shape_proto(JSRuntime* rt, JSObject* proto) {
  JSShape* sh1;
  uint32_t h, h1;

  h = shape_initial_hash(proto);
  h1 = get_shape_hash(h, rt->shape_hash_bits);
  for (sh1 = rt->shape_hash[h1]; sh1 != NULL; sh1 = sh1->shape_hash_next) {
    if (sh1->hash == h && sh1->proto == proto && sh1->prop_count == 0) {
      return sh1;
    }
  }
  return NULL;
}

/* find a hashed shape matching sh + (prop, prop_flags). Return NULL if
   not found */
JSShape* find_hashed_shape_prop(JSRuntime* rt, JSShape* sh, JSAtom atom, int prop_flags) {
  JSShape* sh1;
  uint32_t h, h1, i, n;

  h = sh->hash;
  h = shape_hash(h, atom);
  h = shape_hash(h, prop_flags);
  h1 = get_shape_hash(h, rt->shape_hash_bits);
  for (sh1 = rt->shape_hash[h1]; sh1 != NULL; sh1 = sh1->shape_hash_next) {
    /* we test the hash first so that the rest is done only if the
       shapes really match */
    if (sh1->hash == h && sh1->proto == sh->proto && sh1->prop_count == ((n = sh->prop_count) + 1)) {
      for (i = 0; i < n; i++) {
        if (unlikely(sh1->prop[i].atom != sh->prop[i].atom) || unlikely(sh1->prop[i].flags != sh->prop[i].flags))
          goto next;
      }
      if (unlikely(sh1->prop[n].atom != atom) || unlikely(sh1->prop[n].flags != prop_flags))
        goto next;
      return sh1;
    }
  next:;
  }
  return NULL;
}

__maybe_unused void JS_DumpShape(JSRuntime* rt, int i, JSShape* sh) {
  char atom_buf[ATOM_GET_STR_BUF_SIZE];
  int j;

  /* XXX: should output readable class prototype */
  printf("%5d %3d%c %14p %5d %5d", i, sh->header.ref_count, " *"[sh->is_hashed], (void*)sh -> proto, sh -> prop_size,
         sh -> prop_count);
  for (j = 0; j < sh->prop_count; j++) {
    printf(" %s", JS_AtomGetStrRT(rt, atom_buf, sizeof(atom_buf), sh->prop[j].atom));
  }
  printf("\n");
}

__maybe_unused void JS_DumpShapes(JSRuntime* rt) {
  int i;
  JSShape* sh;
  struct list_head* el;
  JSObject* p;
  JSGCObjectHeader* gp;

  printf("JSShapes: {\n");
  printf("%5s %4s %14s %5s %5s %s\n", "SLOT", "REFS", "PROTO", "SIZE", "COUNT", "PROPS");
  for (i = 0; i < rt->shape_hash_size; i++) {
    for (sh = rt->shape_hash[i]; sh != NULL; sh = sh->shape_hash_next) {
      JS_DumpShape(rt, i, sh);
      assert(sh->is_hashed);
    }
  }
  /* dump non-hashed shapes */
  list_for_each(el, &rt->gc_obj_list) {
    gp = list_entry(el, JSGCObjectHeader, link);
    if (gp->gc_obj_type == JS_GC_OBJ_TYPE_JS_OBJECT) {
      p = (JSObject*)gp;
      if (!p->shape->is_hashed) {
        JS_DumpShape(rt, -1, p->shape);
      }
    }
  }
  printf("}\n");
}

JSValue JS_NewObjectFromShape(JSContext* ctx, JSShape* sh, JSClassID class_id) {
  JSObject* p;

  js_trigger_gc(ctx->rt, sizeof(JSObject));
  p = js_malloc(ctx, sizeof(JSObject));
  if (unlikely(!p))
    goto fail;
  p->class_id = class_id;
  p->extensible = TRUE;
  p->free_mark = 0;
  p->is_exotic = 0;
  p->fast_array = 0;
  p->is_constructor = 0;
  p->is_uncatchable_error = 0;
  p->tmp_mark = 0;
  p->is_HTMLDDA = 0;
  p->first_weak_ref = NULL;
  p->u.opaque = NULL;
  p->shape = sh;
  p->prop = js_malloc(ctx, sizeof(JSProperty) * sh->prop_size);
  if (unlikely(!p->prop)) {
    js_free(ctx, p);
  fail:
    js_free_shape(ctx->rt, sh);
    return JS_EXCEPTION;
  }

  switch (class_id) {
    case JS_CLASS_OBJECT:
      break;
    case JS_CLASS_ARRAY: {
      JSProperty* pr;
      p->is_exotic = 1;
      p->fast_array = 1;
      p->u.array.u.values = NULL;
      p->u.array.count = 0;
      p->u.array.u1.size = 0;
      /* the length property is always the first one */
      if (likely(sh == ctx->array_shape)) {
        pr = &p->prop[0];
      } else {
        /* only used for the first array */
        /* cannot fail */
        pr = add_property(ctx, p, JS_ATOM_length, JS_PROP_WRITABLE | JS_PROP_LENGTH);
      }
      pr->u.value = JS_NewInt32(ctx, 0);
    } break;
    case JS_CLASS_C_FUNCTION:
      p->prop[0].u.value = JS_UNDEFINED;
      break;
    case JS_CLASS_ARGUMENTS:
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
    case JS_CLASS_FLOAT64_ARRAY:
      p->is_exotic = 1;
      p->fast_array = 1;
      p->u.array.u.ptr = NULL;
      p->u.array.count = 0;
      break;
    case JS_CLASS_DATAVIEW:
      p->u.array.u.ptr = NULL;
      p->u.array.count = 0;
      break;
    case JS_CLASS_NUMBER:
    case JS_CLASS_STRING:
    case JS_CLASS_BOOLEAN:
    case JS_CLASS_SYMBOL:
    case JS_CLASS_DATE:
#ifdef CONFIG_BIGNUM
    case JS_CLASS_BIG_INT:
    case JS_CLASS_BIG_FLOAT:
    case JS_CLASS_BIG_DECIMAL:
#endif
      p->u.object_data = JS_UNDEFINED;
      goto set_exotic;
    case JS_CLASS_REGEXP:
      p->u.regexp.pattern = NULL;
      p->u.regexp.bytecode = NULL;
      goto set_exotic;
    default:
    set_exotic:
      if (ctx->rt->class_array[class_id].exotic) {
        p->is_exotic = 1;
      }
      break;
  }
  p->header.ref_count = 1;
  add_gc_object(ctx->rt, &p->header, JS_GC_OBJ_TYPE_JS_OBJECT);
  return JS_MKPTR(JS_TAG_OBJECT, p);
}

/* ensure that the shape can be safely modified */
int js_shape_prepare_update(JSContext* ctx, JSObject* p, JSShapeProperty** pprs) {
  JSShape* sh;
  uint32_t idx = 0; /* prevent warning */

  sh = p->shape;
  if (sh->is_hashed) {
    if (sh->header.ref_count != 1) {
      if (pprs)
        idx = *pprs - get_shape_prop(sh);
      /* clone the shape (the resulting one is no longer hashed) */
      sh = js_clone_shape(ctx, sh);
      if (!sh)
        return -1;
      js_free_shape(ctx->rt, p->shape);
      p->shape = sh;
      if (pprs)
        *pprs = get_shape_prop(sh) + idx;
    } else {
      js_shape_hash_unlink(ctx->rt, sh);
      sh->is_hashed = FALSE;
    }
  }
  return 0;
}