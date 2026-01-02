/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "qjs_dart_binding_object.h"

#include <vector>

#include "bindings/qjs/converter_impl.h"
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/member_installer.h"
#include "bindings/qjs/script_value.h"
#include "core/dart_binding_object.h"
#include "core/executing_context.h"
#include "foundation/native_value_converter.h"

namespace webf {

// ExecutionContextData lazily creates a per-wrapper-type "constructor object" (a JS object with a JSClassCall)
// the first time `prototypeForType()` is requested. For wrapper types that are not installed onto the JS global
// object, that constructor object would otherwise remain as an external ref at runtime teardown (DUMP_LEAKS),
// because ExecutionContextData only caches raw JSValue handles and does not explicitly JS_FreeValue() them.
//
// DartBindingObject is such a type (its JS-visible constructor is injected from Dart), so we anchor the internal
// constructor object onto the global object under a private name to transfer ownership into the JS object graph.
static void EnsureDartBindingObjectConstructorAnchored(ExecutingContext* context) {
  static constexpr const char* kCtorKey = "__webf_internal_dart_binding_object_constructor__";
  JSContext* ctx = context->ctx();

  JSValue existing = JS_GetPropertyStr(ctx, context->Global(), kCtorKey);
  bool already_defined = !JS_IsUndefined(existing) && !JS_IsException(existing);
  JS_FreeValue(ctx, existing);
  if (already_defined) {
    return;
  }

  // Transfer the cached constructor object's original reference to the global object.
  JSValue ctor = context->contextData()->constructorForType(DartBindingObject::GetStaticWrapperTypeInfo());
  JS_DefinePropertyValueStr(ctx, context->Global(), kCtorKey, ctor, JS_PROP_CONFIGURABLE);
}

static JSValue __webf_create_binding_object__(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute '__webf_create_binding_object__' : 1 argument required, but %d present.",
                            argc);
  }

  ExceptionState exception_state;
  ExecutingContext* context = ExecutingContext::From(ctx);
  if (!context || !context->IsContextValid())
    return JS_NULL;
  MemberMutationScope scope{context};

  auto&& class_name = Converter<IDLDOMString>::FromValue(ctx, argv[0], exception_state);
  if (UNLIKELY(exception_state.HasException())) {
    return exception_state.ToQuickJS();
  }

  std::vector<NativeValue> native_args;
  native_args.reserve(argc);
  native_args.emplace_back(NativeValueConverter<NativeTypeString>::ToNativeValue(ctx, class_name));

  for (int i = 1; i < argc; i++) {
    native_args.emplace_back(ScriptValue(ctx, argv[i]).ToNative(ctx, exception_state));
    if (UNLIKELY(exception_state.HasException())) {
      return exception_state.ToQuickJS();
    }
  }

  auto* binding_object = MakeGarbageCollected<DartBindingObject>(context);
  context->dartMethodPtr()->createBindingObject(context->isDedicated(), context->contextId(), binding_object->bindingObject(),
                                               CreateBindingObjectType::kCreateCustomBindingObject, native_args.data(),
                                               static_cast<int32_t>(native_args.size()));

  return binding_object->ToQuickJS();
}

void QJSDartBindingObject::Install(ExecutingContext* context) {
  InstallGlobalFunctions(context);
  EnsureDartBindingObjectConstructorAnchored(context);
}

void QJSDartBindingObject::InstallGlobalFunctions(ExecutingContext* context) {
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig{
      {"__webf_create_binding_object__", __webf_create_binding_object__, 1},
  };
  MemberInstaller::InstallFunctions(context, context->Global(), functionConfig);
}

}  // namespace webf
