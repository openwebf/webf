/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_dd_element.h"

namespace webf {

HTMLDDElement::HTMLDDElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("dd"), &document) {}

}  // namespace webf