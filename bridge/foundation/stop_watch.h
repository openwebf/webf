/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_STOP_WATCH_H_
#define WEBF_FOUNDATION_STOP_WATCH_H_

#include <chrono>

namespace webf {

class Stopwatch {
 public:
  Stopwatch() : is_running(false), elapsed_time(0) {}

  void Begin();
  void Pause();
  void Resume();
  void End();

  [[nodiscard]] long long elapsed() const { return elapsed_time; }

 private:
  std::chrono::steady_clock::time_point start_time;
  bool is_running;
  long long elapsed_time;  // In microseconds
};

}  // namespace webf

#endif  // WEBF_FOUNDATION_STOP_WATCH_H_
