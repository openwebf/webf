/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_HTML_HTML_ELEMENT_H_
#define BRIDGE_CORE_HTML_HTML_HTML_ELEMENT_H_

#include "html_element.h"
#include "plugin_api_gen/html_html_element.h"

namespace webf {

class HTMLHtmlElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLHtmlElement*;
  explicit HTMLHtmlElement(Document&);

  const HTMLHtmlElementPublicMethods* htmlHtmlElementPublicMethods() {
    static HTMLHtmlElementPublicMethods html_html_element_public_methods;
    return &html_html_element_public_methods;
  }
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_HTML_ELEMENT_H_
