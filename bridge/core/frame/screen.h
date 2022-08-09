/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#ifndef KRAKENBRIDGE_SCREEN_H
#define KRAKENBRIDGE_SCREEN_H

#include "core/dom/events/event_target.h"

namespace kraken {

class Window;

struct NativeScreen {};

class Screen : public EventTargetWithInlineData {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = Screen*;
  explicit Screen(Window* window, NativeBindingObject* binding_object);

 private:
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_SCREEN_H
