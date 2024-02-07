/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_
#define WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_

#include "core/rust_api/rust_value.h"
#include "core/rust_api/exception_state.h"
#include "core/rust_api/document.h"
#include "core/rust_api/window.h"

namespace webf {

typedef struct Document Document;
typedef struct ExecutingContext ExecutingContext;
typedef struct Window Window;

using RustContextGetDocument = RustValue<Document, DocumentRustMethods> (*)(ExecutingContext*);
using RustContextGetWindow =  RustValue<Window, WindowRustMethods> (*)(ExecutingContext*);
using RustContextGetExceptionState = RustValue<SharedExceptionState, ExceptionStateRustMethods>(*)();

// Memory aligned and readable from Rust side.
// Only C type member can be included in this class, any C++ type and classes can is not allowed to use here.
struct ExecutingContextRustMethods {
  static RustValue<Document, DocumentRustMethods> document(ExecutingContext* context);
  static RustValue<Window, WindowRustMethods> window(ExecutingContext* context);
  static RustValue<SharedExceptionState, ExceptionStateRustMethods> CreateExceptionState();

  double version{1.0};
  RustContextGetDocument rust_context_get_document_{document};
  RustContextGetWindow rust_context_get_window_{window};
  RustContextGetExceptionState rust_context_get_exception_state_{CreateExceptionState};
};

}

#endif  // WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_
