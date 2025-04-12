/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_EVENTS_KEYBOARD_EVENT_H_
#define BRIDGE_CORE_EVENTS_KEYBOARD_EVENT_H_

#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/source_location.h"
#include "plugin_api_gen/keyboard_event.h"
#include "qjs_keyboard_event_init.h"
#include "ui_event.h"

namespace webf {

struct NativeKeyboardEvent;

class KeyboardEvent : public UIEvent {
  DEFINE_WRAPPERTYPEINFO();

 public:
  enum KeyLocationCode {
    kDomKeyLocationStandard = 0x00,
    kDomKeyLocationLeft = 0x01,
    kDomKeyLocationRight = 0x02,
    kDomKeyLocationNumpad = 0x03
  };
  using ImplType = KeyboardEvent*;

  static double DOM_KEY_LOCATION_LEFT;
  static double DOM_KEY_LOCATION_RIGHT;
  static double DOM_KEY_LOCATION_NUMPAD;
  static double DOM_KEY_LOCATION_STANDARD;

  static KeyboardEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  static KeyboardEvent* Create(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<KeyboardEventInit>& initializer,
                               ExceptionState& exception_state);

  explicit KeyboardEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);

  explicit KeyboardEvent(ExecutingContext* context,
                         const AtomicString& type,
                         const std::shared_ptr<KeyboardEventInit>& initializer,
                         ExceptionState& exception_state);

  explicit KeyboardEvent(ExecutingContext* context,
                         const AtomicString& type,
                         NativeKeyboardEvent* native_keyboard_event);

  bool altKey() const;
  double charCode() const;
  const AtomicString& code() const;
  bool ctrlKey() const;
  bool isComposing() const;
  const AtomicString& key() const;
  double keyCode() const;
  double location() const;
  bool metaKey() const;
  bool repeat() const;
  bool shiftKey() const;

  bool getModifierState(const AtomicString& key_args, ExceptionState& exception_state);

  bool IsKeyboardEvent() const override;

  static const KeyboardEventPublicMethods* keyboardEventPublicMethods();

 private:
  bool alt_key_;
  double char_code_;
  AtomicString code_;
  bool ctrl_key_;
  bool is_composing_;
  AtomicString key_;
  double key_code_;
  double location_;
  bool meta_key_;
  bool repeat_;
  bool shift_key_;
};

template <>
struct DowncastTraits<KeyboardEvent> {
  static bool AllowFrom(const Event& event) { return event.IsKeyboardEvent(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_EVENTS_KEYBOARD_EVENT_H_
