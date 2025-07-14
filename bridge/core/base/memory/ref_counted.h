// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_BASE_MEMORY_REF_COUNTED_H_
#define WEBF_CORE_BASE_MEMORY_REF_COUNTED_H_

#include <atomic>
#include <cassert>
#include <cstddef>

#include "core/base/memory/scoped_refptr.h"

namespace webf {

namespace subtle {

class RefCountedBase {
 public:
  bool HasOneRef() const { return ref_count_ == 1; }
  bool HasAtLeastOneRef() const { return ref_count_ >= 1; }

  void Adopted() {
    // In WebF, we start with ref_count_ = 1
    assert(ref_count_ == 1);
  }

 protected:
  RefCountedBase() : ref_count_(1) {}

  ~RefCountedBase() {
    assert(ref_count_ == 0);
  }

  void AddRef() const {
    assert(ref_count_ >= 0);
    assert(ref_count_ < std::numeric_limits<int>::max());
    ++ref_count_;
  }

  // Returns true if the object should self-delete.
  bool Release() const {
    assert(ref_count_ > 0);
    if (--ref_count_ == 0) {
      return true;
    }
    return false;
  }

 private:
  mutable int ref_count_;
  
  RefCountedBase(const RefCountedBase&) = delete;
  RefCountedBase& operator=(const RefCountedBase&) = delete;
};

class RefCountedThreadSafeBase {
 public:
  bool HasOneRef() const { return ref_count_.load(std::memory_order_acquire) == 1; }
  bool HasAtLeastOneRef() const { return ref_count_.load(std::memory_order_acquire) >= 1; }

  void Adopted() {
    // In WebF, we start with ref_count_ = 1
    assert(ref_count_.load(std::memory_order_acquire) == 1);
  }

 protected:
  RefCountedThreadSafeBase() : ref_count_(1) {}

  ~RefCountedThreadSafeBase() {
    assert(ref_count_.load(std::memory_order_acquire) == 0);
  }

  void AddRef() const {
    ref_count_.fetch_add(1, std::memory_order_relaxed);
  }

  // Returns true if the object should self-delete.
  bool Release() const {
    if (ref_count_.fetch_sub(1, std::memory_order_acq_rel) == 1) {
      return true;
    }
    return false;
  }

 private:
  mutable std::atomic<int> ref_count_;
  
  RefCountedThreadSafeBase(const RefCountedThreadSafeBase&) = delete;
  RefCountedThreadSafeBase& operator=(const RefCountedThreadSafeBase&) = delete;
};

}  // namespace subtle

// A base class for reference counted classes. Otherwise, known as a cheap
// knock-off of WebKit's RefCounted<T> class. To use this, just extend your
// class from it like so:
//
//   class MyFoo : public RefCounted<MyFoo> {
//    ...
//    private:
//     friend class RefCounted<MyFoo>;
//     ~MyFoo();
//   };
//
// Usage Notes:
// 1. You should always make your destructor non-public, to avoid any code
//    deleting the object accidentally while there are references to it.
// 2. You should always make the ref-counted base class a friend of your class,
//    so that it can access the destructor.
//
// The ref count manipulation to RefCounted is NOT thread safe and has DCHECKs
// to trap unsafe cross thread usage. A subclass instance of RefCounted can be
// passed to another execution sequence only when its ref count is 1. If the ref
// count is more than 1, the RefCounted class verifies the ref count
// manipulation is on the same execution sequence as the previous ones. The
// subclass can also manually call IsOnValidSequence to trap other non-thread
// safe accesses; see the documentation for that method.
//
template <class T, typename Traits = void>
class RefCounted : public subtle::RefCountedBase {
 public:
  static constexpr subtle::StartRefCountFromOneTag kRefCountPreference =
      subtle::kStartRefCountFromOneTag;

  RefCounted() = default;

  RefCounted(const RefCounted&) = delete;
  RefCounted& operator=(const RefCounted&) = delete;

  void AddRef() const {
    subtle::RefCountedBase::AddRef();
  }

  void Release() const {
    if (subtle::RefCountedBase::Release()) {
      // Prune the code paths which the static analyzer may take to simulate
      // object destruction. Use-after-free errors aren't possible given the
      // lifetime guarantees of the refcounting system.
      delete static_cast<const T*>(this);
    }
  }

 protected:
  ~RefCounted() = default;
};

// Forward declaration.
template <class T, typename Traits> class RefCountedThreadSafe;

// Default traits for RefCountedThreadSafe<T>. Deletes the object when its ref
// count reaches 0. Overload to delete it on a different thread etc.
template<typename T>
struct DefaultRefCountedThreadSafeTraits {
  static void Destruct(const T* x) {
    delete x;
  }
};

//
// A thread-safe variant of RefCounted<T>
//
//   class MyFoo : public RefCountedThreadSafe<MyFoo> {
//    ...
//   };
//
// If you're using the default trait, then you should add compile time
// asserts that no one else is deleting your object.  i.e.
//    private:
//     friend class RefCountedThreadSafe<MyFoo>;
//     ~MyFoo();
//
// We can use REFCOUNTED_VIRTUAL_DTOR() with RefCountedThreadSafe in the
// presence of virtual inheritance. For more details, see the comment above
// the REFCOUNTED_VIRTUAL_DTOR() macro below.
template <class T, typename Traits = DefaultRefCountedThreadSafeTraits<T> >
class RefCountedThreadSafe : public subtle::RefCountedThreadSafeBase {
 public:
  static constexpr subtle::StartRefCountFromOneTag kRefCountPreference =
      subtle::kStartRefCountFromOneTag;

  RefCountedThreadSafe() = default;

  RefCountedThreadSafe(const RefCountedThreadSafe&) = delete;
  RefCountedThreadSafe& operator=(const RefCountedThreadSafe&) = delete;

  void AddRef() const {
    subtle::RefCountedThreadSafeBase::AddRef();
  }

  void Release() const {
    if (subtle::RefCountedThreadSafeBase::Release()) {
      Traits::Destruct(static_cast<const T*>(this));
    }
  }

 protected:
  ~RefCountedThreadSafe() = default;

 private:
  friend struct DefaultRefCountedThreadSafeTraits<T>;
  static void DeleteInternal(const T* x) { delete x; }
};

}  // namespace webf

#endif  // WEBF_CORE_BASE_MEMORY_REF_COUNTED_H_