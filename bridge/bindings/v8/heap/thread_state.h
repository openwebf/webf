/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_PLATFORM_HEAP_THREAD_STATE_H_
#define WEBF_PLATFORM_HEAP_THREAD_STATE_H_

//#include "base/compiler_specific.h"
//#include "base/functional/callback_forward.h"
//#include "build/build_config.h"
//#include "third_party/blink/renderer/platform/heap/forward.h"
//#include "third_party/blink/renderer/platform/heap/thread_state_storage.h"
//#include "third_party/blink/renderer/platform/wtf/allocator/allocator.h"
//#include "third_party/blink/renderer/platform/wtf/threading.h"

#include <v8/cppgc/common.h>
#include <v8/cppgc/heap-consistency.h>
#include <v8/v8-callbacks.h>
#include <v8/v8-cppgc.h>
#include <v8/v8-profiler.h>
#include <v8/v8-embedder-heap.h>
#include "foundation/macros.h"
#include "thread_state_storage.h"

namespace webf {

//    class BlinkGCMemoryDumpProvider;

    using V8BuildEmbedderGraphCallback = void (*)(v8::Isolate*,
                                                  v8::EmbedderGraph*,
                                                  void*);

    class ThreadState final {
    public:
    class GCForbiddenScope;
    class NoAllocationScope;

    using StackState = cppgc::EmbedderStackState;

    FORCE_INLINE static ThreadState* Current() {
        return &ThreadStateStorage::Current()->thread_state();
    }

    // Returns true if the current thread is currently sweeping, i.e., whether the
    // caller is invoked from a destructor.
    FORCE_INLINE static bool IsSweepingOnOwningThread(
            ThreadStateStorage& storage);

    // Attaches a ThreadState to the main-thread.
    static ThreadState* AttachMainThread();
    // Attaches a ThreadState to the currently running thread. Must not be the
    // main thread and must be called after AttachMainThread().
    static ThreadState* AttachCurrentThread();
    static void DetachCurrentThread();

    void AttachToIsolate(v8::Isolate* isolate, V8BuildEmbedderGraphCallback);
    void DetachFromIsolate();

    FORCE_INLINE cppgc::HeapHandle& heap_handle() const { return heap_handle_; }
    FORCE_INLINE v8::CppHeap& cpp_heap() const { return *cpp_heap_; }

    bool IsMainThread() const {
        return this ==
               &ThreadStateStorage::MainThreadStateStorage()->thread_state();
    }
    /* TODO V8 support base/threading/platform_thread.h
    bool IsCreationThread() const { return thread_id_ == CurrentThread(); }
    */
    bool IsAllocationAllowed() const {
        return cppgc::subtle::DisallowGarbageCollectionScope::
        IsGarbageCollectionAllowed(cpp_heap().GetHeapHandle());
    }

    // Waits until sweeping is done and invokes the given callback with
    // the total sizes of live objects in Node and CSS arenas.
    /* TODO V8 support base/functional/callback_forward.h
    void CollectNodeAndCssStatistics(
            base::OnceCallback<void(size_t allocated_node_bytes,
    size_t allocated_css_bytes)>);
    */

    bool IsIncrementalMarking();

    // Forced garbage collection for testing:
    //
    // Collects garbage as long as live memory decreases (capped at 5).
    void CollectAllGarbageForTesting(
            StackState stack_state = StackState::kNoHeapPointers);

    // Perform stop-the-world garbage collection in young generation for testing.
    void CollectGarbageInYoungGenerationForTesting(
            StackState stack_state = StackState::kNoHeapPointers);

    void EnableDetachedGarbageCollectionsForTesting();

    static ThreadState* AttachMainThreadForTesting(v8::Platform*);
    static ThreadState* AttachCurrentThreadForTesting(v8::Platform*);

    // Takes a heap snapshot that can be loaded into DevTools. Requires that
    // `ThreadState` is attached to a `v8::Isolate`.
    //
    // `filename` specifies the path on the system to store the snapshot. If no
    // filename is provided, the snapshot will be emitted to `stdout`.
    //
    // Writing to a file requires a disabled sandbox.
    void TakeHeapSnapshotForTesting(const char* filename) const;

    bool IsTakingHeapSnapshot() const;

    // Copies a string into the V8 heap profiler, and returns a pointer to the
    // copy. Only valid while taking a heap snapshot.
    const char* CopyNameForHeapSnapshot(const char* name) const;

    private:
    explicit ThreadState(v8::Platform*);
    ~ThreadState();

    std::unique_ptr<v8::CppHeap> cpp_heap_;
    std::unique_ptr<v8::EmbedderRootsHandler> embedder_roots_handler_;
    cppgc::HeapHandle& heap_handle_;
    v8::Isolate* isolate_ = nullptr;
    /*TODO V8 support base/threading/platform_thread.h
    base::PlatformThreadId thread_id_;
    */

//    friend class BlinkGCMemoryDumpProvider;
};

// static
bool ThreadState::IsSweepingOnOwningThread(ThreadStateStorage& storage) {
    return cppgc::subtle::HeapState::IsSweepingOnOwningThread(
            storage.heap_handle());
}

}  // namespace webf

#endif  // WEBF_PLATFORM_HEAP_THREAD_STATE_H_
