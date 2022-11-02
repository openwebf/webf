/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "dart_context.h"
#include "page.h"

namespace webf {

DartContext::DartContext(const uint64_t* dart_methods, int32_t dart_methods_length):
      dart_method_ptr_(std::make_unique<DartMethodPointer>(dart_methods, dart_methods_length)) {

}

DartContext::~DartContext() {
  data_.reset();
  for(auto& page : pages_) {
    delete page;
  }
}

void DartContext::AddNewPage(WebFPage* new_page)  {
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

}