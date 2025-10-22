/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_DART_CONTEXT_H_
#define WEBF_DART_CONTEXT_H_

#include <unordered_set>
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/value_cache.h"
#include "dart_methods.h"
#include "multiple_threading/dispatcher.h"
#include "foundation/metrics_registry.h"

namespace webf {

// Forward declaration
class DartMethodPointer;

class WebFPage;
class DartIsolateContext;
class NativeWidgetElementShape;

class PageGroup {
 public:
  ~PageGroup();
  void AddNewPage(WebFPage* new_page);
  void RemovePage(WebFPage* page);
  bool Empty() { return pages_.empty(); }

  std::vector<WebFPage*>* pages() { return &pages_; };

 private:
  std::vector<WebFPage*> pages_;
};

struct DartWireContext {
  ScriptValue jsObject;
  bool is_dedicated;
  double context_id;
  bool disposed;
  multi_threading::Dispatcher* dispatcher;
};

void InitializeCoreGlobals();

void WatchDartWire(DartWireContext* wire);
bool IsDartWireAlive(DartWireContext* wire);
void DeleteDartWire(DartWireContext* wire);
bool IsWebFDefinedClass(JSClassID class_id);

// Get the current DartIsolateContext bound to this JS thread, if any.
DartIsolateContext* GetCurrentDartIsolateContext();

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
  FORCE_INLINE StringCache* stringCache() const { return string_cache_.get(); }
  FORCE_INLINE MetricsRegistry* metrics() { return &metrics_; }
  FORCE_INLINE const MetricsRegistry* metrics() const { return &metrics_; }

  void InitializeGlobalsPerThread();

  void* AddNewPage(double thread_identity,
                   int32_t sync_buffer_size,
                   int8_t use_legacy_ui_command,
                   int8_t enable_blink,
                   void* native_widget_element_shapes,
                   int32_t shape_len,
                   Dart_Handle dart_handle,
                   AllocateNewPageCallback result_callback);
  void* AddNewPageSync(double thread_identity, void* native_widget_element_shapes, int32_t shape_len, int8_t enable_blink = 0);
  void RemovePage(double thread_identity, WebFPage* page, Dart_Handle dart_handle, DisposePageCallback result_callback);
  void RemovePageSync(double thread_identity, WebFPage* page);

  ~DartIsolateContext();
  void Dispose(multi_threading::Callback callback);

 private:
  static void InitializeJSRuntime();
  static void FinalizeJSRuntime();
  static std::unique_ptr<WebFPage> InitializeNewPageSync(DartIsolateContext* dart_isolate_context,
                                                         size_t sync_buffer_size,
                                                         double page_context_id,
                                                         void* native_widget_element_shapes,
                                                         int32_t shape_len);
  static void InitializeNewPageInJSThread(PageGroup* page_group,
                                          DartIsolateContext* dart_isolate_context,
                                          double page_context_id,
                                          int32_t sync_buffer_size,
                                          int8_t use_legacy_ui_command,
                                          int8_t enable_blink,
                                          NativeWidgetElementShape* native_widget_element_shapes,
                                          int32_t shape_len,
                                          Dart_Handle dart_handle,
                                          AllocateNewPageCallback result_callback);
  static void DisposePageAndKilledJSThread(DartIsolateContext* dart_isolate_context,
                                           WebFPage* page,
                                           int thread_group_id,
                                           Dart_Handle dart_handle,
                                           DisposePageCallback result_callback);
  static void DisposePageInJSThread(DartIsolateContext* dart_isolate_context,
                                    WebFPage* page,
                                    Dart_Handle dart_handle,
                                    DisposePageCallback result_callback);
  static void HandleNewPageResult(PageGroup* page_group,
                                  Dart_Handle persistent_handle,
                                  AllocateNewPageCallback result_callback,
                                  WebFPage* new_page);
  static void HandleDisposePage(Dart_Handle persistent_handle, DisposePageCallback result_callback);
  static void HandleDisposePageAndKillJSThread(DartIsolateContext* dart_isolate_context,
                                               int thread_group_id,
                                               Dart_Handle persistent_handle,
                                               DisposePageCallback result_callback);

  int is_valid_{false};
  std::thread::id running_thread_;
  std::unordered_set<std::unique_ptr<WebFPage>> pages_in_ui_thread_;
  static thread_local std::unique_ptr<StringCache> string_cache_;
  std::unique_ptr<multi_threading::Dispatcher> dispatcher_ = nullptr;
  // Dart methods ptr should keep alive when ExecutingContext is disposing.
  const std::unique_ptr<DartMethodPointer> dart_method_ptr_ = nullptr;
  // Per-isolate metrics shared across all pages in the isolate.
  MetricsRegistry metrics_{};
};

}  // namespace webf

#endif
