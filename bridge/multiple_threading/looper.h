/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_LOOPER_H_
#define MULTI_THREADING_LOOPER_H_

#include <condition_variable>
#include <functional>
#include <future>
#include <queue>
#include <thread>

#include "foundation/logging.h"
#include "task.h"

namespace webf {

namespace multi_threading {

typedef void (*OpaqueFinalizer)(void* p);

/**
 * @brief thread looper, used to Run tasks in a thread.
 *
 */
class Looper {
 public:
  Looper(int32_t js_id);
  ~Looper();

  void Start();

  template <typename Func, typename... Args>
  void PostMessage(Func&& func, Args&&... args) {
    auto task = std::make_shared<ConcreteTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    {
      std::unique_lock<std::mutex> lock(mutex_);
      tasks_.emplace(std::move(task));
    }
    cv_.notify_one();
  }

  template <typename Func, typename... Args>
  void PostMessageAndCallback(Func&& func, Callback&& callback, Args&&... args) {
    auto task = std::make_shared<ConcreteCallbackTask<Func, Args...>>(
        std::forward<Func>(func), std::forward<Args>(args)..., std::forward<Callback>(callback));
    {
      std::unique_lock<std::mutex> lock(mutex_);
      tasks_.emplace(std::move(task));
    }
    cv_.notify_one();
  }

  template <typename Func, typename... Args>
  auto PostMessageSync(Func&& func, Args&&... args) -> std::invoke_result_t<Func, Args...> {
    auto task =
        std::make_shared<ConcreteSyncTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    auto task_copy = task;
    {
      std::unique_lock<std::mutex> lock(mutex_);
      tasks_.emplace(std::move(task));
    }
    cv_.notify_one();
    task_copy->wait();

    return task_copy->getResult();
  }

  void Pause();
  void Resume();
  void Stop();

  void SetOpaque(void* p, OpaqueFinalizer finalizer);
  void* opaque();

  void ExecuteOpaqueFinalizer();

 private:
  void Run();

  std::condition_variable cv_;
  std::mutex mutex_;
  std::queue<std::shared_ptr<Task>> tasks_;
  std::thread worker_;
  bool paused_;
  bool running_;
  void* opaque_;
  OpaqueFinalizer opaque_finalizer_;
  int32_t js_id_;
};

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_LOOPER_H_
