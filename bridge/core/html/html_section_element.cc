/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_section_element.h"

namespace webf {

HTMLSectionElement::HTMLSectionElement(Document& document) : HTMLElement(AtomicString("section"), &document) {}

}  // namespace webf