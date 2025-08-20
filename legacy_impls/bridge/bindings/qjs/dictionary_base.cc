/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dictionary_base.h"

namespace webf {

JSValue DictionaryBase::toQuickJS(JSContext* ctx) const {
  JSValue object = JS_NewObject(ctx);
  if (!FillQJSObjectWithMembers(ctx, object)) {
    return JS_NULL;
  }
  return object;
}

}  // namespace webf
