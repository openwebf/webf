/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_label_element.h"

namespace webf {

HTMLLabelElement::HTMLLabelElement(Document& document) : HTMLElement(AtomicString("label"), &document) {}

}  // namespace webf