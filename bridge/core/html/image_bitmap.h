/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_IMAGE_BITMAP_H_
#define BRIDGE_CORE_HTML_IMAGE_BITMAP_H_

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/cppgc/member.h"

namespace webf {

class ExecutingContext;
class HTMLImageElement;

class ImageBitmap : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = ImageBitmap*;

  ImageBitmap() = delete;
  ImageBitmap(ExecutingContext* context,
              HTMLImageElement* source,
              double sx,
              double sy,
              double sw,
              double sh,
              double width,
              double height);

  static ImageBitmap* Create(ExecutingContext* context,
                             HTMLImageElement* source,
                             double sx,
                             double sy,
                             double sw,
                             double sh,
                             double width,
                             double height,
                             ExceptionState& exception_state);

  double width() const { return width_; }
  double height() const { return height_; }

  double sx() const { return sx_; }
  double sy() const { return sy_; }
  double sw() const { return sw_; }
  double sh() const { return sh_; }

  void close(ExceptionState& exception_state);

  HTMLImageElement* sourceImageElement() const { return image_.Get(); }

  void Trace(GCVisitor* visitor) const override;

 private:
  Member<HTMLImageElement> image_;
  double sx_ = 0.0;
  double sy_ = 0.0;
  double sw_ = 0.0;
  double sh_ = 0.0;
  double width_ = 0.0;
  double height_ = 0.0;
  bool closed_ = false;
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_IMAGE_BITMAP_H_
