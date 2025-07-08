/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_small_element.h"

namespace webf {

HTMLSmallElement::HTMLSmallElement(Document& document) : HTMLElement(AtomicString("small"), &document) {}

}  // namespace webf