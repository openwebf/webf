/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_CPPGC_MEMBER_H_
#define BRIDGE_BINDINGS_QJS_CPPGC_MEMBER_H_

#include <type_traits>
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/executing_context.h"
#include "foundation/casting.h"
#include "mutation_scope.h"

namespace webf {

class ScriptWrappable;

/**
 * Members are used in classes to contain strong pointers to other garbage
 * collected objects. All Member fields of a class must be traced in the class'
 * trace method.
 */
template <typename T, typename = std::is_base_of<ScriptWrappable, T>>
class Member {
 public:
  struct KeyHasher {
    std::size_t operator()(const Member& k) const { return reinterpret_cast<std::size_t>(k.raw_); }
  };

  Member() = default;
  Member(T* ptr) { SetRaw(ptr); }
  Member(const Member<T>& other) {
    raw_ = other.raw_;
    runtime_ = other.runtime_;
    js_object_ptr_ = other.js_object_ptr_;
    ((JSRefCountHeader*)other.js_object_ptr_)->ref_count++;
  }
  ~Member() {
    if (raw_ != nullptr) {
      assert(runtime_ != nullptr);
      JS_FreeValueRT(runtime_, JS_MKPTR(JS_TAG_OBJECT, js_object_ptr_));
    }
  };

  T* Get() const { return raw_; }
  void Clear() const {
    if (raw_ == nullptr)
      return;
    JSGCPhaseEnum phase = JS_GetEnginePhase(runtime_);

    if (phase == JS_GC_PHASE_REMOVE_CYCLES) {
      // Free the pointer immediately if parent object are removed by GC.
      JS_FreeValueRT(runtime_, JS_MKPTR(JS_TAG_OBJECT, js_object_ptr_));
    } else {
      auto* wrappable = To<ScriptWrappable>(raw_);
      assert(wrappable->GetExecutingContext()->HasMutationScope());
      // Record the free operation to avoid JSObject had been freed immediately.
      wrappable->GetExecutingContext()->mutationScope()->RecordFree(wrappable);
    }
    raw_ = nullptr;
    js_object_ptr_ = nullptr;
  }

  // Copy assignment.
  Member& operator=(const Member& other) {
    raw_ = other.raw_;
    runtime_ = other.runtime_;
    js_object_ptr_ = other.js_object_ptr_;
    ((JSRefCountHeader*)other.js_object_ptr_)->ref_count++;
    return *this;
  }
  // Move assignment.
  Member& operator=(Member&& other) noexcept {
    operator=(other.Get());
    other.Clear();
    return *this;
  }

  Member& operator=(T* other) {
    Clear();
    SetRaw(other);
    return *this;
  }
  Member& operator=(std::nullptr_t) {
    Clear();
    return *this;
  }

  explicit operator bool() const { return Get(); }
  operator T*() const { return Get(); }
  T* operator->() const { return Get(); }
  T& operator*() const { return *Get(); }

  T* Release() {
    T* result = Get();
    Clear();
    return result;
  }

 private:
  void SetRaw(T* p) {
    if (p != nullptr) {
      auto* wrappable = To<ScriptWrappable>(p);
      assert_m(wrappable->GetExecutingContext()->HasMutationScope(),
               "Member must be used after MemberMutationScope allcated.");
      runtime_ = wrappable->runtime();
      js_object_ptr_ = JS_VALUE_GET_PTR(wrappable->ToQuickJSUnsafe());
      JS_DupValue(wrappable->ctx(), wrappable->ToQuickJSUnsafe());
    }
    raw_ = p;
  }

  mutable T* raw_{nullptr};
  mutable void* js_object_ptr_{nullptr};
  JSRuntime* runtime_{nullptr};
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_CPPGC_MEMBER_H_
