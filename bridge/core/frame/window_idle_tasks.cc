// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "window_idle_tasks.h"
#include "qjs_window_idle_request_options.h"

namespace webf {

int WindowIdleTasks::requestIdleCallback(webf::Window& window,
                                         const std::shared_ptr<IdleCallback>& callback,
                                         const std::shared_ptr<WindowIdleRequestOptions>& options) {
  window.scripted_idle_task_controller_.RegisterIdleCallback(callback, options->hasTimeout() ? options->timeout() : 0);
}

void WindowIdleTasks::cancelIdleCallback(webf::Window& window, int64_t id) {
  window.scripted_idle_task_controller_.CancelIdleCallback(window.GetExecutingContext(), id);
}

}  // namespace webf