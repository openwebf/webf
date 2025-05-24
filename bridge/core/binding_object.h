/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_BINDING_OBJECT_H_
#define BRIDGE_CORE_DOM_BINDING_OBJECT_H_

#include <include/dart_api_dl.h>
#include <cinttypes>
#include <unordered_set>
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/dart_methods.h"
#include "foundation/native_type.h"
#include "foundation/native_value.h"

namespace webf {

class BindingObject;
struct NativeBindingObject;
class ExceptionState;
class GCVisitor;
class ScriptPromiseResolver;
class DartIsolateContext;

using InvokeBindingsMethodsFromNative = void (*)(double contextId,
                                                 int64_t profile_id,
                                                 const NativeBindingObject* binding_object,
                                                 NativeValue* return_value,
                                                 NativeValue* method,
                                                 int32_t argc,
                                                 const NativeValue* argv);

using DartInvokeResultCallback = void (*)(Dart_Handle dart_object, NativeValue* result);

using InvokeBindingMethodsFromDart = void (*)(NativeBindingObject* binding_object,
                                              int64_t profile_id,
                                              NativeValue* method,
                                              int32_t argc,
                                              NativeValue* argv,
                                              Dart_Handle dart_object,
                                              DartInvokeResultCallback result_callback);

struct NativeBindingObject : public DartReadable {
  NativeBindingObject() = delete;
  explicit NativeBindingObject(BindingObject* target);

  static void HandleCallFromDartSide(const DartIsolateContext* dart_isolate_context,
                                     const NativeBindingObject* binding_object,
                                     int64_t profile_id,
                                     const NativeValue* method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_PersistentHandle dart_object,
                                     DartInvokeResultCallback result_callback);
  static bool IsDisposed(const NativeBindingObject* native_binding_object) {
    return native_binding_object->disposed_.load(std::memory_order_acquire);
  }
  BindingObject* binding_target_{nullptr};
  InvokeBindingMethodsFromDart invoke_binding_methods_from_dart{nullptr};
  InvokeBindingsMethodsFromNative invoke_bindings_methods_from_native{nullptr};
  void* extra{nullptr};
  std::atomic<bool> disposed_{false};
};

enum BindingMethodCallOperations {
  kGetProperty,
  kSetProperty,
};

enum CreateBindingObjectType {
  kCreateDOMMatrix = 0,
  kCreatePath2D = 1,
  kCreateDOMPoint = 2,
  kCreateFormData = 3
};

struct BindingObjectPromiseContext : public DartReadable {
  ExecutingContext* context;
  BindingObject* binding_object;
  std::shared_ptr<ScriptPromiseResolver> promise_resolver;
};

using BindingObjectAsyncCallback = void (*)(ScriptPromiseResolver* resolver,
                                            NativeValue* success_result,
                                            const char* error_msg);

struct BindingObjectAsyncCallContext : public DartReadable {
  NativeValue* method_name;
  int32_t argc;
  const webf::NativeValue* argv;
  ScriptPromiseResolver* async_invoke_reader;
  BindingObjectAsyncCallback callback;
};

class BindingObject : public ScriptWrappable {
 public:
  BindingObject() = delete;
  ~BindingObject();
  explicit BindingObject(JSContext* ctx);

  // Handle call from dart side.
  virtual NativeValue HandleCallFromDartSide(const AtomicString& method,
                                             int32_t argc,
                                             const NativeValue* argv,
                                             Dart_Handle dart_object);
  // Invoke methods which implemented at dart side.
  NativeValue InvokeBindingMethod(const AtomicString& method,
                                  int32_t argc,
                                  const NativeValue* args,
                                  uint32_t reason,
                                  ExceptionState& exception_state) const;
  ScriptPromise InvokeBindingMethodAsync(const AtomicString& method,
                                         int32_t argc,
                                         const NativeValue* args,
                                         ExceptionState& exception_state) const;
  NativeValue GetBindingProperty(const AtomicString& prop, uint32_t reason, ExceptionState& exception_state) const;
  NativeValue SetBindingProperty(const AtomicString& prop, NativeValue value, ExceptionState& exception_state) const;

  ScriptPromise GetBindingPropertyAsync(const AtomicString& prop, ExceptionState& exception_state);
  void SetBindingPropertyAsync(const AtomicString& prop, NativeValue value, ExceptionState& exception_state);

  void CollectElementDepsOnArgs(std::vector<NativeBindingObject*>& deps, size_t argc, const NativeValue* args) const;

  bool IsBindingObject() const override;

  FORCE_INLINE NativeBindingObject* bindingObject() const { return binding_object_; }

  void Trace(GCVisitor* visitor) const override;

  inline static BindingObject* From(NativeBindingObject* native_binding_object) {
    if (native_binding_object == nullptr)
      return nullptr;

    return native_binding_object->binding_target_;
  };

  virtual bool IsEventTarget() const;
  virtual bool IsTouchList() const;
  virtual bool IsComputedCssStyleDeclaration() const;
  virtual bool IsCanvasGradient() const;
  virtual bool IsCanvasRenderingContext2D() const;
  virtual bool IsFormData() const;

 protected:
  void TrackPendingPromiseBindingContext(BindingObjectPromiseContext* binding_object_promise_context);
  void FullFillPendingPromise(BindingObjectPromiseContext* binding_object_promise_context);
  NativeValue InvokeBindingMethod(BindingMethodCallOperations binding_method_call_operation,
                                  size_t argc,
                                  const NativeValue* args,
                                  uint32_t reason,
                                  ExceptionState& exception_state) const;
  ScriptPromise InvokeBindingMethodAsync(BindingMethodCallOperations binding_method_call_operation,
                                         int32_t argc,
                                         const NativeValue* args,
                                         ExceptionState& exception_state) const;
  ScriptPromise InvokeBindingMethodAsyncInternal(NativeValue method,
                                                 int32_t argc,
                                                 const NativeValue* args,
                                                 ExceptionState& exception_state) const;

  // NativeBindingObject may allocated at Dart side. Binding this with Dart allocated NativeBindingObject.
  explicit BindingObject(JSContext* ctx, NativeBindingObject* native_binding_object);

 private:
  NativeBindingObject* binding_object_ = nullptr;
  std::unordered_set<BindingObjectPromiseContext*> pending_promise_contexts_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_BINDING_OBJECT_H_
