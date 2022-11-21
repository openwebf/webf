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

#ifndef QUICKJS_STRING_H
#define QUICKJS_STRING_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "types.h"

#define ATOM_GET_STR_BUF_SIZE 64

/* return the max count from the hash size */
#define JS_ATOM_COUNT_RESIZE(n) ((n)*2)

typedef struct StringBuffer {
  JSContext* ctx;
  JSString* str;
  int len;
  int size;
  int is_wide_char;
  int error_status;
} StringBuffer;

static inline uint32_t atom_get_free(const JSAtomStruct* p) {
  return (uintptr_t)p >> 1;
}

static inline int is_digit(int c) {
  return c >= '0' && c <= '9';
}

static inline BOOL atom_is_free(const JSAtomStruct* p) {
  return (uintptr_t)p & 1;
}

static inline JSAtomStruct* atom_set_free(uint32_t v) {
  return (JSAtomStruct*)(((uintptr_t)v << 1) | 1);
}


JSString* js_alloc_string(JSContext* ctx, int max_len, int is_wide_char);
/* Note: the string contents are uninitialized */
JSString* js_alloc_string_rt(JSRuntime* rt, int max_len, int is_wide_char);

int JS_InitAtoms(JSRuntime* rt);
JSAtom __JS_NewAtomInit(JSRuntime* rt, const char* str, int len, int atom_type);
JSAtom __JS_FindAtom(JSRuntime* rt, const char* str, size_t len, int atom_type);
void JS_FreeAtomStruct(JSRuntime* rt, JSAtomStruct* p);
void __JS_FreeAtom(JSRuntime* rt, uint32_t i);
JSAtom JS_NewAtomInt64(JSContext* ctx, int64_t n);
/* Should only be used for debug. */
const char* JS_AtomGetStrRT(JSRuntime* rt, char* buf, int buf_size, JSAtom atom);
const char* JS_AtomGetStr(JSContext* ctx, char* buf, int buf_size, JSAtom atom);
JSValue __JS_AtomToValue(JSContext* ctx, JSAtom atom, BOOL force_string);
/* val must be a symbol */
JSAtom js_symbol_to_atom(JSContext* ctx, JSValue val);
/* return TRUE if the atom is an array index (i.e. 0 <= index <=
   2^32-2 and return its value */
BOOL JS_AtomIsArrayIndex(JSContext* ctx, uint32_t* pval, JSAtom atom);
/* This test must be fast if atom is not a numeric index (e.g. a
   method name). Return JS_UNDEFINED if not a numeric
   index. JS_EXCEPTION can also be returned. */
JSValue JS_AtomIsNumericIndex1(JSContext* ctx, JSAtom atom);
/* return -1 if exception or TRUE/FALSE */
int JS_AtomIsNumericIndex(JSContext* ctx, JSAtom atom);
/* Warning: 'p' is freed */
JSAtom JS_NewAtomStr(JSContext* ctx, JSString* p);
__maybe_unused void JS_DumpAtoms(JSRuntime* rt);
JSAtomKindEnum JS_AtomGetKind(JSContext* ctx, JSAtom v);
BOOL JS_AtomIsString(JSContext* ctx, JSAtom v);
JSAtom js_get_atom_index(JSRuntime* rt, JSAtomStruct* p);
int memcmp16_8(const uint16_t* src1, const uint8_t* src2, int len);
int memcmp16(const uint16_t* src1, const uint16_t* src2, int len);
int js_string_memcmp(const JSString* p1, const JSString* p2, int len);
/* return < 0, 0 or > 0 */
int js_string_compare(JSContext* ctx, const JSString* p1, const JSString* p2);
void copy_str16(uint16_t* dst, const JSString* p, int offset, int len);
JSValue JS_ConcatString1(JSContext* ctx, const JSString* p1, const JSString* p2);

__maybe_unused void JS_DumpString(JSRuntime* rt, const JSString* p);

/* same as JS_FreeValueRT() but faster */
static inline void js_free_string(JSRuntime* rt, JSString* str) {
  if (--str->header.ref_count <= 0) {
    if (str->atom_type) {
      JS_FreeAtomStruct(rt, str);
    } else {
#ifdef DUMP_LEAKS
      list_del(&str->link);
#endif
      js_free_rt(rt, str);
    }
  }
}
int JS_ResizeAtomHash(JSRuntime* rt, int new_hash_size);
static inline BOOL __JS_AtomIsTaggedInt(JSAtom v) {
  return (v & JS_ATOM_TAG_INT) != 0;
}
static inline BOOL __JS_AtomIsConst(JSAtom v) {
#if defined(DUMP_LEAKS) && DUMP_LEAKS > 1
  return (int32_t)v <= 0;
#else
  return (int32_t)v < JS_ATOM_END;
#endif
}

static inline JSAtom __JS_AtomFromUInt32(uint32_t v) {
  return v | JS_ATOM_TAG_INT;
}

static inline uint32_t __JS_AtomToUInt32(JSAtom atom) {
  return atom & ~JS_ATOM_TAG_INT;
}

static inline int is_num(int c) {
  return c >= '0' && c <= '9';
}

/* return TRUE if the string is a number n with 0 <= n <= 2^32-1 */
static inline BOOL is_num_string(uint32_t* pval, const JSString* p) {
  uint32_t n;
  uint64_t n64;
  int c, i, len;

  len = p->len;
  if (len == 0 || len > 10)
    return FALSE;
  if (p->is_wide_char)
    c = p->u.str16[0];
  else
    c = p->u.str8[0];
  if (is_num(c)) {
    if (c == '0') {
      if (len != 1)
        return FALSE;
      n = 0;
    } else {
      n = c - '0';
      for (i = 1; i < len; i++) {
        if (p->is_wide_char)
          c = p->u.str16[i];
        else
          c = p->u.str8[i];
        if (!is_num(c))
          return FALSE;
        n64 = (uint64_t)n * 10 + (c - '0');
        if ((n64 >> 32) != 0)
          return FALSE;
        n = n64;
      }
    }
    *pval = n;
    return TRUE;
  } else {
    return FALSE;
  }
}

/* XXX: could use faster version ? */
static inline uint32_t hash_string8(const uint8_t* str, size_t len, uint32_t h) {
  size_t i;

  for (i = 0; i < len; i++)
    h = h * 263 + str[i];
  return h;
}

static inline uint32_t hash_string16(const uint16_t* str, size_t len, uint32_t h) {
  size_t i;

  for (i = 0; i < len; i++)
    h = h * 263 + str[i];
  return h;
}
uint32_t hash_string(const JSString* str, uint32_t h);
int string_buffer_init2(JSContext* ctx, StringBuffer* s, int size, int is_wide);

static inline int string_buffer_init(JSContext* ctx, StringBuffer* s, int size) {
  return string_buffer_init2(ctx, s, size, 0);
}
void string_buffer_free(StringBuffer* s);
int string_buffer_set_error(StringBuffer* s);
no_inline int string_buffer_widen(StringBuffer* s, int size);
no_inline int string_buffer_realloc(StringBuffer* s, int new_len, int c);
no_inline int string_buffer_putc_slow(StringBuffer* s, uint32_t c);
/* 0 <= c <= 0xff */
int string_buffer_putc8(StringBuffer* s, uint32_t c);
/* 0 <= c <= 0xffff */
int string_buffer_putc16(StringBuffer* s, uint32_t c);
/* 0 <= c <= 0x10ffff */
int string_buffer_putc(StringBuffer* s, uint32_t c);
int string_get(const JSString* p, int idx);
int string_getc(const JSString* p, int* pidx);
int string_buffer_write8(StringBuffer* s, const uint8_t* p, int len);
int string_buffer_write16(StringBuffer* s, const uint16_t* p, int len);
/* appending an ASCII string */
int string_buffer_puts8(StringBuffer* s, const char* str);
int string_buffer_concat(StringBuffer* s, const JSString* p, uint32_t from, uint32_t to);
int string_buffer_concat_value(StringBuffer* s, JSValueConst v);
int string_buffer_concat_value_free(StringBuffer* s, JSValue v);
int string_buffer_fill(StringBuffer* s, int c, int count);
JSValue string_buffer_end(StringBuffer* s);

JSValue js_new_string8(JSContext* ctx, const uint8_t* buf, int len);
JSValue js_new_string16(JSContext* ctx, const uint16_t* buf, int len);
JSValue js_new_string_char(JSContext* ctx, uint16_t c);
JSValue js_sub_string(JSContext* ctx, JSString* p, int start, int end);
JSValue JS_ConcatString3(JSContext* ctx, const char* str1, JSValue str2, const char* str3);
/* op1 and op2 are converted to strings. For convience, op1 or op2 =
   JS_EXCEPTION are accepted and return JS_EXCEPTION.  */
JSValue JS_ConcatString(JSContext* ctx, JSValue op1, JSValue op2);

/* return a string atom containing name concatenated with str1 */
JSAtom js_atom_concat_str(JSContext* ctx, JSAtom name, const char* str1);
JSAtom js_atom_concat_num(JSContext* ctx, JSAtom name, uint32_t n);
static inline BOOL JS_IsEmptyString(JSValueConst v) {
  return JS_VALUE_GET_TAG(v) == JS_TAG_STRING && JS_VALUE_GET_STRING(v)->len == 0;
}

/* return TRUE if 'v' is a symbol with a string description */
BOOL JS_AtomSymbolHasDescription(JSContext* ctx, JSAtom v);
__maybe_unused void print_atom(JSContext* ctx, JSAtom atom);

/* 'p' is freed */
JSValue JS_NewSymbol(JSContext* ctx, JSString* p, int atom_type);
/* descr must be a non-numeric string atom */
JSValue JS_NewSymbolFromAtom(JSContext* ctx, JSAtom descr, int atom_type);

/* It is valid to call string_buffer_end() and all string_buffer functions even
   if string_buffer_init() or another string_buffer function returns an error.
   If the error_status is set, string_buffer_end() returns JS_EXCEPTION.
 */
int string_buffer_init2(JSContext* ctx, StringBuffer* s, int size, int is_wide);

#endif
