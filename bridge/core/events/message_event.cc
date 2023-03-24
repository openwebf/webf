/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "message_event.h"
#include "core/dom/events/event.h"
#include "qjs_message_event.h"

namespace webf {

MessageEvent* MessageEvent::Create(ExecutingContext* context,
                                   const AtomicString& type,
                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<MessageEvent>(context, type, exception_state);
}

MessageEvent* MessageEvent::Create(ExecutingContext* context,
                                   const AtomicString& type,
                                   const std::shared_ptr<MessageEventInit>& init,
                                   ExceptionState& exception_state) {
  return MakeGarbageCollected<MessageEvent>(context, type, init);
}

MessageEvent::MessageEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, type) {}

MessageEvent::MessageEvent(ExecutingContext* context,
                           const AtomicString& type,
                           const std::shared_ptr<MessageEventInit>& init)
    : Event(context, type),
      data_(init->hasData() ? init->data() : ScriptValue::Empty(ctx())),
      origin_(init->hasOrigin() ? init->origin() : AtomicString::Empty()),
      lastEventId_(init->hasLastEventId() ? init->lastEventId() : AtomicString::Empty()),
      source_(init->hasSource() ? init->source() : AtomicString::Empty()) {}

MessageEvent::MessageEvent(ExecutingContext* context,
                           const AtomicString& type,
                           NativeMessageEvent* native_message_event)
    : Event(context, type, &native_message_event->native_event),
#if ANDROID_32_BIT
      data_(ScriptValue(ctx(), *(reinterpret_cast<NativeValue*>(native_message_event->data)))),
      origin_(AtomicString(ctx(),
                           std::unique_ptr<AutoFreeNativeString>(
                               reinterpret_cast<AutoFreeNativeString*>(native_message_event->origin)))),
      lastEventId_(AtomicString(ctx(),
                                std::unique_ptr<AutoFreeNativeString>(
                                    reinterpret_cast<AutoFreeNativeString*>(native_message_event->lastEventId)))),
      source_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_message_event->source))))
#else
      data_(ScriptValue(ctx(), *(static_cast<NativeValue*>(native_message_event->data)))),
      origin_(AtomicString(ctx(),
                           std::unique_ptr<AutoFreeNativeString>(
                               reinterpret_cast<AutoFreeNativeString*>(native_message_event->origin)))),
      lastEventId_(AtomicString(ctx(),
                                std::unique_ptr<AutoFreeNativeString>(
                                    reinterpret_cast<AutoFreeNativeString*>(native_message_event->lastEventId)))),
      source_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_message_event->source))))
#endif

{
}

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
