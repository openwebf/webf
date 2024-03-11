/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "hashchange_event.h"
#include "qjs_hashchange_event.h"

namespace webf {

HashchangeEvent* HashchangeEvent::Create(webf::ExecutingContext* context,
                                         const webf::AtomicString& type,
                                         webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<HashchangeEvent>(context, type, exception_state);
}

HashchangeEvent* HashchangeEvent::Create(webf::ExecutingContext* context,
                                         const webf::AtomicString& type,
                                         const std::shared_ptr<HashchangeEventInit>& initializer,
                                         webf::ExceptionState& exception_state) {
  return MakeGarbageCollected<HashchangeEvent>(context, type, initializer, exception_state);
}

HashchangeEvent::HashchangeEvent(webf::ExecutingContext* context,
                                 const webf::AtomicString& type,
                                 webf::ExceptionState& exception_state)
    : Event(context, type) {}

HashchangeEvent::HashchangeEvent(webf::ExecutingContext* context,
                                 const webf::AtomicString& type,
                                 const std::shared_ptr<HashchangeEventInit>& initializer,
                                 webf::ExceptionState& exception_state)
    : Event(context, type),
      new_url_(initializer->hasNewURL() ? initializer->newURL() : AtomicString::Empty()),
      old_url_(initializer->hasOldURL() ? initializer->oldURL() : AtomicString::Empty()) {}

HashchangeEvent::HashchangeEvent(webf::ExecutingContext* context,
                                 const webf::AtomicString& type,
                                 webf::NativeHashchangeEvent* native_hash_change_event)
    : Event(context, type, &native_hash_change_event->native_event),
#if ANDROID_32_BIT
      new_url_(AtomicString(ctx(),
                            std::unique_ptr<AutoFreeNativeString>(
                                reinterpret_cast<AutoFreeNativeString*>(native_gesture_event->newURL)))),
      old_url_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_gesture_event->oldURL))))
#else
      new_url_(AtomicString(ctx(),
                            std::unique_ptr<AutoFreeNativeString>(
                                reinterpret_cast<AutoFreeNativeString*>(native_hash_change_event->newURL)))),
      old_url_(AtomicString(ctx(),
                            std::unique_ptr<AutoFreeNativeString>(
                                reinterpret_cast<AutoFreeNativeString*>(native_hash_change_event->oldURL))))
#endif
{
}

bool HashchangeEvent::IsHashChangeEvent() const {
  return true;
}

const AtomicString& HashchangeEvent::newURL() const {
  return new_url_;
}

const AtomicString& HashchangeEvent::oldURL() const {
  return old_url_;
}

}  // namespace webf