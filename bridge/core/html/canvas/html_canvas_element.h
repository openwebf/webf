/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_CANVAS_HTML_CANVAS_ELEMENT_H_
#define BRIDGE_CORE_HTML_CANVAS_HTML_CANVAS_ELEMENT_H_

#include "core/html/html_element.h"

namespace webf {

class HTMLCanvasElement : public HTMLElement {
 public:
  explicit HTMLCanvasElement(Document&);
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_CANVAS_HTML_CANVAS_ELEMENT_H_
