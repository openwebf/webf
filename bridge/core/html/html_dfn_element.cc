/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_dfn_element.h"

namespace webf {

HTMLDfnElement::HTMLDfnElement(Document& document) : HTMLElement(AtomicString("dfn"), &document) {}

}  // namespace webf