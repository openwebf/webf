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
  pthread_setname_np(name.c_str());
}

Looper::Looper(int32_t js_id) : js_id_(js_id), running_(false), paused_(false) {}

Looper::~Looper() {}

void Looper::Start() {
  WEBF_LOG(DEBUG) << "Looper::Start" << std::endl;
  std::lock_guard<std::mutex> lock(mutex_);
  if (!worker_.joinable()) {
    running_ = true;
    worker_ = std::thread([this] {
      WEBF_LOG(VERBOSE) << " WORKER RUN.. ";
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
  WEBF_LOG(DEBUG) << "Looper::Resume" << std::endl;
  paused_ = false;
  cv_.notify_one();  // wake up the worker thread.
}

void Looper::Stop() {
  WEBF_LOG(DEBUG) << "Looper::Stop" << std::endl;
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
  WEBF_LOG(DEBUG) << "Looper::Run" << std::endl;
  while (true) {
    std::shared_ptr<Task> task = nullptr;
    {
      std::unique_lock<std::mutex> lock(mutex_);
      cv_.wait(lock, [this] { return !running_ || (!tasks_.empty() && !paused_); });

      if (!running_) {
        WEBF_LOG(DEBUG) << "Looper::Run, running_ is false, break" << std::endl;
        return;
      }

      if (!paused_ && !tasks_.empty()) {
        WEBF_LOG(INFO) << "Looper::Run, pick up front task, size= " << tasks_.size() << std::endl;
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

void* Looper::opaque() {
  return opaque_;
}

void Looper::ExecuteOpaqueFinalizer() {
  opaque_finalizer_(opaque_);
}

}  // namespace multi_threading

}  // namespace webf
