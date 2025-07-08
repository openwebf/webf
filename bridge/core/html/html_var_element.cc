/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_var_element.h"

namespace webf {

HTMLVarElement::HTMLVarElement(Document& document) : HTMLElement(AtomicString("var"), &document) {}

}  // namespace webf