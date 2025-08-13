/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_del_element.h"

namespace webf {

HTMLDelElement::HTMLDelElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("del"), &document) {}

}  // namespace webf