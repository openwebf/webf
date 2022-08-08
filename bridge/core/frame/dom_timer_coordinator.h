/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_BOM_DOM_TIMER_COORDINATOR_H_
#define BRIDGE_BINDINGS_QJS_BOM_DOM_TIMER_COORDINATOR_H_

#include <quickjs/quickjs.h>
#include <unordered_map>
#include <vector>

namespace webf {

class DOMTimer;
class ExecutingContext;

// Maintains a set of DOMTimers for a given page
// DOMTimerCoordinator assigns IDs to timers; these IDs are
// the ones returned to web authors from setTimeout or setInterval. It
// also tracks recursive creation or iterative scheduling of timers,
// which is used as a signal for throttling repetitive timers.
class DOMTimerCoordinator {
 public:
  // Creates and installs a new timer. Returns the assigned ID.
  void installNewTimer(ExecutingContext* context, int32_t timerId, std::shared_ptr<DOMTimer> timer);

  // Removes and disposes the timer with the specified ID, if any. This may
  // destroy the timer.
  void* removeTimeoutById(int32_t timerId);
  std::shared_ptr<DOMTimer> getTimerById(int32_t timerId);

 private:
  std::unordered_map<int, std::shared_ptr<DOMTimer>> m_activeTimers;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_BOM_DOM_TIMER_COORDINATOR_H_
