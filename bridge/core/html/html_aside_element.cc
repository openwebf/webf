/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_aside_element.h"

namespace webf {

HTMLAsideElement::HTMLAsideElement(Document& document) : HTMLElement(AtomicString("aside"), &document) {}

}  // namespace webf