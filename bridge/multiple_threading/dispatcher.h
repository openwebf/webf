/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_DISPATCHER_H
#define MULTI_THREADING_DISPATCHER_H

#include <include/dart_api_dl.h>
#include <include/webf_bridge.h>
#include <condition_variable>
#include <functional>
#include <memory>
#include <set>
#include <unordered_map>

#include "logging.h"
#include "looper.h"
#include "task.h"

#if defined(_WIN32)
#define WEBF_EXPORT_C extern "C" __declspec(dllexport)
#define WEBF_EXPORT __declspec(dllexport)
#else
#define WEBF_EXPORT_C extern "C" __attribute__((visibility("default"))) __attribute__((used))
#define WEBF_EXPORT __attribute__((__visibility__("default")))
#endif

namespace webf {

namespace multi_threading {

/**
 * @brief thread dispatcher, used to dispatch tasks to dart thread or js thread.
 *
 */
class Dispatcher {
 public:
  explicit Dispatcher(Dart_Port dart_port);
  ~Dispatcher();

  void AllocateNewJSThread(int32_t js_context_id);
  bool IsThreadGroupExist(int32_t js_context_id);
  bool IsThreadBlocked(int32_t js_context_id);
  void KillJSThreadSync(int32_t js_context_id);
  void SetOpaqueForJSThread(int32_t js_context_id, void* opaque, OpaqueFinalizer finalizer);
  void* GetOpaque(int32_t js_context_id);
  void Dispose(Callback callback);

  std::unique_ptr<Looper>& looper(int32_t js_context_id);

  template <typename Func, typename... Args>
  void PostToDart(bool dedicated_thread, Func&& func, Args&&... args) {
    if (!dedicated_thread) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      return;
    }

    auto task = std::make_shared<ConcreteTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    DartWork work = [task](bool cancel) { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    NotifyDart(work_ptr, false);
  }

  template <typename Func, typename... Args>
  void PostToDartAndCallback(bool dedicated_thread, Func&& func, Callback callback, Args&&... args) {
    if (!dedicated_thread) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      callback();
      return;
    }

    auto task = std::make_shared<ConcreteCallbackTask<Func, Args...>>(
        std::forward<Func>(func), std::forward<Args>(args)..., std::forward<Callback>(callback));
    const DartWork work = [task]() { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    NotifyDart(work_ptr, false);
  }

  template <typename Func, typename... Args>
  auto PostToDartSync(bool dedicated_thread, double js_context_id, Func&& func, Args&&... args)
      -> std::invoke_result_t<Func, bool, Args...> {
    if (!dedicated_thread) {
      return std::invoke(std::forward<Func>(func), false, std::forward<Args>(args)...);
    }

    auto task =
        std::make_shared<ConcreteSyncTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    auto thread_group_id = static_cast<int32_t>(js_context_id);
    auto& looper = js_threads_[thread_group_id];
    const DartWork work = [task, &looper](bool cancel) {
#if ENABLE_LOG
      WEBF_LOG(WARN) << " BLOCKED THREAD " << std::this_thread::get_id() << " HAD BEEN RESUMED"
                     << " is_cancel: " << cancel;
#endif

      looper->is_blocked_ = false;
      (*task)(cancel);
    };

    DartWork* work_ptr = new DartWork(work);
    pending_dart_tasks_.insert(work_ptr);

    NotifyDart(work_ptr, true);

    looper->is_blocked_ = true;
    task->wait();
    pending_dart_tasks_.erase(work_ptr);

    return task->getResult();
  }

  //  template <typename Func, typename... Args>
  //  void PostToDartWithoutResSync(bool dedicated_thread, Func&& func, Args&&... args) {
  //    if (!dedicated_thread) {
  //      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
  //    }
  //
  //    auto task =
  //        std::make_shared<ConcreteSyncTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
  //    const DartWork work = [task]() { (*task)(); };
  //
  //    const DartWork* work_ptr = new DartWork(work);
  //    NotifyDart(work_ptr, true);
  //
  //    task->wait();
  //  }

  template <typename Func, typename... Args>
  void PostToJs(bool dedicated_thread, int32_t js_context_id, Func&& func, Args&&... args) {
    if (!dedicated_thread) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      return;
    }

    assert(js_threads_.count(js_context_id) > 0);
    auto& looper = js_threads_[js_context_id];
    looper->PostMessage(std::forward<Func>(func), std::forward<Args>(args)...);
  }

  template <typename Func, typename... Args>
  void PostToJsAndCallback(bool dedicated_thread,
                           int32_t js_context_id,
                           Func&& func,
                           Callback&& callback,
                           Args&&... args) {
    if (!dedicated_thread) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      callback();
      return;
    }

    assert(js_threads_.count(js_context_id) > 0);
    auto& looper = js_threads_[js_context_id];
    looper->PostMessageAndCallback(std::forward<Func>(func), std::forward<Callback>(callback),
                                   std::forward<Args>(args)...);
  }

  template <typename Func, typename... Args>
  auto PostToJsSync(bool dedicated_thread, int32_t js_context_id, Func&& func, Args&&... args)
      -> std::invoke_result_t<Func, bool, Args...> {
    if (!dedicated_thread) {
      return std::invoke(std::forward<Func>(func), false, std::forward<Args>(args)...);
    }

    assert(js_threads_.count(js_context_id) > 0);
    auto& looper = js_threads_[js_context_id];
    return looper->PostMessageSync(std::forward<Func>(func), std::forward<Args>(args)...);
  }

 private:
  void NotifyDart(const DartWork* work_ptr, bool is_sync);

  void FinalizeAllJSThreads(Callback callback);
  void StopAllJSThreads();

 private:
  Dart_Port dart_port_;
  std::unordered_map<int32_t, std::unique_ptr<Looper>> js_threads_;
  std::set<DartWork*> pending_dart_tasks_;
  friend Looper;
};

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_DISPATCHER_H