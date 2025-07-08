/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_data_element.h"

namespace webf {

HTMLDataElement::HTMLDataElement(Document& document) : HTMLElement(AtomicString("data"), &document) {}

}  // namespace webf