/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "screen.h"
#include "core/frame/window.h"
#include "foundation/native_value_converter.h"

namespace kraken {

Screen::Screen(Window* window, NativeBindingObject* native_binding_object)
    : EventTargetWithInlineData(window->GetExecutingContext()) {
  BindDartObject(native_binding_object);
}

}  // namespace kraken
