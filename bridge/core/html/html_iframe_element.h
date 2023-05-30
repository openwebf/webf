/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_IFRAME_HTML_ELEMENT_H_
#define BRIDGE_CORE_HTML_IFRAME_HTML_ELEMENT_H_

#include "html_element.h"

namespace webf {

class HTMLIFrameElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLIFrameElement*;
  explicit HTMLIFrameElement(Document&);
 private:
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_IFRAME_HTML_ELEMENT_H_
