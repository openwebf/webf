/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "looper.h"
#include <pthread.h>

#include <cstddef>

#include "logging.h"

namespace webf {

namespace multi_threading {

static void setThreadName(const std::string& name) {
#if defined(__APPLE__) && defined(__MACH__)  // Apple OSX and iOS (Darwin)
  pthread_setname_np(name.c_str());
#elif defined(__ANDROID__)
  pthread_setname_np(pthread_self(), name.c_str());
#endif
}

Looper::Looper(int32_t js_id) : js_id_(js_id), running_(false), paused_(false) {}

Looper::~Looper() {}

void Looper::Start() {
  std::lock_guard<std::mutex> lock(mutex_);
  if (!worker_.joinable()) {
    running_ = true;
    worker_ = std::thread([this] {
      std::string thread_name = "JS Worker " + std::to_string(js_id_);
      setThreadName(thread_name.c_str());
      this->Run();
    });
  }
}

void Looper::Pause() {
  WEBF_LOG(DEBUG) << "Looper::Pause" << std::endl;
  paused_ = true;
}

void Looper::Resume() {
  paused_ = false;
  cv_.notify_one();  // wake up the worker thread.
}

void Looper::Stop() {
  {
    std::lock_guard<std::mutex> lock(mutex_);
    running_ = false;
  }
  cv_.notify_one();
  if (worker_.joinable()) {
    worker_.join();
  }
}

// private methods
void Looper::Run() {
  while (true) {
    std::shared_ptr<Task> task = nullptr;
    {
      std::unique_lock<std::mutex> lock(mutex_);
      cv_.wait(lock, [this] { return !running_ || (!tasks_.empty() && !paused_); });

      if (!running_) {
        return;
      }

      if (!paused_ && !tasks_.empty()) {
        task = std::move(tasks_.front());
        tasks_.pop();
      }
    }
    if (task != nullptr) {
      (*task)();
    }
  }
}

void Looper::SetOpaque(void* p, OpaqueFinalizer finalizer) {
  opaque_ = p;
  opaque_finalizer_ = finalizer;
}

bool Looper::isBlocked() {
  return is_blocked_;
}

void* Looper::opaque() {
  return opaque_;
}

void Looper::ExecuteOpaqueFinalizer() {
  opaque_finalizer_(opaque_);
}

}  // namespace multi_threading

}  // namespace webf
