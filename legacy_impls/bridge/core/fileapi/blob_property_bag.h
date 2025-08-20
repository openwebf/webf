/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_FILEAPI_BLOB_PROPERTY_BAG_H_
#define BRIDGE_CORE_FILEAPI_BLOB_PROPERTY_BAG_H_

#include <quickjs/quickjs.h>
#include <memory>
#include "core/executing_context.h"

namespace webf {

class BlobPropertyBag final {
 public:
  using ImplType = std::shared_ptr<BlobPropertyBag>;

  static std::shared_ptr<BlobPropertyBag> Create(JSContext* ctx, JSValue value, ExceptionState& exceptionState);

  const std::string& type() const { return m_type; }

 private:
  void FillMemberFromQuickjsObject(JSContext* ctx, JSValue value, ExceptionState& exceptionState);
  std::string m_type;
};

}  // namespace webf

#endif  // BRIDGE_CORE_FILEAPI_BLOB_PROPERTY_BAG_H_
