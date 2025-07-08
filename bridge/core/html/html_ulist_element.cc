/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_ulist_element.h"

namespace webf {

HTMLUListElement::HTMLUListElement(Document& document) : HTMLElement(AtomicString("ul"), &document) {}

}  // namespace webf