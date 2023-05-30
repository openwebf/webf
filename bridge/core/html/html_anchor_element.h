/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_HTML_ANCHOR_ELEMENT_H
#define BRIDGE_HTML_ANCHOR_ELEMENT_H

#include "html_element.h"

namespace webf {

class HTMLAnchorElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLAnchorElement(Document& document);
 private:
};

}  // namespace webf

#endif  // BRIDGE_HTML_ANCHOR_ELEMENT_H
