/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_FORMS_HTML_OPTGROUP_ELEMENT_H_
#define BRIDGE_CORE_HTML_FORMS_HTML_OPTGROUP_ELEMENT_H_

#include "core/html/html_element.h"

namespace webf {

class HTMLOptgroupElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLOptgroupElement*;
  explicit HTMLOptgroupElement(Document&);

  bool disabled() const;
  void setDisabled(bool disabled, ExceptionState& exception_state);
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_FORMS_HTML_OPTGROUP_ELEMENT_H_
