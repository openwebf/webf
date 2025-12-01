/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_FORMS_HTML_TEXTAREA_ELEMENT_H_
#define BRIDGE_CORE_HTML_FORMS_HTML_TEXTAREA_ELEMENT_H_

#include "core/html/custom/widget_element.h"

namespace webf {

class HTMLTextareaElement : public WidgetElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLTextareaElement(Document&);
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_FORMS_HTML_TEXTAREA_ELEMENT_H_
