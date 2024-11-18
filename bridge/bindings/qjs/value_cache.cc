/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include <cassert>
#include "value_cache.h"
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

  JSAtom new_string_atom = JS_NewAtomLen(ctx, string_impl->Characters8(), string_impl->length());
  string_cache_[string_impl] = JS_DupAtom(ctx, new_string_atom);
  atom_to_string_cache[JS_DupAtom(ctx, new_string_atom)] = string_impl;

  JS_FreeAtom(ctx, new_string_atom);

  return new_string_atom;
}

std::shared_ptr<StringImpl> StringCache::GetStringFromJSAtom(JSContext* ctx, JSAtom atom) {
  if (atom_to_string_cache.find(atom) == atom_to_string_cache.end()) {
    const char* str = JS_AtomToCString(ctx, atom);
    std::shared_ptr<StringImpl> string_impl = AtomicStringTable::Instance().Add(str, strlen(str));
    atom_to_string_cache[JS_DupAtom(ctx, atom)] = string_impl;
    JS_FreeCString(ctx, str);
    return string_impl;
  }

  return atom_to_string_cache[atom];
}

void StringCache::Dispose() {
  for(auto&& item : string_cache_) {
    JS_FreeAtomRT(runtime_, item.second);
  }

  for(auto&& item : atom_to_string_cache) {
    JS_FreeAtomRT(runtime_, item.first);
  }
}

}