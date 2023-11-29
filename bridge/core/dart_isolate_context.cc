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

void* DartIsolateContext::AddNewPage(double thread_identity) {
  bool is_in_flutter_ui_thread = thread_identity < 0;

  if (!is_in_flutter_ui_thread) {
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

    auto* page = static_cast<WebFPage*>(dispatcher_->PostToJsSync(
        true, thread_group_id,
        [](DartIsolateContext* dart_isolate_context, double page_context_id) -> void* {
          InitializeJSRuntime();
          return new webf::WebFPage(dart_isolate_context, true, page_context_id, nullptr);
        },
        this, thread_identity));

    page_group->AddNewPage(page);

    return page;
  } else {
    auto page = std::make_unique<webf::WebFPage>(this, false, thread_identity, nullptr);
    void* p = page.get();
    pages_in_ui_thread_.emplace(std::move(page));
    return p;
  }
}

void DartIsolateContext::RemovePage(double thread_identity, webf::WebFPage* page) {
  bool is_in_flutter_ui_thread = thread_identity < 0;

  if (!is_in_flutter_ui_thread) {
    int thread_group_id = static_cast<int>(page->contextId());
    auto page_group = static_cast<PageGroup*>(dispatcher_->GetOpaque(thread_group_id));
    page_group->RemovePage(page);

    if (page_group->Empty()) {
      dispatcher_->PostToJsSync(
          true, thread_group_id, [](WebFPage* page) { delete page; }, page);
      dispatcher_->KillJSThread(thread_group_id);
    } else {
      dispatcher_->PostToJsSync(
          true, thread_group_id, [](WebFPage* page) { delete page; }, page);
    }
  } else {
    for (auto it = pages_in_ui_thread_.begin(); it != pages_in_ui_thread_.end(); ++it) {
      if (it->get() == page) {
        pages_in_ui_thread_.erase(it);
        break;
      }
    }
  }
}

}  // namespace webf