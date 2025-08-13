/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_bold_element.h"

namespace webf {

HTMLBoldElement::HTMLBoldElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("b"), &document) {}

}  // namespace webf