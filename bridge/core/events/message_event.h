/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_EVENTS_MESSAGE_EVENT_H_
#define BRIDGE_CORE_EVENTS_MESSAGE_EVENT_H_

#include "core/dom/events/event.h"
#include "plugin_api/message_event.h"
#include "qjs_message_event_init.h"

namespace webf {

struct NativeMessageEvent;

class MessageEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = MessageEvent*;

  static MessageEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  static MessageEvent* Create(ExecutingContext* context,
                              const AtomicString& type,
                              const std::shared_ptr<MessageEventInit>& init,
                              ExceptionState& exception_state);

  explicit MessageEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  explicit MessageEvent(ExecutingContext* context,
                        const AtomicString& type,
                        const std::shared_ptr<MessageEventInit>& init);
  explicit MessageEvent(ExecutingContext* context, const AtomicString& type, NativeMessageEvent* native_message_event);

  ScriptValue data() const;
  AtomicString origin() const;
  AtomicString lastEventId() const;
  AtomicString source() const;

  bool IsMessageEvent() const override;

  const MessageEventPublicMethods* messageEventPublicMethods();

 private:
  ScriptValue data_;
  AtomicString origin_;
  AtomicString lastEventId_;
  AtomicString source_;
};

template <>
struct DowncastTraits<MessageEvent> {
  static bool AllowFrom(const Event& event) { return event.IsMessageEvent(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_EVENTS_MESSAGE_EVENT_H_
