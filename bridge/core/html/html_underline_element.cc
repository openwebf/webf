/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_underline_element.h"

namespace webf {

HTMLUnderlineElement::HTMLUnderlineElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("u"), &document) {}

}  // namespace webf