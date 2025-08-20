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

#include "string.h"
#include "convertion.h"
#include "exception.h"
#include "quickjs/cutils.h"
#include "quickjs/list.h"

/* Note: the string contents are uninitialized */
JSString* js_alloc_string_rt(JSRuntime* rt, int max_len, int is_wide_char) {
  JSString* str;
  str = js_malloc_rt(rt, sizeof(JSString) + (max_len << is_wide_char) + 1 - is_wide_char);
  if (unlikely(!str))
    return NULL;
  str->header.ref_count = 1;
  str->is_wide_char = is_wide_char;
  str->len = max_len;
  str->atom_type = 0;
  str->hash = 0;      /* optional but costless */
  str->hash_next = 0; /* optional */
#ifdef DUMP_LEAKS
  list_add_tail(&str->link, &rt->string_list);
#endif
  return str;
}

JSString* js_alloc_string(JSContext* ctx, int max_len, int is_wide_char) {
  JSString* p;
  p = js_alloc_string_rt(ctx->rt, max_len, is_wide_char);
  if (unlikely(!p)) {
    JS_ThrowOutOfMemory(ctx);
    return NULL;
  }
  return p;
}


int JS_ResizeAtomHash(JSRuntime* rt, int new_hash_size) {
  JSAtomStruct* p;
  uint32_t new_hash_mask, h, i, hash_next1, j, *new_hash;

  assert((new_hash_size & (new_hash_size - 1)) == 0); /* power of two */
  new_hash_mask = new_hash_size - 1;
  new_hash = js_mallocz_rt(rt, sizeof(rt->atom_hash[0]) * new_hash_size);
  if (!new_hash)
    return -1;
  for (i = 0; i < rt->atom_hash_size; i++) {
    h = rt->atom_hash[i];
    while (h != 0) {
      p = rt->atom_array[h];
      hash_next1 = p->hash_next;
      /* add in new hash table */
      j = p->hash & new_hash_mask;
      p->hash_next = new_hash[j];
      new_hash[j] = h;
      h = hash_next1;
    }
  }
  js_free_rt(rt, rt->atom_hash);
  rt->atom_hash = new_hash;
  rt->atom_hash_size = new_hash_size;
  rt->atom_count_resize = JS_ATOM_COUNT_RESIZE(new_hash_size);
  //    JS_DumpAtoms(rt);
  return 0;
}

int JS_InitAtoms(JSRuntime* rt) {
  int i, len, atom_type;
  const char* p;

  rt->atom_hash_size = 0;
  rt->atom_hash = NULL;
  rt->atom_count = 0;
  rt->atom_size = 0;
  rt->atom_free_index = 0;
  if (JS_ResizeAtomHash(rt, 1024)) /* there are at least 195 predefined atoms */
    return -1;

  p = js_atom_init;

  for (i = 1; i < JS_ATOM_END; i++) {
    if (i == JS_ATOM_Private_brand)
      atom_type = JS_ATOM_TYPE_PRIVATE;
    else if (i >= JS_ATOM_Symbol_toPrimitive && i <= JS_ATOM_Symbol_asyncIterator)
      atom_type = JS_ATOM_TYPE_SYMBOL;
    else
      atom_type = JS_ATOM_TYPE_STRING;
    len = strlen(p);
    if (__JS_NewAtomInit(rt, p, len, atom_type) == JS_ATOM_NULL)
      return -1;
    p = p + len + 1;
  }
  return 0;
}


uint32_t hash_string(const JSString* str, uint32_t h) {
  if (str->is_wide_char)
    h = hash_string16(str->u.str16, str->len, h);
  else
    h = hash_string8(str->u.str8, str->len, h);
  return h;
}

__maybe_unused void JS_DumpString(JSRuntime* rt, const JSString* p) {
  int i, c, sep;

  if (p == NULL) {
    printf("<null>");
    return;
  }
  printf("%d", p->header.ref_count);
  sep = (p->header.ref_count == 1) ? '\"' : '\'';
  putchar(sep);
  for (i = 0; i < p->len; i++) {
    if (p->is_wide_char)
      c = p->u.str16[i];
    else
      c = p->u.str8[i];
    if (c == sep || c == '\\') {
      putchar('\\');
      putchar(c);
    } else if (c >= ' ' && c <= 126) {
      putchar(c);
    } else if (c == '\n') {
      putchar('\\');
      putchar('n');
    } else {
      printf("\\u%04x", c);
    }
  }
  putchar(sep);
}

__maybe_unused void JS_DumpAtoms(JSRuntime* rt) {
  JSAtomStruct* p;
  int h, i;
  /* This only dumps hashed atoms, not JS_ATOM_TYPE_SYMBOL atoms */
  printf("JSAtom count=%d size=%d hash_size=%d:\n", rt->atom_count, rt->atom_size, rt->atom_hash_size);
  printf("JSAtom hash table: {\n");
  for (i = 0; i < rt->atom_hash_size; i++) {
    h = rt->atom_hash[i];
    if (h) {
      printf("  %d:", i);
      while (h) {
        p = rt->atom_array[h];
        printf(" ");
        JS_DumpString(rt, p);
        h = p->hash_next;
      }
      printf("\n");
    }
  }
  printf("}\n");
  printf("JSAtom table: {\n");
  for (i = 0; i < rt->atom_size; i++) {
    p = rt->atom_array[i];
    if (!atom_is_free(p)) {
      printf("  %d: { %d %08x ", i, p->atom_type, p->hash);
      if (!(p->len == 0 && p->is_wide_char != 0))
        JS_DumpString(rt, p);
      printf(" %d }\n", p->hash_next);
    }
  }
  printf("}\n");
}

JSAtom JS_DupAtomRT(JSRuntime* rt, JSAtom v) {
  JSAtomStruct* p;

  if (!__JS_AtomIsConst(v)) {
    p = rt->atom_array[v];
    p->header.ref_count++;
  }
  return v;
}

JSAtom JS_DupAtom(JSContext* ctx, JSAtom v) {
  JSRuntime* rt;
  JSAtomStruct* p;

  if (!__JS_AtomIsConst(v)) {
    rt = ctx->rt;
    p = rt->atom_array[v];
    p->header.ref_count++;
  }
  return v;
}

JSAtomKindEnum JS_AtomGetKind(JSContext* ctx, JSAtom v) {
  JSRuntime* rt;
  JSAtomStruct* p;

  rt = ctx->rt;
  if (__JS_AtomIsTaggedInt(v))
    return JS_ATOM_KIND_STRING;
  p = rt->atom_array[v];
  switch (p->atom_type) {
    case JS_ATOM_TYPE_STRING:
      return JS_ATOM_KIND_STRING;
    case JS_ATOM_TYPE_GLOBAL_SYMBOL:
      return JS_ATOM_KIND_SYMBOL;
    case JS_ATOM_TYPE_SYMBOL:
      switch (p->hash) {
        case JS_ATOM_HASH_SYMBOL:
          return JS_ATOM_KIND_SYMBOL;
        case JS_ATOM_HASH_PRIVATE:
          return JS_ATOM_KIND_PRIVATE;
        default:
          abort();
      }
    default:
      abort();
  }
}

BOOL JS_AtomIsString(JSContext* ctx, JSAtom v) {
  return JS_AtomGetKind(ctx, v) == JS_ATOM_KIND_STRING;
}

JSAtom js_get_atom_index(JSRuntime* rt, JSAtomStruct* p) {
  uint32_t i = p->hash_next; /* atom_index */
  if (p->atom_type != JS_ATOM_TYPE_SYMBOL) {
    JSAtomStruct* p1;

    i = rt->atom_hash[p->hash & (rt->atom_hash_size - 1)];
    p1 = rt->atom_array[i];
    while (p1 != p) {
      assert(i != 0);
      i = p1->hash_next;
      p1 = rt->atom_array[i];
    }
  }
  return i;
}

int memcmp16_8(const uint16_t* src1, const uint8_t* src2, int len) {
  int c, i;
  for (i = 0; i < len; i++) {
    c = src1[i] - src2[i];
    if (c != 0)
      return c;
  }
  return 0;
}

int memcmp16(const uint16_t* src1, const uint16_t* src2, int len) {
  int c, i;
  for (i = 0; i < len; i++) {
    c = src1[i] - src2[i];
    if (c != 0)
      return c;
  }
  return 0;
}

int js_string_memcmp(const JSString* p1, const JSString* p2, int len) {
  int res;

  if (likely(!p1->is_wide_char)) {
    if (likely(!p2->is_wide_char))
      res = memcmp(p1->u.str8, p2->u.str8, len);
    else
      res = -memcmp16_8(p2->u.str16, p1->u.str8, len);
  } else {
    if (!p2->is_wide_char)
      res = memcmp16_8(p1->u.str16, p2->u.str8, len);
    else
      res = memcmp16(p1->u.str16, p2->u.str16, len);
  }
  return res;
}

/* return < 0, 0 or > 0 */
int js_string_compare(JSContext* ctx, const JSString* p1, const JSString* p2) {
  int res, len;
  len = min_int(p1->len, p2->len);
  res = js_string_memcmp(p1, p2, len);
  if (res == 0) {
    if (p1->len == p2->len)
      res = 0;
    else if (p1->len < p2->len)
      res = -1;
    else
      res = 1;
  }
  return res;
}

void copy_str16(uint16_t* dst, const JSString* p, int offset, int len) {
  if (p->is_wide_char) {
    memcpy(dst, p->u.str16 + offset, len * 2);
  } else {
    const uint8_t* src1 = p->u.str8 + offset;
    int i;

    for (i = 0; i < len; i++)
      dst[i] = src1[i];
  }
}

JSValue JS_ConcatString1(JSContext* ctx, const JSString* p1, const JSString* p2) {
  JSString* p;
  uint32_t len;
  int is_wide_char;

  len = p1->len + p2->len;
  if (len > JS_STRING_LEN_MAX)
    return JS_ThrowInternalError(ctx, "string too long");
  is_wide_char = p1->is_wide_char | p2->is_wide_char;
  p = js_alloc_string(ctx, len, is_wide_char);
  if (!p)
    return JS_EXCEPTION;
  if (!is_wide_char) {
    memcpy(p->u.str8, p1->u.str8, p1->len);
    memcpy(p->u.str8 + p1->len, p2->u.str8, p2->len);
    p->u.str8[len] = '\0';
  } else {
    copy_str16(p->u.str16, p1, 0, p1->len);
    copy_str16(p->u.str16 + p1->len, p2, 0, p2->len);
  }
  return JS_MKPTR(JS_TAG_STRING, p);
}

/* string case (internal). Return JS_ATOM_NULL if error. 'str' is
   freed. */
JSAtom __JS_NewAtom(JSRuntime* rt, JSString* str, int atom_type) {
  uint32_t h, h1, i;
  JSAtomStruct* p;
  int len;

#if 0
    printf("__JS_NewAtom: ");  JS_DumpString(rt, str); printf("\n");
#endif
  if (atom_type < JS_ATOM_TYPE_SYMBOL) {
    /* str is not NULL */
    if (str->atom_type == atom_type) {
      /* str is the atom, return its index */
      i = js_get_atom_index(rt, str);
      /* reduce string refcount and increase atom's unless constant */
      if (__JS_AtomIsConst(i))
        str->header.ref_count--;
      return i;
    }
    /* try and locate an already registered atom */
    len = str->len;
    /* only in extreme case will str has zero hash, we accept extra hash calc in that case. */
    h = str->hash != 0 ? str->hash : hash_string(str, atom_type);
    h &= JS_ATOM_HASH_MASK;
    h1 = h & (rt->atom_hash_size - 1);
    i = rt->atom_hash[h1];
    while (i != 0) {
      p = rt->atom_array[i];
      if (p->hash == h && p->atom_type == atom_type && p->len == len && js_string_memcmp(p, str, len) == 0) {
        if (!__JS_AtomIsConst(i))
          p->header.ref_count++;
        goto done;
      }
      i = p->hash_next;
    }
  } else {
    h1 = 0; /* avoid warning */
    if (atom_type == JS_ATOM_TYPE_SYMBOL) {
      h = JS_ATOM_HASH_SYMBOL;
    } else {
      h = JS_ATOM_HASH_PRIVATE;
      atom_type = JS_ATOM_TYPE_SYMBOL;
    }
  }

  if (rt->atom_free_index == 0) {
    /* allow new atom entries */
    uint32_t new_size, start;
    JSAtomStruct** new_array;

    /* alloc new with size progression 3/2:
       4 6 9 13 19 28 42 63 94 141 211 316 474 711 1066 1599 2398 3597 5395 8092
       preallocating space for predefined atoms (at least 195).
     */
    new_size = max_int(1066, rt->atom_size * 9 / 2);
    if (new_size > JS_ATOM_MAX)
      goto fail;
    /* XXX: should use realloc2 to use slack space */
    new_array = js_realloc_rt(rt, rt->atom_array, sizeof(*new_array) * new_size);
    if (!new_array)
      goto fail;
    /* Note: the atom 0 is not used */
    start = rt->atom_size;
    if (start == 0) {
      /* JS_ATOM_NULL entry */
      p = js_mallocz_rt(rt, sizeof(JSAtomStruct));
      if (!p) {
        js_free_rt(rt, new_array);
        goto fail;
      }
      p->header.ref_count = 1; /* not refcounted */
      p->atom_type = JS_ATOM_TYPE_SYMBOL;
#ifdef DUMP_LEAKS
      list_add_tail(&p->link, &rt->string_list);
#endif
      new_array[0] = p;
      rt->atom_count++;
      start = 1;
    }
    rt->atom_size = new_size;
    rt->atom_array = new_array;
    rt->atom_free_index = start;
    for (i = start; i < new_size; i++) {
      uint32_t next;
      if (i == (new_size - 1))
        next = 0;
      else
        next = i + 1;
      rt->atom_array[i] = atom_set_free(next);
    }
  }

  if (str) {
    if (str->atom_type == 0) {
      p = str;
      p->atom_type = atom_type;
    } else {
      p = js_malloc_rt(rt, sizeof(JSString) + (str->len << str->is_wide_char) + 1 - str->is_wide_char);
      if (unlikely(!p))
        goto fail;
      p->header.ref_count = 1;
      p->is_wide_char = str->is_wide_char;
      p->len = str->len;
#ifdef DUMP_LEAKS
      list_add_tail(&p->link, &rt->string_list);
#endif
      memcpy(p->u.str8, str->u.str8, (str->len << str->is_wide_char) + 1 - str->is_wide_char);
      js_free_string(rt, str);
    }
  } else {
    p = js_malloc_rt(rt, sizeof(JSAtomStruct)); /* empty wide string */
    if (!p)
      return JS_ATOM_NULL;
    p->header.ref_count = 1;
    p->is_wide_char = 1; /* Hack to represent NULL as a JSString */
    p->len = 0;
#ifdef DUMP_LEAKS
    list_add_tail(&p->link, &rt->string_list);
#endif
  }

  /* use an already free entry */
  i = rt->atom_free_index;
  rt->atom_free_index = atom_get_free(rt->atom_array[i]);
  rt->atom_array[i] = p;

  p->hash = h;
  p->hash_next = i; /* atom_index */
  p->atom_type = atom_type;

  rt->atom_count++;

  if (atom_type != JS_ATOM_TYPE_SYMBOL) {
    p->hash_next = rt->atom_hash[h1];
    rt->atom_hash[h1] = i;
    if (unlikely(rt->atom_count >= rt->atom_count_resize))
      JS_ResizeAtomHash(rt, rt->atom_hash_size * 2);
  }

  //    JS_DumpAtoms(rt);
  return i;

fail:
  i = JS_ATOM_NULL;
done:
  if (str)
    js_free_string(rt, str);
  return i;
}

/* only works with zero terminated 8 bit strings */
JSAtom __JS_NewAtomInit(JSRuntime* rt, const char* str, int len, int atom_type) {
  JSString* p;
  p = js_alloc_string_rt(rt, len, 0);
  if (!p)
    return JS_ATOM_NULL;
  memcpy(p->u.str8, str, len);
  p->u.str8[len] = '\0';
  return __JS_NewAtom(rt, p, atom_type);
}

JSAtom __JS_FindAtom(JSRuntime* rt, const char* str, size_t len, int atom_type) {
  uint32_t h, h1, i;
  JSAtomStruct* p;

  h = hash_string8((const uint8_t*)str, len, JS_ATOM_TYPE_STRING);
  h &= JS_ATOM_HASH_MASK;
  h1 = h & (rt->atom_hash_size - 1);
  i = rt->atom_hash[h1];
  while (i != 0) {
    p = rt->atom_array[i];
    if (p->hash == h && p->atom_type == JS_ATOM_TYPE_STRING && p->len == len && p->is_wide_char == 0 && memcmp(p->u.str8, str, len) == 0) {
      if (!__JS_AtomIsConst(i))
        p->header.ref_count++;
      return i;
    }
    i = p->hash_next;
  }
  return JS_ATOM_NULL;
}

void JS_FreeAtomStruct(JSRuntime* rt, JSAtomStruct* p) {
#if 0 /* JS_ATOM_NULL is not refcounted: __JS_AtomIsConst() includes 0 */
    if (unlikely(i == JS_ATOM_NULL)) {
        p->header.ref_count = INT32_MAX / 2;
        return;
    }
#endif
  uint32_t i = p->hash_next; /* atom_index */
  if (p->atom_type != JS_ATOM_TYPE_SYMBOL) {
    JSAtomStruct *p0, *p1;
    uint32_t h0;

    h0 = p->hash & (rt->atom_hash_size - 1);
    i = rt->atom_hash[h0];
    p1 = rt->atom_array[i];
    if (p1 == p) {
      rt->atom_hash[h0] = p1->hash_next;
    } else {
      for (;;) {
        assert(i != 0);
        p0 = p1;
        i = p1->hash_next;
        p1 = rt->atom_array[i];
        if (p1 == p) {
          p0->hash_next = p1->hash_next;
          break;
        }
      }
    }
  }
  /* insert in free atom list */
  rt->atom_array[i] = atom_set_free(rt->atom_free_index);
  rt->atom_free_index = i;
  /* free the string structure */
#ifdef DUMP_LEAKS
  list_del(&p->link);
#endif
  js_free_rt(rt, p);
  rt->atom_count--;
  assert(rt->atom_count >= 0);
}

void __JS_FreeAtom(JSRuntime* rt, uint32_t i) {
  JSAtomStruct* p;

  p = rt->atom_array[i];
  if (--p->header.ref_count > 0)
    return;
  JS_FreeAtomStruct(rt, p);
}

/* Warning: 'p' is freed */
JSAtom JS_NewAtomStr(JSContext* ctx, JSString* p) {
  JSRuntime* rt = ctx->rt;
  uint32_t n;
  if (is_num_string(&n, p)) {
    if (n <= JS_ATOM_MAX_INT) {
      js_free_string(rt, p);
      return __JS_AtomFromUInt32(n);
    }
  }
  /* XXX: should generate an exception */
  return __JS_NewAtom(rt, p, JS_ATOM_TYPE_STRING);
}

JSAtom JS_NewAtomLen(JSContext* ctx, const char* str, size_t len) {
  JSValue val;

  if (len == 0 || !is_digit(*str)) {
    JSAtom atom = __JS_FindAtom(ctx->rt, str, len, JS_ATOM_TYPE_STRING);
    if (atom)
      return atom;
  }
  val = JS_NewStringLen(ctx, str, len);
  if (JS_IsException(val))
    return JS_ATOM_NULL;
  return JS_NewAtomStr(ctx, JS_VALUE_GET_STRING(val));
}

JSAtom JS_NewAtom(JSContext* ctx, const char* str) {
  return JS_NewAtomLen(ctx, str, strlen(str));
}

JSAtom JS_NewAtomUInt32(JSContext* ctx, uint32_t n) {
  if (n <= JS_ATOM_MAX_INT) {
    return __JS_AtomFromUInt32(n);
  } else {
    char buf[11];
    JSValue val;
    snprintf(buf, sizeof(buf), "%u", n);
    val = JS_NewString(ctx, buf);
    if (JS_IsException(val))
      return JS_ATOM_NULL;
    return __JS_NewAtom(ctx->rt, JS_VALUE_GET_STRING(val), JS_ATOM_TYPE_STRING);
  }
}

JSAtom JS_NewAtomInt64(JSContext* ctx, int64_t n) {
  if ((uint64_t)n <= JS_ATOM_MAX_INT) {
    return __JS_AtomFromUInt32((uint32_t)n);
  } else {
    char buf[24];
    JSValue val;
    snprintf(buf, sizeof(buf), "%" PRId64, n);
    val = JS_NewString(ctx, buf);
    if (JS_IsException(val))
      return JS_ATOM_NULL;
    return __JS_NewAtom(ctx->rt, JS_VALUE_GET_STRING(val), JS_ATOM_TYPE_STRING);
  }
}

/* Should only be used for debug. */
const char* JS_AtomGetStrRT(JSRuntime* rt, char* buf, int buf_size, JSAtom atom) {
  if (__JS_AtomIsTaggedInt(atom)) {
    snprintf(buf, buf_size, "%u", __JS_AtomToUInt32(atom));
  } else {
    JSAtomStruct* p;
    assert(atom < rt->atom_size);
    if (atom == JS_ATOM_NULL) {
      snprintf(buf, buf_size, "<null>");
    } else {
      int i, c;
      char* q;
      JSString* str;

      q = buf;
      p = rt->atom_array[atom];
      assert(!atom_is_free(p));
      str = p;
      if (str) {
        if (!str->is_wide_char) {
          /* special case ASCII strings */
          c = 0;
          for (i = 0; i < str->len; i++) {
            c |= str->u.str8[i];
          }
          if (c < 0x80)
            return (const char*)str->u.str8;
        }
        for (i = 0; i < str->len; i++) {
          if (str->is_wide_char)
            c = str->u.str16[i];
          else
            c = str->u.str8[i];
          if ((q - buf) >= buf_size - UTF8_CHAR_LEN_MAX)
            break;
          if (c < 128) {
            *q++ = c;
          } else {
            q += unicode_to_utf8((uint8_t*)q, c);
          }
        }
      }
      *q = '\0';
    }
  }
  return buf;
}

const char* JS_AtomGetStr(JSContext* ctx, char* buf, int buf_size, JSAtom atom) {
  return JS_AtomGetStrRT(ctx->rt, buf, buf_size, atom);
}

JSValue __JS_AtomToValue(JSContext* ctx, JSAtom atom, BOOL force_string) {
  char buf[ATOM_GET_STR_BUF_SIZE];

  if (__JS_AtomIsTaggedInt(atom)) {
    snprintf(buf, sizeof(buf), "%u", __JS_AtomToUInt32(atom));
    return JS_NewString(ctx, buf);
  } else {
    JSRuntime* rt = ctx->rt;
    JSAtomStruct* p;
    assert(atom < rt->atom_size);
    p = rt->atom_array[atom];
    if (p->atom_type == JS_ATOM_TYPE_STRING) {
      goto ret_string;
    } else if (force_string) {
      if (p->len == 0 && p->is_wide_char != 0) {
        /* no description string */
        p = rt->atom_array[JS_ATOM_empty_string];
      }
    ret_string:
      return JS_DupValue(ctx, JS_MKPTR(JS_TAG_STRING, p));
    } else {
      return JS_DupValue(ctx, JS_MKPTR(JS_TAG_SYMBOL, p));
    }
  }
}

JSValue JS_AtomToValue(JSContext* ctx, JSAtom atom) {
  return __JS_AtomToValue(ctx, atom, FALSE);
}

JSValue JS_AtomToString(JSContext* ctx, JSAtom atom) {
  return __JS_AtomToValue(ctx, atom, TRUE);
}

/* val must be a symbol */
JSAtom js_symbol_to_atom(JSContext *ctx, JSValue val)
{
  JSAtomStruct *p = JS_VALUE_GET_PTR(val);
  return js_get_atom_index(ctx->rt, p);
}

/* return JS_ATOM_NULL in case of exception */
JSAtom JS_ValueToAtom(JSContext *ctx, JSValueConst val)
{
  JSAtom atom;
  uint32_t tag;
  tag = JS_VALUE_GET_TAG(val);
  if (tag == JS_TAG_INT &&
      (uint32_t)JS_VALUE_GET_INT(val) <= JS_ATOM_MAX_INT) {
    /* fast path for integer values */
    atom = __JS_AtomFromUInt32(JS_VALUE_GET_INT(val));
  } else if (tag == JS_TAG_SYMBOL) {
    JSAtomStruct *p = JS_VALUE_GET_PTR(val);
    atom = JS_DupAtom(ctx, js_get_atom_index(ctx->rt, p));
  } else {
    JSValue str;
    str = JS_ToPropertyKey(ctx, val);
    if (JS_IsException(str))
      return JS_ATOM_NULL;
    if (JS_VALUE_GET_TAG(str) == JS_TAG_SYMBOL) {
      atom = js_symbol_to_atom(ctx, str);
    } else {
      atom = JS_NewAtomStr(ctx, JS_VALUE_GET_STRING(str));
    }
  }
  return atom;
}

/* return TRUE if the atom is an array index (i.e. 0 <= index <=
   2^32-2 and return its value */
BOOL JS_AtomIsArrayIndex(JSContext* ctx, uint32_t* pval, JSAtom atom) {
  if (__JS_AtomIsTaggedInt(atom)) {
    *pval = __JS_AtomToUInt32(atom);
    return TRUE;
  } else {
    JSRuntime* rt = ctx->rt;
    JSAtomStruct* p;
    uint32_t val;

    assert(atom < rt->atom_size);
    p = rt->atom_array[atom];
    if (p->atom_type == JS_ATOM_TYPE_STRING && is_num_string(&val, p) && val != -1) {
      *pval = val;
      return TRUE;
    } else {
      *pval = 0;
      return FALSE;
    }
  }
}

/* This test must be fast if atom is not a numeric index (e.g. a
   method name). Return JS_UNDEFINED if not a numeric
   index. JS_EXCEPTION can also be returned. */
JSValue JS_AtomIsNumericIndex1(JSContext* ctx, JSAtom atom) {
  JSRuntime* rt = ctx->rt;
  JSAtomStruct* p1;
  JSString* p;
  int c, len, ret;
  JSValue num, str;

  if (__JS_AtomIsTaggedInt(atom))
    return JS_NewInt32(ctx, __JS_AtomToUInt32(atom));
  assert(atom < rt->atom_size);
  p1 = rt->atom_array[atom];
  if (p1->atom_type != JS_ATOM_TYPE_STRING)
    return JS_UNDEFINED;
  p = p1;
  len = p->len;
  if (p->is_wide_char) {
    const uint16_t *r = p->u.str16, *r_end = p->u.str16 + len;
    if (r >= r_end)
      return JS_UNDEFINED;
    c = *r;
    if (c == '-') {
      if (r >= r_end)
        return JS_UNDEFINED;
      r++;
      c = *r;
      /* -0 case is specific */
      if (c == '0' && len == 2)
        goto minus_zero;
    }
    /* XXX: should test NaN, but the tests do not check it */
    if (!is_num(c)) {
      /* XXX: String should be normalized, therefore 8-bit only */
      const uint16_t nfinity16[7] = {'n', 'f', 'i', 'n', 'i', 't', 'y'};
      if (!(c == 'I' && (r_end - r) == 8 && !memcmp(r + 1, nfinity16, sizeof(nfinity16))))
        return JS_UNDEFINED;
    }
  } else {
    const uint8_t *r = p->u.str8, *r_end = p->u.str8 + len;
    if (r >= r_end)
      return JS_UNDEFINED;
    c = *r;
    if (c == '-') {
      if (r >= r_end)
        return JS_UNDEFINED;
      r++;
      c = *r;
      /* -0 case is specific */
      if (c == '0' && len == 2) {
      minus_zero:
        return __JS_NewFloat64(ctx, -0.0);
      }
    }
    if (!is_num(c)) {
      if (!(c == 'I' && (r_end - r) == 8 && !memcmp(r + 1, "nfinity", 7)))
        return JS_UNDEFINED;
    }
  }
  /* XXX: bignum: would be better to only accept integer to avoid
     relying on current floating point precision */
  /* this is ECMA CanonicalNumericIndexString primitive */
  num = JS_ToNumber(ctx, JS_MKPTR(JS_TAG_STRING, p));
  if (JS_IsException(num))
    return num;
  str = JS_ToString(ctx, num);
  if (JS_IsException(str)) {
    JS_FreeValue(ctx, num);
    return str;
  }
  ret = js_string_compare(ctx, p, JS_VALUE_GET_STRING(str));
  JS_FreeValue(ctx, str);
  if (ret == 0) {
    return num;
  } else {
    JS_FreeValue(ctx, num);
    return JS_UNDEFINED;
  }
}

/* return -1 if exception or TRUE/FALSE */
int JS_AtomIsNumericIndex(JSContext* ctx, JSAtom atom) {
  JSValue num;
  num = JS_AtomIsNumericIndex1(ctx, atom);
  if (likely(JS_IsUndefined(num)))
    return FALSE;
  if (JS_IsException(num))
    return -1;
  JS_FreeValue(ctx, num);
  return TRUE;
}

void JS_FreeAtom(JSContext* ctx, JSAtom v) {
  if (!__JS_AtomIsConst(v))
    __JS_FreeAtom(ctx->rt, v);
}

void JS_FreeAtomRT(JSRuntime* rt, JSAtom v) {
  if (!__JS_AtomIsConst(v))
    __JS_FreeAtom(rt, v);
}

/* return TRUE if 'v' is a symbol with a string description */
BOOL JS_AtomSymbolHasDescription(JSContext* ctx, JSAtom v) {
  JSRuntime* rt;
  JSAtomStruct* p;

  rt = ctx->rt;
  if (__JS_AtomIsTaggedInt(v))
    return FALSE;
  p = rt->atom_array[v];
  return (((p->atom_type == JS_ATOM_TYPE_SYMBOL && p->hash == JS_ATOM_HASH_SYMBOL) || p->atom_type == JS_ATOM_TYPE_GLOBAL_SYMBOL) && !(p->len == 0 && p->is_wide_char != 0));
}

__maybe_unused void print_atom(JSContext* ctx, JSAtom atom) {
  char buf[ATOM_GET_STR_BUF_SIZE];
  const char* p;
  int i;

  /* XXX: should handle embedded null characters */
  /* XXX: should move encoding code to JS_AtomGetStr */
  p = JS_AtomGetStr(ctx, buf, sizeof(buf), atom);
  for (i = 0; p[i]; i++) {
    int c = (unsigned char)p[i];
    if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c == '_' || c == '$') || (c >= '0' && c <= '9' && i > 0)))
      break;
  }
  if (i > 0 && p[i] == '\0') {
    printf("%s", p);
  } else {
    putchar('"');
    printf("%.*s", i, p);
    for (; p[i]; i++) {
      int c = (unsigned char)p[i];
      if (c == '\"' || c == '\\') {
        putchar('\\');
        putchar(c);
      } else if (c >= ' ' && c <= 126) {
        putchar(c);
      } else if (c == '\n') {
        putchar('\\');
        putchar('n');
      } else {
        printf("\\u%04x", c);
      }
    }
    putchar('\"');
  }
}

/* free with JS_FreeCString() */
const char* JS_AtomToCString(JSContext* ctx, JSAtom atom) {
  JSValue str;
  const char* cstr;

  str = JS_AtomToString(ctx, atom);
  if (JS_IsException(str))
    return NULL;
  cstr = JS_ToCString(ctx, str);
  JS_FreeValue(ctx, str);
  return cstr;
}

/* return a string atom containing name concatenated with str1 */
JSAtom js_atom_concat_str(JSContext* ctx, JSAtom name, const char* str1) {
  JSValue str;
  JSAtom atom;
  const char* cstr;
  char* cstr2;
  size_t len, len1;

  str = JS_AtomToString(ctx, name);
  if (JS_IsException(str))
    return JS_ATOM_NULL;
  cstr = JS_ToCStringLen(ctx, &len, str);
  if (!cstr)
    goto fail;
  len1 = strlen(str1);
  cstr2 = js_malloc(ctx, len + len1 + 1);
  if (!cstr2)
    goto fail;
  memcpy(cstr2, cstr, len);
  memcpy(cstr2 + len, str1, len1);
  cstr2[len + len1] = '\0';
  atom = JS_NewAtomLen(ctx, cstr2, len + len1);
  js_free(ctx, cstr2);
  JS_FreeCString(ctx, cstr);
  JS_FreeValue(ctx, str);
  return atom;
fail:
  JS_FreeCString(ctx, cstr);
  JS_FreeValue(ctx, str);
  return JS_ATOM_NULL;
}

JSAtom js_atom_concat_num(JSContext* ctx, JSAtom name, uint32_t n) {
  char buf[16];
  snprintf(buf, sizeof(buf), "%u", n);
  return js_atom_concat_str(ctx, name, buf);
}

/* 'p' is freed */
JSValue JS_NewSymbol(JSContext* ctx, JSString* p, int atom_type) {
  JSRuntime* rt = ctx->rt;
  JSAtom atom;
  atom = __JS_NewAtom(rt, p, atom_type);
  if (atom == JS_ATOM_NULL)
    return JS_ThrowOutOfMemory(ctx);
  return JS_MKPTR(JS_TAG_SYMBOL, rt->atom_array[atom]);
}

/* descr must be a non-numeric string atom */
JSValue JS_NewSymbolFromAtom(JSContext* ctx, JSAtom descr, int atom_type) {
  JSRuntime* rt = ctx->rt;
  JSString* p;

  assert(!__JS_AtomIsTaggedInt(descr));
  assert(descr < rt->atom_size);
  p = rt->atom_array[descr];
  JS_DupValue(ctx, JS_MKPTR(JS_TAG_STRING, p));
  return JS_NewSymbol(ctx, p, atom_type);
}

/* It is valid to call string_buffer_end() and all string_buffer functions even
   if string_buffer_init() or another string_buffer function returns an error.
   If the error_status is set, string_buffer_end() returns JS_EXCEPTION.
 */
int string_buffer_init2(JSContext* ctx, StringBuffer* s, int size, int is_wide) {
  s->ctx = ctx;
  s->size = size;
  s->len = 0;
  s->is_wide_char = is_wide;
  s->error_status = 0;
  s->str = js_alloc_string(ctx, size, is_wide);
  if (unlikely(!s->str)) {
    s->size = 0;
    return s->error_status = -1;
  }
#ifdef DUMP_LEAKS
  /* the StringBuffer may reallocate the JSString, only link it at the end */
  list_del(&s->str->link);
#endif
  return 0;
}



void string_buffer_free(StringBuffer* s) {
  js_free(s->ctx, s->str);
  s->str = NULL;
}

int string_buffer_set_error(StringBuffer* s) {
  js_free(s->ctx, s->str);
  s->str = NULL;
  s->size = 0;
  s->len = 0;
  return s->error_status = -1;
}

no_inline int string_buffer_widen(StringBuffer* s, int size) {
  JSString* str;
  size_t slack;
  int i;

  if (s->error_status)
    return -1;

  str = js_realloc2(s->ctx, s->str, sizeof(JSString) + (size << 1), &slack);
  if (!str)
    return string_buffer_set_error(s);
  size += slack >> 1;
  for (i = s->len; i-- > 0;) {
    str->u.str16[i] = str->u.str8[i];
  }
  s->is_wide_char = 1;
  s->size = size;
  s->str = str;
  return 0;
}

no_inline int string_buffer_realloc(StringBuffer* s, int new_len, int c) {
  JSString* new_str;
  int new_size;
  size_t new_size_bytes, slack;

  if (s->error_status)
    return -1;

  if (new_len > JS_STRING_LEN_MAX) {
    JS_ThrowInternalError(s->ctx, "string too long");
    return string_buffer_set_error(s);
  }
  new_size = min_int(max_int(new_len, s->size * 9 / 2), JS_STRING_LEN_MAX);
  if (!s->is_wide_char && c >= 0x100) {
    return string_buffer_widen(s, new_size);
  }
  new_size_bytes = sizeof(JSString) + (new_size << s->is_wide_char) + 1 - s->is_wide_char;
  new_str = js_realloc2(s->ctx, s->str, new_size_bytes, &slack);
  if (!new_str)
    return string_buffer_set_error(s);
  new_size = min_int(new_size + (slack >> s->is_wide_char), JS_STRING_LEN_MAX);
  s->size = new_size;
  s->str = new_str;
  return 0;
}

no_inline int string_buffer_putc_slow(StringBuffer* s, uint32_t c) {
  if (unlikely(s->len >= s->size)) {
    if (string_buffer_realloc(s, s->len + 1, c))
      return -1;
  }
  if (s->is_wide_char) {
    s->str->u.str16[s->len++] = c;
  } else if (c < 0x100) {
    s->str->u.str8[s->len++] = c;
  } else {
    if (string_buffer_widen(s, s->size))
      return -1;
    s->str->u.str16[s->len++] = c;
  }
  return 0;
}

/* 0 <= c <= 0xff */
int string_buffer_putc8(StringBuffer* s, uint32_t c) {
  if (unlikely(s->len >= s->size)) {
    if (string_buffer_realloc(s, s->len + 1, c))
      return -1;
  }
  if (s->is_wide_char) {
    s->str->u.str16[s->len++] = c;
  } else {
    s->str->u.str8[s->len++] = c;
  }
  return 0;
}

/* 0 <= c <= 0xffff */
int string_buffer_putc16(StringBuffer* s, uint32_t c) {
  if (likely(s->len < s->size)) {
    if (s->is_wide_char) {
      s->str->u.str16[s->len++] = c;
      return 0;
    } else if (c < 0x100) {
      s->str->u.str8[s->len++] = c;
      return 0;
    }
  }
  return string_buffer_putc_slow(s, c);
}

/* 0 <= c <= 0x10ffff */
int string_buffer_putc(StringBuffer* s, uint32_t c) {
  if (unlikely(c >= 0x10000)) {
    /* surrogate pair */
    c -= 0x10000;
    if (string_buffer_putc16(s, (c >> 10) + 0xd800))
      return -1;
    c = (c & 0x3ff) + 0xdc00;
  }
  return string_buffer_putc16(s, c);
}

int string_get(const JSString* p, int idx) {
  return p->is_wide_char ? p->u.str16[idx] : p->u.str8[idx];
}

int string_getc(const JSString* p, int* pidx) {
  int idx, c, c1;
  idx = *pidx;
  if (p->is_wide_char) {
    c = p->u.str16[idx++];
    if (c >= 0xd800 && c < 0xdc00 && idx < p->len) {
      c1 = p->u.str16[idx];
      if (c1 >= 0xdc00 && c1 < 0xe000) {
        c = (((c & 0x3ff) << 10) | (c1 & 0x3ff)) + 0x10000;
        idx++;
      }
    }
  } else {
    c = p->u.str8[idx++];
  }
  *pidx = idx;
  return c;
}

int string_buffer_write8(StringBuffer* s, const uint8_t* p, int len) {
  int i;

  if (s->len + len > s->size) {
    if (string_buffer_realloc(s, s->len + len, 0))
      return -1;
  }
  if (s->is_wide_char) {
    for (i = 0; i < len; i++) {
      s->str->u.str16[s->len + i] = p[i];
    }
    s->len += len;
  } else {
    memcpy(&s->str->u.str8[s->len], p, len);
    s->len += len;
  }
  return 0;
}

int string_buffer_write16(StringBuffer* s, const uint16_t* p, int len) {
  int c = 0, i;

  for (i = 0; i < len; i++) {
    c |= p[i];
  }
  if (s->len + len > s->size) {
    if (string_buffer_realloc(s, s->len + len, c))
      return -1;
  } else if (!s->is_wide_char && c >= 0x100) {
    if (string_buffer_widen(s, s->size))
      return -1;
  }
  if (s->is_wide_char) {
    memcpy(&s->str->u.str16[s->len], p, len << 1);
    s->len += len;
  } else {
    for (i = 0; i < len; i++) {
      s->str->u.str8[s->len + i] = p[i];
    }
    s->len += len;
  }
  return 0;
}

/* appending an ASCII string */
int string_buffer_puts8(StringBuffer* s, const char* str) {
  return string_buffer_write8(s, (const uint8_t*)str, strlen(str));
}

int string_buffer_concat(StringBuffer* s, const JSString* p, uint32_t from, uint32_t to) {
  if (to <= from)
    return 0;
  if (p->is_wide_char)
    return string_buffer_write16(s, p->u.str16 + from, to - from);
  else
    return string_buffer_write8(s, p->u.str8 + from, to - from);
}

int string_buffer_concat_value(StringBuffer* s, JSValueConst v) {
  JSString* p;
  JSValue v1;
  int res;

  if (s->error_status) {
    /* prevent exception overload */
    return -1;
  }
  if (unlikely(JS_VALUE_GET_TAG(v) != JS_TAG_STRING)) {
    v1 = JS_ToString(s->ctx, v);
    if (JS_IsException(v1))
      return string_buffer_set_error(s);
    p = JS_VALUE_GET_STRING(v1);
    res = string_buffer_concat(s, p, 0, p->len);
    JS_FreeValue(s->ctx, v1);
    return res;
  }
  p = JS_VALUE_GET_STRING(v);
  return string_buffer_concat(s, p, 0, p->len);
}

int string_buffer_concat_value_free(StringBuffer* s, JSValue v) {
  JSString* p;
  int res;

  if (s->error_status) {
    /* prevent exception overload */
    JS_FreeValue(s->ctx, v);
    return -1;
  }
  if (unlikely(JS_VALUE_GET_TAG(v) != JS_TAG_STRING)) {
    v = JS_ToStringFree(s->ctx, v);
    if (JS_IsException(v))
      return string_buffer_set_error(s);
  }
  p = JS_VALUE_GET_STRING(v);
  res = string_buffer_concat(s, p, 0, p->len);
  JS_FreeValue(s->ctx, v);
  return res;
}

int string_buffer_fill(StringBuffer* s, int c, int count) {
  /* XXX: optimize */
  if (s->len + count > s->size) {
    if (string_buffer_realloc(s, s->len + count, c))
      return -1;
  }
  while (count-- > 0) {
    if (string_buffer_putc16(s, c))
      return -1;
  }
  return 0;
}

JSValue string_buffer_end(StringBuffer* s) {
  JSString* str;
  str = s->str;
  if (s->error_status)
    return JS_EXCEPTION;
  if (s->len == 0) {
    js_free(s->ctx, str);
    s->str = NULL;
    return JS_AtomToString(s->ctx, JS_ATOM_empty_string);
  }
  if (s->len < s->size) {
    /* smaller size so js_realloc should not fail, but OK if it does */
    /* XXX: should add some slack to avoid unnecessary calls */
    /* XXX: might need to use malloc+free to ensure smaller size */
    str = js_realloc_rt(s->ctx->rt, str, sizeof(JSString) + (s->len << s->is_wide_char) + 1 - s->is_wide_char);
    if (str == NULL)
      str = s->str;
    s->str = str;
  }
  if (!s->is_wide_char)
    str->u.str8[s->len] = 0;
#ifdef DUMP_LEAKS
  list_add_tail(&str->link, &s->ctx->rt->string_list);
#endif
  str->is_wide_char = s->is_wide_char;
  str->len = s->len;
  s->str = NULL;
  return JS_MKPTR(JS_TAG_STRING, str);
}

JSValue js_new_string8(JSContext* ctx, const uint8_t* buf, int len) {
  JSString* str;

  if (len <= 0) {
    return JS_AtomToString(ctx, JS_ATOM_empty_string);
  }
  str = js_alloc_string(ctx, len, 0);
  if (!str)
    return JS_EXCEPTION;
  memcpy(str->u.str8, buf, len);
  str->u.str8[len] = '\0';
  return JS_MKPTR(JS_TAG_STRING, str);
}

JSValue js_new_string16(JSContext* ctx, const uint16_t* buf, int len) {
  JSString* str;
  str = js_alloc_string(ctx, len, 1);
  if (!str)
    return JS_EXCEPTION;
  memcpy(str->u.str16, buf, len * 2);
  return JS_MKPTR(JS_TAG_STRING, str);
}

JSValue js_new_string_char(JSContext* ctx, uint16_t c) {
  if (c < 0x100) {
    uint8_t ch8 = c;
    return js_new_string8(ctx, &ch8, 1);
  } else {
    uint16_t ch16 = c;
    return js_new_string16(ctx, &ch16, 1);
  }
}

JSValue js_sub_string(JSContext* ctx, JSString* p, int start, int end) {
  int len = end - start;
  if (start == 0 && end == p->len) {
    return JS_DupValue(ctx, JS_MKPTR(JS_TAG_STRING, p));
  }
  if (p->is_wide_char && len > 0) {
    JSString* str;
    int i;
    uint16_t c = 0;
    for (i = start; i < end; i++) {
      c |= p->u.str16[i];
    }
    if (c > 0xFF)
      return js_new_string16(ctx, p->u.str16 + start, len);

    str = js_alloc_string(ctx, len, 0);
    if (!str)
      return JS_EXCEPTION;
    for (i = 0; i < len; i++) {
      str->u.str8[i] = p->u.str16[start + i];
    }
    str->u.str8[len] = '\0';
    return JS_MKPTR(JS_TAG_STRING, str);
  } else {
    return js_new_string8(ctx, p->u.str8 + start, len);
  }
}

/* create a string from a UTF-8 buffer */
JSValue JS_NewStringLen(JSContext* ctx, const char* buf, size_t buf_len) {
  const uint8_t *p, *p_end, *p_start, *p_next;
  uint32_t c;
  StringBuffer b_s, *b = &b_s;
  size_t len1;

  p_start = (const uint8_t*)buf;
  p_end = p_start + buf_len;
  p = p_start;
  while (p < p_end && * p < 128)
    p++;
  len1 = p - p_start;
  if (len1 > JS_STRING_LEN_MAX)
    return JS_ThrowInternalError(ctx, "string too long");
  if (p == p_end) {
    /* ASCII string */
    return js_new_string8(ctx, (const uint8_t*)buf, buf_len);
  } else {
    if (string_buffer_init(ctx, b, buf_len))
      goto fail;
    string_buffer_write8(b, p_start, len1);
    while (p < p_end) {
      if (*p < 128) {
        string_buffer_putc8(b, *p++);
      } else {
        /* parse utf-8 sequence, return 0xFFFFFFFF for error */
        c = unicode_from_utf8(p, p_end - p, &p_next);
        if (c < 0x10000) {
          p = p_next;
        } else if (c <= 0x10FFFF) {
          p = p_next;
          /* surrogate pair */
          c -= 0x10000;
          string_buffer_putc16(b, (c >> 10) + 0xd800);
          c = (c & 0x3ff) + 0xdc00;
        } else {
          /* invalid char */
          c = 0xfffd;
          /* skip the invalid chars */
          /* XXX: seems incorrect. Why not just use c = *p++; ? */
          while (p < p_end && (*p >= 0x80 && *p < 0xc0))
            p++;
          if (p < p_end) {
            p++;
            while (p < p_end && (*p >= 0x80 && *p < 0xc0))
              p++;
          }
        }
        string_buffer_putc16(b, c);
      }
    }
  }
  return string_buffer_end(b);

fail:
  string_buffer_free(b);
  return JS_EXCEPTION;
}

JSValue JS_ConcatString3(JSContext* ctx, const char* str1, JSValue str2, const char* str3) {
  StringBuffer b_s, *b = &b_s;
  int len1, len3;
  JSString* p;

  if (unlikely(JS_VALUE_GET_TAG(str2) != JS_TAG_STRING)) {
    str2 = JS_ToStringFree(ctx, str2);
    if (JS_IsException(str2))
      goto fail;
  }
  p = JS_VALUE_GET_STRING(str2);
  len1 = strlen(str1);
  len3 = strlen(str3);

  if (string_buffer_init2(ctx, b, len1 + p->len + len3, p->is_wide_char))
    goto fail;

  string_buffer_write8(b, (const uint8_t*)str1, len1);
  string_buffer_concat(b, p, 0, p->len);
  string_buffer_write8(b, (const uint8_t*)str3, len3);

  JS_FreeValue(ctx, str2);
  return string_buffer_end(b);

fail:
  JS_FreeValue(ctx, str2);
  return JS_EXCEPTION;
}

JSValue JS_NewString(JSContext* ctx, const char* str) {
  return JS_NewStringLen(ctx, str, strlen(str));
}

JSValue JS_NewAtomString(JSContext* ctx, const char* str) {
  JSAtom atom = JS_NewAtom(ctx, str);
  if (atom == JS_ATOM_NULL)
    return JS_EXCEPTION;
  JSValue val = JS_AtomToString(ctx, atom);
  JS_FreeAtom(ctx, atom);
  return val;
}

/* return (NULL, 0) if exception. */
/* return pointer into a JSString with a live ref_count */
/* cesu8 determines if non-BMP1 codepoints are encoded as 1 or 2 utf-8 sequences */
const char* JS_ToCStringLen2(JSContext* ctx, size_t* plen, JSValueConst val1, BOOL cesu8) {
  JSValue val;
  JSString *str, *str_new;
  int pos, len, c, c1;
  uint8_t* q;

  if (JS_VALUE_GET_TAG(val1) != JS_TAG_STRING) {
    val = JS_ToString(ctx, val1);
    if (JS_IsException(val))
      goto fail;
  } else {
    val = JS_DupValue(ctx, val1);
  }

  str = JS_VALUE_GET_STRING(val);
  len = str->len;
  if (!str->is_wide_char) {
    const uint8_t* src = str->u.str8;
    int count;

    /* count the number of non-ASCII characters */
    /* Scanning the whole string is required for ASCII strings,
       and computing the number of non-ASCII bytes is less expensive
       than testing each byte, hence this method is faster for ASCII
       strings, which is the most common case.
     */
    count = 0;
    for (pos = 0; pos < len; pos++) {
      count += src[pos] >> 7;
    }
    if (count == 0) {
      if (plen)
        *plen = len;
      return (const char*)src;
    }
    str_new = js_alloc_string(ctx, len + count, 0);
    if (!str_new)
      goto fail;
    q = str_new->u.str8;
    for (pos = 0; pos < len; pos++) {
      c = src[pos];
      if (c < 0x80) {
        *q++ = c;
      } else {
        *q++ = (c >> 6) | 0xc0;
        *q++ = (c & 0x3f) | 0x80;
      }
    }
  } else {
    const uint16_t* src = str->u.str16;
    /* Allocate 3 bytes per 16 bit code point. Surrogate pairs may
       produce 4 bytes but use 2 code points.
     */
    str_new = js_alloc_string(ctx, len * 3, 0);
    if (!str_new)
      goto fail;
    q = str_new->u.str8;
    pos = 0;
    while (pos < len) {
      c = src[pos++];
      if (c < 0x80) {
        *q++ = c;
      } else {
        if (c >= 0xd800 && c < 0xdc00) {
          if (pos < len && !cesu8) {
            c1 = src[pos];
            if (c1 >= 0xdc00 && c1 < 0xe000) {
              pos++;
              /* surrogate pair */
              c = (((c & 0x3ff) << 10) | (c1 & 0x3ff)) + 0x10000;
            } else {
              /* Keep unmatched surrogate code points */
              /* c = 0xfffd; */ /* error */
            }
          } else {
            /* Keep unmatched surrogate code points */
            /* c = 0xfffd; */ /* error */
          }
        }
        q += unicode_to_utf8(q, c);
      }
    }
  }

  *q = '\0';
  str_new->len = q - str_new->u.str8;
  JS_FreeValue(ctx, val);
  if (plen)
    *plen = str_new->len;
  return (const char*)str_new->u.str8;
fail:
  if (plen)
    *plen = 0;
  return NULL;
}

void JS_FreeCString(JSContext* ctx, const char* ptr) {
  JSString* p;
  if (!ptr)
    return;
  /* purposely removing constness */
  p = (JSString*)(void*)(ptr - offsetof(JSString, u));
  JS_FreeValue(ctx, JS_MKPTR(JS_TAG_STRING, p));
}

/* op1 and op2 are converted to strings. For convience, op1 or op2 =
   JS_EXCEPTION are accepted and return JS_EXCEPTION.  */
JSValue JS_ConcatString(JSContext* ctx, JSValue op1, JSValue op2) {
  JSValue ret;
  JSString *p1, *p2;

  if (unlikely(JS_VALUE_GET_TAG(op1) != JS_TAG_STRING)) {
    op1 = JS_ToStringFree(ctx, op1);
    if (JS_IsException(op1)) {
      JS_FreeValue(ctx, op2);
      return JS_EXCEPTION;
    }
  }
  if (unlikely(JS_VALUE_GET_TAG(op2) != JS_TAG_STRING)) {
    op2 = JS_ToStringFree(ctx, op2);
    if (JS_IsException(op2)) {
      JS_FreeValue(ctx, op1);
      return JS_EXCEPTION;
    }
  }
  p1 = JS_VALUE_GET_STRING(op1);
  p2 = JS_VALUE_GET_STRING(op2);

  /* XXX: could also check if p1 is empty */
  if (p2->len == 0) {
    goto ret_op1;
  }
  if (p1->header.ref_count == 1 && p1->is_wide_char == p2->is_wide_char && js_malloc_usable_size(ctx, p1) >= sizeof(*p1) + ((p1->len + p2->len) << p2->is_wide_char) + 1 - p1->is_wide_char) {
    /* Concatenate in place in available space at the end of p1 */
    if (p1->is_wide_char) {
      memcpy(p1->u.str16 + p1->len, p2->u.str16, p2->len << 1);
      p1->len += p2->len;
    } else {
      memcpy(p1->u.str8 + p1->len, p2->u.str8, p2->len);
      p1->len += p2->len;
      p1->u.str8[p1->len] = '\0';
    }
  ret_op1:
    JS_FreeValue(ctx, op2);
    return op1;
  }
  ret = JS_ConcatString1(ctx, p1, p2);
  JS_FreeValue(ctx, op1);
  JS_FreeValue(ctx, op2);
  return ret;
}