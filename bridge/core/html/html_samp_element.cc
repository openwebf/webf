/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_samp_element.h"

namespace webf {

HTMLSampElement::HTMLSampElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("samp"), &document) {}

}  // namespace webf