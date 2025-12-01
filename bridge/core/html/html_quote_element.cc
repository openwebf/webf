/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_quote_element.h"
#include "html_names.h"

namespace webf {

HTMLQuoteElement::HTMLQuoteElement(const AtomicString& local_name, Document& document) 
    : HTMLElement(local_name, &document) {}

}  // namespace webf