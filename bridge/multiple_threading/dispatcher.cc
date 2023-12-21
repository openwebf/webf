/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dispatcher.h"

#include "foundation/logging.h"

using namespace webf;

namespace webf {

namespace multi_threading {

Dispatcher::Dispatcher(Dart_Port dart_port) : dart_port_(dart_port) {}

Dispatcher::~Dispatcher() {
  //  WEBF_LOG(VERBOSE) << " BEGIN EXE OPAQUE FINALIZER ";
  //  for (auto&& thread : js_threads_) {
  //    PostToJsSync(
  //        true, thread.first, [](Looper* looper) { looper->ExecuteOpaqueFinalizer(); }, thread.second.get());
  //  }
  //
  //
  //
  //  for (auto&& thread : js_threads_) {
  //    thread.second->Stop();
  //  }
  //
  //  WEBF_LOG(VERBOSE) << " ALL THREAD STOPPED";
}

void Dispatcher::AllocateNewJSThread(int32_t js_context_id) {
  assert(js_threads_.count(js_context_id) == 0);
  js_threads_[js_context_id] = std::make_unique<Looper>(js_context_id);
  js_threads_[js_context_id]->Start();
}

bool Dispatcher::IsThreadGroupExist(int32_t js_context_id) {
  return js_threads_.count(js_context_id) > 0;
}

bool Dispatcher::IsThreadBlocked(int32_t js_context_id) {
  if (js_threads_.count(js_context_id) == 0)
    return false;

  auto& loop = js_threads_[js_context_id];
  return loop->isBlocked();
}

void Dispatcher::KillJSThreadSync(int32_t js_context_id) {
  assert(js_threads_.count(js_context_id) > 0);
  auto& looper = js_threads_[js_context_id];
  PostToJsSync(
      true, js_context_id, [](bool cancel, Looper* looper) { looper->ExecuteOpaqueFinalizer(); }, js_threads_[js_context_id].get());
  looper->Stop();
  js_threads_.erase(js_context_id);
}

void Dispatcher::SetOpaqueForJSThread(int32_t js_context_id, void* opaque, OpaqueFinalizer finalizer) {
  assert(js_threads_.count(js_context_id) > 0);
  js_threads_[js_context_id]->SetOpaque(opaque, finalizer);
}

void* Dispatcher::GetOpaque(int32_t js_context_id) {
  assert(js_threads_.count(js_context_id) > 0);
  return js_threads_[js_context_id]->opaque();
}

void Dispatcher::Dispose(webf::multi_threading::Callback callback) {
  WEBF_LOG(VERBOSE) << " BEGIN EXE OPAQUE FINALIZER ";

  std::set<DartWork *> pending_tasks = pending_dart_tasks_;

  for(auto task : pending_tasks) {
    const DartWork dart_work = *task;
    WEBF_LOG(VERBOSE) << " BEGIN EXEC SYNC DART WORKER";
    dart_work(true);
    WEBF_LOG(VERBOSE) << " FINISH EXEC SYNC DART WORKER";
  }

  WEBF_LOG(VERBOSE) << " BEGIN FINALIZE ALL JS THREAD";

  FinalizeAllJSThreads([this, &callback]() {
    StopAllJSThreads();
    callback();
  });
}

std::unique_ptr<Looper>& Dispatcher::looper(int32_t js_context_id) {
  assert(js_threads_.count(js_context_id) > 0);
  return js_threads_[js_context_id];
}

// run in the cpp thread
void Dispatcher::NotifyDart(const DartWork* work_ptr, bool is_sync) {
  const intptr_t work_addr = reinterpret_cast<intptr_t>(work_ptr);

  Dart_CObject** array = new Dart_CObject*[3];

  array[0] = new Dart_CObject();
  array[0]->type = Dart_CObject_Type::Dart_CObject_kInt64;
  array[0]->value.as_int64 = is_sync ? 1 : 0;

  array[1] = new Dart_CObject();
  array[1]->type = Dart_CObject_Type::Dart_CObject_kInt64;
  array[1]->value.as_int64 = work_addr;

  array[2] = new Dart_CObject();
  array[2]->type = Dart_CObject_Type ::Dart_CObject_kInt64;
  size_t thread_id = std::hash<std::thread::id>{}(std::this_thread::get_id());
  array[2]->value.as_int64 = thread_id;

  Dart_CObject dart_object;
  dart_object.type = Dart_CObject_kArray;
  dart_object.value.as_array.length = 3;
  dart_object.value.as_array.values = array;

#if ENABLE_LOG
  if (is_sync) {
    WEBF_LOG(WARN) << " SYNC BLOCK THREAD " << std::this_thread::get_id() << " FOR A DART CALLBACK TO RECOVER";
  }
#endif

  const bool result = Dart_PostCObject_DL(dart_port_, &dart_object);
  if (!result) {
    delete work_ptr;
  }

  delete array[0];
  delete array[1];
  delete array[2];
  delete[] array;
}

void Dispatcher::FinalizeAllJSThreads(webf::multi_threading::Callback callback) {
  std::atomic<uint32_t> unfinished_thread = js_threads_.size();

  for (auto&& thread : js_threads_) {
    PostToJs(
        true, thread.first,
        [&unfinished_thread, &callback, this](Looper* looper) {
          looper->ExecuteOpaqueFinalizer();
          unfinished_thread--;

          if (unfinished_thread == 0) {
            PostToDart(
                true, [&callback]() { callback(); });
          }
        },
        thread.second.get());
  }
}

void Dispatcher::StopAllJSThreads() {
  WEBF_LOG(VERBOSE) << " FINISH EXECU OPAQUE FINALIZER ";
  for (auto&& thread : js_threads_) {
    thread.second->Stop();
  }
  WEBF_LOG(VERBOSE) << " ALL THREAD STOPPED";
}

}  // namespace multi_threading

}  // namespace webf