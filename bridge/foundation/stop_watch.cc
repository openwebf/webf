/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "stop_watch.h"

namespace webf {

void Stopwatch::Begin() {
  if (!is_running) {
    start_time = std::chrono::steady_clock::now();
    is_running = true;
  }
}

void Stopwatch::Pause() {
  if (is_running) {
    auto pause_time = std::chrono::steady_clock::now();
    elapsed_time += std::chrono::duration_cast<std::chrono::microseconds>(pause_time - start_time).count();
    is_running = false;
  }
}

void Stopwatch::Resume() {
  if (!is_running) {
    start_time = std::chrono::steady_clock::now();
    is_running = true;
  }
}

void Stopwatch::End() {
  if (is_running) {
    auto end_time = std::chrono::steady_clock::now();
    elapsed_time += std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time).count();
    is_running = false;
  }
}

}  // namespace webf