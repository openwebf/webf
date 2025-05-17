/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_GARBAGE_COLLECTED_H
#define BRIDGE_GARBAGE_COLLECTED_H

#include <quickjs/quickjs.h>
#include <memory>

#include "foundation/casting.h"
#include "foundation/macros.h"
#include "local_handle.h"

namespace webf {

template <typename T>
class MakeGarbageCollectedTrait;

class ExecutingContext;
class GCVisitor;
class ScriptWrappable;

/**
 * This class are mainly designed as base class for ScriptWrappable. If you wants to implement
 * a class which have corresponding object in JS environment and have the same memory life circle with JS object, use
 * ScriptWrappable instead.
 *
 * Base class for GC managed objects. Only descendent types of `GarbageCollected`
 * can be constructed using `MakeGarbageCollected()`. Must be inherited from as
 * left-most base class.
 */
template <typename T>
class GarbageCollected {
 public:
  using ParentMostGarbageCollectedType = T;

  // Must use MakeGarbageCollected.
  void* operator new(size_t) = delete;
  void* operator new[](size_t) = delete;

  /**
   * This Trace method must be override by objects inheriting from
   * GarbageCollected.
   */
  virtual void Trace(GCVisitor* visitor) const = 0;

  virtual void InitializeQuickJSObject(){};

 protected:
  GarbageCollected(){};
  ~GarbageCollected() = default;
  friend class MakeGarbageCollectedTrait<T>;
};

template <typename T>
class MakeGarbageCollectedTrait {
 public:
  template <typename... Args>
  static T* Allocate(Args&&... args) {
    T* object = ::new T(std::forward<Args>(args)...);
    object->InitializeQuickJSObject();
    return object;
  }

  friend GarbageCollected<T>;
};

class GarbageCollectedMixin {
 public:
  /**
   * This Trace method must be overriden by objects inheriting from
   * GarbageCollectedMixin.
   */
  virtual void Trace(GCVisitor*) const {}
};

template <typename T, typename... Args>
T* MakeGarbageCollected(Args&&... args) {
  static_assert(std::is_base_of<ScriptWrappable, T>::value,
                "MakeGarbageCollected T must be Derived from ScriptWrappable.");
  return MakeLocal<T>(MakeGarbageCollectedTrait<T>::Allocate(std::forward<Args>(args)...)).Get();
}

}  // namespace webf

#endif  // BRIDGE_GARBAGE_COLLECTED_H
