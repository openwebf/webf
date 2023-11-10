/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "microtask_queue.h"

namespace webf {

void MicrotaskQueue::DrainMicrotaskQueue() {
  while (!queue_.empty()) {
    queue_.front()->callback(queue_.front()->data);
    // This function could be recursive call themselves.
    if (!queue_.empty()) {
      queue_.pop_front();
    }
  }
}

void MicrotaskQueue::EnqueueMicrotask(webf::MicrotaskCallback callback, void* data) {
  std::unique_ptr<QueueData> queue_item = std::make_unique<QueueData>();
  queue_item->callback = callback;
  queue_item->data = data;
  queue_.emplace_back(std::move(queue_item));
}

}