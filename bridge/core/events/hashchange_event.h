/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_EVENTS_HASHCHANGE_EVENT_H_
#define WEBF_CORE_EVENTS_HASHCHANGE_EVENT_H_

#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/source_location.h"
#include "core/dom/events/event.h"
#include "plugin_api/hashchange_event.h"
#include "qjs_hashchange_event_init.h"

namespace webf {

struct NativeHashchangeEvent;

class HashchangeEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HashchangeEvent*;

  static HashchangeEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  static HashchangeEvent* Create(ExecutingContext* context,
                                 const AtomicString& type,
                                 const std::shared_ptr<HashchangeEventInit>& initializer,
                                 ExceptionState& exception_state);

  explicit HashchangeEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit HashchangeEvent(ExecutingContext* context,
                           const AtomicString& type,
                           const std::shared_ptr<HashchangeEventInit>& initializer,
                           ExceptionState& exception_state);

  explicit HashchangeEvent(ExecutingContext* context,
                           const AtomicString& type,
                           NativeHashchangeEvent* native_hash_change_event);

  const AtomicString& newURL() const;
  const AtomicString& oldURL() const;

  bool IsHashChangeEvent() const override;

  const HashchangeEventPublicMethods* hashchangeEventPublicMethods();

 private:
  AtomicString new_url_;
  AtomicString old_url_;
};

template <>
struct DowncastTraits<HashchangeEvent> {
  static bool AllowFrom(const Event& event) { return event.IsHashChangeEvent(); }
};

}  // namespace webf

#endif  // WEBF_CORE_EVENTS_HASHCHANGE_EVENT_H_
