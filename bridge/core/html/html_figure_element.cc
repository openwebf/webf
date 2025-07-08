/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_figure_element.h"

namespace webf {

HTMLFigureElement::HTMLFigureElement(Document& document) : HTMLElement(AtomicString("figure"), &document) {}

}  // namespace webf