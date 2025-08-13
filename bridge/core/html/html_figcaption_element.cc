/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_figcaption_element.h"

namespace webf {

HTMLFigCaptionElement::HTMLFigCaptionElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("figcaption"), &document) {}

}  // namespace webf