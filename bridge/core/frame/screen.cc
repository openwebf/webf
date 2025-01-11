/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "screen.h"
#include "core/frame/window.h"
#include "foundation/native_value_converter.h"

namespace webf {

Screen::Screen(ExecutingContext* context, NativeBindingObject* native_binding_object)
    : EventTargetWithInlineData(context, native_binding_object),
      extra_(static_cast<ScreenData*>(native_binding_object->extra)) {}

}  // namespace webf
