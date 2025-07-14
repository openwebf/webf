// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_BASE_MEMORY_SCOPED_REFPTR_H_
#define WEBF_CORE_BASE_MEMORY_SCOPED_REFPTR_H_

#include <algorithm>
#include <cstddef>
#include <iosfwd>
#include <type_traits>
#include <utility>

namespace webf {

template <class T>
class scoped_refptr;

namespace subtle {

enum AdoptRefTag { kAdoptRefTag };

}  // namespace subtle

// Creates a scoped_refptr from a raw pointer without incrementing the reference
// count. Use this only for a newly created object whose reference count starts
// from 1 instead of 0.
template <typename T>
scoped_refptr<T> AdoptRef(T* obj) {
  // In WebF, we assume reference counts start from 1
  return scoped_refptr<T>(obj, subtle::kAdoptRefTag);
}

// Constructs an instance of T, which is a ref counted type, and wraps the
// object into a scoped_refptr<T>.
template <typename T, typename... Args>
scoped_refptr<T> MakeRefCounted(Args&&... args) {
  T* obj = new T(std::forward<Args>(args)...);
  return AdoptRef(obj);
}

// Takes an instance of T, which is a ref counted type, and wraps the object
// into a scoped_refptr<T>.
template <typename T>
scoped_refptr<T> WrapRefCounted(T* t) {
  return scoped_refptr<T>(t);
}

//
// A smart pointer class for reference counted objects.  Use this class instead
// of calling AddRef and Release manually on a reference counted object to
// avoid common memory leaks caused by forgetting to Release an object
// reference.  Sample usage:
//
//   class MyFoo : public RefCounted<MyFoo> {
//    ...
//    private:
//     friend class RefCounted<MyFoo>;  // Allow destruction by RefCounted<>.
//     ~MyFoo();                        // Destructor must be private/protected.
//   };
//
//   void some_function() {
//     scoped_refptr<MyFoo> foo = MakeRefCounted<MyFoo>();
//     foo->Method(param);
//     // |foo| is released when this function returns
//   }
//
//   void some_other_function() {
//     scoped_refptr<MyFoo> foo = MakeRefCounted<MyFoo>();
//     ...
//     foo.reset();  // explicitly releases |foo|
//     ...
//     if (foo)
//       foo->Method(param);
//   }
//
template <class T>
class scoped_refptr {
 public:
  typedef T element_type;

  constexpr scoped_refptr() = default;

  // Allow implicit construction from nullptr.
  constexpr scoped_refptr(std::nullptr_t) {}

  // Constructs from a raw pointer. Note that this constructor allows implicit
  // conversion from T* to scoped_refptr<T> which is strongly discouraged. If
  // you are creating a new ref-counted object please use
  // MakeRefCounted<T>() or WrapRefCounted<T>().
  scoped_refptr(T* p) : ptr_(p) {
    if (ptr_) {
      AddRef(ptr_);
    }
  }

  // Copy constructor.
  scoped_refptr(const scoped_refptr& r) : scoped_refptr(r.ptr_) {}

  // Copy conversion constructor.
  template <typename U>
  scoped_refptr(const scoped_refptr<U>& r,
                typename std::enable_if<std::is_convertible<U*, T*>::value>::type* = nullptr)
      : scoped_refptr(r.ptr_) {}

  // Move constructor.
  scoped_refptr(scoped_refptr&& r) noexcept : ptr_(r.ptr_) { r.ptr_ = nullptr; }

  // Move conversion constructor.
  template <typename U>
  scoped_refptr(scoped_refptr<U>&& r,
                typename std::enable_if<std::is_convertible<U*, T*>::value>::type* = nullptr) noexcept
      : ptr_(r.ptr_) {
    r.ptr_ = nullptr;
  }

  ~scoped_refptr() {
    if (ptr_) {
      Release(ptr_);
    }
  }

  T* get() const { return ptr_; }

  T& operator*() const {
    assert(ptr_);
    return *ptr_;
  }

  T* operator->() const {
    assert(ptr_);
    return ptr_;
  }

  scoped_refptr& operator=(std::nullptr_t) {
    reset();
    return *this;
  }

  scoped_refptr& operator=(T* p) { return *this = scoped_refptr(p); }

  // Unified assignment operator.
  scoped_refptr& operator=(scoped_refptr r) noexcept {
    swap(r);
    return *this;
  }

  // Sets managed object to null and releases reference to the previous managed
  // object, if it existed.
  void reset() { scoped_refptr().swap(*this); }

  // Returns the owned pointer (if any), releasing ownership to the caller. The
  // caller is responsible for managing the lifetime of the reference.
  [[nodiscard]] T* release();

  void swap(scoped_refptr& r) noexcept { std::swap(ptr_, r.ptr_); }

  explicit operator bool() const { return ptr_ != nullptr; }

  template <typename U>
  friend bool operator==(const scoped_refptr<T>& lhs,
                         const scoped_refptr<U>& rhs) {
    return lhs.ptr_ == rhs.ptr_;
  }

  template <typename U>
  friend bool operator==(const scoped_refptr<T>& lhs, const U* rhs) {
    return lhs.ptr_ == rhs;
  }

  friend bool operator==(const scoped_refptr<T>& lhs, std::nullptr_t null) {
    return !static_cast<bool>(lhs);
  }

  template <typename U>
  friend bool operator!=(const scoped_refptr<T>& lhs,
                         const scoped_refptr<U>& rhs) {
    return !(lhs == rhs);
  }

  template <typename U>
  friend bool operator!=(const scoped_refptr<T>& lhs, const U* rhs) {
    return !(lhs == rhs);
  }

  friend bool operator!=(const scoped_refptr<T>& lhs, std::nullptr_t null) {
    return static_cast<bool>(lhs);
  }

  template <typename U>
  friend bool operator<(const scoped_refptr<T>& lhs,
                        const scoped_refptr<U>& rhs) {
    return lhs.ptr_ < rhs.ptr_;
  }

  template <typename U>
  friend bool operator>(const scoped_refptr<T>& lhs,
                        const scoped_refptr<U>& rhs) {
    return lhs.ptr_ > rhs.ptr_;
  }

  template <typename U>
  friend bool operator<=(const scoped_refptr<T>& lhs,
                         const scoped_refptr<U>& rhs) {
    return lhs.ptr_ <= rhs.ptr_;
  }

  template <typename U>
  friend bool operator>=(const scoped_refptr<T>& lhs,
                         const scoped_refptr<U>& rhs) {
    return lhs.ptr_ >= rhs.ptr_;
  }

 protected:
  T* ptr_ = nullptr;

 private:
  template <typename U>
  friend scoped_refptr<U> AdoptRef(U*);

  scoped_refptr(T* p, subtle::AdoptRefTag) : ptr_(p) {}

  // Friend required for move constructors that set r.ptr_ to null.
  template <typename U>
  friend class scoped_refptr;

  // Non-inline helpers to allow:
  //     class Opaque;
  //     extern template class scoped_refptr<Opaque>;
  // Otherwise the compiler will complain that Opaque is an incomplete type.
  static void AddRef(T* ptr);
  static void Release(T* ptr);
};

template <typename T>
T* scoped_refptr<T>::release() {
  T* ptr = ptr_;
  ptr_ = nullptr;
  return ptr;
}

// static
template <typename T>
void scoped_refptr<T>::AddRef(T* ptr) {
  ptr->AddRef();
}

// static
template <typename T>
void scoped_refptr<T>::Release(T* ptr) {
  ptr->Release();
}

template <typename T>
std::ostream& operator<<(std::ostream& out, const scoped_refptr<T>& p) {
  return out << p.get();
}

// Handy utility for swapping scoped_refptr objects.
template <typename T>
void swap(scoped_refptr<T>& lhs, scoped_refptr<T>& rhs) noexcept {
  lhs.swap(rhs);
}

}  // namespace webf

// Temporary alias for migration
template <class T>
using scoped_refptr = webf::scoped_refptr<T>;

#endif  // WEBF_CORE_BASE_MEMORY_SCOPED_REFPTR_H_