/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dispatcher.h"

#include "core/dart_isolate_context.h"
/* TODO V8 support page
#include "core/page.h"
 */
#include "foundation/logging.h"

using namespace webf;

namespace webf {

namespace multi_threading {

Dispatcher::Dispatcher(Dart_Port dart_port) : dart_port_(dart_port) {}

Dispatcher::~Dispatcher() {}

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
      true, js_context_id, [](bool cancel, Looper* looper) { looper->ExecuteOpaqueFinalizer(); },
      js_threads_[js_context_id].get());
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
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: BEGIN EXE OPAQUE FINALIZER ";
#endif

   /* TODO V8 support page
  for (auto&& thread : js_threads_) {
    auto* page_group = static_cast<PageGroup*>(thread.second->opaque());
    for (auto& page : (*page_group->pages())) {
      page->executingContext()->SetContextInValid();
    }
  }
  */

  std::set<DartWork*> pending_tasks = pending_dart_tasks_;

  for (auto task : pending_tasks) {
    const DartWork dart_work = *task;
#if ENABLE_LOG
    WEBF_LOG(VERBOSE) << "[Dispatcher]: BEGIN EXEC SYNC DART WORKER";
#endif
    dart_work(true);
#if ENABLE_LOG
    WEBF_LOG(VERBOSE) << "[Dispatcher]: FINISH EXEC SYNC DART WORKER";
#endif
  }

#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: BEGIN FINALIZE ALL JS THREAD";
#endif

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
bool Dispatcher::NotifyDart(const DartWork* work_ptr, bool is_sync) {
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
    return false;
  }

  delete array[0];
  delete array[1];
  delete array[2];
  delete[] array;
  return true;
}

void Dispatcher::FinalizeAllJSThreads(webf::multi_threading::Callback callback) {
  std::atomic<size_t> unfinished_thread = js_threads_.size();

  std::atomic<bool> is_final_async_dart_task_complete{false};

  if (unfinished_thread == 0) {
    is_final_async_dart_task_complete = true;
  }

  for (auto&& thread : js_threads_) {
    PostToJs(
        true, thread.first,
        [&unfinished_thread, &thread, &is_final_async_dart_task_complete](Looper* looper) {
#if ENABLE_LOG
          WEBF_LOG(VERBOSE) << "[Dispatcher]: RUN JS FINALIZER, context_id: " << thread.first;
#endif
          looper->ExecuteOpaqueFinalizer();
          unfinished_thread--;

#if ENABLE_LOG
          WEBF_LOG(VERBOSE) << "[Dispatcher]: UNFINISHED THREAD: " << unfinished_thread;
#endif
          if (unfinished_thread == 0) {
            is_final_async_dart_task_complete = true;
            return;
          }
        },
        thread.second.get());
#if ENABLE_LOG
    WEBF_LOG(VERBOSE) << "[Dispatcher]: POST TO JS THREAD";
#endif
  }

#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: WAITING FOR JS THREAD COMPLETE";
#endif
  // Waiting for the final dart task return.
  while (!is_final_async_dart_task_complete) {
  }

#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: ALL JS THREAD FINALIZED SUCCESS";
#endif
  callback();
}

void Dispatcher::StopAllJSThreads() {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: FINISH EXEC OPAQUE FINALIZER ";
#endif
  for (auto&& thread : js_threads_) {
    thread.second->Stop();
  }
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[Dispatcher]: ALL THREAD STOPPED";
#endif
}

}  // namespace multi_threading

}  // namespace webf