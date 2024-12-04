/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_BINDINGS_QJS_VALUE_CACHE_H_
#define WEBF_BINDINGS_QJS_VALUE_CACHE_H_

#include <quickjs/quickjs.h>
#include <unordered_map>
#include "foundation/macros.h"
#include "string_impl.h"

namespace webf {

// String cache helps convert WebF strings (std::shared_ptr<StringImpl>) into QJS strings by
// only creating a QuickJS string for a particular std::shared_ptr<std::string> once and caching it
// for future use.
class StringCache {
  USING_FAST_MALLOC(StringCache);

 public:
  explicit StringCache(JSRuntime* runtime) : runtime_(runtime) {}
  StringCache(const StringCache&) = delete;
  StringCache() = delete;
  StringCache& operator=(const StringCache&) = delete;

  JSValue GetJSValueFromString(JSContext* ctx, std::shared_ptr<StringImpl> string_impl);
  JSAtom GetJSAtomFromString(JSContext* ctx, std::shared_ptr<StringImpl> string_impl);
  std::shared_ptr<StringImpl> GetStringFromJSAtom(JSContext* ctx, JSAtom atom);

  void Dispose();

 private:
  JSAtom CreateStringAndInsertIntoCache(JSContext* ctx, std::shared_ptr<StringImpl>);

  JSRuntime* runtime_;
  std::unordered_map<std::shared_ptr<StringImpl>, JSAtom> string_cache_;
  std::unordered_map<JSAtom, std::shared_ptr<StringImpl>> atom_to_string_cache;
};

}  // namespace webf

#endif  // WEBF_BINDINGS_QJS_VALUE_CACHE_H_
