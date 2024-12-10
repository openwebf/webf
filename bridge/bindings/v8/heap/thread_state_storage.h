/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_PLATFORM_HEAP_THREAD_STATE_STORAGE_H_
#define WEBF_PLATFORM_HEAP_THREAD_STATE_STORAGE_H_

#include <v8/cppgc/heap.h>
#include <cstdint>
#include "foundation/macros.h"

namespace webf {

class ThreadState;
class ThreadStateStorage;

// ThreadAffinity indicates which threads objects can be used on. We
// distinguish between objects that can be used on the main thread
// only and objects that can be used on any thread.
//
// For objects that can only be used on the main thread, we avoid going
// through thread-local storage to get to the thread state. This is
// important for performance.
enum ThreadAffinity {
  kAnyThread,
  kMainThreadOnly,
};

template <typename T, typename = void>
struct ThreadingTrait {
  WEBF_STATIC_ONLY(ThreadingTrait);
  static constexpr ThreadAffinity kAffinity = kAnyThread;
};

// Storage for all ThreadState objects. This includes the main-thread
// ThreadState as well. Keep it outside the class so that PLATFORM_EXPORT
// doesn't apply to it (otherwise, clang-cl complains).
static ThreadStateStorage* g_thread_specific_ = nullptr;

// ThreadStateStorage is the explicitly managed TLS- and global-backed storage
// for ThreadState.
class ThreadStateStorage final {
 public:
  FORCE_INLINE static ThreadStateStorage* MainThreadStateStorage() { return &main_thread_state_storage_; }

  FORCE_INLINE static ThreadStateStorage* Current() { return g_thread_specific_; }

  FORCE_INLINE cppgc::AllocationHandle& allocation_handle() const { return *allocation_handle_; }

  FORCE_INLINE cppgc::HeapHandle& heap_handle() const { return *heap_handle_; }

  FORCE_INLINE ThreadState& thread_state() const { return *thread_state_; }

  FORCE_INLINE bool IsMainThread() const { return this == MainThreadStateStorage(); }

 private:
  static void AttachMainThread(ThreadState&, cppgc::AllocationHandle&, cppgc::HeapHandle&);
  static void AttachNonMainThread(ThreadState&, cppgc::AllocationHandle&, cppgc::HeapHandle&);
  static void DetachNonMainThread(ThreadStateStorage&);

  static ThreadStateStorage main_thread_state_storage_;

  ThreadStateStorage() = default;
  ThreadStateStorage(ThreadState&, cppgc::AllocationHandle&, cppgc::HeapHandle&);

  cppgc::AllocationHandle* allocation_handle_ = nullptr;
  cppgc::HeapHandle* heap_handle_ = nullptr;
  ThreadState* thread_state_ = nullptr;

  friend class ThreadState;
};

template <ThreadAffinity>
class ThreadStateStorageFor;

template <>
class ThreadStateStorageFor<kMainThreadOnly> {
  WEBF_STATIC_ONLY(ThreadStateStorageFor);

 public:
  FORCE_INLINE static ThreadStateStorage* GetState() { return ThreadStateStorage::MainThreadStateStorage(); }
};

template <>
class ThreadStateStorageFor<kAnyThread> {
  WEBF_STATIC_ONLY(ThreadStateStorageFor);

 public:
  FORCE_INLINE static ThreadStateStorage* GetState() { return ThreadStateStorage::Current(); }
};

}  // namespace webf

#endif  // WEBF_PLATFORM_HEAP_THREAD_STATE_STORAGE_H_
