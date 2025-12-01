/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_underline_element.h"

namespace webf {

HTMLUnderlineElement::HTMLUnderlineElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("u"), &document) {}

}  // namespace webf