/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "image.h"

namespace webf {

Image* Image::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<Image>(context, exception_state);
}

Image::Image(ExecutingContext* context, ExceptionState& exception_state) : HTMLImageElement(*context->document()) {}

}  // namespace webf