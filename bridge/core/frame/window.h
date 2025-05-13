/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_WINDOW_H
#define BRIDGE_WINDOW_H

#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/wrapper_type_info.h"
#include "core/css/computed_css_style_declaration.h"
#include "core/dom/events/event_target.h"
#include "core/frame/script_idle_task_controller.h"
#include "plugin_api/window.h"
#include "qjs_scroll_to_options.h"
#include "qjs_window_idle_request_options.h"
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
  ScriptPromise screen_async(ExceptionState& exception_state);

  [[nodiscard]] const Window* window() const { return this; }
  [[nodiscard]] const Window* self() const { return this; }
  [[nodiscard]] const Window* parent() const { return this; }

  AtomicString btoa(const AtomicString& source, ExceptionState& exception_state);
  AtomicString atob(const AtomicString& source, ExceptionState& exception_state);

  void scroll(ExceptionState& exception_state);
  void scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scroll(double x, double y, ExceptionState& exception_state);
  void scroll_async(ExceptionState& exception_state);
  void scroll_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scroll_async(double x, double y, ExceptionState& exception_state);
  void scrollTo(ExceptionState& exception_state);
  void scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollTo(double x, double y, ExceptionState& exception_state);
  void scrollTo_async(ExceptionState& exception_state);
  void scrollTo_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollTo_async(double x, double y, ExceptionState& exception_state);
  void scrollBy(ExceptionState& exception_state);
  void scrollBy(double x, double y, ExceptionState& exception_state);
  void scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollBy_async(ExceptionState& exception_state);
  void scrollBy_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollBy_async(double x, double y, ExceptionState& exception_state);

  void postMessage(const ScriptValue& message, ExceptionState& exception_state);
  void postMessage(const ScriptValue& message, const AtomicString& target_origin, ExceptionState& exception_state);

  ComputedCssStyleDeclaration* getComputedStyle(Element* element, ExceptionState& exception_state);
  ComputedCssStyleDeclaration* getComputedStyle(Element* element,
                                                const AtomicString& pseudo_elt,
                                                ExceptionState& exception_state);

  double requestAnimationFrame(const std::shared_ptr<Function>& callback, ExceptionState& exception_state);
  double ___requestIdleCallback__(const std::shared_ptr<QJSFunction>& callback, ExceptionState& exception_state);
  int64_t ___requestIdleCallback__(const std::shared_ptr<QJSFunction>& callback,
                                   const std::shared_ptr<WindowIdleRequestOptions>& options,
                                   ExceptionState& exception_state);

  void cancelAnimationFrame(double request_id, ExceptionState& exception_state);
  void cancelIdleCallback(int64_t idle_id, ExceptionState& exception_state);

  void OnLoadEventFired();
  bool IsWindowOrWorkerGlobalScope() const override;

  ScriptedIdleTaskController* script_idle_task() { return &scripted_idle_task_controller_; };

  void Trace(GCVisitor* visitor) const override;
  const WindowPublicMethods* windowPublicMethods();

  // Override default ToQuickJS() to return Global object when access `window` property.
  JSValue ToQuickJS() const override;

 private:
  Member<Screen> screen_;
  ScriptedIdleTaskController scripted_idle_task_controller_;
  friend class WindowIdleTasks;
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
