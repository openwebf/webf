/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "event_target.h"
#include "bindings/qjs/atomic_string.h"
#include "core/dom/events/event_target.h"

namespace webf {

class RustEventListenerImpl : public EventListener {
 public:
  RustEventListenerImpl(RustEventListener* rust_event_listener, SharedExceptionState* shared_exception_state)
      : rust_event_listener_(rust_event_listener), shared_exception_state_(shared_exception_state) {}

  static const std::shared_ptr<RustEventListenerImpl> Create(RustEventListener* rust_event_listener,
                                                             SharedExceptionState* shared_exception_state) {
    return std::make_shared<RustEventListenerImpl>(rust_event_listener, shared_exception_state);
  };

  void Invoke(ExecutingContext* context, Event* event, ExceptionState& exception_state) override {
    rust_event_listener_->callback(event, shared_exception_state_);
  }

  bool Matches(const EventListener&) const override {}

  void Trace(GCVisitor* visitor) const override {}

  RustEventListener* rust_event_listener_;
  SharedExceptionState* shared_exception_state_;
};

void EventTargetRustMethods::AddEventListener(EventTarget* event_target,
                                              const char* event_name_str,
                                              RustEventListener* event_listener,
                                              RustAddEventListenerOptions& options,
                                              SharedExceptionState* shared_exception_state) {
  AtomicString event_name = AtomicString(event_target->ctx(), event_name_str);
  std::shared_ptr<AddEventListenerOptions> event_listener_options = AddEventListenerOptions::Create();

  // Preparing for the event listener options.
  event_listener_options->setOnce(options.once);
  event_listener_options->setPassive(options.passive);
  event_listener_options->setCapture(options.capture);

  auto listener_impl = RustEventListenerImpl::Create(event_listener, shared_exception_state);

  event_target->addEventListener(event_name, listener_impl, event_listener_options,
                                 shared_exception_state->exception_state);
}

void EventTargetRustMethods::Release(EventTarget* event_target) {
  event_target->ReleaseAlive();
}

}  // namespace webf