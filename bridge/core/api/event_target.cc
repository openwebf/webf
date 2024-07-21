/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/event_target.h"
#include "plugin_api/exception_state.h"
#include "bindings/qjs/atomic_string.h"
#include "core/dom/events/event_target.h"

namespace webf {

class WebFPublicPluginEventListener : public EventListener {
 public:
  WebFPublicPluginEventListener(WebFEventListenerContext* callback_context, SharedExceptionState* shared_exception_state)
      : callback_context_(callback_context), shared_exception_state_(shared_exception_state) {}

  static const std::shared_ptr<WebFPublicPluginEventListener> Create(WebFEventListenerContext* WebF_event_listener,
                                                             SharedExceptionState* shared_exception_state) {
    return std::make_shared<WebFPublicPluginEventListener>(WebF_event_listener, shared_exception_state);
  };

  [[nodiscard]] bool IsPublicPluginEventHandler() const override { return true; }

  void Invoke(ExecutingContext* context, Event* event, ExceptionState& exception_state) override {
    callback_context_->callback(callback_context_, event, shared_exception_state_);
  }

  [[nodiscard]] bool Matches(const EventListener& other) const override {
    const auto* other_listener = DynamicTo<WebFPublicPluginEventListener>(other);
    return other_listener->callback_context_->ptr == callback_context_->ptr;
  }

  void Trace(GCVisitor* visitor) const override {}

  WebFEventListenerContext* callback_context_;
  SharedExceptionState* shared_exception_state_;
};

template <>
struct DowncastTraits<WebFPublicPluginEventListener> {
  static bool AllowFrom(const EventListener& event_listener) {
    return event_listener.IsPublicPluginEventHandler();
  }
};

void EventTargetWebFMethods::AddEventListener(EventTarget* event_target,
                                              const char* event_name_str,
                                              WebFEventListenerContext* callback_context,
                                              WebFAddEventListenerOptions* options,
                                              SharedExceptionState* shared_exception_state) {
  AtomicString event_name = AtomicString(event_target->ctx(), event_name_str);
  std::shared_ptr<AddEventListenerOptions> event_listener_options = AddEventListenerOptions::Create();

  // Preparing for the event listener options.
  event_listener_options->setOnce(options->once);
  event_listener_options->setPassive(options->passive);
  event_listener_options->setCapture(options->capture);

  auto listener_impl = WebFPublicPluginEventListener::Create(callback_context, shared_exception_state);

  event_target->addEventListener(event_name, listener_impl, event_listener_options,
                                 shared_exception_state->exception_state);
}

void EventTargetWebFMethods::Release(EventTarget* event_target) {
  event_target->ReleaseAlive();
}

}  // namespace webf