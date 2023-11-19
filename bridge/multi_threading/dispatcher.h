/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_DISPATCHER_H
#define MULTI_THREADING_DISPATCHER_H

#include <include/webf_bridge.h>
#include <include/dart_api_dl.h>
#include <condition_variable>
#include <functional>
#include <memory>

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
  explicit Dispatcher(Dart_Port dart_port, bool dedicated_thread = true);
  ~Dispatcher();

  void Start();
  void Stop();
  void Pause();
  void Resume();

  bool isDedicatedThread() const { return dedicated_thread_; }

  template <typename Func, typename... Args>
  void PostToDart(Func&& func, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      return;
    }

    auto task = std::make_shared<ConcreteTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    const DartWork work = [task]() { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    NotifyDart(work_ptr);
    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::PostToDart end, dart_port= " << dart_port_ << std::endl;
  }

  template <typename Func, typename... Args>
  void PostToDartAndCallback(Func&& func, Callback callback, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      callback();
      return;
    }

    auto task = std::make_shared<ConcreteCallbackTask<Func, Args...>>(
        std::forward<Func>(func), std::forward<Args>(args)..., std::forward<Callback>(callback));
    const DartWork work = [task]() { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    NotifyDart(work_ptr);
    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::PostToDartAndCallback end, dart_port= " << dart_port_ << std::endl;
  }

  template <typename Func, typename... Args>
  auto PostToDartSync(Func&& func, Args&&... args) -> std::invoke_result_t<Func, Args...> {
    if (looper_ == nullptr) {
      return std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
    }

    auto task =
        std::make_shared<ConcreteSyncTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    const DartWork work = [task]() { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    NotifyDart(work_ptr);

    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::PostToDartSync Start waiting, dart_port= " << dart_port_ << std::endl;
    task->wait();
    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::PostToDartSync end waiting" << std::endl;
    return task->getResult();
  }

  template <typename Func, typename... Args>
  void PostToDartWithoutResSync(Func&& func, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
    }

    auto task =
        std::make_shared<ConcreteSyncTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    const DartWork work = [task]() { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    NotifyDart(work_ptr);

    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::PostToDartWithoutResSync Start waiting, dart_port= " << dart_port_
                      << std::endl;
    task->wait();
    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::PostToDartWithoutResSync end waiting" << std::endl;
  }

  template <typename Func, typename... Args>
  void PostToJs(Func&& func, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      return;
    }

    looper_->PostMessage(std::forward<Func>(func), std::forward<Args>(args)...);
  }

  template <typename Func, typename... Args>
  void PostToJsAndCallback(Func&& func, Callback&& callback, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      callback();
      return;
    }

    looper_->PostMessageAndCallback(std::forward<Func>(func), std::forward<Callback>(callback),
                                    std::forward<Args>(args)...);
  }

  template <typename Func, typename... Args>
  auto PostToJsSync(Func&& func, Args&&... args) -> std::invoke_result_t<Func, Args...> {
    if (looper_ == nullptr) {
      return std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
    }

    return looper_->PostMessageSync(std::forward<Func>(func), std::forward<Args>(args)...);
  }

 private:
  void NotifyDart(const DartWork* work_ptr);

 private:
  Dart_Port dart_port_;
  bool dedicated_thread_ = true;
  std::unique_ptr<Looper> looper_ = nullptr;
};

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_DISPATCHER_H