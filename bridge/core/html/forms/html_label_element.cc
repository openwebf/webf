/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_label_element.h"

namespace webf {

HTMLLabelElement::HTMLLabelElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("label"), &document) {}

}  // namespace webf