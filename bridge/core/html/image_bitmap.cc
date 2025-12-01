/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
 */

#include "image_bitmap.h"

#include "core/executing_context.h"
#include "core/html/html_image_element.h"

namespace webf {

ImageBitmap::ImageBitmap(ExecutingContext* context,
                         HTMLImageElement* source,
                         double sx,
                         double sy,
                         double sw,
                         double sh,
                         double width,
                         double height)
    : ScriptWrappable(context->ctx()),
      image_(source),
      sx_(sx),
      sy_(sy),
      sw_(sw),
      sh_(sh),
      width_(width),
      height_(height) {}

ImageBitmap* ImageBitmap::Create(ExecutingContext* context,
                                 HTMLImageElement* source,
                                 double sx,
                                 double sy,
                                 double sw,
                                 double sh,
                                 double width,
                                 double height,
                                 ExceptionState& exception_state) {
  if (source == nullptr) {
    exception_state.ThrowException(context->ctx(), ErrorType::TypeError,
                                   "createImageBitmap: source image is null.");
    return nullptr;
  }
  return MakeGarbageCollected<ImageBitmap>(context, source, sx, sy, sw, sh, width, height);
}

void ImageBitmap::close(ExceptionState& exception_state) {
  if (closed_) {
    return;
  }
  closed_ = true;
  image_.Clear();
}

void ImageBitmap::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(image_);
  ScriptWrappable::Trace(visitor);
}

}  // namespace webf
