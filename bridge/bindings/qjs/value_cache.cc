/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "value_cache.h"
#include <cassert>
#include "foundation/atomic_string_table.h"

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
    // For 8-bit strings (UTF-8), use the characters directly
    new_string_atom = JS_NewAtomLen(ctx, string_impl->Characters8(), string_impl->length());
  } else {
    // For 16-bit strings (UTF-16), use QuickJS's Unicode atom function
    new_string_atom = JS_NewUnicodeAtom(ctx, reinterpret_cast<const uint16_t*>(string_impl->Characters16()), string_impl->length());
  }
  
  string_cache_[string_impl] = JS_DupAtom(ctx, new_string_atom);
  atom_to_string_cache[JS_DupAtom(ctx, new_string_atom)] = string_impl;

  JS_FreeAtom(ctx, new_string_atom);

  return new_string_atom;
}

std::shared_ptr<StringImpl> StringCache::GetStringFromJSAtom(JSContext* ctx, JSAtom atom) {
  if (atom_to_string_cache.find(atom) == atom_to_string_cache.end()) {
    bool is_wide_char = !JS_AtomIsTaggedInt(atom) && JS_IsAtomWideChar(JS_GetRuntime(ctx), atom);
    if (LIKELY(!is_wide_char)) {
      uint32_t slen;
      const char* str = reinterpret_cast<const char*>(JS_AtomRawCharacter8(JS_GetRuntime(ctx), atom, &slen));
      std::shared_ptr<StringImpl> string_impl = AtomicStringTable::Instance().Add(str, slen);
      atom_to_string_cache[JS_DupAtom(ctx, atom)] = string_impl;
      return string_impl;
    } else {
      uint32_t slen;
      const char16_t* wstrs = reinterpret_cast<const char16_t*>(JS_AtomRawCharacter16(JS_GetRuntime(ctx), atom, &slen));
      std::shared_ptr<StringImpl> string_impl = AtomicStringTable::Instance().Add(wstrs, slen);
      atom_to_string_cache[JS_DupAtom(ctx, atom)] = string_impl;
      return string_impl;
    }
  }

  return atom_to_string_cache[atom];
}

void StringCache::Dispose() {
  for (auto&& item : string_cache_) {
    JS_FreeAtomRT(runtime_, item.second);
  }

  for (auto&& item : atom_to_string_cache) {
    JS_FreeAtomRT(runtime_, item.first);
  }
}

}  // namespace webf