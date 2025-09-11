/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_link_element.h"
#include "binding_call_methods.h"
#include "html_names.h"
#include "core/dom/document.h"
#include "core/css/style_engine.h"
#include "qjs_html_link_element.h"

namespace webf {

HTMLLinkElement::HTMLLinkElement(Document& document) : HTMLElement(html_names::kLink, &document) {}

NativeValue HTMLLinkElement::HandleCallFromDartSide(const webf::AtomicString& method,
                                                    int32_t argc,
                                                    const webf::NativeValue* argv,
                                                    Dart_Handle dart_object) {
  if (!isContextValid(contextId()))
    return Native_NewNull();
  MemberMutationScope mutation_scope{GetExecutingContext()};

  if (method == binding_call_methods::kparseAuthorStyleSheet) {
    return HandleParseAuthorStyleSheet(argc, argv, dart_object);
  }

  HTMLElement::HandleCallFromDartSide(method, argc, argv, dart_object);

  return Native_NewNull();
};

NativeValue HTMLLinkElement::HandleParseAuthorStyleSheet(int32_t argc,
                                                         const NativeValue* argv,
                                                         Dart_Handle dart_object) {
  //  AtomicString& cssString();
  //  AtomicString& href();
  //  NativeValue result = parseAuthorStyleSheet(cssString(), href());

  return Native_NewNull();
};

NativeValue HTMLLinkElement::parseAuthorStyleSheet(AtomicString& cssString, AtomicString& href) {
  // 走 styleEngine.parseAuthorStyleSheet;

  return Native_NewNull();
};

DOMTokenList* HTMLLinkElement::relList() {
  if (!rel_list_) {
    rel_list_ = MakeGarbageCollected<DOMTokenList>(this, html_names::kRelAttr);
    // Initialize token set from current attribute value
    AtomicString relValue = getAttribute(html_names::kRelAttr, ASSERT_NO_EXCEPTION());
    rel_list_->DidUpdateAttributeValue(g_null_atom, relValue);
  }
  return rel_list_.Get();
}

void HTMLLinkElement::Trace(webf::GCVisitor* visitor) const {
  visitor->TraceMember(rel_list_);
  HTMLElement::Trace(visitor);
}

void HTMLLinkElement::ParseAttribute(const webf::Element::AttributeModificationParams& params) {
  HTMLElement::ParseAttribute(params);
  if (!GetExecutingContext()->isBlinkEnabled()) {
    return;
  }
  // If rel/href/type/disabled attributes change, trigger style recalc.
  if (params.name == html_names::kRelAttr || params.name == html_names::kHrefAttr || params.name == html_names::kTypeAttr ||
      params.name == html_names::kDisabledAttr) {
    GetDocument().EnsureStyleEngine().RecalcStyle(GetDocument());
  }
}

Node::InsertionNotificationRequest HTMLLinkElement::InsertedInto(webf::ContainerNode& insertion_point) {
  HTMLElement::InsertedInto(insertion_point);
  if (isConnected() && GetExecutingContext()->isBlinkEnabled()) {
    GetDocument().EnsureStyleEngine().RecalcStyle(GetDocument());
  }
  return kInsertionDone;
}

void HTMLLinkElement::RemovedFrom(webf::ContainerNode& insertion_point) {
  HTMLElement::RemovedFrom(insertion_point);
  if (GetExecutingContext()->isBlinkEnabled()) {
    GetDocument().EnsureStyleEngine().RecalcStyle(GetDocument());
  }
}

}  // namespace webf
