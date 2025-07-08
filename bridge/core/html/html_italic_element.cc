/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_italic_element.h"

namespace webf {

HTMLItalicElement::HTMLItalicElement(Document& document) : HTMLElement(AtomicString("i"), &document) {}

}  // namespace webf