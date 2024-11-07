/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_WINDOW_H
#define BRIDGE_WINDOW_H

#include "bindings/qjs/wrapper_type_info.h"
#include "core/css/computed_css_style_declaration.h"
#include "core/dom/events/event_target.h"
#include "plugin_api/window.h"
#include "qjs_scroll_to_options.h"
#include "screen.h"

namespace webf {

class Element;

class Window : public EventTargetWithInlineData {
  DEFINE_WRAPPERTYPEINFO();

 public:
  Window() = delete;
  Window(ExecutingContext* context);

  Window* open(ExceptionState& exception_state);
  Window* open(const AtomicString& url, ExceptionState& exception_state);

  Screen* screen();

  [[nodiscard]] const Window* window() const { return this; }
  [[nodiscard]] const Window* self() const { return this; }
  [[nodiscard]] const Window* parent() const { return this; }

  AtomicString btoa(const AtomicString& source, ExceptionState& exception_state);
  AtomicString atob(const AtomicString& source, ExceptionState& exception_state);

  void scroll(ExceptionState& exception_state);
  void scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scroll(double x, double y, ExceptionState& exception_state);
  void scrollTo(ExceptionState& exception_state);
  void scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollTo(double x, double y, ExceptionState& exception_state);
  void scrollBy(ExceptionState& exception_state);
  void scrollBy(double x, double y, ExceptionState& exception_state);
  void scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);

  void postMessage(const ScriptValue& message, ExceptionState& exception_state);
  void postMessage(const ScriptValue& message, const AtomicString& target_origin, ExceptionState& exception_state);

  ComputedCssStyleDeclaration* getComputedStyle(Element* element, ExceptionState& exception_state);
  ComputedCssStyleDeclaration* getComputedStyle(Element* element,
                                                const AtomicString& pseudo_elt,
                                                ExceptionState& exception_state);

  double requestAnimationFrame(const std::shared_ptr<QJSFunction>& callback, ExceptionState& exceptionState);
  void cancelAnimationFrame(double request_id, ExceptionState& exception_state);

  void OnLoadEventFired();
  bool IsWindowOrWorkerGlobalScope() const override;

  void Trace(GCVisitor* visitor) const override;
  const WindowPublicMethods* windowPublicMethods();

  // Override default ToQuickJS() to return Global object when access `window` property.
  JSValue ToQuickJS() const override;

 private:
  Member<Screen> screen_;
};

template <>
struct DowncastTraits<Window> {
  static bool AllowFrom(const EventTarget& event_target) { return event_target.IsWindowOrWorkerGlobalScope(); }
  static bool AllowFrom(const BindingObject& binding_object) {
    return binding_object.IsEventTarget() && DynamicTo<EventTarget>(binding_object)->IsWindowOrWorkerGlobalScope();
  }
};

}  // namespace webf

#endif  // BRIDGE_WINDOW_H
