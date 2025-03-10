/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "native_loader.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "core/executing_context.h"
#include "plugin_api/webf_value.h"

namespace webf {

NativeLoader::NativeLoader(webf::ExecutingContext* context) : ScriptWrappable(context->ctx()) {}

static void ExecuteNativeLibrary(PluginLibraryEntryPoint entry_point,
                                 NativeValue* lib_name,
                                 NativeLibraryLoadContext* native_library_load_context,
                                 void* imported_data) {
  // Encounter loading error.
  if (entry_point == nullptr) {
    ExceptionState exception_state;
    auto* context = native_library_load_context->context;
    exception_state.ThrowException(context->ctx(), ErrorType::InternalError, (const char*)(imported_data));
    JSValue exception_value = ExceptionState::CurrentException(context->ctx());
    native_library_load_context->promise_resolver->Reject(exception_value);
    JS_FreeValue(context->ctx(), exception_value);
  } else {
    auto* meta_data = new NativeLibraryMetaData{lib_name, native_library_load_context};
    auto entry_data = WebFValue<ExecutingContext, ExecutingContextWebFMethods>{
        native_library_load_context->context, native_library_load_context->context->publicMethodPtr(),
        native_library_load_context->context->status()};
    void* result = entry_point(entry_data, meta_data);
    native_library_load_context->context->RegisterNativeLibraryMetaData(meta_data);
    native_library_load_context->context->RunRustFutureTasks();
  }
}

static void HandleNativeLibraryLoad(PluginLibraryEntryPoint entry_point,
                                    NativeValue* lib_name,
                                    void* initialize_data_ptr,
                                    double context_id,
                                    void* imported_data) {
  auto* p_native_library_load_context = static_cast<NativeLibraryLoadContext*>(initialize_data_ptr);

  auto* context = p_native_library_load_context->context;

  if (!context->IsContextValid())
    return;

  context->dartIsolateContext()->dispatcher()->PostToJs(context->isDedicated(), context_id, ExecuteNativeLibrary,
                                                        entry_point, lib_name, p_native_library_load_context,
                                                        imported_data);
}

ScriptPromise NativeLoader::loadNativeLibrary(const AtomicString& lib_name,
                                              const ScriptValue& import_object,
                                              ExceptionState& exception_state) {
  auto resolver = ScriptPromiseResolver::Create(GetExecutingContext());
  auto* context = GetExecutingContext();
  auto* p_native_library_load_context = new NativeLibraryLoadContext();

  p_native_library_load_context->context = context;
  p_native_library_load_context->promise_resolver = resolver;

  context->dartMethodPtr()->loadNativeLibrary(context->isDedicated(), context->contextId(),
                                              lib_name.ToNativeString(ctx()).release(), p_native_library_load_context,
                                              /* TODO */ nullptr, HandleNativeLibraryLoad);

  return resolver->Promise();
}

}  // namespace webf
