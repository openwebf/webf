/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_template_element.h"
#include "core/dom/document_fragment.h"
#include "html_names.h"
#include "qjs_html_template_element.h"

namespace webf {

HTMLTemplateElement::HTMLTemplateElement(Document& document) : HTMLElement(html_names::ktemplate, &document) {}

DocumentFragment* HTMLTemplateElement::content() const {
  return ContentInternal();
}

DocumentFragment* HTMLTemplateElement::ContentInternal() const {
  if (!content_ && GetExecutingContext())
    content_ = DocumentFragment::Create(GetDocument());

  return content_.Get();
}

void HTMLTemplateElement::Trace(webf::GCVisitor* visitor) const {
  visitor->Trace(content_);
}

}  // namespace webf
