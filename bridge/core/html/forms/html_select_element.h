/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_FORMS_HTML_SELECT_ELEMENT_H_
#define BRIDGE_CORE_HTML_FORMS_HTML_SELECT_ELEMENT_H_

#include "core/html/html_element.h"

namespace webf {

class HTMLSelectElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLSelectElement*;
  explicit HTMLSelectElement(Document&);

  HTMLCollection* options() const;
  AtomicString value() const;
  void setValue(const AtomicString& value, ExceptionState& exception_state);

  double selectedIndex() const;
  void setSelectedIndex(double index, ExceptionState& exception_state);

  bool multiple();
  void setMultiple(bool multiple, ExceptionState& exception_state);
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_FORMS_HTML_SELECT_ELEMENT_H_

