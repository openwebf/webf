/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_HTML_CANVAS_ELEMENT_H_
#define WEBF_CORE_RUST_API_HTML_CANVAS_ELEMENT_H_

#include "html_element.h"

namespace webf {

struct HTMLCanvasElementPublicMethods : WebFPublicMethods {
  double version{1.0};
  HTMLElementPublicMethods html_element_public_methods;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_HTML_CANVAS_ELEMENT_H_
