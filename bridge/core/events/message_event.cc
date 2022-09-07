/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "message_event.h"
#include "core/dom/events/event.h"

namespace webf {

struct NativeMessageEvent {
  NativeEvent native_event;
  const char *data;
  NativeString *origin;
  NativeString *lastEventId;
  NativeString *source;
};

MessageEvent *MessageEvent::Create(ExecutingContext *context,
                                   const AtomicString &type,
                                   ExceptionState &exception_state) {
  return MakeGarbageCollected<MessageEvent>(context, type);
}

MessageEvent *MessageEvent::Create(ExecutingContext *context,
                                   const AtomicString &type,
                                   const std::shared_ptr<MessageEventInit> &init,
                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<MessageEvent>(context, type, init);
}

MessageEvent::MessageEvent(ExecutingContext *context, const AtomicString &type) : Event(context, type) {}

MessageEvent::MessageEvent(ExecutingContext *context,
                           const AtomicString &type,
                           const std::shared_ptr<MessageEventInit> &init)
    : Event(context, type),
      data_(init->data()),
      origin_(init->origin()),
      lastEventId_(init->lastEventId()),
      source_(init->source()) {}

MessageEvent::MessageEvent(ExecutingContext *context,
                           const AtomicString &type,
                           NativeMessageEvent *native_message_event) :
    Event(context, type, &native_message_event->native_event),
    data_(ScriptValue::CreateJsonObject(ctx(), native_message_event->data, strlen(native_message_event->data))),
    origin_(AtomicString(ctx(), native_message_event->origin)),
    lastEventId_(AtomicString(ctx(), native_message_event->lastEventId)),
    source_(AtomicString(ctx(), native_message_event->source)) {}

ScriptValue MessageEvent::data() const {
  return data_;
}

AtomicString MessageEvent::origin() const {
  return origin_;
}

AtomicString MessageEvent::lastEventId() const {
  return lastEventId_;
}

AtomicString MessageEvent::source() const {
  return source_;
}

bool MessageEvent::IsMessageEvent() const {
  return true;
}

}  // namespace webf
