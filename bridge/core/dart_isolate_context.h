/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_DART_CONTEXT_H_
#define WEBF_DART_CONTEXT_H_

#include <set>
#include "bindings/qjs/script_value.h"
#include "dart_context_data.h"
#include "dart_method_wrapper.h"
#include "dart_methods.h"
#include "dispatcher.h"

namespace webf {

class WebFPage;
class DartIsolateContext;

struct DartWireContext {
  ScriptValue jsObject;
};

void InitializeBuiltInStrings(JSContext* ctx);

void WatchDartWire(DartWireContext* wire);
bool IsDartWireAlive(DartWireContext* wire);
void DeleteDartWire(DartWireContext* wire);

// DartIsolateContext has a 1:1 correspondence with a dart isolates.
class DartIsolateContext {
 public:
  explicit DartIsolateContext(bool dedicated_thread, const uint64_t* dart_methods, int32_t dart_methods_length);

  FORCE_INLINE JSRuntime* runtime() { return runtime_; }
  FORCE_INLINE bool valid() { return is_valid_ && std::this_thread::get_id() == running_thread_; }
  FORCE_INLINE const std::unique_ptr<DartMethodPointer>& dartMethodPtr() const {
    assert(std::this_thread::get_id() == running_thread_);
    return dart_method_wrapper_->dartMethodPtr();
  }
  FORCE_INLINE const std::unique_ptr<DartMethodPointer>& dartMethodOriginalPtr() const {
    assert(std::this_thread::get_id() == running_thread_);
    return dart_method_ptr_;
  }
  FORCE_INLINE const std::unique_ptr<multi_threading::Dispatcher>& dispatcher() const { return dispatcher_; }
  FORCE_INLINE void SetDispatcher(std::unique_ptr<multi_threading::Dispatcher>&& dispatcher) {
    dispatcher_ = std::move(dispatcher);
  }

  const std::unique_ptr<DartContextData>& EnsureData() const;

  void AddNewPage(std::unique_ptr<WebFPage>&& new_page);
  void RemovePage(const WebFPage* page);

  ~DartIsolateContext();

 private:
  int is_valid_{false};
  std::set<std::unique_ptr<WebFPage>> pages_;
  std::thread::id running_thread_;
  mutable std::unique_ptr<DartContextData> data_;
  static thread_local JSRuntime* runtime_;
  std::unique_ptr<multi_threading::Dispatcher> dispatcher_ = nullptr;
  // Dart methods ptr should keep alive when ExecutingContext is disposing.
  const std::unique_ptr<DartMethodPointer> dart_method_ptr_ = nullptr;
  const std::unique_ptr<multi_threading::DartMethodWrapper> dart_method_wrapper_ = nullptr;
};

}  // namespace webf

#endif