/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_HTML_LINK_ELEMENT_H_
#define WEBF_CORE_HTML_HTML_LINK_ELEMENT_H_

#include "html_element.h"
#include "core/css/css_style_sheet.h"
#include "core/dom/dom_token_list.h"
#include "html_element_type_helper.h"

namespace webf {

class HTMLLinkElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
 explicit HTMLLinkElement(Document& document);
  void Trace(GCVisitor* visitor) const override {
    HTMLElement::Trace(visitor);
    visitor->TraceMember(sheet_);
  }
  CSSStyleSheet* sheet() const { return sheet_.Get(); }
  NativeValue HandleCallFromDartSide(const webf::AtomicString& method,
                                     int32_t argc,
                                     const webf::NativeValue* argv,
                                     Dart_Handle dart_object) override;

  NativeValue parseAuthorStyleSheet(AtomicString& cssString, AtomicString& href);

  // https://html.spec.whatwg.org/multipage/semantics.html#htmllinkelement
  // Expose tokenized view of the `rel` attribute.
  DOMTokenList* relList();

  void Trace(webf::GCVisitor* visitor) const override;

 protected:
  NativeValue HandleParseAuthorStyleSheet(int32_t argc, const NativeValue* argv, Dart_Handle dart_object);

  // Override lifecycle hooks to trigger style recalc when link elements
  // enter/leave the document or when relevant attributes change.
  void ParseAttribute(const webf::Element::AttributeModificationParams& params) override;
  Node::InsertionNotificationRequest InsertedInto(webf::ContainerNode& insertion_point) override;
  void RemovedFrom(webf::ContainerNode& insertion_point) override;

 private:
  // Keep the created stylesheet alive and associated with this element.
  Member<CSSStyleSheet> sheet_;
  mutable Member<DOMTokenList> rel_list_;
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_HTML_LINK_ELEMENT_H_
