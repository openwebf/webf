/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_isolate_context.h"
#include <set>
#include "defined_properties_initializer.h"
#include "event_factory.h"
#include "html_element_factory.h"
#include "logging.h"
#include "multiple_threading/looper.h"
#include "names_installer.h"
#include "page.h"
#include "svg_element_factory.h"

namespace webf {

thread_local std::set<DartWireContext*> alive_wires;

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

static void ClearUpWires() {
  for (auto& wire : alive_wires) {
    delete wire;
  }
  alive_wires.clear();
}

const std::unique_ptr<DartContextData>& DartIsolateContext::EnsureData() const {
  if (data_ == nullptr) {
    data_ = std::make_unique<DartContextData>();
  }
  return data_;
}

thread_local JSRuntime* runtime_{nullptr};
thread_local uint32_t running_dart_isolates = 0;
thread_local bool is_name_installed_ = false;

void InitializeBuiltInStrings(JSContext* ctx) {
  if (!is_name_installed_) {
    names_installer::Init(ctx);
    is_name_installed_ = true;
  }
}

void DartIsolateContext::InitializeJSRuntime() {
  if (runtime_ != nullptr)
    return;
  runtime_ = JS_NewRuntime();
  // Avoid stack overflow when running in multiple threads.
  JS_UpdateStackTop(runtime_);
  // Bump up the built-in classId. To make sure the created classId are larger than JS_CLASS_CUSTOM_CLASS_INIT_COUNT.
  for (int i = 0; i < JS_CLASS_CUSTOM_CLASS_INIT_COUNT - JS_CLASS_GC_TRACKER + 2; i++) {
    JSClassID id{0};
    JS_NewClassID(&id);
  }
}

void DartIsolateContext::FinalizeJSRuntime() {
  if (running_dart_isolates > 0)
    return;

  // Prebuilt strings stored in JSRuntime. Only needs to dispose when runtime disposed.
  names_installer::Dispose();
  HTMLElementFactory::Dispose();
  SVGElementFactory::Dispose();
  EventFactory::Dispose();
  ClearUpWires();
  JS_TurnOnGC(runtime_);
  JS_FreeRuntime(runtime_);
  runtime_ = nullptr;
  is_name_installed_ = false;
}

DartIsolateContext::DartIsolateContext(const uint64_t* dart_methods, int32_t dart_methods_length)
    : is_valid_(true),
      running_thread_(std::this_thread::get_id()),
      dart_method_ptr_(std::make_unique<DartMethodPointer>(this, dart_methods, dart_methods_length)) {
  is_valid_ = true;
  running_dart_isolates++;
  InitializeJSRuntime();
}

JSRuntime* DartIsolateContext::runtime() {
  return runtime_;
}

DartIsolateContext::~DartIsolateContext() {
  is_valid_ = false;
  dispatcher_.reset();
  data_.reset();
  pages_in_ui_thread_.clear();
  running_dart_isolates--;
  FinalizeJSRuntime();
}

class PageGroup {
 public:
  ~PageGroup() {
    for (auto page : pages_) {
      delete page;
    }
  }

  void AddNewPage(WebFPage* new_page) {
    assert(std::find(pages_.begin(), pages_.end(), new_page) == pages_.end());
    pages_.push_back(new_page);
  }

  void RemovePage(WebFPage* page) { pages_.erase(std::find(pages_.begin(), pages_.end(), page)); }

  bool Empty() { return pages_.empty(); }

 private:
  std::vector<WebFPage*> pages_;
};

void DartIsolateContext::InitializeNewPageInJSThread(PageGroup* page_group,
                                                     DartIsolateContext* dart_isolate_context,
                                                     double page_context_id,
                                                     Dart_Handle dart_handle,
                                                     AllocateNewPageCallback result_callback) {
  DartIsolateContext::InitializeJSRuntime();
  auto* page = new WebFPage(dart_isolate_context, true, page_context_id, nullptr);
  dart_isolate_context->dispatcher_->PostToDart(true, HandleNewPageResult, page_group, dart_handle, result_callback,
                                                page);
}

void DartIsolateContext::DisposePageAndKilledJSThread(DartIsolateContext* dart_isolate_context,
                                                      WebFPage* page,
                                                      int thread_group_id,
                                                      Dart_Handle dart_handle,
                                                      DisposePageCallback result_callback) {
  delete page;
  dart_isolate_context->dispatcher_->PostToDart(true, HandleDisposePageAndKillJSThread, dart_isolate_context, thread_group_id, dart_handle, result_callback);
}

void DartIsolateContext::DisposePageInJSThread(DartIsolateContext* dart_isolate_context,
                                               WebFPage* page,
                                               Dart_Handle dart_handle,
                                               DisposePageCallback result_callback) {
  delete page;
  dart_isolate_context->dispatcher_->PostToDart(true, HandleDisposePage, dart_handle, result_callback);
}

void* DartIsolateContext::AddNewPage(double thread_identity,
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
                        dart_handle, result_callback);
  return nullptr;
}

void* DartIsolateContext::AddNewPageSync(double thread_identity) {
  auto page = std::make_unique<WebFPage>(this, false, thread_identity, nullptr);
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

void DartIsolateContext::HandleDisposePageAndKillJSThread(DartIsolateContext* dart_isolate_context, int thread_group_id, Dart_Handle persistent_handle, DisposePageCallback result_callback) {
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
    dispatcher_->PostToJs(
        true, thread_group_id, DisposePageAndKilledJSThread,
        this, page, thread_group_id,
        dart_handle, result_callback);
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
}

}  // namespace webf
