/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_mark_element.h"

namespace webf {

HTMLMarkElement::HTMLMarkElement(Document& document) : HTMLElement(AtomicString("mark"), &document) {}

}  // namespace webf