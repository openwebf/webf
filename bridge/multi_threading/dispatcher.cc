/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dispatcher.h"

#include "foundation/logging.h"

using namespace webf;

// run in the dart isolate thread
void executeNativeCallback(DartWork* work_ptr) {
  WEBF_LOG(VERBOSE) << "[Dart] executeThreadingRequest call from dart" << std::endl;
  const DartWork dart_work = *work_ptr;
  dart_work();
  WEBF_LOG(VERBOSE) << "[Dart] executeThreadingRequest end" << std::endl;
  delete work_ptr;
}

namespace webf {

namespace multi_threading {

Dispatcher::Dispatcher(Dart_Port dart_port, bool dedicated_thread)
    : dart_port_(dart_port), dedicated_thread_(dedicated_thread) {
  start();
}

Dispatcher::~Dispatcher() {
  if (looper_ != nullptr) {
    looper_->stop();
    looper_ = nullptr;
  }
}

void Dispatcher::start() {
  if (dedicated_thread_ && looper_ == nullptr) {
    looper_ = std::make_unique<Looper>();
    looper_->start();
  }
}

void Dispatcher::stop() {
  if (looper_ != nullptr) {
    looper_->stop();
    looper_ = nullptr;
  }
}

void Dispatcher::pause() {
  if (looper_ != nullptr) {
    looper_->pause();
  }
}

void Dispatcher::resume() {
  if (looper_ != nullptr) {
    looper_->resume();
  }
}

// run in the cpp thread
void Dispatcher::notifyDart(const DartWork* work_ptr) {
  WEBF_LOG(VERBOSE) << "[CPP] Dispatcher::notifyDart call from c++, dart_port= " << dart_port_ << std::endl;
  const intptr_t work_addr = reinterpret_cast<intptr_t>(work_ptr);

  Dart_CObject dart_object;
  dart_object.type = Dart_CObject_kInt64;
  dart_object.value.as_int64 = work_addr;

  const bool result = Dart_PostCObject_DL(dart_port_, &dart_object);
  if (!result) {
    WEBF_LOG(ERROR) << "[CPP] Dispatcher::notifyDart failed" << std::endl;
    delete work_ptr;
  }
}

}  // namespace multi_threading

}  // namespace webf