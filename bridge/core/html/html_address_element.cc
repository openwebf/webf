/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_address_element.h"

namespace webf {

HTMLAddressElement::HTMLAddressElement(Document& document) : HTMLElement(AtomicString("address"), &document) {}

}  // namespace webf