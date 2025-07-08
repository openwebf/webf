/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_nav_element.h"

namespace webf {

HTMLNavElement::HTMLNavElement(Document& document) : HTMLElement(AtomicString("nav"), &document) {}

}  // namespace webf