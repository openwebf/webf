/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_ALLOCATOR_H
#define WEBF_ALLOCATOR_H

#include "bindings/v8/base/memory/stack_allocated.h"
#include "foundation/macros.h"
#include "bindings/v8/base/allocator/partitions.h"

namespace webf {

using base::NotNullTag;

namespace internal {
// A dummy class used in following macros.
class __thisIsHereToForceASemicolonAfterThisMacro;
}  // namespace internal

// Classes that contain references to garbage-collected objects but aren't
// themselves garbaged allocated, have some extra macros available which
// allows their use to be restricted to cases where the garbage collector
// is able to discover their references. These macros will be useful for
// non-garbage-collected objects to avoid unintended allocations.
//
// STACK_ALLOCATED() classes may contain raw pointers to garbage-collected
// objects.
//
// DISALLOW_NEW(): Cannot be allocated with new operators but can be a
// part of object, a value object in collections or stack allocated. If it has
// Members you need a trace method and the containing object needs to call that
// trace method.
//
#define DISALLOW_NEW()                                          \
 public:                                                        \
  using IsDisallowNewMarker [[maybe_unused]] = int;             \
  void* operator new(size_t, webf::NotNullTag, void* location) { \
    return location;                                            \
  }                                                             \
  void* operator new(size_t, void* location) {                  \
    return location;                                            \
  }                                                             \
                                                                \
 private:                                                       \
  void* operator new(size_t) = delete;                          \
                                                                \
 public:                                                        \
  friend class ::webf::internal::__thisIsHereToForceASemicolonAfterThisMacro

#define STATIC_ONLY(Type)                                      \
  Type() = delete;                                             \
  Type(const Type&) = delete;                                  \
  Type& operator=(const Type&) = delete;                       \
  void* operator new(size_t) = delete;                         \
  void* operator new(size_t, webf::NotNullTag, void*) = delete; \
  void* operator new(size_t, void*) = delete

// Provides customizable overrides of fastMalloc/fastFree and operator
// new/delete
//
// Provided functionality:
//    Macro: USING_FAST_MALLOC
//
// Example usage:
//    class Widget {
//        USING_FAST_MALLOC(Widget)
//    ...
//    };
//
//    struct Data {
//        USING_FAST_MALLOC(Data)
//    public:
//    ...
//    };
//

#define USING_FAST_MALLOC(type)                                 \
 public:                                                        \
  void* operator new(size_t, void* p) {                         \
    return p;                                                   \
  }                                                             \
  void* operator new[](size_t, void* p) {                       \
    return p;                                                   \
  }                                                             \
                                                                \
  void* operator new(size_t size) {                             \
    return ::webf::Partitions::FastMalloc(size, nullptr);        \
  }                                                             \
                                                                \
  void operator delete(void* p) {                               \
    ::webf::Partitions::FastFree(p);                             \
  }                                                             \
                                                                \
  void* operator new[](size_t size) {                           \
    return ::webf::Partitions::FastMalloc(size, nullptr);        \
  }                                                             \
                                                                \
  void operator delete[](void* p) {                             \
    ::webf::Partitions::FastFree(p);                             \
  }                                                             \
  void* operator new(size_t, webf::NotNullTag, void* location) { \
    assert_m(location, "location is nullptr");                  \
    return location;                                            \
  }                                                             \
                                                                \
 private:                                                       \
  friend class ::webf::internal::__thisIsHereToForceASemicolonAfterThisMacro

}  // namespace webf

// This version of placement new omits a 0 check.
inline void* operator new(size_t, webf::NotNullTag, void* location) {
  assert_m(location, "location is nullptr");
  return location;
}

#endif  // WEBF_ALLOCATOR_H
