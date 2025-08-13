/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_footer_element.h"

namespace webf {

HTMLFooterElement::HTMLFooterElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("footer"), &document) {}

}  // namespace webf