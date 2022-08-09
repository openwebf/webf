/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef KRAKENBRIDGE_HTML_TEMPLATE_ELEMENT_H
#define KRAKENBRIDGE_HTML_TEMPLATE_ELEMENT_H

#include "html_element.h"

namespace webf {

class DocumentFragment;

class HTMLTemplateElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLTemplateElement(Document& document);

  DocumentFragment* content() const;

 private:
  DocumentFragment* ContentInternal() const;
  mutable Member<DocumentFragment> content_;
};

}  // namespace webf

#endif  // KRAKENBRIDGE_TEMPLATE_ELEMENTT_H
