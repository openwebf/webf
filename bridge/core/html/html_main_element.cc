/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_main_element.h"

namespace webf {

HTMLMainElement::HTMLMainElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("main"), &document) {}

}  // namespace webf