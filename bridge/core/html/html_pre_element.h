/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_HTML_PRE_ELEMENT_H_
#define WEBF_CORE_HTML_HTML_PRE_ELEMENT_H_

#include "core/html/html_element.h"

namespace webf {

class HTMLPreElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLPreElement*;
  explicit HTMLPreElement(Document&);
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_HTML_PRE_ELEMENT_H_