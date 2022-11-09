/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_BINDING_OBJECT_H_
#define BRIDGE_CORE_DOM_BINDING_OBJECT_H_

#include <cinttypes>
#include <set>
#include "bindings/qjs/atomic_string.h"
#include "foundation/native_type.h"
#include "foundation/native_value.h"

namespace webf {

class BindingObject;
class NativeBindingObject;
class ExceptionState;
class GCVisitor;
class ScriptPromiseResolver;

using InvokeBindingsMethodsFromNative = void (*)(const NativeBindingObject* binding_object,
                                                 NativeValue* return_value,
                                                 NativeValue* method,
                                                 int32_t argc,
                                                 const NativeValue* argv);

using InvokeBindingMethodsFromDart = void (*)(NativeBindingObject* binding_object,
                                              NativeValue* return_value,
                                              NativeValue* method,
                                              int32_t argc,
                                              NativeValue* argv);

struct NativeBindingObject : public DartReadable {
  NativeBindingObject() = delete;
  explicit NativeBindingObject(BindingObject* target)
      : binding_target_(target), invoke_binding_methods_from_dart(HandleCallFromDartSide){};

  static void HandleCallFromDartSide(NativeBindingObject* binding_object,
                                     NativeValue* return_value,
                                     NativeValue* method,
                                     int32_t argc,
                                     NativeValue* argv);

  bool disposed_{false};
  BindingObject* binding_target_{nullptr};
  InvokeBindingMethodsFromDart invoke_binding_methods_from_dart{nullptr};
  InvokeBindingsMethodsFromNative invoke_bindings_methods_from_native{nullptr};
};

enum BindingMethodCallOperations {
  kGetProperty,
  kSetProperty,
  kGetAllPropertyNames,
  kAnonymousFunctionCall,
  kAsyncAnonymousFunction,
};

enum CreateBindingObjectType { kCreateDOMMatrix = 0 };

struct BindingObjectPromiseContext : public DartReadable {
  ExecutingContext* context;
  BindingObject* binding_object;
  std::shared_ptr<ScriptPromiseResolver> promise_resolver;
};

class BindingObject {
 public:
  struct AnonymousFunctionData {
    std::string method_name;
  };

  // This function were called when the anonymous function returned to the JS code has been called by users.
  static ScriptValue AnonymousFunctionCallback(JSContext* ctx,
                                               const ScriptValue& this_val,
                                               uint32_t argc,
                                               const ScriptValue* argv,
                                               void* private_data);
  static ScriptValue AnonymousAsyncFunctionCallback(JSContext* ctx,
                                                    const ScriptValue& this_val,
                                                    uint32_t argc,
                                                    const ScriptValue* argv,
                                                    void* private_data);
  static void HandleAnonymousAsyncCalledFromDart(void* ptr,
                                                 NativeValue* native_value,
                                                 int32_t contextId,
                                                 const char* errmsg);

  BindingObject() = delete;
  ~BindingObject();
  explicit BindingObject(ExecutingContext* context);

  // Handle call from dart side.
  virtual NativeValue HandleCallFromDartSide(const NativeValue* method, int32_t argc, const NativeValue* argv) = 0;
  // Invoke methods which implemented at dart side.
  NativeValue InvokeBindingMethod(const AtomicString& method,
                                  int32_t argc,
                                  const NativeValue* args,
                                  ExceptionState& exception_state) const;
  NativeValue GetBindingProperty(const AtomicString& prop, ExceptionState& exception_state) const;
  NativeValue SetBindingProperty(const AtomicString& prop, NativeValue value, ExceptionState& exception_state) const;
  NativeValue GetAllBindingPropertyNames(ExceptionState& exception_state) const;

  NativeBindingObject* bindingObject() const { return binding_object_; }

  void Trace(GCVisitor* visitor) const;

  inline static BindingObject* From(NativeBindingObject* native_binding_object) {
    if (native_binding_object == nullptr)
      return nullptr;

    return native_binding_object->binding_target_;
  };

  virtual bool IsEventTarget() const;
  virtual bool IsTouchList() const;
  virtual bool IsCanvasGradient() const;

 protected:
  void TrackPendingPromiseBindingContext(BindingObjectPromiseContext* binding_object_promise_context);
  void FullFillPendingPromise(BindingObjectPromiseContext* binding_object_promise_context);
  NativeValue InvokeBindingMethod(BindingMethodCallOperations binding_method_call_operation,
                                  size_t argc,
                                  const NativeValue* args,
                                  ExceptionState& exception_state) const;

  // NativeBindingObject may allocated at Dart side. Binding this with Dart allocated NativeBindingObject.
  explicit BindingObject(ExecutingContext* context, NativeBindingObject* native_binding_object);

 private:
  ExecutingContext* context_{nullptr};
  NativeBindingObject* binding_object_{new NativeBindingObject(this)};
  std::set<BindingObjectPromiseContext*> pending_promise_contexts_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_BINDING_OBJECT_H_
