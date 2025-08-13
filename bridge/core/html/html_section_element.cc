/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_section_element.h"

namespace webf {

HTMLSectionElement::HTMLSectionElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("section"), &document) {}

}  // namespace webf