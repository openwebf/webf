/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_HTML_SCRIPT_ELEMENT_H_
#define BRIDGE_CORE_HTML_HTML_SCRIPT_ELEMENT_H_

#include "html_element.h"
#include "html_names.h"

namespace webf {

class HTMLScriptElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static bool supports(const AtomicString& type, ExceptionState& exception_state);

  explicit HTMLScriptElement(Document& document);
};

template <>
struct DowncastTraits<HTMLScriptElement> {
  static bool AllowFrom(const BindingObject& binding_object) {
    return binding_object.IsEventTarget() && To<EventTarget>(binding_object).IsNode() &&
           To<Node>(binding_object).IsHTMLElement() && To<HTMLElement>(binding_object).tagName() == html_names::kScript;
  }
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_SCRIPT_ELEMENT_H_
