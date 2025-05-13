/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#include "webf_touch_area_element.h"
#include "webf_element_names.h"

namespace webf {

WebFTouchAreaElement::WebFTouchAreaElement(webf::Document& document)
    : HTMLElement(webf_element_names::kWebfToucharea, &document) {}

bool WebFTouchAreaElement::IsWebFTouchAreaElement() const {
  return true;
}

}  // namespace webf