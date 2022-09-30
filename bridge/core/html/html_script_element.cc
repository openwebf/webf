/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_script_element.h"
#include "html_names.h"
#include "script_type_names.h"
#include "qjs_html_script_element.h"

namespace webf {

HTMLScriptElement::HTMLScriptElement(Document& document) : HTMLElement(html_names::kscript, &document) {}

bool HTMLScriptElement::supports(const AtomicString& type, ExceptionState& exception_state) {
  // Only class module support now.
  if (type == script_type_names::kclassic) {
    return true;
  }
  return false;
}

bool HTMLScriptElement::IsAttributeDefinedInternal(const AtomicString& key) const {
  return QJSHTMLScriptElement::IsAttributeDefinedInternal(key) || HTMLElement::IsAttributeDefinedInternal(key);
}

}  // namespace webf
