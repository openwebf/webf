/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef KRAKENBRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_
#define KRAKENBRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_

#include "html_element.h"

namespace kraken {

class HTMLImageElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLImageElement(Document& document);

 private:
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_
