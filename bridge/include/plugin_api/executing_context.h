/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_
#define WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_

#include "foundation/native_value.h"
#include "core/native/native_function.h"
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
using PublicWebFInvokeModule = NativeValue (*)(ExecutingContext*,
                                              const char*,
                                              const char*,
                                              SharedExceptionState*);
using PublicWebFInvokeModuleWithParams = NativeValue (*)(ExecutingContext*,
                                              const char*,
                                              const char*,
                                              NativeValue*,
                                              SharedExceptionState*);
using PublicWebFInvokeModuleWithParamsAndCallback = NativeValue (*)(ExecutingContext*,
                                              const char*,
                                              const char*,
                                              NativeValue*,
                                              WebFNativeFunctionContext*,
                                              SharedExceptionState*);
using PublicContextSetTimeout = int32_t (*)(ExecutingContext*,
                                            WebFNativeFunctionContext*,
                                            int32_t,
                                            SharedExceptionState*);
using PublicContextSetInterval = int32_t (*)(ExecutingContext*,
                                             WebFNativeFunctionContext*,
                                             int32_t,
                                             SharedExceptionState*);
using PublicContextClearTimeout = void (*)(ExecutingContext*, int32_t, SharedExceptionState*);
using PublicContextClearInterval = void (*)(ExecutingContext*, int32_t, SharedExceptionState*);

// Memory aligned and readable from WebF side.
// Only C type member can be included in this class, any C++ type and classes can is not allowed to use here.
struct ExecutingContextWebFMethods {
  static WebFValue<Document, DocumentPublicMethods> document(ExecutingContext* context);
  static WebFValue<Window, WindowPublicMethods> window(ExecutingContext* context);
  static WebFValue<SharedExceptionState, ExceptionStatePublicMethods> CreateExceptionState();
  static void FinishRecordingUIOperations(ExecutingContext* context);
  static NativeValue WebFInvokeModule(ExecutingContext* context,
                                  const char* module_name,
                                  const char* method,
                                  SharedExceptionState* shared_exception_state);
  static NativeValue WebFInvokeModuleWithParams(ExecutingContext* context,
                                  const char* module_name,
                                  const char* method,
                                  NativeValue* params,
                                  SharedExceptionState* shared_exception_state);
  static NativeValue WebFInvokeModuleWithParamsAndCallback(ExecutingContext* context,
                                  const char* module_name,
                                  const char* method,
                                  NativeValue* params,
                                  WebFNativeFunctionContext* callback_context,
                                  SharedExceptionState* shared_exception_state);
  static int32_t SetTimeout(ExecutingContext* context,
                            WebFNativeFunctionContext* callback_context,
                            int32_t timeout,
                            SharedExceptionState* shared_exception_state);
  static int32_t SetInterval(ExecutingContext* context,
                             WebFNativeFunctionContext* callback_context,
                             int32_t timeout,
                             SharedExceptionState* shared_exception_state);
  static void ClearTimeout(ExecutingContext* context, int32_t timeout_id, SharedExceptionState* shared_exception_state);
  static void ClearInterval(ExecutingContext* context,
                            int32_t interval_id,
                            SharedExceptionState* shared_exception_state);

  double version{1.0};
  PublicContextGetDocument context_get_document{document};
  PublicContextGetWindow context_get_window{window};
  PublicContextGetExceptionState context_get_exception_state{CreateExceptionState};
  PublicFinishRecordingUIOperations context_finish_recording_ui_operations{FinishRecordingUIOperations};
  PublicWebFInvokeModule context_webf_invoke_module{WebFInvokeModule};
  PublicWebFInvokeModuleWithParams context_webf_invoke_module_with_params{WebFInvokeModuleWithParams};
  PublicWebFInvokeModuleWithParamsAndCallback context_webf_invoke_module_with_params_and_callback{WebFInvokeModuleWithParamsAndCallback};
  PublicContextSetTimeout context_set_timeout{SetTimeout};
  PublicContextSetInterval context_set_interval{SetInterval};
  PublicContextClearTimeout context_clear_timeout{ClearTimeout};
  PublicContextClearInterval context_clear_interval{ClearInterval};
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_EXECUTING_CONTEXT_H_
