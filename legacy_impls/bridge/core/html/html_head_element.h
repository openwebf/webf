/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_HTML_HEAD_ELEMENT_H_
#define BRIDGE_CORE_HTML_HTML_HEAD_ELEMENT_H_

#include "html_element.h"
#include "plugin_api_gen/html_head_element.h"

namespace webf {

class HTMLHeadElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLHeadElement*;
  explicit HTMLHeadElement(Document&);

  const HTMLHeadElementPublicMethods* htmlHeadElementPublicMethods() {
    static HTMLHeadElementPublicMethods html_head_element_public_methods;
    return &html_head_element_public_methods;
  }
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_HEAD_ELEMENT_H_
