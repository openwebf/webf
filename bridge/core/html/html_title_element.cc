/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_title_element.h"

namespace webf {

HTMLTitleElement::HTMLTitleElement(Document& document) : HTMLElement(AtomicString("title"), &document) {}

}  // namespace webf