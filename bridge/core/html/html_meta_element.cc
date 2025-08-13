/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_meta_element.h"

namespace webf {

HTMLMetaElement::HTMLMetaElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("meta"), &document) {}

}  // namespace webf