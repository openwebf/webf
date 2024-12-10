/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "thread_state.h"
#include <v8/v8-cppgc.h>
#include <v8/v8-isolate.h>
#include <fstream>
#include <iostream>
#include <memory>
#include "custom_spaces.h"
#include "foundation/logging.h"

//#include "base/functional/callback.h"
//#include "base/notreached.h"
//#include "gin/public/v8_platform.h"
//#include "third_party/blink/renderer/platform/bindings/dom_data_store.h"
//#include "third_party/blink/renderer/platform/bindings/dom_wrapper_world.h"
//#include "third_party/blink/renderer/platform/bindings/script_wrappable.h"
//#include "third_party/blink/renderer/platform/bindings/wrapper_type_info.h"
//#include "third_party/blink/renderer/platform/heap/custom_spaces.h"
//#include "third_party/blink/renderer/platform/heap/thread_state_storage.h"
//#include "third_party/blink/renderer/platform/wtf/hash_set.h"
//#include "third_party/blink/renderer/platform/wtf/vector.h"
//#include "v8/include/cppgc/heap-consistency.h"
//#include "v8/include/v8-cppgc.h"
//#include "v8/include/v8-embedder-heap.h"
//#include "v8/include/v8-isolate.h"
//#include "v8/include/v8-object.h"
//#include "v8/include/v8-profiler.h"
//#include "v8/include/v8-traced-handle.h"

namespace webf {
// Handler allowing for dropping V8 wrapper objects that can be recreated
// lazily.
class WebfRootsHandler final : public v8::EmbedderRootsHandler {
 public:
  explicit WebfRootsHandler(v8::Isolate* isolate) : isolate_(isolate) {}

  bool IsRoot(const v8::TracedReference<v8::Value>& handle) {
    /*TODO support IsRoot
     */
    return false;
  }

  // ResetRoot() clears references to V8 wrapper objects in all worlds. It is
  // invoked for references where IsRoot() returned false during young
  // generation garbage collections.
  void ResetRoot(const v8::TracedReference<v8::Value>& handle) final {
    const v8::TracedReference<v8::Object>& traced = handle.As<v8::Object>();
    /*TODO v8 support ClearWrapperInAnyWorldIfEqualTo
    const bool success = DOMDataStore::ClearWrapperInAnyWorldIfEqualTo(
    ToAnyScriptWrappable(isolate_, traced), traced);
    */
    const bool success = true;
    // Since V8 found a handle, Blink needs to find it as well when trying to
    // remove it. Note that this is even true for the case where a
    // DOMWrapperWorld and DOMDataStore are already unreachable as the internal
    // worldmap contains a weak ref that remains valid until the next full GC
    // call. The weak ref is guaranteed to still be valid because it is only
    // cleared on full GCs and the `WebfRootsHandler` is used on minor V8 GCs.
    WEBF_CHECK(success);
  }

  bool TryResetRoot(const v8::TracedReference<v8::Value>& handle) final {
    const v8::TracedReference<v8::Object>& traced = handle.As<v8::Object>();
    /*TODO v8 suppport ClearInlineStorageWrapperIfEqualTo
    return DOMDataStore::ClearInlineStorageWrapperIfEqualTo(
    ToAnyScriptWrappable(isolate_, traced), traced);
    */
    return true;
  }

 private:
  v8::Isolate* isolate_;
};

// static
ThreadState* ThreadState::AttachMainThread() {
  /* TODO v8 support V8Platform
  auto* thread_state = new ThreadState(gin::V8Platform::Get());
  */
  auto* thread_state = new ThreadState(nullptr);
  ThreadStateStorage::AttachMainThread(*thread_state, thread_state->cpp_heap().GetAllocationHandle(),
                                       thread_state->cpp_heap().GetHeapHandle());
  return thread_state;
}

// static
ThreadState* ThreadState::AttachMainThreadForTesting(v8::Platform* platform) {
  auto* thread_state = new ThreadState(platform);
  ThreadStateStorage::AttachMainThread(*thread_state, thread_state->cpp_heap().GetAllocationHandle(),
                                       thread_state->cpp_heap().GetHeapHandle());
  thread_state->EnableDetachedGarbageCollectionsForTesting();
  return thread_state;
}

// static
ThreadState* ThreadState::AttachCurrentThread() {
  /* TODO v8 support V8Platform
  auto* thread_state = new ThreadState(gin::V8Platform::Get());
   */
  auto* thread_state = new ThreadState(nullptr);
  ThreadStateStorage::AttachNonMainThread(*thread_state, thread_state->cpp_heap().GetAllocationHandle(),
                                          thread_state->cpp_heap().GetHeapHandle());
  return thread_state;
}

// static
ThreadState* ThreadState::AttachCurrentThreadForTesting(v8::Platform* platform) {
  ThreadState* thread_state = new ThreadState(platform);
  ThreadStateStorage::AttachNonMainThread(*thread_state, thread_state->cpp_heap().GetAllocationHandle(),
                                          thread_state->cpp_heap().GetHeapHandle());
  thread_state->EnableDetachedGarbageCollectionsForTesting();
  return thread_state;
}

// static
void ThreadState::DetachCurrentThread() {
  auto* state = ThreadState::Current();
  WEBF_CHECK(state);
  delete state;
}

void ThreadState::AttachToIsolate(v8::Isolate* isolate, V8BuildEmbedderGraphCallback) {
  isolate->AttachCppHeap(cpp_heap_.get());
  WEBF_CHECK(cpp_heap_.get() == isolate->GetCppHeap());
  isolate_ = isolate;
  embedder_roots_handler_ = std::make_unique<WebfRootsHandler>(isolate);
  isolate_->SetEmbedderRootsHandler(embedder_roots_handler_.get());
}

void ThreadState::DetachFromIsolate() {
  WEBF_CHECK(cpp_heap_.get() == isolate_->GetCppHeap());
  isolate_->DetachCppHeap();
  isolate_->SetEmbedderRootsHandler(nullptr);
  isolate_ = nullptr;
}

ThreadState::ThreadState(v8::Platform* platform)
    : cpp_heap_(v8::CppHeap::Create(
          platform,
          v8::CppHeapCreateParams(CustomSpaces::CreateCustomSpaces(), v8::WrapperDescriptor(0, 0, 0)))),
      heap_handle_(cpp_heap_->GetHeapHandle()) {}
/*TODO support thread_id_  WrapperDescriptor
 * thread_id_(CurrentThread()) {}
 */

ThreadState::~ThreadState() {
  /*TODO support IsCreationThread
  WEBF_CHECK(IsCreationThread());
   */
  cpp_heap_->Terminate();
  ThreadStateStorage::DetachNonMainThread(*ThreadStateStorage::Current());
}

void ThreadState::CollectAllGarbageForTesting(StackState stack_state) {
  size_t previous_live_bytes = 0;
  for (size_t i = 0; i < 5; i++) {
    // Either triggers unified heap or stand-alone garbage collections.
    cpp_heap().CollectGarbageForTesting(stack_state);
    const size_t live_bytes = cpp_heap().CollectStatistics(cppgc::HeapStatistics::kBrief).used_size_bytes;
    if (previous_live_bytes == live_bytes) {
      break;
    }
    previous_live_bytes = live_bytes;
  }
}

void ThreadState::CollectGarbageInYoungGenerationForTesting(StackState stack_state) {
  cpp_heap().CollectGarbageInYoungGenerationForTesting(stack_state);
}
/*TODO support CustomSpaceStatisticsReceiverImpl
    namespace {

        class CustomSpaceStatisticsReceiverImpl final
                : public v8::CustomSpaceStatisticsReceiver {
        public:
            explicit CustomSpaceStatisticsReceiverImpl(
                    base::OnceCallback<void(size_t allocated_node_bytes,
                                            size_t allocated_css_bytes)> callback)
                    : callback_(std::move(callback)) {}

            ~CustomSpaceStatisticsReceiverImpl() final {
                WEBF_CHECK(node_bytes_.has_value());
                WEBF_CHECK(css_bytes_.has_value());
                std::move(callback_).Run(*node_bytes_, *css_bytes_);
            }

            void AllocatedBytes(cppgc::CustomSpaceIndex space_index, size_t bytes) final {
                if (space_index.value == NodeSpace::kSpaceIndex.value) {
                    node_bytes_ = bytes;
                } else {
                    WEBF_CHECK(space_index.value == CSSValueSpace::kSpaceIndex.value);
                    css_bytes_ = bytes;
                }
            }

        private:
            base::OnceCallback<void(size_t allocated_node_bytes,
                                    size_t allocated_css_bytes)>
                    callback_;
            std::optional<size_t> node_bytes_;
            std::optional<size_t> css_bytes_;
        };

    }  // anonymous namespace
*/
/*TODO V8 support CollectNodeAndCssStatistics
void ThreadState::CollectNodeAndCssStatistics(
        base::OnceCallback<void(size_t allocated_node_bytes,
                                size_t allocated_css_bytes)> callback) {
    std::vector<cppgc::CustomSpaceIndex> spaces{NodeSpace::kSpaceIndex,
                                                CSSValueSpace::kSpaceIndex};
    cpp_heap().CollectCustomSpaceStatisticsAtLastGC(
            std::move(spaces),
            std::make_unique<CustomSpaceStatisticsReceiverImpl>(std::move(callback)));
}
*/

void ThreadState::EnableDetachedGarbageCollectionsForTesting() {
  cpp_heap().EnableDetachedGarbageCollectionsForTesting();
}

bool ThreadState::IsIncrementalMarking() {
  return cppgc::subtle::HeapState::IsMarking(ThreadState::Current()->heap_handle()) &&
         !cppgc::subtle::HeapState::IsInAtomicPause(ThreadState::Current()->heap_handle());
}

namespace {

class BufferedStream final : public v8::OutputStream {
 public:
  explicit BufferedStream(std::streambuf* stream_buffer) : out_stream_(stream_buffer) {}

  WriteResult WriteAsciiChunk(char* data, int size) override {
    out_stream_.write(data, size);
    return kContinue;
  }

  void EndOfStream() override {}

 private:
  std::ostream out_stream_;
};

}  // namespace

void ThreadState::TakeHeapSnapshotForTesting(const char* filename) const {
  WEBF_CHECK(isolate_);
  v8::HeapProfiler* profiler = isolate_->GetHeapProfiler();
  WEBF_CHECK(profiler);

  v8::HeapProfiler::HeapSnapshotOptions options;
  options.snapshot_mode = v8::HeapProfiler::HeapSnapshotMode::kExposeInternals;
  const v8::HeapSnapshot* snapshot = profiler->TakeHeapSnapshot(options);

  {
    std::ofstream file_stream;
    if (filename) {
      file_stream.open(filename, std::ios_base::out | std::ios_base::trunc);
    }
    BufferedStream stream(filename ? file_stream.rdbuf() : std::cout.rdbuf());
    snapshot->Serialize(&stream);
  }

  const_cast<v8::HeapSnapshot*>(snapshot)->Delete();
}

bool ThreadState::IsTakingHeapSnapshot() const {
  if (!isolate_) {
    return false;
  }
  /* TODO support  IsTakingSnapshot
  v8::HeapProfiler* profiler = isolate_->GetHeapProfiler();
  return profiler && profiler->IsTakingSnapshot();
   */
  return false;
}

const char* ThreadState::CopyNameForHeapSnapshot(const char* name) const {
  WEBF_CHECK(isolate_);
  v8::HeapProfiler* profiler = isolate_->GetHeapProfiler();
  WEBF_CHECK(profiler);
  /* TODO support  CopyNameForHeapSnapshot
  return profiler->CopyNameForHeapSnapshot(name);
   */
  return nullptr;
}

}  // namespace webf
