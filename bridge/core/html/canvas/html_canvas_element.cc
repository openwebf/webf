/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_canvas_element.h"
#include "html_names.h"

namespace webf {

HTMLCanvasElement::HTMLCanvasElement(Document& document) : HTMLElement(html_names::kcanvas, &document) {}
}  // namespace webf
