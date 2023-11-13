/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_BINDINGS_QJS_MICROTASK_QUEUE_H_
#define WEBF_BINDINGS_QJS_MICROTASK_QUEUE_H_

#include <list>

namespace webf {

using MicrotaskCallback = void (*)(void* data);

class MicrotaskQueue final {
 public:

  struct QueueData {
    void* data;
    MicrotaskCallback callback;
  };

  void DrainMicrotaskQueue();
  void EnqueueMicrotask(MicrotaskCallback callback, void* data = nullptr);
  bool empty();

 private:

  std::list<std::unique_ptr<QueueData>> queue_;
};

}

#endif  // WEBF_BINDINGS_QJS_MICROTASK_QUEUE_H_
