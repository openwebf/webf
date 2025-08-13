/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_strikethrough_element.h"

namespace webf {

HTMLStrikethroughElement::HTMLStrikethroughElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("s"), &document) {}

}  // namespace webf