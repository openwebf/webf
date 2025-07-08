/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_hr_element.h"

namespace webf {

HTMLHRElement::HTMLHRElement(Document& document) : HTMLElement(AtomicString("hr"), &document) {}

}  // namespace webf