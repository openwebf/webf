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

#include "ic.h"

static force_inline uint32_t get_index_hash(JSAtom atom, int hash_bits) {
  return (atom * 0x9e370001) >> (32 - hash_bits);
}

InlineCache *init_ic(JSContext *ctx) {
  InlineCache *ic;
  ic = js_malloc(ctx, sizeof(InlineCache));
  if (unlikely(!ic))
    goto fail;
  ic->count = 0;
  ic->hash_bits = 2;
  ic->capacity = 1 << ic->hash_bits;
  ic->ctx = ctx;
  ic->hash = js_malloc(ctx, sizeof(ic->hash[0]) * ic->capacity);
  if (unlikely(!ic->hash))
    goto fail;
  memset(ic->hash, 0, sizeof(ic->hash[0]) * ic->capacity);
  ic->cache = NULL;
  ic->updated = FALSE;
  ic->updated_offset = 0;
  return ic;
fail:
  return NULL;
}

int rebuild_ic(InlineCache *ic) {
  uint32_t i, count;
  InlineCacheHashSlot *ch;
  if (ic->count == 0)
    goto end;
  count = 0;
  ic->cache = js_malloc(ic->ctx, sizeof(InlineCacheRingSlot) * ic->count);
  if (unlikely(!ic->cache))
    goto fail;
  memset(ic->cache, 0, sizeof(InlineCacheRingSlot) * ic->count);
  for (i = 0; i < ic->capacity; i++) {
    for (ch = ic->hash[i]; ch != NULL; ch = ch->next) {
      ch->index = count++;
      ic->cache[ch->index].atom = JS_DupAtom(ic->ctx, ch->atom);
      ic->cache[ch->index].index = 0;
    }
  }
end:
  return 0;
fail:
  return -1;
}

int resize_ic_hash(InlineCache *ic) {
  uint32_t new_capacity, i, h;
  InlineCacheHashSlot *ch, *ch_next;
  InlineCacheHashSlot **new_hash;
  ic->hash_bits += 1;
  new_capacity = 1 << ic->hash_bits;
  new_hash = js_malloc(ic->ctx, sizeof(ic->hash[0]) * new_capacity);
  if (unlikely(!new_hash))
    goto fail;
  memset(new_hash, 0, sizeof(ic->hash[0]) * new_capacity);
  for (i = 0; i < ic->capacity; i++) {
    for (ch = ic->hash[i]; ch != NULL; ch = ch_next) {
      h = get_index_hash(ch->atom, ic->hash_bits);
      ch_next = ch->next;
      ch->next = new_hash[h];
      new_hash[h] = ch;
    }
  }
  js_free(ic->ctx, ic->hash);
  ic->hash = new_hash;
  ic->capacity = new_capacity;
  return 0;
fail:
  return -1;
}

int free_ic(InlineCache *ic) {
  uint32_t i, j;
  InlineCacheHashSlot *ch, *ch_next;
  InlineCacheRingItem *buffer;
  for (i = 0; i < ic->count; i++) {
    buffer = ic->cache[i].buffer;
    JS_FreeAtom(ic->ctx, ic->cache[i].atom);
    for (j = 0; j < IC_CACHE_ITEM_CAPACITY; j++) {
      js_free_shape_null(ic->ctx->rt, buffer[j].shape);
    }
  }
  for (i = 0; i < ic->capacity; i++) {
    for (ch = ic->hash[i]; ch != NULL; ch = ch_next) {
      ch_next = ch->next;
      JS_FreeAtom(ic->ctx, ch->atom);
      js_free(ic->ctx, ch);
    }
  }
  if (ic->count > 0)
    js_free(ic->ctx, ic->cache);
  js_free(ic->ctx, ic->hash);
  js_free(ic->ctx, ic);
  return 0;
}

uint32_t add_ic_slot(InlineCache *ic, JSAtom atom, JSObject *object,
                     uint32_t prop_offset) {
  int32_t i;
  uint32_t h;
  InlineCacheHashSlot *ch;
  InlineCacheRingSlot *cr;
  JSShape *sh;
  cr = NULL;
  h = get_index_hash(atom, ic->hash_bits);
  for (ch = ic->hash[h]; ch != NULL; ch = ch->next)
    if (ch->atom == atom) {
      cr = ic->cache + ch->index;
      break;
    }

  assert(cr != NULL);
  i = cr->index;
  for (;;) {
    if (object->shape == cr->buffer[i].shape) {
      cr->buffer[i].prop_offset = prop_offset;
      goto end;
    }

    i = (i + 1) % IC_CACHE_ITEM_CAPACITY;
    if (unlikely(i == cr->index))
      break;
  }

  sh = cr->buffer[i].shape;
  cr->buffer[i].shape = js_dup_shape(object->shape);
  js_free_shape_null(ic->ctx->rt, sh);
  cr->buffer[i].prop_offset = prop_offset;
end:
  return ch->index;
}

uint32_t add_ic_slot1(InlineCache *ic, JSAtom atom) {
  uint32_t h;
  InlineCacheHashSlot *ch;
  if (ic->count + 1 >= ic->capacity && resize_ic_hash(ic))
    goto end;
  h = get_index_hash(atom, ic->hash_bits);
  for (ch = ic->hash[h]; ch != NULL; ch = ch->next)
    if (ch->atom == atom)
      goto end;
  ch = js_malloc(ic->ctx, sizeof(InlineCacheHashSlot));
  if (unlikely(!ch))
    goto end;
  ch->atom = JS_DupAtom(ic->ctx, atom);
  ch->index = 0;
  ch->next = ic->hash[h];
  ic->hash[h] = ch;
  ic->count += 1;
end:
  return 0;
}