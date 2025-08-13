/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_pre_element.h"

namespace webf {

HTMLPreElement::HTMLPreElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("pre"), &document) {}

}  // namespace webf