/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_DART_METHOD_WRAPPER_H
#define MULTI_THREADING_DART_METHOD_WRAPPER_H

#include <memory>

#include "core/dart_methods.h"
#include "foundation/macros.h"

namespace webf {

namespace multi_threading {

using namespace webf;

/**
 * @brief c++ call dart method wrapper, for supporting multi-threading.
 * it's call on c++ QuickJS thread.
 */
class DartMethodWrapper {
 public:
  static void* GetDartIsolateContext();  // need call on c++ QuickJS thread.

 public:
  DartMethodWrapper(void* dart_isolate_context, const uint64_t* dart_methods, int32_t dart_methods_length);

  FORCE_INLINE const std::unique_ptr<DartMethodPointer>& dartMethodPtr() const { return dart_method_ptr_; }

 private:
  const std::unique_ptr<DartMethodPointer> dart_method_ptr_;
};

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_DART_METHOD_WRAPPER_H