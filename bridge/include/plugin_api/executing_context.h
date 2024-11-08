/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_
#define WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_

#include "document.h"
#include "exception_state.h"
#include "window.h"

namespace webf {

class Document;
class ExecutingContext;
class Window;

using PublicContextGetDocument = WebFValue<Document, DocumentPublicMethods> (*)(ExecutingContext*);
using PublicContextGetWindow = WebFValue<Window, WindowPublicMethods> (*)(ExecutingContext*);
using PublicContextGetExceptionState = WebFValue<SharedExceptionState, ExceptionStatePublicMethods> (*)();
using PublicFinishRecordingUIOperations = void (*)(ExecutingContext* context);

// Memory aligned and readable from WebF side.
// Only C type member can be included in this class, any C++ type and classes can is not allowed to use here.
struct ExecutingContextWebFMethods {
  static WebFValue<Document, DocumentPublicMethods> document(ExecutingContext* context);
  static WebFValue<Window, WindowPublicMethods> window(ExecutingContext* context);
  static WebFValue<SharedExceptionState, ExceptionStatePublicMethods> CreateExceptionState();
  static void FinishRecordingUIOperations(ExecutingContext* context);

  double version{1.0};
  PublicContextGetDocument rust_context_get_document_{document};
  PublicContextGetWindow rust_context_get_window_{window};
  PublicContextGetExceptionState rust_context_get_exception_state_{CreateExceptionState};
  PublicFinishRecordingUIOperations finish_recording_ui_operations{FinishRecordingUIOperations};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_
