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

/**
 * @brief thread looper, used to run tasks in a thread.
 *
 */
class Looper {
 public:
  Looper();
  ~Looper();

  void start();

  template <typename Func, typename... Args>
  void postMessage(Func&& func, Args&&... args) {
    auto task = std::make_shared<ConcreteTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    {
      std::unique_lock<std::mutex> lock(mutex_);
      tasks_.emplace(std::move(task));
    }
    cv_.notify_one();
  }

  template <typename Func, typename... Args>
  void postMessageAndCallback(Func&& func, Callback&& callback, Args&&... args) {
    auto task = std::make_shared<ConcreteCallbackTask<Func, Args...>>(
        std::forward<Func>(func), std::forward<Args>(args)..., std::forward<Callback>(callback));
    {
      std::unique_lock<std::mutex> lock(mutex_);
      tasks_.emplace(std::move(task));
    }
    cv_.notify_one();
  }

  template <typename Func, typename... Args>
  auto postMessageSync(Func&& func, Args&&... args) -> std::invoke_result_t<Func, Args...> {
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

  void pause();
  void resume();
  void stop();

 private:
  void run();

  std::condition_variable cv_;
  std::mutex mutex_;
  std::queue<std::shared_ptr<Task>> tasks_;
  std::thread worker_;
  bool paused_;
  bool running_;
};

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_LOOPER_H_
