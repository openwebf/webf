/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_button_element.h"
#include "html_names.h"

namespace webf {

HTMLButtonElement::HTMLButtonElement(Document& document) : WidgetElement(html_names::kButton, &document) {}
}  // namespace webf