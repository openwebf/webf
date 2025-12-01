/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_footer_element.h"

namespace webf {

HTMLFooterElement::HTMLFooterElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("footer"), &document) {}

}  // namespace webf