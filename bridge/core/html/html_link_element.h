/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_HTML_LINK_ELEMENT_H_
#define WEBF_CORE_HTML_HTML_LINK_ELEMENT_H_

#include "html_element.h"

namespace webf {

class HTMLLinkElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLLinkElement(Document& document);
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_HTML_LINK_ELEMENT_H_
