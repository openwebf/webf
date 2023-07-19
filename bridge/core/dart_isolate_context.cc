/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_isolate_context.h"
#include <set>
#include "defined_properties_initializer.h"
#include "event_factory.h"
#include "html_element_factory.h"
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

thread_local JSRuntime* DartIsolateContext::runtime_{nullptr};
thread_local bool is_name_installed_ = false;
thread_local int64_t running_isolates_ = 0;

void InitializeBuiltInStrings(JSContext* ctx) {
  if (!is_name_installed_) {
    names_installer::Init(ctx);
    is_name_installed_ = true;
  }
}

DartIsolateContext::DartIsolateContext(const uint64_t* dart_methods, int32_t dart_methods_length)
    : is_valid_(true),
      running_thread_(std::this_thread::get_id()),
      dart_method_ptr_(std::make_unique<DartMethodPointer>(dart_methods, dart_methods_length)) {
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
  is_valid_ = true;
}

DartIsolateContext::~DartIsolateContext() {
  is_valid_ = false;
  pages_.clear();
  running_isolates_--;

  if (running_isolates_ == 0) {
    // Prebuilt strings stored in JSRuntime. Only needs to dispose when runtime disposed.
    names_installer::Dispose();
    HTMLElementFactory::Dispose();
    SVGElementFactory::Dispose();
    EventFactory::Dispose();
    ClearUpWires();
    data_.reset();
    JS_FreeRuntime(runtime_);
    runtime_ = nullptr;
    is_name_installed_ = false;
  }
}

void DartIsolateContext::AddNewPage(std::unique_ptr<WebFPage>&& new_page) {
  pages_.insert(std::move(new_page));
}

void DartIsolateContext::RemovePage(const webf::WebFPage* page) {
  for (auto it = pages_.begin(); it != pages_.end(); ++it) {
    if (it->get() == page) {
      pages_.erase(it);
      break;
    }
  }
}

}  // namespace webf