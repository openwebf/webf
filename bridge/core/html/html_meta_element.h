/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_HTML_META_ELEMENT_H_
#define WEBF_CORE_HTML_HTML_META_ELEMENT_H_

#include "core/html/html_element.h"

namespace webf {

class HTMLMetaElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLMetaElement*;
  explicit HTMLMetaElement(Document&);
  
  void AttributeChanged(const AttributeModificationParams&) override;
  Node::InsertionNotificationRequest InsertedInto(ContainerNode&) override;
  void RemovedFrom(ContainerNode&) override;

 private:
  void ProcessMetaElement();
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_HTML_META_ELEMENT_H_