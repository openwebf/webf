/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef KRAKENBRIDGE_HTML_ANCHOR_ELEMENT_H
#define KRAKENBRIDGE_HTML_ANCHOR_ELEMENT_H

#include "html_element.h"

namespace webf {

class HTMLAnchorElement : public HTMLElement {
 public:
  explicit HTMLAnchorElement(Document&);
};

}  // namespace webf

#endif  // KRAKENBRIDGE_HTML_ANCHOR_ELEMENT_H
