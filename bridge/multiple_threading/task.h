/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_TASK_H
#define MULTI_THREADING_TASK_H

#include <chrono>
#include <functional>
#include <future>
#include <any>

#include "foundation/logging.h"

namespace webf {

namespace multi_threading {

using Callback = std::function<void()>;

class Task {
 public:
  virtual ~Task() = default;
  virtual void operator()(bool cancel = false) = 0;
};

template <typename Func, typename... Args>
class ConcreteTask : public Task {
 public:
  ConcreteTask(Func&& f, Args&&... args) : func_(std::bind(std::forward<Func>(f), std::forward<Args>(args)...)) {}

  void operator()(bool cancel = false) override {
    if (func_) {
      func_();
    }
  }

 private:
  std::function<void()> func_;
};

template <typename Func, typename... Args>
class ConcreteCallbackTask : public Task {
 public:
  ConcreteCallbackTask(Func&& f, Args&&... args, Callback&& callback)
      : func_(std::bind(std::forward<Func>(f), std::forward<Args>(args)...)),
        callback_(std::forward<Callback>(callback)) {}

  void operator()(bool cancel = false) override {
    if (func_) {
      func_();
    }
    if (callback_) {
      callback_();
    }
  }

 private:
  std::function<void()> func_;
  Callback callback_;
};

class SyncTask : public Task {
 public:
  virtual ~SyncTask() = default;
  virtual void wait() = 0;
};

template <typename Func, typename... Args>
class ConcreteSyncTask : public SyncTask {
 public:
  using ReturnType = std::invoke_result_t<Func, bool, Args...>;

  ConcreteSyncTask(Func&& func, Args&&... args)
      : task_(std::bind(std::forward<Func>(func), std::placeholders::_1, std::forward<Args>(args)...)), future_(task_.get_future()) {}

  void operator()(bool cancel = false) override {
    WEBF_LOG(VERBOSE) << " CALL SYNC CONCRETE TASK";
    task_(cancel);
  }

  void wait() override {
#ifdef DDEBUG
    future_.wait();
#else
    auto status = future_.wait_for(std::chrono::milliseconds(2000));
    if (status == std::future_status::timeout) {
      WEBF_LOG(ERROR) << "SyncTask wait timeout" << std::endl;
    }
#endif
  }

  ReturnType getResult() { return future_.get(); }

 private:
  std::packaged_task<ReturnType(bool)> task_;
  std::future<ReturnType> future_;
};

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_TASK_H