// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_FRAME_WINDOW_IDLE_TASKS_H_
#define WEBF_CORE_FRAME_WINDOW_IDLE_TASKS_H_

#include "foundation/macros.h"
#include "qjs_window_idle_request_options.h"
#include "window.h"

namespace webf {

class Window;

class WindowIdleTasks {
  WEBF_STATIC_ONLY(WindowIdleTasks);

 public:
  static int requestIdleCallback(Window&,
                                 const std::shared_ptr<IdleCallback>& callback,
                                 const std::shared_ptr<WindowIdleRequestOptions>& options);
  static void cancelIdleCallback(Window&, int64_t id);

 private:
  friend class Window;
};

}  // namespace webf

#endif  // WEBF_CORE_FRAME_WINDOW_IDLE_TASKS_H_
