/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "keyboard_event.h"
#include "qjs_keyboard_event.h"

namespace webf {

double KeyboardEvent::DOM_KEY_LOCATION_LEFT = KeyLocationCode::kDomKeyLocationLeft;
double KeyboardEvent::DOM_KEY_LOCATION_RIGHT = KeyLocationCode::kDomKeyLocationRight;
double KeyboardEvent::DOM_KEY_LOCATION_STANDARD = KeyLocationCode::kDomKeyLocationStandard;
double KeyboardEvent::DOM_KEY_LOCATION_NUMPAD = KeyLocationCode::kDomKeyLocationNumpad;

KeyboardEvent* KeyboardEvent::Create(ExecutingContext* context,
                                     const AtomicString& type,
                                     ExceptionState& exception_state) {
  return MakeGarbageCollected<KeyboardEvent>(context, type, exception_state);
}

KeyboardEvent* KeyboardEvent::Create(ExecutingContext* context,
                                     const AtomicString& type,
                                     const std::shared_ptr<KeyboardEventInit>& initializer,
                                     ExceptionState& exception_state) {
  return MakeGarbageCollected<KeyboardEvent>(context, type, initializer, exception_state);
}

KeyboardEvent::KeyboardEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : UIEvent(context, type, exception_state) {}

KeyboardEvent::KeyboardEvent(ExecutingContext* context,
                             const AtomicString& type,
                             const std::shared_ptr<KeyboardEventInit>& initializer,
                             ExceptionState& exception_state)
    : UIEvent(context, type, initializer, exception_state),
      // alt_key_(initializer->hasAltKey() && initializer->altKey()),
      // char_code_(initializer->hasCharCode() ? initializer->charCode() : 0.0),
      code_(initializer->hasCode() ? initializer->code() : AtomicString::Empty()),
      // ctrl_key_(initializer->hasCtrlKey() && initializer->ctrlKey()),
      // is_composing_(initializer->hasComposed() && initializer->isComposing()),
      key_(initializer->hasKey() ? initializer->key() : AtomicString::Empty())
// key_code_(initializer->hasKeyCode() ? initializer->keyCode() : 0.0),
// location_(initializer->hasLocation() ? initializer->location() : 0.0),
// meta_key_(initializer->hasMetaKey() && initializer->metaKey()),
// repeat_(initializer->hasRepeat() && initializer->repeat()),
// shift_key_(initializer->hasShiftKey() && initializer->shiftKey())
{}

KeyboardEvent::KeyboardEvent(ExecutingContext* context,
                             const AtomicString& type,
                             NativeKeyboardEvent* native_keyboard_event)
    : UIEvent(context, type, &native_keyboard_event->native_event),
// alt_key_(native_keyboard_event->altKey),
// char_code_(native_keyboard_event->charCode),
#if ANDROID_32_BIT
      code_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_keyboard_event->code)))),
      key_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_keyboard_event->key)))),
#else
      code_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_keyboard_event->code)))),
      key_(AtomicString(
          ctx(),
          std::unique_ptr<AutoFreeNativeString>(reinterpret_cast<AutoFreeNativeString*>(native_keyboard_event->key))))
#endif
// ctrl_key_(native_keyboard_event->ctrlKey),
// is_composing_(native_keyboard_event->isComposing),
// key_code_(native_keyboard_event->keyCode),
// location_(native_keyboard_event->location),
// meta_key_(native_keyboard_event->metaKey),
// repeat_(native_keyboard_event->repeat),
// shift_key_(native_keyboard_event->shiftKey)
{
}

bool KeyboardEvent::getModifierState(const AtomicString& key_args, ExceptionState& exception_state) {
  return false;
}

bool KeyboardEvent::altKey() const {
  return alt_key_;
}

double KeyboardEvent::charCode() const {
  return char_code_;
}

const AtomicString& KeyboardEvent::code() const {
  return code_;
}

bool KeyboardEvent::ctrlKey() const {
  return ctrl_key_;
}

bool KeyboardEvent::isComposing() const {
  return is_composing_;
}

const AtomicString& KeyboardEvent::key() const {
  return key_;
}

double KeyboardEvent::keyCode() const {
  return key_code_;
}

double KeyboardEvent::location() const {
  return location_;
}

bool KeyboardEvent::metaKey() const {
  return meta_key_;
}

bool KeyboardEvent::repeat() const {
  return repeat_;
}

bool KeyboardEvent::shiftKey() const {
  return shift_key_;
}

bool KeyboardEvent::IsKeyboardEvent() const {
  return true;
}

}  // namespace webf