/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_address_element.h"

namespace webf {

HTMLAddressElement::HTMLAddressElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("address"), &document) {}

}  // namespace webf