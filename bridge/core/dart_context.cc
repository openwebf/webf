/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_context.h"
#include "defined_properties_initializer.h"
#include "event_factory.h"
#include "html_element_factory.h"
#include "names_installer.h"
#include "page.h"

namespace webf {

DartContext::DartContext(const uint64_t* dart_methods, int32_t dart_methods_length)
    : dart_method_ptr_(std::make_unique<DartMethodPointer>(dart_methods, dart_methods_length)) {
  runtime_ = JS_NewRuntime();
  // Avoid stack overflow when running in multiple threads.
  JS_UpdateStackTop(runtime_);
  // Bump up the built-in classId. To make sure the created classId are larger than JS_CLASS_CUSTOM_CLASS_INIT_COUNT.
  for (int i = 0; i < JS_CLASS_CUSTOM_CLASS_INIT_COUNT - JS_CLASS_GC_TRACKER + 2; i++) {
    JSClassID id{0};
    JS_NewClassID(&id);
  }
  is_valid_ = true;
}

DartContext::~DartContext() {
  is_valid_ = false;
  pages_.clear();
  // Prebuilt strings stored in JSRuntime. Only needs to dispose when runtime disposed.
  DefinedPropertiesInitializer::Dispose();
  names_installer::Dispose();
  HTMLElementFactory::Dispose();
  EventFactory::Dispose();
  data_.reset();
  JS_FreeRuntime(runtime_);
  runtime_ = nullptr;
}

void DartContext::AddNewPage(std::unique_ptr<WebFPage>&& new_page) {
  pages_.insert(std::move(new_page));
}

void DartContext::RemovePage(const WebFPage* page) {
  for (auto it = pages_.begin(); it != pages_.end(); ++it) {
    if (it->get() == page) {
      pages_.erase(it);
      break;
    }
  }
}

const std::unique_ptr<DartContextData>& DartContext::EnsureData() const {
  if (data_ == nullptr) {
    data_ = std::make_unique<DartContextData>();
  }
  return data_;
}

}  // namespace webf