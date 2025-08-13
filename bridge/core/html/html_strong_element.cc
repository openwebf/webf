/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_strong_element.h"

namespace webf {

HTMLStrongElement::HTMLStrongElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("strong"), &document) {}

}  // namespace webf