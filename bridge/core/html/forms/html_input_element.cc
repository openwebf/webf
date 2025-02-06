/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_input_element.h"
#include "html_names.h"
#include "qjs_html_input_element.h"

namespace webf {

HTMLInputElement::HTMLInputElement(Document& document) : WidgetElement(html_names::kInput, &document) {}

}  // namespace webf
