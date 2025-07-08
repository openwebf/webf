/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_CUSTOM_HTML_ELEMENT_FACTORY_H_
#define WEBF_CORE_HTML_CUSTOM_HTML_ELEMENT_FACTORY_H_

#include "core/dom/element.h"
#include "foundation/atomic_string.h"

namespace webf {

class Document;
class HTMLElement;

// Factory for HTML elements that need special handling (e.g., shared implementations)
class CustomHTMLElementFactory {
 public:
  static HTMLElement* CreateCustomElement(const AtomicString& tag_name, Document& document);
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_CUSTOM_HTML_ELEMENT_FACTORY_H_