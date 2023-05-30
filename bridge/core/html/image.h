/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_IMAGE_H_
#define WEBF_CORE_HTML_IMAGE_H_

#include "html_image_element.h"

namespace webf {

class Image : public HTMLImageElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static Image* Create(ExecutingContext* context, ExceptionState& exception_state);

  explicit Image(ExecutingContext* context, ExceptionState& exception_state);
 private:
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_IMAGE_H_
