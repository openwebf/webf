/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_noscript_element.h"

namespace webf {

HTMLNoScriptElement::HTMLNoScriptElement(Document& document) : HTMLElement(AtomicString("noscript"), &document) {}

}  // namespace webf