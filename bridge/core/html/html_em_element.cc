/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_em_element.h"

namespace webf {

HTMLEmElement::HTMLEmElement(Document& document) : HTMLElement(AtomicString("em"), &document) {}

}  // namespace webf