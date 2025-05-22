/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#include "file.h"

namespace webf {

File* File::Create(webf::ExecutingContext* context,
                   std::vector<std::shared_ptr<BlobPart>>& data,
                   const webf::AtomicString& file_name,
                   webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<File>(context->ctx(), data, file_name, nullptr);
}

File* File::Create(webf::ExecutingContext* context,
                   std::vector<std::shared_ptr<BlobPart>>& data,
                   const webf::AtomicString& file_name,
                   std::shared_ptr<FileOptions> property,
                   webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<File>(context->ctx(), data, file_name, property);
}

bool File::IsFile() const {
  return true;
}

}  // namespace webf