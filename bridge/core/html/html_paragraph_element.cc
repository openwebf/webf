/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_paragraph_element.h"

namespace webf {

HTMLParagraphElement::HTMLParagraphElement(Document& document) : HTMLElement(AtomicString("p"), &document) {}

}  // namespace webf