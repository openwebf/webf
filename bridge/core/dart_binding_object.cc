/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "dart_binding_object.h"

#include <string>
#include <vector>

#include "bindings/qjs/cppgc/mutation_scope.h"
#include "bindings/qjs/script_value.h"
#include "core/dart_methods.h"
#include "foundation/native_value_converter.h"

namespace webf {

static inline bool IsSymbolAtom(JSContext* ctx, JSAtom atom) {
  JSValue atom_value = JS_AtomToValue(ctx, atom);
  bool is_symbol = JS_IsSymbol(atom_value);
  JS_FreeValue(ctx, atom_value);
  return is_symbol;
}

static inline AtomicString KeyFromAtom(JSContext* ctx, JSAtom atom) {
  if (JS_AtomIsTaggedInt(atom)) {
    const uint32_t index = JS_AtomToUInt32(atom);
    const std::string s = std::to_string(index);
    return AtomicString::CreateFromUTF8(s.c_str(), s.size());
  }
  return AtomicString(ctx, atom);
}

static inline JSValue NativeValueToJSValue(JSContext* ctx, const NativeValue& native_value) {
  ScriptValue script_value(ctx, native_value);
  return JS_DupValue(ctx, script_value.QJSValue());
}

static JSValue InvokeMethodCallback(JSContext* ctx,
                                    JSValueConst this_val,
                                    int argc,
                                    JSValueConst* argv,
                                    int magic,
                                    JSValue* data) {
  ExceptionState exception_state;
  ExecutingContext* context = ExecutingContext::From(ctx);
  if (!context || !context->IsContextValid())
    return JS_NULL;
  MemberMutationScope scope{context};

  // Ensure `this` is a DartBindingObject.
  auto* receiver = toScriptWrappable<DartBindingObject>(this_val);
  if (receiver == nullptr) {
    return JS_ThrowTypeError(ctx, "Illegal invocation");
  }

  AtomicString method_name(ctx, data[0]);
  std::vector<NativeValue> native_args;
  native_args.reserve(argc);
  for (int i = 0; i < argc; i++) {
    native_args.emplace_back(ScriptValue(ctx, argv[i]).ToNative(ctx, exception_state));
    if (UNLIKELY(exception_state.HasException())) {
      return exception_state.ToQuickJS();
    }
  }

  // magic: 1 = sync, 2 = async
  if (magic == 2) {
    ScriptPromise promise = receiver->InvokeBindingMethodAsync(method_name, argc, native_args.data(), exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return exception_state.ToQuickJS();
    }
    return promise.ToQuickJS();
  }

  NativeValue result = receiver->InvokeBindingMethod(method_name, argc, native_args.data(), FlushUICommandReason::kStandard,
                                                     exception_state);
  if (UNLIKELY(exception_state.HasException())) {
    return exception_state.ToQuickJS();
  }
  return NativeValueToJSValue(ctx, result);
}

static const WrapperTypeInfo kDartBindingObjectWrapperTypeInfo{
    JS_CLASS_DART_BINDING_OBJECT,
    "DartBindingObject",
    nullptr,
    nullptr,
    nullptr,
    nullptr,
    DartBindingObject::StringPropertyGetter,
    DartBindingObject::StringPropertySetter,
    DartBindingObject::PropertyChecker,
    nullptr,
    nullptr,
};

const WrapperTypeInfo& DartBindingObject::wrapper_type_info_ = kDartBindingObjectWrapperTypeInfo;

DartBindingObject::DartBindingObject(ExecutingContext* context) : BindingObject(context->ctx()) {}

DartBindingObject::DartBindingObject(ExecutingContext* context, NativeBindingObject* native_binding_object)
    : BindingObject(context->ctx(), native_binding_object) {}

bool DartBindingObject::HasBindingProperty(const AtomicString& prop, ExceptionState& exception_state) const {
  const NativeValue argv[] = {Native_NewString(prop.ToNativeString().release())};
  NativeValue result =
      InvokeBindingMethod(BindingMethodCallOperations::kHasProperty, 1, argv, FlushUICommandReason::kStandard, exception_state);
  if (UNLIKELY(exception_state.HasException())) {
    return false;
  }
  return NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
}

int DartBindingObject::GetBindingMethodType(const AtomicString& method, ExceptionState& exception_state) const {
  const NativeValue argv[] = {Native_NewString(method.ToNativeString().release())};
  NativeValue result =
      InvokeBindingMethod(BindingMethodCallOperations::kGetMethodType, 1, argv, FlushUICommandReason::kStandard, exception_state);
  if (UNLIKELY(exception_state.HasException())) {
    return 0;
  }
  return static_cast<int>(NativeValueConverter<NativeTypeInt64>::FromNativeValue(result));
}

JSValue DartBindingObject::StringPropertyGetter(JSContext* ctx, JSValue obj, JSAtom atom) {
  ExecutingContext* context = ExecutingContext::From(ctx);
  if (!context || !context->IsContextValid())
    return JS_NULL;
  MemberMutationScope scope{context};

  auto* binding_object = static_cast<DartBindingObject*>(JS_GetOpaque(obj, JS_GetClassID(obj)));
  if (binding_object == nullptr)
    return JS_UNDEFINED;

  if (IsSymbolAtom(ctx, atom)) {
    return JS_UNDEFINED;
  }

  AtomicString key = KeyFromAtom(ctx, atom);
  if (binding_object->IsPrototypeProperty(key)) {
    return JS_UNDEFINED;
  }

  ExceptionState exception_state;

  if (binding_object->HasBindingProperty(key, exception_state)) {
    if (UNLIKELY(exception_state.HasException())) {
      return exception_state.ToQuickJS();
    }
    NativeValue prop_value =
        binding_object->GetBindingProperty(key, FlushUICommandReason::kStandard, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return exception_state.ToQuickJS();
    }
    return NativeValueToJSValue(ctx, prop_value);
  }

  int method_type = binding_object->GetBindingMethodType(key, exception_state);
  if (UNLIKELY(exception_state.HasException())) {
    return exception_state.ToQuickJS();
  }
  if (method_type == 0) {
    return JS_UNDEFINED;
  }

  JSValue data[1];
  data[0] = JS_AtomToString(ctx, atom);
  // The function takes ownership of `data`.
  JSValue fn = JS_NewCFunctionData(ctx, InvokeMethodCallback, 0, method_type, 1, data);
  JS_FreeValue(ctx, data[0]);
  return fn;
}

bool DartBindingObject::StringPropertySetter(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value) {
  ExecutingContext* context = ExecutingContext::From(ctx);
  if (!context || !context->IsContextValid())
    return false;
  MemberMutationScope scope{context};

  auto* binding_object = static_cast<DartBindingObject*>(JS_GetOpaque(obj, JS_GetClassID(obj)));
  if (binding_object == nullptr)
    return false;

  if (IsSymbolAtom(ctx, atom)) {
    return false;
  }

  AtomicString key = KeyFromAtom(ctx, atom);
  if (binding_object->IsPrototypeProperty(key)) {
    return false;
  }

  ExceptionState exception_state;
  NativeValue native_value = ScriptValue(ctx, value).ToNative(ctx, exception_state);
  if (UNLIKELY(exception_state.HasException())) {
    return false;
  }

  binding_object->SetBindingProperty(key, native_value, exception_state);
  return !exception_state.HasException();
}

bool DartBindingObject::PropertyChecker(JSContext* ctx, JSValueConst obj, JSAtom atom) {
  ExecutingContext* context = ExecutingContext::From(ctx);
  if (!context || !context->IsContextValid())
    return false;
  MemberMutationScope scope{context};

  auto* binding_object = static_cast<DartBindingObject*>(JS_GetOpaque(obj, JS_GetClassID(obj)));
  if (binding_object == nullptr)
    return false;

  // For symbol keys, only check prototype chain.
  if (IsSymbolAtom(ctx, atom)) {
    JSValue proto = JS_GetPrototype(ctx, obj);
    bool result = JS_HasProperty(ctx, proto, atom);
    JS_FreeValue(ctx, proto);
    return result;
  }

  AtomicString key = KeyFromAtom(ctx, atom);
  if (binding_object->IsPrototypeProperty(key)) {
    return true;
  }

  ExceptionState exception_state;
  if (binding_object->HasBindingProperty(key, exception_state)) {
    return true;
  }

  if (binding_object->GetBindingMethodType(key, exception_state) != 0) {
    return true;
  }

  return false;
}

}  // namespace webf
