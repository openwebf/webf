/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "keyboard_event.h"

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
      alt_key_(initializer->altKey()),
      char_code_(initializer->charCode()),
      code_(initializer->code()),
      ctrl_key_(initializer->ctrlKey()),
      is_composing_(initializer->isComposing()),
      key_(initializer->key()),
      key_code_(initializer->keyCode()),
      location_(initializer->location()),
      meta_key_(initializer->metaKey()),
      repeat_(initializer->repeat()),
      shift_key_(initializer->shiftKey()) {}

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