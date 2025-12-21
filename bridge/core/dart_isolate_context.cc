/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_isolate_context.h"
#include <algorithm>
#include <iomanip>
#include <unordered_set>
#include <vector>
#include "../foundation/string/atomic_string_table.h"
#include "core/core_initializer.h"
#include "core/html/custom/widget_element_shape.h"
#include "defined_properties_initializer.h"
#include "event_factory.h"
#include "html_element_factory.h"
#include "logging.h"
#include "multiple_threading/looper.h"
#include "names_installer.h"
#include "page.h"
#include "svg_element_factory.h"

namespace webf {

thread_local std::unordered_set<DartWireContext*> alive_wires;

PageGroup::~PageGroup() {
  for (auto page : pages_) {
    delete page;
  }
}

void PageGroup::AddNewPage(webf::WebFPage* new_page) {
  assert(std::find(pages_.begin(), pages_.end(), new_page) == pages_.end());
  pages_.push_back(new_page);
}

void PageGroup::RemovePage(webf::WebFPage* page) {
  pages_.erase(std::find(pages_.begin(), pages_.end(), page));
}

void WatchDartWire(DartWireContext* wire) {
  alive_wires.emplace(wire);
}

bool IsDartWireAlive(DartWireContext* wire) {
  return alive_wires.find(wire) != alive_wires.end();
}

void DeleteDartWire(DartWireContext* wire) {
  alive_wires.erase(wire);
  delete wire;
}

static void ClearUpWires(JSRuntime* runtime) {
  for (auto& wire : alive_wires) {
    JS_FreeValueRT(runtime, wire->jsObject.QJSValue());
    wire->disposed = true;
  }
  alive_wires.clear();
}

thread_local JSRuntime* runtime_{nullptr};
thread_local DartIsolateContext* g_current_isolate_context = nullptr;
thread_local uint32_t running_dart_isolates = 0;
thread_local bool is_core_global_initialized = false;
thread_local std::unique_ptr<StringCache> DartIsolateContext::string_cache_{nullptr};

void InitializeCoreGlobals() {
  if (!is_core_global_initialized) {
    CoreInitializer::Initialize();
    is_core_global_initialized = true;
  }
}

bool IsWebFDefinedClass(JSClassID class_id) {
  return class_id > JS_CLASS_GC_TRACKER && class_id < JS_CLASS_CUSTOM_CLASS_INIT_COUNT;
}

void DartIsolateContext::InitializeJSRuntime() {
  if (runtime_ != nullptr)
    return;
  runtime_ = JS_NewRuntime();
  // Avoid stack overflow when running in multiple threads.
  JS_UpdateStackTop(runtime_);
#ifndef NDEBUG
  JS_SetMaxStackSize(runtime_, 8 * 1024 * 1024 - 1);
#endif
  // Bump up the built-in classId. To make sure the created classId are larger than JS_CLASS_CUSTOM_CLASS_INIT_COUNT.
  for (int i = 0; i < JS_CLASS_CUSTOM_CLASS_INIT_COUNT - JS_CLASS_GC_TRACKER + 2; i++) {
    JSClassID id{0};
    JS_NewClassID(&id);
  }
}

void DartIsolateContext::FinalizeJSRuntime() {
  if (running_dart_isolates > 0 || runtime_ == nullptr) {
    return;
  }

  string_cache_->Dispose();
  string_cache_ = nullptr;
  // Prebuilt strings stored in JSRuntime. Only needs to dispose when runtime disposed.
  names_installer::Dispose();
  HTMLElementFactory::Dispose();
  SVGElementFactory::Dispose();
  EventFactory::Dispose();
  ClearUpWires(runtime_);
  JS_TurnOnGC(runtime_);
  JS_FreeRuntime(runtime_);
  AtomicStringTable::Instance().Clear();
  runtime_ = nullptr;
  is_core_global_initialized = false;
}

DartIsolateContext* GetCurrentDartIsolateContext() { return g_current_isolate_context; }

DartIsolateContext::DartIsolateContext(const uint64_t* dart_methods, int32_t dart_methods_length)
    : is_valid_(true),
      running_thread_(std::this_thread::get_id()),
      dart_method_ptr_(std::make_unique<DartMethodPointer>(this, dart_methods, dart_methods_length)) {
  is_valid_ = true;
  running_dart_isolates++;
}

JSRuntime* DartIsolateContext::runtime() {
  assert_m(runtime_ != nullptr, "nullptr is unsafe");
  return runtime_;
}

DartIsolateContext::~DartIsolateContext() {}

void DartIsolateContext::InitializeGlobalsPerThread() {
  DCHECK(runtime_ != nullptr);
  if (string_cache_ == nullptr) {
    string_cache_ = std::make_unique<StringCache>(runtime_);
  }
  InitializeCoreGlobals();
  // Bind current isolate to this JS thread for helper access.
  g_current_isolate_context = this;
}

void DartIsolateContext::Dispose(multi_threading::Callback callback) {
  dispatcher_->Dispose([this, &callback]() {
    is_valid_ = false;
    pages_in_ui_thread_.clear();

    // Pretty-print metrics snapshot at teardown.
    auto snapshot = metrics_.SnapshotAllNamed();
    if (!snapshot.empty()) {
      // Collect items and sort by value desc, then key asc for readability.
      std::vector<std::pair<std::string, uint64_t>> items;
      items.reserve(snapshot.size());
      size_t max_key_len = 0;
      uint64_t total = 0;
      for (const auto& kv : snapshot) {
        items.emplace_back(kv.first, kv.second);
        max_key_len = std::max(max_key_len, kv.first.size());
        total += kv.second;
      }
      std::sort(items.begin(), items.end(), [](const auto& a, const auto& b) {
        if (a.second != b.second)
          return a.second > b.second;
        return a.first < b.first;
      });

      WEBF_LOG(INFO) << "===== WebF Metrics (DartIsolateContext) =====";
      WEBF_LOG(INFO) << "Entries: " << items.size() << ", Total: " << total;
      for (const auto& [key, value] : items) {
        std::ostringstream line;
        line << "  " << std::left << std::setw(static_cast<int>(max_key_len)) << key << " : " << value;
        WEBF_LOG(INFO) << line.str();
      }
      WEBF_LOG(INFO) << "============================================";
    }

    running_dart_isolates--;
    FinalizeJSRuntime();
    callback();
  });
}

void DartIsolateContext::InitializeNewPageInJSThread(PageGroup* page_group,
                                                     DartIsolateContext* dart_isolate_context,
                                                     double page_context_id,
                                                     int32_t sync_buffer_size,
                                                     int8_t use_legacy_ui_command,
                                                     int8_t enable_blink,
                                                     NativeWidgetElementShape* native_widget_element_shapes,
                                                     int32_t shape_len,
                                                     Dart_Handle dart_handle,
                                                     AllocateNewPageCallback result_callback) {
  DartIsolateContext::InitializeJSRuntime();
  dart_isolate_context->InitializeGlobalsPerThread();
  auto* page = new WebFPage(dart_isolate_context, true, sync_buffer_size, use_legacy_ui_command, page_context_id, native_widget_element_shapes,
                            shape_len, nullptr);

  if (enable_blink) {
    page->executingContext()->EnableBlinkEngine();
  }

  dart_isolate_context->dispatcher_->PostToDart(true, HandleNewPageResult, page_group, dart_handle, result_callback,
                                                page);
}

void DartIsolateContext::DisposePageAndKilledJSThread(DartIsolateContext* dart_isolate_context,
                                                      WebFPage* page,
                                                      int thread_group_id,
                                                      Dart_Handle dart_handle,
                                                      DisposePageCallback result_callback) {
  delete page;
  dart_isolate_context->dispatcher_->PostToDart(true, HandleDisposePageAndKillJSThread, dart_isolate_context,
                                                thread_group_id, dart_handle, result_callback);
}

void DartIsolateContext::DisposePageInJSThread(DartIsolateContext* dart_isolate_context,
                                               WebFPage* page,
                                               Dart_Handle dart_handle,
                                               DisposePageCallback result_callback) {
  delete page;
  dart_isolate_context->dispatcher_->PostToDart(true, HandleDisposePage, dart_handle, result_callback);
}

void* DartIsolateContext::AddNewPage(double thread_identity,
                                     int32_t sync_buffer_size,
                                     int8_t use_legacy_ui_command,
                                     int8_t enable_blink,
                                     void* native_widget_element_shapes,
                                     int32_t shape_len,
                                     Dart_Handle dart_handle,
                                     AllocateNewPageCallback result_callback) {
  bool is_in_flutter_ui_thread = thread_identity < 0;
  assert(is_in_flutter_ui_thread == false);

  int thread_group_id = static_cast<int>(thread_identity);

  PageGroup* page_group;
  if (!dispatcher_->IsThreadGroupExist(thread_group_id)) {
    dispatcher_->AllocateNewJSThread(thread_group_id);
    page_group = new PageGroup();
    dispatcher_->SetOpaqueForJSThread(thread_group_id, page_group, [](void* p) {
      delete static_cast<PageGroup*>(p);
      DartIsolateContext::FinalizeJSRuntime();
    });
  } else {
    page_group = static_cast<PageGroup*>(dispatcher_->GetOpaque(thread_group_id));
  }

  dispatcher_->PostToJs(true, thread_group_id, InitializeNewPageInJSThread, page_group, this, thread_identity,
                        sync_buffer_size, use_legacy_ui_command, enable_blink, static_cast<NativeWidgetElementShape*>(native_widget_element_shapes),
                        shape_len, dart_handle, result_callback);
  return nullptr;
}

std::unique_ptr<WebFPage> DartIsolateContext::InitializeNewPageSync(DartIsolateContext* dart_isolate_context,
                                                                    size_t sync_buffer_size,
                                                                    double page_context_id,
                                                                    void* native_widget_element_shapes,
                                                                    int32_t shape_len) {
  DartIsolateContext::InitializeJSRuntime();
  dart_isolate_context->InitializeGlobalsPerThread();
  auto page = std::make_unique<WebFPage>(dart_isolate_context, false, sync_buffer_size, 0, page_context_id,
                                         reinterpret_cast<NativeWidgetElementShape*>(native_widget_element_shapes),
                                         shape_len, nullptr);

  return page;
}

void* DartIsolateContext::AddNewPageSync(double thread_identity,
                                         void* native_widget_element_shapes,
                                         int32_t shape_len,
                                         int8_t enable_blink) {
  auto page = InitializeNewPageSync(this, 0, thread_identity, native_widget_element_shapes, shape_len);

  if (enable_blink) {
    page->executingContext()->EnableBlinkEngine();
  }

  void* p = page.get();
  pages_in_ui_thread_.emplace(std::move(page));
  return p;
}

void DartIsolateContext::HandleNewPageResult(PageGroup* page_group,
                                             Dart_Handle persistent_handle,
                                             AllocateNewPageCallback result_callback,
                                             WebFPage* new_page) {
  page_group->AddNewPage(new_page);
  Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent_handle);
  result_callback(handle, new_page);
  Dart_DeletePersistentHandle_DL(persistent_handle);
}

void DartIsolateContext::HandleDisposePage(Dart_Handle persistent_handle, DisposePageCallback result_callback) {
  Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent_handle);
  result_callback(handle);
  Dart_DeletePersistentHandle_DL(persistent_handle);
}

void DartIsolateContext::HandleDisposePageAndKillJSThread(DartIsolateContext* dart_isolate_context,
                                                          int thread_group_id,
                                                          Dart_Handle persistent_handle,
                                                          DisposePageCallback result_callback) {
  dart_isolate_context->dispatcher_->KillJSThreadSync(thread_group_id);

  Dart_Handle handle = Dart_HandleFromPersistent_DL(persistent_handle);
  result_callback(handle);
  Dart_DeletePersistentHandle_DL(persistent_handle);
}

void DartIsolateContext::RemovePage(double thread_identity,
                                    WebFPage* page,
                                    Dart_Handle dart_handle,
                                    DisposePageCallback result_callback) {
  bool is_in_flutter_ui_thread = thread_identity < 0;
  assert(is_in_flutter_ui_thread == false);

  int thread_group_id = static_cast<int>(page->contextId());
  auto page_group = static_cast<PageGroup*>(dispatcher_->GetOpaque(thread_group_id));

  page_group->RemovePage(page);

  if (page_group->Empty()) {
    page->executingContext()->SetContextInValid();
    dispatcher_->PostToJs(true, thread_group_id, DisposePageAndKilledJSThread, this, page, thread_group_id, dart_handle,
                          result_callback);
  } else {
    dispatcher_->PostToJs(true, thread_group_id, DisposePageInJSThread, this, page, dart_handle, result_callback);
  }
}

void DartIsolateContext::RemovePageSync(double thread_identity, WebFPage* page) {
  for (auto it = pages_in_ui_thread_.begin(); it != pages_in_ui_thread_.end(); ++it) {
    if (it->get() == page) {
      pages_in_ui_thread_.erase(it);
      break;
    }
  }

  if (pages_in_ui_thread_.empty()) {
    FinalizeJSRuntime();
  }
}

}  // namespace webf
