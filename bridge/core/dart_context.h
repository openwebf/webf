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
class DartIsolateContext;

// DartContext has a 1:1 correspondence with a flutter.ui thread.
// When running with a single Flutter engine and WebF, the relationship between DartContext, Dart Isolate and Flutter.ui
// thread is 1:1:1.
// When running with multiple Flutter engines and WebF, the relationship between DartContext, Dart Isolate and
// Flutter.ui thread is 1:n:1.
// Flutter supports creating multiple Dart isolates that share the same Flutter.ui thread, and WebF supports creating
// multiple WebF pages within a Dart Isolate, allowing data sharing between them.
class DartContext {
 public:
  DartContext();
  ~DartContext();

  void AddIsolate(std::unique_ptr<DartIsolateContext>&& dart_isolate_context);
  void RemoveIsolate(DartIsolateContext* dart_isolate_context);
  bool IsIsolateEmpty();
  const std::unique_ptr<DartContextData>& EnsureData() const;

  FORCE_INLINE bool valid() { return is_valid_; }
  FORCE_INLINE JSRuntime* runtime() const { return runtime_; }

 private:
  bool is_valid_{false};
  // One dart context have one corresponding JSRuntime.
  JSRuntime* runtime_{nullptr};
  mutable std::unique_ptr<DartContextData> data_;
  std::set<std::unique_ptr<DartIsolateContext>> isolates_;
};

// DartIsolateContext has a 1:1 correspondence with a dart isolates.
class DartIsolateContext {
 public:
  explicit DartIsolateContext(DartContext* owner_dart_context,
                              const uint64_t* dart_methods,
                              int32_t dart_methods_length);

  FORCE_INLINE DartContext* dartContext() { return owner_dart_context_; }
  FORCE_INLINE bool valid() { return is_valid_ && std::this_thread::get_id() == running_thread_; }
  FORCE_INLINE const std::unique_ptr<DartMethodPointer>& dartMethodPtr() const {
    assert(std::this_thread::get_id() == running_thread_);
    return dart_method_ptr_;
  }

  void AddNewPage(std::unique_ptr<WebFPage>&& new_page);
  void RemovePage(const WebFPage* page);

  ~DartIsolateContext();

 private:
  int is_valid_{false};
  DartContext* owner_dart_context_;
  std::set<std::unique_ptr<WebFPage>> pages_;
  std::thread::id running_thread_;
  // Dart methods ptr should keep alive when ExecutingContext is disposing.
  const std::unique_ptr<DartMethodPointer> dart_method_ptr_ = nullptr;
};

}  // namespace webf

#endif