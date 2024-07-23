/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_MACROS_H
#define BRIDGE_MACROS_H

#include <stddef.h>

#if defined(__GNUC__) || defined(__clang__)
#define LIKELY(x) __builtin_expect(!!(x), 1)
#define UNLIKELY(x) __builtin_expect(!!(x), 0)
#define FORCE_INLINE inline __attribute__((always_inline))
#else
#define LIKELY(x) (x)
#define UNLIKELY(x) (x)
#define FORCE_INLINE inline
#endif

#define assert_m(exp, msg) assert(((void)msg, exp))

#define WEBF_DISALLOW_COPY(TypeName) TypeName(const TypeName&) = delete

#define WEBF_DISALLOW_ASSIGN(TypeName) TypeName& operator=(const TypeName&) = delete

#define WEBF_DISALLOW_MOVE(TypeName) \
  TypeName(TypeName&&) = delete;     \
  TypeName& operator=(TypeName&&) = delete

#define WEBF_STATIC_ONLY(Type)           \
  Type() = delete;                       \
  Type(const Type&) = delete;            \
  Type& operator=(const Type&) = delete; \
  void* operator new(size_t) = delete;   \
  void* operator new(size_t, void*) = delete

#define WEBF_STACK_ALLOCATED()         \
 private:                              \
  void* operator new(size_t) = delete; \
  void* operator new(size_t, void*) = delete

// WEBF_DISALLOW_NEW(): Cannot be allocated with new operators but can be a
// part of object, a value object in collections or stack allocated. If it has
// Members you need a trace method and the containing object needs to call that
// trace method.
//
#define WEBF_DISALLOW_NEW()                                       \
 public:                                                          \
  using IsDisallowNewMarker = int;                                \
  void* operator new(size_t, void* location) { return location; } \
                                                                  \
 private:                                                         \
  void* operator new(size_t) = delete;

#define WEBF_DISALLOW_COPY_AND_ASSIGN(TypeName) \
  TypeName(const TypeName&) = delete;           \
  TypeName& operator=(const TypeName&) = delete

#define WEBF_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName) \
  TypeName(const TypeName&) = delete;                \
  TypeName(TypeName&&) = delete;                     \
  TypeName& operator=(const TypeName&) = delete;     \
  TypeName& operator=(TypeName&&) = delete

#define WEBF_DISALLOW_IMPLICIT_CONSTRUCTORS(TypeName) \
  TypeName() = delete;                                \
  WEBF_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName)

// WEBF_DEFINE_COMPARISON_OPERATORS_WITH_REFERENCES
// Allow equality comparisons of Objects by reference or pointer,
// interchangeably.  This can be only used on types whose equality makes no
// other sense than pointer equality.

#define WEBF_DEFINE_COMPARISON_OPERATORS_WITH_REFERENCES(Type)                    \
  inline bool operator==(const Type& a, const Type& b) { return &a == &b; }  \
  inline bool operator==(const Type& a, const Type* b) { return &a == b; }   \
  inline bool operator==(const Type* a, const Type& b) { return a == &b; }   \
  inline bool operator!=(const Type& a, const Type& b) { return !(a == b); } \
  inline bool operator!=(const Type& a, const Type* b) { return !(a == b); } \
  inline bool operator!=(const Type* a, const Type& b) { return !(a == b); }

#define DEFINE_GLOBAL(type, name)                                          \
  std::aligned_storage_t<sizeof(type), alignof(type)> name##Storage; \
  const type& name = *std::launder(reinterpret_cast<type*>(&name##Storage))

#endif  // BRIDGE_MACROS_H
