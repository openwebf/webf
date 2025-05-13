/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#ifndef WEBF_CORE_HTML_TOUCHES_WEBF_TOUCH_AREA_ELEMENT_H_
#define WEBF_CORE_HTML_TOUCHES_WEBF_TOUCH_AREA_ELEMENT_H_

#include "core/html/html_element.h"

namespace webf {

class WebFTouchAreaElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = WebFTouchAreaElement*;
  explicit WebFTouchAreaElement(Document&);

  bool IsWebFTouchAreaElement() const override;
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_TOUCHES_WEBF_TOUCH_AREA_ELEMENT_H_
