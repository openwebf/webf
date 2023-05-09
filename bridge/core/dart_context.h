/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_DART_CONTEXT_H_
#define WEBF_DART_CONTEXT_H_

#include <set>
#include "dart_context_data.h"
#include "dart_methods.h"

namespace webf {

class WebFPage;

// Dart Context are 1:1 corresponding to a Dart isolate thread.
// WebF support create many webf pages in a dart isolate, and data share between them are allowed.
class DartContext {
 public:
  DartContext(const uint64_t* dart_methods, int32_t dart_methods_length);
  ~DartContext();

  [[nodiscard]] const std::set<std::unique_ptr<WebFPage>>* pages() const { return &pages_; };
  void AddNewPage(std::unique_ptr<WebFPage>&& new_page);
  void RemovePage(const WebFPage* page);
  const std::unique_ptr<DartContextData>& EnsureData() const;

  FORCE_INLINE bool valid() { return is_valid_; }
  FORCE_INLINE JSRuntime* runtime() const { return runtime_; }
  FORCE_INLINE const std::unique_ptr<DartMethodPointer>& dartMethodPtr() const { return dart_method_ptr_; }

 private:
  bool is_valid_{false};
  // One dart context have one corresponding JSRuntime.
  JSRuntime* runtime_{nullptr};
  // Dart methods ptr should keep alive when ExecutingContext is disposing.
  const std::unique_ptr<DartMethodPointer> dart_method_ptr_ = nullptr;
  mutable std::unique_ptr<DartContextData> data_;
  std::set<std::unique_ptr<WebFPage>> pages_;
};

}  // namespace webf

#endif