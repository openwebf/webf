/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_data_element.h"

namespace webf {

HTMLDataElement::HTMLDataElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("data"), &document) {}

}  // namespace webf