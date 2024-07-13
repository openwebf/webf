/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

 // Generated from template:
 //   code_generator/src/json/templates/event_factory.cc.tmp
 // and input files:
 //   <%= template_path %>

#include "event_factory.h"
#include <unordered_map>
#include "event_type_names.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "core/dom/events/custom_event.h"

<% _.forEach(data, (item, index) => { %>
<% if (_.isString(item)) { %>
#include "qjs_<%= item %>_event.h"
<% } else if (_.isObject(item)) { %>
#include "qjs_<%= _.snakeCase(item.class) %>.h"
<% } %>
<% }); %>


namespace webf {

using EventConstructorFunction = Event* (*)(ExecutingContext* context, const AtomicString& type, RawEvent* raw_event);

using EventMap = std::unordered_map<AtomicString, EventConstructorFunction, AtomicString::KeyHasher>;

static thread_local EventMap* g_event_constructors = nullptr;

struct CreateEventFunctionMapData {
  const AtomicString& tag;
  EventConstructorFunction func;
};

<% _.forEach(data, (item, index) => { %>
  <% if (_.isString(item)) { %>

    static Event* <%= _.upperFirst(item) %>EventConstructor(ExecutingContext* context, const AtomicString& type, RawEvent* raw_event) {
      if (raw_event == nullptr) {
        return MakeGarbageCollected<<%= _.upperFirst(_.camelCase(item)) %>Event>(context, type, ASSERT_NO_EXCEPTION());
      }
      if (raw_event->length == sizeof(Native<%= _.upperFirst(item) %>Event) / sizeof(int64_t)) {
        return MakeGarbageCollected<<%= _.upperFirst(_.camelCase(item)) %>Event>(context, type, toNativeEvent<Native<%= _.upperFirst(item) %>Event>(raw_event));
      }
      return MakeGarbageCollected<Event>(context, type, toNativeEvent<NativeEvent>(raw_event));
    }
  <% } else if (_.isObject(item)) { %>
    static Event* <%= item.class %>Constructor(ExecutingContext* context, const AtomicString& type, RawEvent* raw_event) {
      if (raw_event == nullptr) {
        return MakeGarbageCollected<<%= item.class %>>(context, type, ASSERT_NO_EXCEPTION());
      }
      if (raw_event->length == sizeof(Native<%= _.upperFirst(item.class) %>) / sizeof(int64_t)) {
        return MakeGarbageCollected<<%= item.class %>>(context, type, toNativeEvent<Native<%= _.upperFirst(item.class) %>>(raw_event));
      }
      return MakeGarbageCollected<Event>(context, type, toNativeEvent<NativeEvent>(raw_event));
    }
  <% } %>
<% }); %>

static void CreateEventFunctionMap() {
  assert(!g_event_constructors);
  g_event_constructors = new EventMap();
  // Empty array initializer lists are illegal [dcl.init.aggr] and will not
  // compile in MSVC. If tags list is empty, add check to skip this.

  const CreateEventFunctionMapData data[] = {

      <% _.forEach(data, (item, index) => { %>
          <% if (_.isString(item)) { %>
            {event_type_names::k<%= item %>, <%= _.upperFirst(item) %>EventConstructor},
          <% } else if (_.isObject(item)) { %>
            <% _.forEach(item.types, function(type) { %>
              {event_type_names::k<%= type %>, <%= item.class %>Constructor},
            <% }) %>
          <% } %>
      <% }); %>

  };

  for (size_t i = 0; i < std::size(data); i++)
    g_event_constructors->insert(std::make_pair(data[i].tag, data[i].func));
}

Event* EventFactory::Create(ExecutingContext* context, const AtomicString& type, RawEvent* raw_event) {
  if (!g_event_constructors)
    CreateEventFunctionMap();

  if (raw_event != nullptr && raw_event->is_custom_event) {
    return MakeGarbageCollected<CustomEvent>(context, type, toNativeEvent<NativeCustomEvent>(raw_event));
  }

  auto it = g_event_constructors->find(type);
  if (it == g_event_constructors->end()) {
    if (raw_event == nullptr) {
      return MakeGarbageCollected<Event>(context, type);
    }
    return MakeGarbageCollected<Event>(context, type, toNativeEvent<NativeEvent>(raw_event));
  }
  EventConstructorFunction function = it->second;
  return function(context, type, raw_event);
}

void EventFactory::Dispose() {
  delete g_event_constructors;
  g_event_constructors = nullptr;
}

}  // namespace webf
