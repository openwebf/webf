/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_DART_CONTEXT_H_
#define WEBF_DART_CONTEXT_H_

#include <set>
#include "bindings/qjs/script_value.h"
#include "dart_context_data.h"
#include "dart_methods.h"
#include "multiple_threading/dispatcher.h"

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
  explicit DartIsolateContext(const uint64_t* dart_methods, int32_t dart_methods_length);

  JSRuntime* runtime();
  FORCE_INLINE bool valid() { return is_valid_; }
  FORCE_INLINE DartMethodPointer* dartMethodPtr() const { return dart_method_ptr_.get(); }
  FORCE_INLINE const std::unique_ptr<multi_threading::Dispatcher>& dispatcher() const { return dispatcher_; }
  FORCE_INLINE void SetDispatcher(std::unique_ptr<multi_threading::Dispatcher>&& dispatcher) {
    dispatcher_ = std::move(dispatcher);
  }

  const std::unique_ptr<DartContextData>& EnsureData() const;

  void* AddNewPage(double thread_identity);
  void RemovePage(double thread_identity, WebFPage* page);

  ~DartIsolateContext();

 private:
  static void InitializeJSRuntime();
  static void FinalizeJSRuntime();

  int is_valid_{false};
  std::thread::id running_thread_;
  mutable std::unique_ptr<DartContextData> data_;
  std::set<std::unique_ptr<WebFPage>> pages_in_ui_thread_;
  std::unique_ptr<multi_threading::Dispatcher> dispatcher_ = nullptr;
  // Dart methods ptr should keep alive when ExecutingContext is disposing.
  const std::unique_ptr<DartMethodPointer> dart_method_ptr_ = nullptr;
};

}  // namespace webf

#endif