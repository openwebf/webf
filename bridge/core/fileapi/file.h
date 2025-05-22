/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#ifndef WEBF_CORE_FILEAPI_FILE_H_
#define WEBF_CORE_FILEAPI_FILE_H_

#include <chrono>
#include "blob.h"
#include "qjs_blob_options.h"
#include "qjs_file_options.h"

namespace webf {

class File : public Blob {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = File*;
  static File* Create(ExecutingContext* context,
                      std::vector<std::shared_ptr<BlobPart>>& data,
                      const AtomicString& file_name,
                      ExceptionState& exception_state);
  static File* Create(ExecutingContext* context,
                      std::vector<std::shared_ptr<BlobPart>>& data,
                      const AtomicString& file_name,
                      std::shared_ptr<FileOptions> property,
                      ExceptionState& exception_state);

  explicit File(JSContext* ctx,
                std::vector<std::shared_ptr<BlobPart>>& data,
                AtomicString filename,
                const std::shared_ptr<FileOptions>& file_options)
      : file_name_(std::move(filename)), Blob(ctx, data, file_options) {
    if (file_options != nullptr && file_options->hasLastModified()) {
      last_modified_ = file_options->lastModified();
    } else {
      auto now = std::chrono::system_clock::now();
      last_modified_ = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();
    }
  };

  bool IsFile() const override;

  AtomicString name() const {
    return file_name_;
  }

  double lastModified() const {
    return last_modified_;
  }

 private:

  AtomicString file_name_;
  double last_modified_;
};

template <>
struct DowncastTraits<File> {
  static bool AllowFrom(const Blob& blob) { return blob.IsFile(); }
};

}  // namespace webf

#endif  // WEBF_CORE_FILEAPI_FILE_H_
