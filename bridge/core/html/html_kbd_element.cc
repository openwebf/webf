/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_kbd_element.h"

namespace webf {

HTMLKbdElement::HTMLKbdElement(Document& document) : HTMLElement(AtomicString("kbd"), &document) {}

}  // namespace webf