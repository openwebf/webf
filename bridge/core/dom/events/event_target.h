/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_EVENT_TARGET_H
#define BRIDGE_EVENT_TARGET_H

#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/js_event_listener.h"
#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "event_listener_map.h"
#include "foundation/logging.h"
#include "foundation/native_string.h"
#include "qjs_add_event_listener_options.h"
#include "qjs_unionadd_event_listener_options_boolean.h"
#include "qjs_unionevent_listener_options_boolean.h"

#if UNIT_TEST
void TEST_invokeBindingMethod(void* nativePtr, void* returnValue, void* method, int32_t argc, void* argv);
#endif

#define GetPropertyMagic "%g"
#define SetPropertyMagic "%s"

namespace webf {

enum class DispatchEventResult {
  // Event was not canceled by event handler or default event handler.
  kNotCanceled,
  // Event was canceled by event handler; i.e. a script handler calling
  // preventDefault.
  kCanceledByEventHandler,
  // Event was canceled by the default event handler; i.e. executing the default
  // action.  This result should be used sparingly as it deviates from the DOM
  // Event Dispatch model. Default event handlers really shouldn't be invoked
  // inside of dispatch.
  kCanceledByDefaultEventHandler,
  // Event was canceled but suppressed before dispatched to event handler.  This
  // result should be used sparingly; and its usage likely indicates there is
  // potential for a bug. Trusted events may return this code; but untrusted
  // events likely should always execute the event handler the developer intends
  // to execute.
  kCanceledBeforeDispatch,
};

struct FiringEventIterator {
  WEBF_DISALLOW_NEW();

 public:
  FiringEventIterator(const AtomicString& event_type, size_t& iterator, size_t& end)
      : event_type(event_type), iterator(iterator), end(end) {}

  const AtomicString& event_type;
  size_t& iterator;
  size_t& end;
};

using FiringEventIteratorVector = std::vector<FiringEventIterator>;

class EventTargetData final {
  WEBF_DISALLOW_NEW();

 public:
  EventTargetData();
  EventTargetData(const EventTargetData&) = delete;
  EventTargetData& operator=(const EventTargetData&) = delete;
  ~EventTargetData();

  void Trace(GCVisitor* visitor) const;

  EventListenerMap event_listener_map;
  EventListenerMap event_capture_listener_map;

  std::unique_ptr<FiringEventIteratorVector> firing_event_iterators;
};

class Node;

// All DOM event targets extend EventTarget. The spec is defined here:
// https://dom.spec.whatwg.org/#interface-eventtarget
// EventTarget objects allow us to add and remove an event
// listeners of a specific event type. Each EventTarget object also represents
// the target to which an event is dispatched when something has occurred.
class EventTarget : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = EventTarget*;

  static EventTarget* Create(ExecutingContext* context, ExceptionState& exception_state);

  EventTarget() = delete;
  ~EventTarget();
  explicit EventTarget(ExecutingContext* context);
  explicit EventTarget(ExecutingContext* context, NativeBindingObject* native_binding_object);

  virtual Node* ToNode();

  bool addEventListener(const AtomicString& event_type,
                        const std::shared_ptr<EventListener>& event_listener,
                        const std::shared_ptr<QJSUnionAddEventListenerOptionsBoolean>& options,
                        ExceptionState& exception_state);
  bool addEventListener(const AtomicString& event_type,
                        const std::shared_ptr<EventListener>& event_listener,
                        ExceptionState& exception_state);
  bool removeEventListener(const AtomicString& event_type,
                           const std::shared_ptr<EventListener>& event_listener,
                           ExceptionState& exception_state);
  bool removeEventListener(const AtomicString& event_type,
                           const std::shared_ptr<EventListener>& event_listener,
                           const std::shared_ptr<QJSUnionEventListenerOptionsBoolean>& options,
                           ExceptionState& exception_state);
  bool removeEventListener(const AtomicString& event_type,
                           const std::shared_ptr<EventListener>& event_listener,
                           bool use_capture,
                           ExceptionState& exception_state);
  bool dispatchEvent(Event* event, ExceptionState& exception_state);

  virtual DispatchEventResult FireEventListeners(Event&, ExceptionState&);
  virtual DispatchEventResult FireEventListeners(Event&, bool isCapture, ExceptionState&);

  static DispatchEventResult GetDispatchEventResult(const Event&);

  // Used for legacy "onEvent" attribute APIs.
  bool SetAttributeEventListener(const AtomicString& event_type,
                                 const std::shared_ptr<EventListener>& listener,
                                 ExceptionState& exception_state);
  std::shared_ptr<EventListener> GetAttributeEventListener(const AtomicString& event_type);

  EventListenerVector* GetEventListeners(const AtomicString& event_type);

  virtual bool IsWindowOrWorkerGlobalScope() const { return false; }
  virtual bool IsNode() const { return false; }
  bool IsEventTarget() const override;

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;

  void Trace(GCVisitor* visitor) const override;

 protected:
  virtual bool AddEventListenerInternal(const AtomicString& event_type,
                                        const std::shared_ptr<EventListener>& listener,
                                        const std::shared_ptr<AddEventListenerOptions>& options);
  bool RemoveEventListenerInternal(const AtomicString& event_type,
                                   const std::shared_ptr<EventListener>& listener,
                                   const std::shared_ptr<EventListenerOptions>& options);

  DispatchEventResult DispatchEventInternal(Event& event, ExceptionState& exception_state);

  NativeValue HandleDispatchEventFromDart(int32_t argc, const NativeValue* argv, Dart_Handle dart_object);

  // Subclasses should likely not override these themselves; instead, they
  // should subclass EventTargetWithInlineData.
  virtual EventTargetData* GetEventTargetData() = 0;
  virtual EventTargetData& EnsureEventTargetData() = 0;

 private:
  RegisteredEventListener* GetAttributeRegisteredEventListener(const AtomicString& event_type);

  bool FireEventListeners(Event&, EventTargetData*, EventListenerVector&, ExceptionState&);
};

template <>
struct DowncastTraits<EventTarget> {
  static bool AllowFrom(const BindingObject& binding_object) { return binding_object.IsEventTarget(); }
};

// Provide EventTarget with inlined EventTargetData for improved performance.
class EventTargetWithInlineData : public EventTarget {
 public:
  EventTargetWithInlineData() = delete;
  explicit EventTargetWithInlineData(ExecutingContext* context) : EventTarget(context){};
  explicit EventTargetWithInlineData(ExecutingContext* context, NativeBindingObject* native_binding_object)
      : EventTarget(context, native_binding_object){};

  void Trace(GCVisitor* visitor) const override;

 protected:
  EventTargetData* GetEventTargetData() final { return &data_; }
  EventTargetData& EnsureEventTargetData() final { return data_; }

 private:
  EventTargetData data_;
};

// Macros to define an attribute event listener.
//  |lower_name| - Lower-cased event type name.  e.g. |focus|
//  |symbol_name| - C++ symbol name in event_type_names namespace. e.g. |kFocus|
#define DEFINE_ATTRIBUTE_EVENT_LISTENER(lower_name, symbol_name)                                       \
  EventListener* on##lower_name() { return GetAttributeEventListener(event_type_names::symbol_name); } \
  void setOn##lower_name(EventListener* listener) {                                                    \
    SetAttributeEventListener(event_type_names::symbol_name, listener);                                \
  }

#define DEFINE_STATIC_ATTRIBUTE_EVENT_LISTENER(lower_name, symbol_name)                                   \
  static std::shared_ptr<EventListener> on##lower_name(EventTarget& eventTarget) {                        \
    return eventTarget.GetAttributeEventListener(event_type_names::symbol_name);                          \
  }                                                                                                       \
  static void setOn##lower_name(EventTarget& eventTarget, const std::shared_ptr<EventListener>& listener, \
                                ExceptionState& exception_state) {                                        \
    eventTarget.SetAttributeEventListener(event_type_names::symbol_name, listener, exception_state);      \
  }

#define DEFINE_WINDOW_ATTRIBUTE_EVENT_LISTENER(lower_name, symbol_name)                                      \
  std::shared_ptr<EventListener> on##lower_name() {                                                          \
    return GetDocument().GetWindowAttributeEventListener(event_type_names::symbol_name);                     \
  }                                                                                                          \
  void setOn##lower_name(const std::shared_ptr<EventListener>& listener, ExceptionState& exception_state) {  \
    GetDocument().SetWindowAttributeEventListener(event_type_names::symbol_name, listener, exception_state); \
  }

#define DEFINE_DOCUMENT_ATTRIBUTE_EVENT_LISTENER(lower_name, symbol_name)                                   \
  std::shared_ptr<EventListener> on##lower_name() {                                                         \
    return GetWindowAttributeEventListener(event_type_names::symbol_name);                                  \
  }                                                                                                         \
  void setOn##lower_name(const std::shared_ptr<EventListener>& listener, ExceptionState& exception_state) { \
    SetWindowAttributeEventListener(event_type_names::symbol_name, listener, exception_state);              \
  }

#define DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(lower_name, symbol_name)                                       \
  static std::shared_ptr<EventListener> on##lower_name(EventTarget& eventTarget) {                                   \
    if (Node* node = eventTarget.ToNode()) {                                                                         \
      return node->GetDocument().GetWindowAttributeEventListener(event_type_names::symbol_name);                     \
    }                                                                                                                \
    return eventTarget.GetAttributeEventListener(event_type_names::symbol_name);                                     \
  }                                                                                                                  \
  static void setOn##lower_name(EventTarget& eventTarget, const std::shared_ptr<EventListener>& listener,            \
                                ExceptionState& exception_state) {                                                   \
    if (Node* node = eventTarget.ToNode()) {                                                                         \
      node->GetDocument().SetWindowAttributeEventListener(event_type_names::symbol_name, listener, exception_state); \
    } else {                                                                                                         \
      eventTarget.SetAttributeEventListener(event_type_names::symbol_name, listener, exception_state);               \
    }                                                                                                                \
  }

}  // namespace webf

#endif  // BRIDGE_EVENT_TARGET_H
