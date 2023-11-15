/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef MULTI_THREADING_DISPATCHER_H
#define MULTI_THREADING_DISPATCHER_H

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

typedef std::function<void()> DartWork;

WEBF_EXPORT_C void executeNativeCallback(DartWork* work_ptr);

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

  void start();
  void stop();
  void pause();
  void resume();

  bool isDedicatedThread() const { return dedicated_thread_; }

  template <typename Func, typename... Args>
  void postToDart(Func&& func, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      return;
    }

    auto task = std::make_shared<ConcreteTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    const DartWork work = [task]() { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    notifyDart(work_ptr);
    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::postToDart end, dart_port= " << dart_port_ << std::endl;
  }

  template <typename Func, typename... Args>
  void postToDartAndCallback(Func&& func, Callback callback, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      callback();
      return;
    }

    auto task = std::make_shared<ConcreteCallbackTask<Func, Args...>>(
        std::forward<Func>(func), std::forward<Args>(args)..., std::forward<Callback>(callback));
    const DartWork work = [task]() { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    notifyDart(work_ptr);
    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::postToDartAndCallback end, dart_port= " << dart_port_ << std::endl;
  }

  template <typename Func, typename... Args>
  auto postToDartSync(Func&& func, Args&&... args) -> std::invoke_result_t<Func, Args...> {
    if (looper_ == nullptr) {
      return std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
    }

    auto task =
        std::make_shared<ConcreteSyncTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    const DartWork work = [task]() { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    notifyDart(work_ptr);

    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::postToDartSync start waiting, dart_port= " << dart_port_ << std::endl;
    task->wait();
    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::postToDartSync end waiting" << std::endl;
    return task->getResult();
  }

  template <typename Func, typename... Args>
  void postToDartWithoutResSync(Func&& func, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
    }

    auto task =
        std::make_shared<ConcreteSyncTask<Func, Args...>>(std::forward<Func>(func), std::forward<Args>(args)...);
    const DartWork work = [task]() { (*task)(); };

    const DartWork* work_ptr = new DartWork(work);
    notifyDart(work_ptr);

    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::postToDartWithoutResSync start waiting, dart_port= " << dart_port_
                      << std::endl;
    task->wait();
    WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::postToDartWithoutResSync end waiting" << std::endl;
  }

  template <typename Func, typename... Args>
  void postToJS(Func&& func, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      return;
    }

    looper_->postMessage(std::forward<Func>(func), std::forward<Args>(args)...);
  }

  template <typename Func, typename... Args>
  void postToJSAndCallback(Func&& func, Callback&& callback, Args&&... args) {
    if (looper_ == nullptr) {
      std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
      callback();
      return;
    }

    looper_->postMessageAndCallback(std::forward<Func>(func), std::forward<Callback>(callback),
                                    std::forward<Args>(args)...);
  }

  template <typename Func, typename... Args>
  auto postToJSSync(Func&& func, Args&&... args) -> std::invoke_result_t<Func, Args...> {
    if (looper_ == nullptr) {
      return std::invoke(std::forward<Func>(func), std::forward<Args>(args)...);
    }

    return looper_->postMessageSync(std::forward<Func>(func), std::forward<Args>(args)...);
  }

 private:
  void notifyDart(const DartWork* work_ptr);

 private:
  Dart_Port dart_port_;
  bool dedicated_thread_ = true;
  std::unique_ptr<Looper> looper_ = nullptr;
};

}  // namespace multi_threading

}  // namespace webf

#endif  // MULTI_THREADING_DISPATCHER_H