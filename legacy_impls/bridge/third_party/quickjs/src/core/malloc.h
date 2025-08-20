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

#ifndef QUICKJS_MALLOC_H
#define QUICKJS_MALLOC_H

#include "quickjs/quickjs.h"
#include "quickjs/cutils.h"
#include "types.h"
#if ENABLE_MI_MALLOC
#include "mimalloc.h"
#endif

void js_trigger_gc(JSRuntime* rt, size_t size);
no_inline int js_realloc_array(JSContext* ctx, void** parray, int elem_size, int* psize, int req_size);

/* resize the array and update its size if req_size > *psize */
static inline int js_resize_array(JSContext* ctx, void** parray, int elem_size, int* psize, int req_size) {
  if (unlikely(req_size > *psize))
    return js_realloc_array(ctx, parray, elem_size, psize, req_size);
  else
    return 0;
}

static inline void js_dbuf_init(JSContext* ctx, DynBuf* s) {
  dbuf_init2(s, ctx->rt, (DynBufReallocFunc*)js_realloc_rt);
}


void* js_def_malloc(JSMallocState* s, size_t size);
void js_def_free(JSMallocState* s, void* ptr);
void* js_def_realloc(JSMallocState* s, void* ptr, size_t size);
size_t js_malloc_usable_size_unknown(const void* ptr);


#if CONFIG_BIGNUM
void* js_bf_realloc(void* opaque, void* ptr, size_t size);
#endif

#endif