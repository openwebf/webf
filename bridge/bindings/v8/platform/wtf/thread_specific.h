/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef PLATFORM_WEBF_THREAD_SPECIFIC_H_
#define PLATFORM_WEBF_THREAD_SPECIFIC_H_

#include "bindings/v8/base/threading/thread_local_storage.h"
#include "bindings/v8/for_build/build_config.h"
//#include "bindings/v8/platform/wtf/allocator/allocator.h"
#include "bindings/v8/platform/wtf/allocator/partition_allocator.h"
//#include "bindings/v8/platform/wtf/allocator/partitions.h"
#include "bindings/v8/platform/wtf/stack_util.h"
#include "bindings/v8/platform/util/main_thread_util.h"

namespace webf {

template <typename T>
class ThreadSpecific {
  USING_FAST_MALLOC(ThreadSpecific);

 public:
  ThreadSpecific() : slot_(&Destroy) {}
  ThreadSpecific(const ThreadSpecific&) = delete;
  ThreadSpecific& operator=(const ThreadSpecific&) = delete;
  bool
  IsSet();  // Useful as a fast check to see if this thread has set this value.
  T* operator->();
  operator T*();
  T& operator*();

 private:
  // Not implemented. It's technically possible to destroy a thread specific
  // key, but one would need to make sure that all values have been destroyed
  // already (usually, that all threads that used it have exited). It's
  // unlikely that any user of this call will be in that situation - and having
  // a destructor defined can be confusing, given that it has such strong
  // pre-requisites to work correctly.
  ~ThreadSpecific() = delete;

  T* Get() { return static_cast<T*>(slot_.Get()); }

  void Set(T* ptr) {
    DCHECK(!Get());
    slot_.Set(ptr);
  }

  void static Destroy(void* ptr);

  // This member must only be accessed or modified on the main thread.
  T* main_thread_storage_ = nullptr;
  base::ThreadLocalStorage::Slot slot_;
};

template <typename T>
inline void ThreadSpecific<T>::Destroy(void* ptr) {
  // Never call destructors on the main thread. This is fine because Blink no
  // longer has a graceful shutdown sequence. Be careful to call this function
  // (which can be re-entrant) while the pointer is still set, to avoid lazily
  // allocating Threading after it is destroyed.
  if (IsMainThread())
    return;

  // The memory was allocated via Partitions::FastZeroedMalloc, and then the
  // object was placement-newed. To destroy, we must call the delete expression,
  // and then free the memory manually.
  T* instance = static_cast<T*>(ptr);
  instance->~T();
  Partitions::FastFree(ptr);
}

template <typename T>
inline bool ThreadSpecific<T>::IsSet() {
  return !!Get();
}

template <typename T>
inline ThreadSpecific<T>::operator T*() {
  T* off_thread_ptr;
#if defined(__GLIBC__) || BUILDFLAG(IS_ANDROID) || BUILDFLAG(IS_FREEBSD)
  // TLS is fast on these platforms.
  // TODO(csharrison): Qualify this statement for Android.
  const bool kMainThreadAlwaysChecksTLS = true;
  T** ptr = &off_thread_ptr;
  off_thread_ptr = static_cast<T*>(Get());
#else
  const bool kMainThreadAlwaysChecksTLS = false;
  T** ptr = &main_thread_storage_;
  if (UNLIKELY(MayNotBeMainThread())) {
    off_thread_ptr = static_cast<T*>(Get());
    ptr = &off_thread_ptr;
  }
#endif
  // Set up thread-specific value's memory pointer before invoking constructor,
  // in case any function it calls needs to access the value, to avoid
  // recursion.
  if (UNLIKELY(!*ptr)) {
    *ptr = static_cast<T*>(Partitions::FastZeroedMalloc(
        sizeof(T), nullptr));

    // Even if we didn't realize we're on the main thread, we might still be.
    // We need to double-check so that |main_thread_storage_| is populated.
    if (!kMainThreadAlwaysChecksTLS && UNLIKELY(ptr != &main_thread_storage_) &&
        IsMainThread()) {
      main_thread_storage_ = *ptr;
    }

    Set(*ptr);
    ::new (NotNullTag::kNotNull, *ptr) T;
  }
  return *ptr;
}

template <typename T>
inline T* ThreadSpecific<T>::operator->() {
  return operator T*();
}

template <typename T>
inline T& ThreadSpecific<T>::operator*() {
  return *operator T*();
}

}  // namespace webf

using webf::ThreadSpecific;

#endif  // PLATFORM_WEBF_THREAD_SPECIFIC_H_

