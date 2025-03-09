/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_anchor_element.h"
#include "html_names.h"
#include "qjs_html_anchor_element.h"

namespace webf {

HTMLAnchorElement::HTMLAnchorElement(Document& document) : HTMLElement(html_names::kA, &document) {}

}  // namespace webf
