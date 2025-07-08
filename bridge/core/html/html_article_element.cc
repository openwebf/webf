/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_article_element.h"
#include "html_names.h"

namespace webf {

HTMLArticleElement::HTMLArticleElement(Document& document) : HTMLElement(AtomicString("article"), &document) {}

}  // namespace webf