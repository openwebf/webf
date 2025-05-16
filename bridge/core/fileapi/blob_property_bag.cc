/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "blob_property_bag.h"

namespace webf {

std::shared_ptr<BlobPropertyBag> BlobPropertyBag::Create(JSContext* ctx,
                                                         JSValue value,
                                                         ExceptionState& exceptionState) {
  auto bag = std::make_shared<BlobPropertyBag>();
  bag->FillMemberFromQuickjsObject(ctx, value, exceptionState);
  return bag;
}

void BlobPropertyBag::FillMemberFromQuickjsObject(JSContext* ctx, JSValue value, ExceptionState& exceptionState) {
  if (!JS_IsObject(value)) {
    return;
  }

  JSValue typeValue = JS_GetPropertyStr(ctx, value, "type");
  const char* ctype = JS_ToCString(ctx, typeValue);
  m_type = std::string(ctype);

  JS_FreeCString(ctx, ctype);
  JS_FreeValue(ctx, typeValue);
}

}  // namespace webf
