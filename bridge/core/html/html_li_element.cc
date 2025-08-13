/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_li_element.h"

namespace webf {

HTMLLIElement::HTMLLIElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("li"), &document) {}

}  // namespace webf