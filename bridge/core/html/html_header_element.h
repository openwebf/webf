/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_HTML_HEADER_ELEMENT_H_
#define WEBF_CORE_HTML_HTML_HEADER_ELEMENT_H_

#include "core/html/html_element.h"

namespace webf {

class HTMLHeaderElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLHeaderElement*;
  explicit HTMLHeaderElement(Document&);
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_HTML_HEADER_ELEMENT_H_