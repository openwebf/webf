/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "custom_html_element_factory.h"
#include "html_names.h"
#include "html_heading_element.h"
#include "html_quote_element.h"
#include "bindings/qjs/cppgc/garbage_collected.h"

namespace webf {

HTMLElement* CustomHTMLElementFactory::CreateCustomElement(const AtomicString& tag_name, Document& document) {
  // Heading elements (h1-h6)
  if (tag_name == AtomicString::CreateFromUTF8("h1") || tag_name == AtomicString::CreateFromUTF8("h2") || 
      tag_name == AtomicString::CreateFromUTF8("h3") || tag_name == AtomicString::CreateFromUTF8("h4") ||
      tag_name == AtomicString::CreateFromUTF8("h5") || tag_name == AtomicString::CreateFromUTF8("h6")) {
    return MakeGarbageCollected<HTMLHeadingElement>(tag_name, document);
  }
  
  // Quote elements (blockquote, q)
  if (tag_name == AtomicString::CreateFromUTF8("blockquote") || tag_name == AtomicString::CreateFromUTF8("q")) {
    return MakeGarbageCollected<HTMLQuoteElement>(tag_name, document);
  }
  
  return nullptr;
}

}  // namespace webf