/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "value_cache.h"
#include <cassert>
#include "../../foundation/string/atomic_string_table.h"

namespace webf {

JSValue StringCache::GetJSValueFromString(JSContext* ctx, std::shared_ptr<StringImpl> string_impl) {
  JSAtom atom = GetJSAtomFromString(ctx, std::move(string_impl));
  return JS_AtomToValue(ctx, atom);
}

JSAtom StringCache::GetJSAtomFromString(JSContext* ctx, std::shared_ptr<StringImpl> string_impl) {
  DCHECK(string_impl);
  if (!string_impl->length()) {
    return JS_ATOM_NULL;
  }

  auto cached_qjs_string = string_cache_.find(string_impl);

  if (cached_qjs_string != string_cache_.end()) {
    return cached_qjs_string->second;
  }

  return CreateStringAndInsertIntoCache(ctx, string_impl);
}

JSAtom StringCache::CreateStringAndInsertIntoCache(JSContext* ctx, std::shared_ptr<StringImpl> string_impl) {
  DCHECK(string_impl);
  DCHECK(!string_cache_.contains(string_impl));
  DCHECK(string_impl->length());

  JSAtom new_string_atom;
  
  if (string_impl->Is8Bit()) {
    // For 8-bit strings (Latin1), use the characters directly
    auto str = JS_NewRawUTF8String(ctx, string_impl->Characters8(), string_impl->length());
    new_string_atom = JS_ValueToAtom(ctx, str);
    JS_FreeValue(ctx, str);
  } else {
    // For 16-bit strings (UTF-16), use QuickJS's Unicode atom function
    new_string_atom = JS_NewUnicodeAtom(ctx, reinterpret_cast<const uint16_t*>(string_impl->Characters16()), string_impl->length());
  }
  
  string_cache_[string_impl] = JS_DupAtom(ctx, new_string_atom);

  JSAtom cache_key;
  if (UNLIKELY(atom_to_string_cache.contains(new_string_atom)))  {
    cache_key = new_string_atom;
  } else {
    cache_key = JS_DupAtom(ctx, new_string_atom);
  }
  atom_to_string_cache[cache_key] = string_impl;

  JS_FreeAtom(ctx, new_string_atom);

  return new_string_atom;
}

std::shared_ptr<StringImpl> StringCache::GetStringFromJSAtom(JSContext* ctx, JSAtom atom) {
  auto it = atom_to_string_cache.find(atom);
  if (it != atom_to_string_cache.end()) {
    return it->second;
  }
  
  // Atom not in cache, create StringImpl and cache it
  bool is_wide_char = !JS_AtomIsTaggedInt(atom) && JS_IsAtomWideChar(JS_GetRuntime(ctx), atom);
  std::shared_ptr<StringImpl> string_impl;
  
  if (LIKELY(!is_wide_char)) {
    uint32_t slen;
    auto* str = reinterpret_cast<const LChar*>(JS_AtomRawCharacter8(JS_GetRuntime(ctx), atom, &slen));
    string_impl = AtomicStringTable::Instance().AddLatin1(str, slen);
  } else {
    uint32_t slen;
    auto* wstrs = reinterpret_cast<const UChar*>(JS_AtomRawCharacter16(JS_GetRuntime(ctx), atom, &slen));
    string_impl = AtomicStringTable::Instance().Add(wstrs, slen);
  }
  
  // Cache the mapping - duplicate the atom since we're storing it
  atom_to_string_cache[JS_DupAtom(ctx, atom)] = string_impl;
  return string_impl;
}

void StringCache::Dispose() {
  for (auto&& item : string_cache_) {
    JS_FreeAtomRT(runtime_, item.second);
  }

  for (auto&& item : atom_to_string_cache) {
    JS_FreeAtomRT(runtime_, item.first);
  }
  
  // Clear the maps to release all StringImpl references
  string_cache_.clear();
  atom_to_string_cache.clear();
}

}  // namespace webf