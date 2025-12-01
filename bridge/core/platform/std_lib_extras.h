/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
#ifndef WEBF_CORE_PLATFORM_WTF_STD_LIB_EXTRAS_H_
#define WEBF_CORE_PLATFORM_WTF_STD_LIB_EXTRAS_H_

#include "sanitizers.h"

// We don't need cross-threads, we only have single one.
#define DEFINE_STATIC_LOCAL(type, var, value)   \
  thread_local static type var(value)

/*
 * The reinterpret_cast<Type1*>([pointer to Type2]) expressions - where
 * sizeof(Type1) > sizeof(Type2) - cause the following warning on ARM with GCC:
 * increases required alignment of target type.
 *
 * An implicit or an extra static_cast<void*> bypasses the warning.
 * For more info see the following bugzilla entries:
 * - https://bugs.webkit.org/show_bug.cgi?id=38045
 * - http://gcc.gnu.org/bugzilla/show_bug.cgi?id=43976
 */
#if defined(ARCH_CPU_ARMEL) && defined(COMPILER_GCC)
template <typename Type>
bool isPointerTypeAlignmentOkay(Type* ptr) {
  return !(reinterpret_cast<intptr_t>(ptr) % __alignof__(Type));
}

template <typename TypePtr>
TypePtr reinterpret_cast_ptr(void* ptr) {
  assert(isPointerTypeAlignmentOkay(reinterpret_cast<TypePtr>(ptr)));
  return reinterpret_cast<TypePtr>(ptr);
}

template <typename TypePtr>
TypePtr reinterpret_cast_ptr(const void* ptr) {
  assert(isPointerTypeAlignmentOkay(reinterpret_cast<TypePtr>(ptr)));
  return reinterpret_cast<TypePtr>(ptr);
}
#else
template <typename Type>
bool isPointerTypeAlignmentOkay(Type*) {
  return true;
}
#define reinterpret_cast_ptr reinterpret_cast
#endif

template <typename TypePtr>
NO_SANITIZE_UNRELATED_CAST TypePtr unsafe_reinterpret_cast_ptr(void* ptr) {
#if defined(ARCH_CPU_ARMEL) && defined(COMPILER_GCC)
  assert(isPointerTypeAlignmentOkay(reinterpret_cast<TypePtr>(ptr)));
#endif
  return reinterpret_cast<TypePtr>(ptr);
}

template <typename TypePtr>
NO_SANITIZE_UNRELATED_CAST TypePtr unsafe_reinterpret_cast_ptr(const void* ptr) {
#if defined(ARCH_CPU_ARMEL) && defined(COMPILER_GCC)
  assert(isPointerTypeAlignmentOkay(reinterpret_cast<TypePtr>(ptr)));
#endif
  return reinterpret_cast<TypePtr>(ptr);
}

namespace WTF {

// Stub for Persistent smart pointer template
// This is a simplified implementation for WebF compatibility
template<typename T>
class Persistent {
 public:
  Persistent() : ptr_(nullptr) {}
  explicit Persistent(T* ptr) : ptr_(ptr) {}
  Persistent(const Persistent& other) : ptr_(other.ptr_) {}
  
  Persistent& operator=(const Persistent& other) {
    ptr_ = other.ptr_;
    return *this;
  }
  
  T* operator->() const { return ptr_; }
  T& operator*() const { return *ptr_; }
  T* Get() const { return ptr_; }
  
  bool operator==(const Persistent& other) const { return ptr_ == other.ptr_; }
  bool operator!=(const Persistent& other) const { return ptr_ != other.ptr_; }
  
 private:
  T* ptr_;
};

// Use the following macros to prevent errors caused by accidental
// implicit casting of function arguments.  For example, this can
// be used to prevent overflows from non-promoting conversions.
//
// Example:
//
// HAS_STRICTLY_TYPED_ARG
// void sendData(void* data, STRICTLY_TYPED_ARG(size))
// {
//    ALLOW_NUMERIC_ARG_TYPES_PROMOTABLE_TO(size_t);
//    ...
// }
//
// The previous example will prevent callers from passing, for example, an
// 'int'. On a 32-bit build, it will prevent use of an 'unsigned long long'.
#define HAS_STRICTLY_TYPED_ARG template <typename ActualArgType>
#define STRICTLY_TYPED_ARG(argName) ActualArgType argName
#define STRICT_ARG_TYPE(ExpectedArgType)                             \
  static_assert(std::is_same<ActualArgType, ExpectedArgType>::value, \
                "Strictly typed argument must be of type '" #ExpectedArgType "'.")
#define ALLOW_NUMERIC_ARG_TYPES_PROMOTABLE_TO(ExpectedArgType)                                                      \
  static_assert(std::numeric_limits<ExpectedArgType>::is_integer == std::numeric_limits<ActualArgType>::is_integer, \
                "Conversion between integer and non-integer types not allowed.");                                   \
  static_assert(sizeof(ExpectedArgType) >= sizeof(ActualArgType), "Truncating conversions not allowed.");           \
  static_assert(!std::numeric_limits<ActualArgType>::is_signed || std::numeric_limits<ExpectedArgType>::is_signed,  \
                "Signed to unsigned conversion not allowed.");                                                      \
  static_assert(                                                                                                    \
      (sizeof(ExpectedArgType) != sizeof(ActualArgType)) ||                                                         \
          (std::numeric_limits<ActualArgType>::is_signed == std::numeric_limits<ExpectedArgType>::is_signed),       \
      "Unsigned to signed conversion not allowed for types with "                                                   \
      "identical size (could overflow).");

}  // namespace WTF

namespace webf {

// Import Persistent into webf namespace
using WTF::Persistent;

}  // namespace webf

#endif  // WEBF_CORE_PLATFORM_WTF_STD_LIB_EXTRAS_H_
