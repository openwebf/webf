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

#ifndef QUICKJS_IC_H
#define QUICKJS_IC_H

#include "quickjs/quickjs.h"
#include "shape.h"
#include "types.h"

InlineCache *init_ic(JSContext *ctx);
int rebuild_ic(InlineCache *ic);
int resize_ic_hash(InlineCache *ic);
int free_ic(InlineCache *ic);
void add_ic_slot(InlineCacheUpdate *icu, JSAtom atom, JSObject *object,
                     uint32_t prop_offset, JSObject* prototype);
uint32_t add_ic_slot1(InlineCache *ic, JSAtom atom);
force_inline uint32_t get_ic_prop_offset(const InlineCacheUpdate *icu,
                                        JSShape *shape, JSObject **prototype) {
  uint32_t i, cache_offset = icu->offset;
  InlineCache *ic = icu->ic;
  InlineCacheRingSlot *cr;
  InlineCacheRingItem *buffer;
  assert(cache_offset < ic->capacity);
  cr = ic->cache + cache_offset;
  i = cr->index;
  for (;;) {
    buffer = cr->buffer + i;
    if (likely(buffer->shape == shape)) {
      cr->index = i;
      *prototype = buffer->proto;
      return buffer->prop_offset;
    }

    i = (i + 1) % IC_CACHE_ITEM_CAPACITY;
    if (unlikely(i == cr->index)) {
      break;
    }
  }

  *prototype = NULL;
  return INLINE_CACHE_MISS;
}

force_inline JSAtom get_ic_atom(InlineCache *ic, uint32_t cache_offset) {
  assert(cache_offset < ic->capacity);
  return ic->cache[cache_offset].atom;
}

int ic_watchpoint_delete_handler(JSRuntime* rt, intptr_t ref, JSAtom atom, void* target);
int ic_watchpoint_free_handler(JSRuntime* rt, intptr_t ref, JSAtom atom);
int ic_delete_shape_proto_watchpoints(JSRuntime *rt, JSShape *shape, JSAtom atom);
int ic_free_shape_proto_watchpoints(JSRuntime *rt, JSShape *shape);
#endif