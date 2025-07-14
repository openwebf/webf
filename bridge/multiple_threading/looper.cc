/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "looper.h"
#include <pthread.h>

#include <cstddef>
#include <memory>

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

// Helper struct to pass data to pthread
struct ThreadData {
  Looper* looper;
  std::string thread_name;
};

// Thread function for pthread_create
static void* threadFunc(void* arg) {
  std::unique_ptr<ThreadData> data(static_cast<ThreadData*>(arg));
  setThreadName(data->thread_name);
  data->looper->ThreadMain();
  return nullptr;
}

Looper::Looper(int32_t js_id) : js_id_(js_id), running_(false), paused_(false) {}

Looper::~Looper() {}

void Looper::Start() {
  std::lock_guard<std::mutex> lock(mutex_);
  if (!has_pthread_) {
    running_ = true;
    
    // Create pthread attributes
    pthread_attr_t attr;
    pthread_attr_init(&attr);

#ifndef NDEBUG
    // Set stack size to 8MB (default is usually 512KB-2MB)
    const size_t stackSize = 8 * 1024 * 1024;  // 8MB
    pthread_attr_setstacksize(&attr, stackSize);
#else
    // Set stack size to 1MB (default is usually 512KB-2MB)
    const size_t stackSize = 1024 * 1024;  // 1MB
    pthread_attr_setstacksize(&attr, stackSize);
#endif
    // Create thread data
    auto* threadData = new ThreadData{
      this,
      "JS Worker " + std::to_string(js_id_)
    };
    
    // Create pthread with custom stack size
    int result = pthread_create(&pthread_worker_, &attr, threadFunc, threadData);
    if (result == 0) {
      has_pthread_ = true;
    } else {
      delete threadData;
      running_ = false;
    }
    
    // Clean up attributes
    pthread_attr_destroy(&attr);
  }
}

void Looper::Stop() {
  {
    std::lock_guard<std::mutex> lock(mutex_);
    running_ = false;
  }
  cv_.notify_one();
  
  if (has_pthread_) {
    pthread_join(pthread_worker_, nullptr);
    has_pthread_ = false;
  } else if (worker_.joinable()) {
    worker_.join();
  }
}

void Looper::ThreadMain() {
  Run();
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
    if (task != nullptr && running_) {
      (*task)(false);
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