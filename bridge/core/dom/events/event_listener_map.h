/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_BINDINGS_QJS_DOM_EVENT_LISTENER_MAP_H_
#define BRIDGE_BINDINGS_QJS_DOM_EVENT_LISTENER_MAP_H_

#include <quickjs/quickjs.h>

#include <vector>

#include "event_listener.h"
#include "foundation/macros.h"
#include "registered_eventListener.h"

namespace webf {

class AddEventListenerOptions;
class EventListenerOptions;

using EventListenerVector = std::vector<RegisteredEventListener>;

class EventListenerMap final {
  WEBF_DISALLOW_NEW();

 public:
  EventListenerMap();
  EventListenerMap(const EventListenerMap&) = delete;
  EventListenerMap& operator=(const EventListenerMap&) = delete;

  bool IsEmpty() const { return entries_.empty(); }
  bool Contains(const AtomicString& event_type) const;
  bool ContainsCapturing(const AtomicString& event_type) const;
  void Clear();
  bool Add(const AtomicString& event_type,
           const std::shared_ptr<EventListener>& listener,
           const std::shared_ptr<AddEventListenerOptions>& options,
           RegisteredEventListener* registered_event_listener,
           uint32_t* listener_count);
  bool Remove(const AtomicString& event_type,
              const std::shared_ptr<EventListener>& listener,
              const std::shared_ptr<EventListenerOptions>& options,
              size_t* index_of_removed_listener,
              RegisteredEventListener* registered_event_listener,
              uint32_t* listener_count);
  EventListenerVector* Find(const AtomicString& event_type) const;

  void Trace(GCVisitor* visitor) const;

 private:
  // EventListener handlers registered with addEventListener API.
  // We use vector instead of hashMap because
  //  - vector is much more space efficient than hashMap.
  //  - An EventTarget rarely has event listeners for many event types, and
  //    vector is faster in such cases.
  std::vector<std::pair<AtomicString, std::unique_ptr<EventListenerVector>>> entries_;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_DOM_EVENT_LISTENER_MAP_H_
