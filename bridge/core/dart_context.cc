/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_context.h"
#include "defined_properties_initializer.h"
#include "event_factory.h"
#include "html_element_factory.h"
#include "names_installer.h"
#include "page.h"
#include "svg_element_factory.h"

namespace webf {

DartContext::DartContext(const uint64_t* dart_methods, int32_t dart_methods_length)
    : dart_method_ptr_(std::make_unique<DartMethodPointer>(dart_methods, dart_methods_length)) {}

DartContext::~DartContext() {
  pages_.clear();
}

void DartContext::AddNewPage(WebFPage* new_page) {
  pages_.emplace(new_page);
}

void DartContext::RemovePage(WebFPage* page) {
  pages_.erase(page);
}

const std::unique_ptr<DartContextData>& DartContext::EnsureData() const {
  if (data_ == nullptr) {
    data_ = std::make_unique<DartContextData>();
  }
  return data_;
}

void DartContext::InitializeJSRuntime() {
  runtime_ = JS_NewRuntime();
  // Avoid stack overflow when running in multiple threads.
  JS_UpdateStackTop(runtime_);
  // Bump up the built-in classId. To make sure the created classId are larger than JS_CLASS_CUSTOM_CLASS_INIT_COUNT.
  for (int i = 0; i < JS_CLASS_CUSTOM_CLASS_INIT_COUNT - JS_CLASS_GC_TRACKER + 2; i++) {
    JSClassID id{0};
    JS_NewClassID(&id);
  }
}

void DartContext::DisposeJSRuntime() {
  // Prebuilt strings stored in JSRuntime. Only needs to dispose when runtime disposed.
  DefinedPropertiesInitializer::Dispose();
  names_installer::Dispose();
  HTMLElementFactory::Dispose();
  SVGElementFactory::Dispose();
  EventFactory::Dispose();
  data_.reset();
  JS_FreeRuntime(runtime_);
  runtime_ = nullptr;
}

}  // namespace webf