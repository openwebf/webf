/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_WEB_EVENT_LISTENER_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_WEB_EVENT_LISTENER_H_

#include "core/dom/events/event_listener.h"
#include "core/dom/events/event.h"
#include "foundation/casting.h"
#include "rust_readable.h"
#include "webf_value.h"

namespace webf {

class SharedExceptionState;
class Event;
typedef struct EventPublicMethods EventPublicMethods;
typedef struct WebFEventListenerContext WebFEventListenerContext;

using WebFImplEventCallback = void (*)(WebFEventListenerContext* callback_context,
                                       Event* event,
                                       const EventPublicMethods* event_methods,
                                       WebFValueStatus* status,
                                       SharedExceptionState* shared_exception_state);
using FreePtrFn = void (*)(WebFEventListenerContext* callback_context);

struct WebFEventListenerContext : public RustReadable {
  WebFImplEventCallback callback;
  FreePtrFn free_ptr;
  void* ptr;
};

class WebFPublicPluginEventListener : public EventListener {
 public:
  WebFPublicPluginEventListener(WebFEventListenerContext* callback_context,
                                SharedExceptionState* shared_exception_state)
      : callback_context_(callback_context), shared_exception_state_(shared_exception_state) {}

  ~WebFPublicPluginEventListener() {
    callback_context_->free_ptr(callback_context_);
    delete callback_context_;
  }

  static const std::shared_ptr<WebFPublicPluginEventListener> Create(WebFEventListenerContext* WebF_event_listener,
                                                                     SharedExceptionState* shared_exception_state) {
    return std::make_shared<WebFPublicPluginEventListener>(WebF_event_listener, shared_exception_state);
  };

  [[nodiscard]] bool IsPublicPluginEventHandler() const override { return true; }

  void Invoke(ExecutingContext* context, Event* event, ExceptionState& exception_state) override {
    WebFValueStatus* status_block = event->KeepAlive();
    callback_context_->callback(callback_context_, event, event->eventPublicMethods(), status_block,
                                shared_exception_state_);
  }

  [[nodiscard]] bool Matches(const EventListener& other) const override {
    const auto* other_listener = DynamicTo<WebFPublicPluginEventListener>(other);
    return other_listener && other_listener->callback_context_ &&
           other_listener->callback_context_->callback == callback_context_->callback;
  }

  void Trace(GCVisitor* visitor) const override {}

  WebFEventListenerContext* callback_context_;
  SharedExceptionState* shared_exception_state_;
};

template <>
struct DowncastTraits<WebFPublicPluginEventListener> {
  static bool AllowFrom(const EventListener& event_listener) { return event_listener.IsPublicPluginEventHandler(); }
};

}  // namespace webf

#endif  // WEBF_CORE_WEBF_API_PLUGIN_API_WEB_EVENT_LISTENER_H_
