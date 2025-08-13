/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_time_element.h"

namespace webf {

HTMLTimeElement::HTMLTimeElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("time"), &document) {}

}  // namespace webf