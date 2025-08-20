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

#include "quickjs/cutils.h"
#include "malloc.h"
#include "exception.h"

void js_trigger_gc(JSRuntime* rt, size_t size) {
  BOOL force_gc;
#ifdef FORCE_GC_AT_MALLOC
  force_gc = TRUE;
#else
  force_gc = ((rt->malloc_state.malloc_size + size) > rt->malloc_gc_threshold);
#endif
  if (force_gc) {
#ifdef DUMP_GC
    printf("GC: size=%" PRIu64 "\n", (uint64_t)rt->malloc_state.malloc_size);
#endif
    JS_RunGC(rt);
    rt->malloc_gc_threshold = rt->malloc_state.malloc_size + (rt->malloc_state.malloc_size >> 1);
  }
}


/* default memory allocation functions with memory limitation */
static inline size_t js_def_malloc_usable_size(void* ptr) {
#if ENABLE_MI_MALLOC
  return mi_usable_size(ptr);
#else
#if defined(__APPLE__)
  return malloc_size(ptr);
#elif defined(_WIN32)
  return _msize(ptr);
#elif defined(EMSCRIPTEN)
  return 0;
#elif defined(__linux__)
  return malloc_usable_size(ptr);
#else
  /* change this to `return 0;` if compilation fails */
  return malloc_usable_size(ptr);
#endif
#endif
}

size_t js_malloc_usable_size_unknown(const void* ptr) {
  return 0;
}

void* js_malloc_rt(JSRuntime* rt, size_t size) {
  return rt->mf.js_malloc(&rt->malloc_state, size);
}

void js_free_rt(JSRuntime* rt, void* ptr) {
  rt->mf.js_free(&rt->malloc_state, ptr);
}

void* js_realloc_rt(JSRuntime* rt, void* ptr, size_t size) {
  return rt->mf.js_realloc(&rt->malloc_state, ptr, size);
}

size_t js_malloc_usable_size_rt(JSRuntime* rt, const void* ptr) {
  return rt->mf.js_malloc_usable_size(ptr);
}

void* js_mallocz_rt(JSRuntime* rt, size_t size) {
  void* ptr;
  ptr = js_malloc_rt(rt, size);
  if (!ptr)
    return NULL;
  return memset(ptr, 0, size);
}

#ifdef CONFIG_BIGNUM
/* called by libbf */
void* js_bf_realloc(void* opaque, void* ptr, size_t size) {
  JSRuntime* rt = opaque;
  return js_realloc_rt(rt, ptr, size);
}
#endif /* CONFIG_BIGNUM */

/* Throw out of memory in case of error */
void* js_malloc(JSContext* ctx, size_t size) {
  void* ptr;
  ptr = js_malloc_rt(ctx->rt, size);
  if (unlikely(!ptr)) {
    JS_ThrowOutOfMemory(ctx);
    return NULL;
  }
  return ptr;
}

/* Throw out of memory in case of error */
void* js_mallocz(JSContext* ctx, size_t size) {
  void* ptr;
  ptr = js_mallocz_rt(ctx->rt, size);
  if (unlikely(!ptr)) {
    JS_ThrowOutOfMemory(ctx);
    return NULL;
  }
  return ptr;
}

void js_free(JSContext* ctx, void* ptr) {
  js_free_rt(ctx->rt, ptr);
}

/* Throw out of memory in case of error */
void* js_realloc(JSContext* ctx, void* ptr, size_t size) {
  void* ret;
  ret = js_realloc_rt(ctx->rt, ptr, size);
  if (unlikely(!ret && size != 0)) {
    JS_ThrowOutOfMemory(ctx);
    return NULL;
  }
  return ret;
}

/* store extra allocated size in *pslack if successful */
void* js_realloc2(JSContext* ctx, void* ptr, size_t size, size_t* pslack) {
  void* ret;
  ret = js_realloc_rt(ctx->rt, ptr, size);
  if (unlikely(!ret && size != 0)) {
    JS_ThrowOutOfMemory(ctx);
    return NULL;
  }
  if (pslack) {
    size_t new_size = js_malloc_usable_size_rt(ctx->rt, ret);
    *pslack = (new_size > size) ? new_size - size : 0;
  }
  return ret;
}

size_t js_malloc_usable_size(JSContext* ctx, const void* ptr) {
  return js_malloc_usable_size_rt(ctx->rt, ptr);
}

/* Throw out of memory exception in case of error */
char* js_strndup(JSContext* ctx, const char* s, size_t n) {
  char* ptr;
  ptr = js_malloc(ctx, n + 1);
  if (ptr) {
    memcpy(ptr, s, n);
    ptr[n] = '\0';
  }
  return ptr;
}

char* js_strdup(JSContext* ctx, const char* str) {
  return js_strndup(ctx, str, strlen(str));
}

no_inline int js_realloc_array(JSContext* ctx, void** parray, int elem_size, int* psize, int req_size) {
  int new_size;
  size_t slack;
  void* new_array;
  /* XXX: potential arithmetic overflow */
  new_size = max_int(req_size, *psize * 9 / 2);
  new_array = js_realloc2(ctx, *parray, new_size * elem_size, &slack);
  if (!new_array)
    return -1;
  new_size += slack / elem_size;
  *psize = new_size;
  *parray = new_array;
  return 0;
}

void* js_def_malloc(JSMallocState* s, size_t size) {
  void* ptr;

  /* Do not allocate zero bytes: behavior is platform dependent */
  assert(size != 0);

  if (unlikely(s->malloc_size + size > s->malloc_limit))
    return NULL;

#if ENABLE_MI_MALLOC
  ptr = mi_malloc(size);
#else
  ptr = malloc(size);
#endif

  if (!ptr)
    return NULL;

  s->malloc_count++;
  s->malloc_size += js_def_malloc_usable_size(ptr) + MALLOC_OVERHEAD;
  return ptr;
}

void js_def_free(JSMallocState* s, void* ptr) {
  if (!ptr)
    return;

  s->malloc_count--;
  s->malloc_size -= js_def_malloc_usable_size(ptr) + MALLOC_OVERHEAD;
#if ENABLE_MI_MALLOC
  mi_free(ptr);
#else
  free(ptr);
#endif
}

void* js_def_realloc(JSMallocState* s, void* ptr, size_t size) {
  size_t old_size;

  if (!ptr) {
    if (size == 0)
      return NULL;
    return js_def_malloc(s, size);
  }
  old_size = js_def_malloc_usable_size(ptr);
  if (size == 0) {
    s->malloc_count--;
    s->malloc_size -= old_size + MALLOC_OVERHEAD;
#if ENABLE_MI_MALLOC
    mi_free(ptr);
#else
    free(ptr);
#endif
    return NULL;
  }
  if (s->malloc_size + size - old_size > s->malloc_limit)
    return NULL;

#if ENABLE_MI_MALLOC
  ptr = mi_realloc(ptr, size);
#else
  ptr = realloc(ptr, size);
#endif
  if (!ptr)
    return NULL;

  s->malloc_size += js_def_malloc_usable_size(ptr) - old_size;
  return ptr;
}

/* use -1 to disable automatic GC */
void JS_SetGCThreshold(JSRuntime *rt, size_t gc_threshold)
{
  rt->malloc_gc_threshold = gc_threshold;
}