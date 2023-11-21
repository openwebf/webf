/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_isolate_context.h"
#include <set>
#include "defined_properties_initializer.h"
#include "event_factory.h"
#include "html_element_factory.h"
#include "logging.h"
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
thread_local bool is_name_installed_ = false;
thread_local int64_t running_isolates_ = 0;

void InitializeBuiltInStrings(JSContext* ctx) {
  if (!is_name_installed_) {
    names_installer::Init(ctx);
    is_name_installed_ = true;
  }
}

void DartIsolateContext::InitializeJSRuntime() {
  if (runtime_ == nullptr) {
    runtime_ = JS_NewRuntime();
  }
  running_isolates_++;
  // Avoid stack overflow when running in multiple threads.
  JS_UpdateStackTop(runtime_);
  // Bump up the built-in classId. To make sure the created classId are larger than JS_CLASS_CUSTOM_CLASS_INIT_COUNT.
  for (int i = 0; i < JS_CLASS_CUSTOM_CLASS_INIT_COUNT - JS_CLASS_GC_TRACKER + 2; i++) {
    JSClassID id{0};
    JS_NewClassID(&id);
  }
}

void DartIsolateContext::FinalizeJSRuntime() {
  // Prebuilt strings stored in JSRuntime. Only needs to dispose when runtime disposed.
  names_installer::Dispose();
  HTMLElementFactory::Dispose();
  SVGElementFactory::Dispose();
  EventFactory::Dispose();
  ClearUpWires();
  data_.reset();
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
  InitializeJSRuntime();
}

JSRuntime* DartIsolateContext::runtime() {
  return runtime_;
}

DartIsolateContext::~DartIsolateContext() {
  is_valid_ = false;
  running_isolates_--;
  dispatcher_.reset();
  pages_in_ui_thread_.clear();
  assert(running_isolates_ == 0);
  FinalizeJSRuntime();
}

void* DartIsolateContext::AddNewPage(bool is_dedicated, int32_t new_page_context_id) {
  if (is_dedicated) {
    dispatcher_->AllocateNewJSThread(new_page_context_id);
    auto* page = dispatcher_->PostToJsSync(
        true, new_page_context_id,
        [](DartIsolateContext* dart_isolate_context, int32_t page_context_id) -> void* {
          InitializeJSRuntime();
          return new webf::WebFPage(dart_isolate_context, true, page_context_id, nullptr);
        },
        this, new_page_context_id);
    dispatcher_->SetOpaqueForJSThread(new_page_context_id, page, [](void* p) {
      delete static_cast<webf::WebFPage*>(p);
      DartIsolateContext::FinalizeJSRuntime();
    });
    return page;
  } else {
    auto page = std::make_unique<webf::WebFPage>(this, false, new_page_context_id, nullptr);
    void* p = page.get();
    pages_in_ui_thread_.emplace(std::move(page));
    return p;
  }
}

void DartIsolateContext::RemovePage(bool is_dedicated, const webf::WebFPage* page) {
  if (is_dedicated) {
    int32_t page_context_id = page->contextId;
    dispatcher_->KillJSThread(page_context_id);
  } else {
    for (auto it = pages_in_ui_thread_.begin(); it != pages_in_ui_thread_.end(); ++it) {
      if (it->get() == page) {
        pages_in_ui_thread_.erase(it);
        break;
      }
    }
  }
}

thread_local std::unique_ptr<DartContextData> DartIsolateContext::data_{};

}  // namespace webf