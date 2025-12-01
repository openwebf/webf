/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_br_element.h"
#include "html_names.h"

namespace webf {

HTMLBrElement::HTMLBrElement(Document& document) : HTMLElement(html_names::kBr, &document) {}

}  // namespace webf