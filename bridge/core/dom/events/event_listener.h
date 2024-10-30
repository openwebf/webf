/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_DOM_EVENTS_EVENT_LISTENER_H_
#define BRIDGE_CORE_DOM_EVENTS_EVENT_LISTENER_H_

#include "core/executing_context.h"

namespace webf {

class JSBasedEventListener;
class Event;

// EventListener represents 'callback' in 'event listener' in DOM standard.
// https://dom.spec.whatwg.org/#concept-event-listener
//
// While RegisteredEventListener represents 'event listener', which consists of
//   - type
//   - callback
//   - capture
//   - passive
//   - once
//   - removed
// EventListener represents 'callback' part.
class EventListener {
 public:
  EventListener(const EventListener&) = delete;
  EventListener& operator=(const EventListener&) = delete;
  ~EventListener() = default;

  // Invokes this event listener.
  virtual void Invoke(ExecutingContext* context, Event*, ExceptionState& exception_state) = 0;

  virtual bool IsJSBasedEventListener() const { return false; }

  // Returns true if this implements IDL EventHandler family.
  virtual bool IsEventHandler() const { return false; }

  virtual bool IsPublicPluginEventHandler() const { return false; }

  // Returns true if this implements IDL EventHandler family and the value is
  // a content attribute (or compiled from a content attribute).
  virtual bool IsEventHandlerForContentAttribute() const { return false; }

  // Returns true if this event listener is considered as the same with the
  // other event listener (in context of EventTarget.removeEventListener).
  // See also |RegisteredEventListener::Matches|.
  //
  // This function must satisfy the symmetric property; a.Matches(b) must
  // produce the same result as b.Matches(a).
  virtual bool Matches(const EventListener&) const = 0;

  virtual void Trace(GCVisitor* visitor) const = 0;

 protected:
  EventListener() = default;

  friend JSBasedEventListener;
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_EVENTS_EVENT_LISTENER_H_
