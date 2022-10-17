/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_JS_EVENT_HANDLER_H_
#define BRIDGE_BINDINGS_QJS_JS_EVENT_HANDLER_H_

#include "foundation/casting.h"
#include "js_based_event_listener.h"

namespace webf {

// |JSEventHandler| implements EventHandler in the HTML standard.
// https://html.spec.whatwg.org/C/#event-handler-attributes
class JSEventHandler : public JSBasedEventListener {
 public:
  using ImplType = std::shared_ptr<JSEventHandler>;

  enum class HandlerType {
    kEventHandler,
    // For kOnErrorEventHandler
    // https://html.spec.whatwg.org/C/#onerroreventhandler
    kOnErrorEventHandler,
    // For OnBeforeUnloadEventHandler
    // https://html.spec.whatwg.org/C/#onbeforeunloadeventhandler
    kOnBeforeUnloadEventHandler,
  };

  static std::shared_ptr<JSEventHandler> CreateOrNull(JSContext* ctx, JSValue value, HandlerType handler_type);
  static JSValue ToQuickJS(JSContext* ctx, EventTarget* event_target, EventListener* listener) {
    if (auto* event_handler = DynamicTo<JSEventHandler>(listener)) {
      return event_handler->GetListenerObject();
    }
    return JS_NULL;
  }

  explicit JSEventHandler(const std::shared_ptr<QJSFunction>& event_handler, HandlerType type)
      : type_(type), event_handler_(event_handler){};

  JSValue GetListenerObject() override { return event_handler_->ToQuickJS(); }

  // Helper functions for DowncastTraits.
  bool IsEventHandler() const override { return true; }

  // For checking special types of EventHandler.
  bool IsOnErrorEventHandler() const { return type_ == HandlerType::kOnErrorEventHandler; }

  bool IsOnBeforeUnloadEventHandler() const { return type_ == HandlerType::kOnBeforeUnloadEventHandler; }

  // EventListener overrides:
  bool Matches(const EventListener&) const override;

  void Trace(GCVisitor* visitor) const override;

 private:
  // JSBasedEventListener override:
  // Performs "The event handler processing algorithm"
  // https://html.spec.whatwg.org/C/#the-event-handler-processing-algorithm
  void InvokeInternal(EventTarget&, Event&, ExceptionState& exception_state) override;

  std::shared_ptr<QJSFunction> event_handler_;
  const HandlerType type_;
};

template <>
struct DowncastTraits<JSEventHandler> {
  static bool AllowFrom(const EventListener& event_listener) {
    auto* js_based = DynamicTo<JSBasedEventListener>(event_listener);
    return js_based && js_based->IsJSEventHandler();
  }
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_JS_EVENT_HANDLER_H_
