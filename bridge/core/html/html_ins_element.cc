/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_ins_element.h"

namespace webf {

HTMLInsElement::HTMLInsElement(Document& document) : HTMLElement(AtomicString("ins"), &document) {}

}  // namespace webf