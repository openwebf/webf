/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_FORMS_HTML_OPTION_ELEMENT_H_
#define BRIDGE_CORE_HTML_FORMS_HTML_OPTION_ELEMENT_H_

#include "core/html/html_element.h"

namespace webf {

class HTMLOptionElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLOptionElement*;
  explicit HTMLOptionElement(Document&);

  AtomicString value();
  void setValue(const AtomicString& value, ExceptionState& exception_state);

  bool selected();
  void setSelected(bool selected, ExceptionState& exception_state);

  bool defaultSelected();
  void setDefaultSelected(bool selected, ExceptionState& exception_state);

  bool disabled();
  void setDisabled(bool disabled, ExceptionState& exception_state);
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_FORMS_HTML_OPTION_ELEMENT_H_

