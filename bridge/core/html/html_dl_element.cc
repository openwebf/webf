/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_dl_element.h"

namespace webf {

HTMLDLElement::HTMLDLElement(Document& document) : HTMLElement(AtomicString("dl"), &document) {}

}  // namespace webf