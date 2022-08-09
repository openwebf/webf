/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#ifndef KRAKENBRIDGE_CORE_HTML_HTML_HTML_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_HTML_ELEMENT_H_

#include "html_element.h"

namespace kraken {

class HTMLHtmlElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLHtmlElement*;
  explicit HTMLHtmlElement(Document&);

 private:
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_HTML_ELEMENT_H_
