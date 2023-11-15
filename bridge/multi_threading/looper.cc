/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "looper.h"

#include <cstddef>

#include "logging.h"

namespace webf {

namespace multi_threading {

Looper::Looper() : running_(false), paused_(false) {}

Looper::~Looper() {}

void Looper::start() {
  WEBF_LOG(DEBUG) << "Looper::start" << std::endl;
  std::lock_guard<std::mutex> lock(mutex_);
  if (!worker_.joinable()) {
    running_ = true;
    worker_ = std::thread([this] { this->run(); });
  }
}

void Looper::pause() {
  WEBF_LOG(DEBUG) << "Looper::pause" << std::endl;
  paused_ = true;
}

void Looper::resume() {
  WEBF_LOG(DEBUG) << "Looper::resume" << std::endl;
  paused_ = false;
  cv_.notify_one();  // wake up the worker thread.
}

void Looper::stop() {
  WEBF_LOG(DEBUG) << "Looper::stop" << std::endl;
  {
    std::lock_guard<std::mutex> lock(mutex_);
    running_ = false;
  }
  cv_.notify_one();
  // if (worker_.joinable()) {
  //     worker_.join();
  // }
}

// private methods
void Looper::run() {
  WEBF_LOG(DEBUG) << "Looper::run" << std::endl;
  while (true) {
    std::shared_ptr<Task> task = nullptr;
    {
      std::unique_lock<std::mutex> lock(mutex_);
      cv_.wait(lock, [this] { return !running_ || (!tasks_.empty() && !paused_); });

      if (!running_) {
        WEBF_LOG(DEBUG) << "Looper::run, running_ is false, break" << std::endl;
        return;
      }

      if (!paused_ && !tasks_.empty()) {
        WEBF_LOG(INFO) << "Looper::run, pick up front task, size= " << tasks_.size() << std::endl;
        task = std::move(tasks_.front());
        tasks_.pop();
      }
    }
    if (task != nullptr) {
      (*task)();
    }
  }
}

}  // namespace multi_threading

}  // namespace webf
