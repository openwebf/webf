/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/event.h"
#include "plugin_api/event_target.h"
#include "plugin_api/exception_state.h"
#include "core/dom/events/event.h"
#include "core/dom/events/event_target.h"

namespace webf {

bool EventWebFMethods::Bubbles(Event* event) {
  return event->bubbles();
}

bool EventWebFMethods::Cancelable(Event* event) {
  return event->cancelable();
}

WebFValue<EventTarget, EventTargetWebFMethods> EventWebFMethods::CurrentTarget(Event* event) {
  EventTarget* current_target = event->currentTarget();
  current_target->KeepAlive();
  return {.value = current_target, .method_pointer = To<EventTargetWebFMethods>(current_target->publicMethodPointer())};
}

bool EventWebFMethods::DefaultPrevented(Event* event) {
  return event->defaultPrevented();
}

WebFValue<EventTarget, EventTargetWebFMethods> EventWebFMethods::SrcElement(Event* event) {
  EventTarget* src_element = event->srcElement();
  src_element->KeepAlive();
  return {.value = src_element, .method_pointer = To<EventTargetWebFMethods>(src_element->publicMethodPointer())};
}

WebFValue<EventTarget, EventTargetWebFMethods> EventWebFMethods::Target(Event* event) {
  EventTarget* target = event->target();
  target->KeepAlive();
  return {.value = target, .method_pointer = To<EventTargetWebFMethods>(target->publicMethodPointer())};
}

bool EventWebFMethods::IsTrusted(Event* event) {
  return event->isTrusted();
}

double EventWebFMethods::TimeStamp(Event* event) {
  return event->timeStamp();
}

const char* EventWebFMethods::Type(Event* event) {
  return event->type().ToStringView().Characters8();
}

void EventWebFMethods::PreventDefault(Event* event, SharedExceptionState* shared_exception_state) {
  event->preventDefault(shared_exception_state->exception_state);
}

void EventWebFMethods::StopImmediatePropagation(Event* event, SharedExceptionState* shared_exception_state) {
  event->stopImmediatePropagation(shared_exception_state->exception_state);
}

void EventWebFMethods::StopPropagation(Event* event, SharedExceptionState* shared_exception_state) {
  event->stopPropagation(shared_exception_state->exception_state);
}

}  // namespace webf
