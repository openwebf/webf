/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "registered_eventListener.h"
#include "event.h"
#include "qjs_add_event_listener_options.h"

namespace webf {

RegisteredEventListener::RegisteredEventListener() = default;

RegisteredEventListener::RegisteredEventListener(const std::shared_ptr<EventListener>& listener,
                                                 std::shared_ptr<AddEventListenerOptions> options)
    : callback_(listener),
      use_capture_(options->hasCapture() && options->capture()),
      passive_(options->hasPassive() && options->passive()),
      once_(options->hasOnce() && options->once()),
      blocked_event_warning_emitted_(false){};

RegisteredEventListener::RegisteredEventListener(const RegisteredEventListener& that) = default;

RegisteredEventListener& RegisteredEventListener::operator=(const RegisteredEventListener& that) = default;

void RegisteredEventListener::SetCallback(const std::shared_ptr<EventListener>& listener) {
  callback_ = listener;
}

bool RegisteredEventListener::Matches(const std::shared_ptr<EventListener>& listener,
                                      const std::shared_ptr<EventListenerOptions>& options) const {
  // Equality is soley based on the listener and useCapture flags.
  assert(callback_);
  assert(listener);
  assert(options != nullptr);
  return callback_->Matches(*listener) &&
         static_cast<bool>(use_capture_) == (options->hasCapture() && options->capture());
}

bool RegisteredEventListener::ShouldFire(const Event& event) const {
  if (event.FireOnlyCaptureListenersAtTarget()) {
    assert(event.eventPhase() == Event::kAtTarget);
    return Capture();
  }
  if (event.FireOnlyNonCaptureListenersAtTarget()) {
    assert(event.eventPhase() == Event::kAtTarget);
    return !Capture();
  }
  if (event.eventPhase() == Event::kCapturingPhase)
    return Capture();
  if (event.eventPhase() == Event::kBubblingPhase)
    return !Capture();
  return true;
}

void RegisteredEventListener::Trace(GCVisitor* visitor) const {
  callback_->Trace(visitor);
}

bool operator==(const RegisteredEventListener& lhs, const RegisteredEventListener& rhs) {
  assert(lhs.Callback());
  assert(rhs.Callback());
  return lhs.Callback()->Matches(*rhs.Callback()) && lhs.Capture() == rhs.Capture();
}

}  // namespace webf
