/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_style_element.h"
#include "core/css/style_element.h"
#include "core/css/style_engine.h"
#include "core/dom/node.h"
#include "core/dom/document.h"
#include "defined_properties.h"
#include "html_names.h"
#include "foundation/logging.h"

namespace webf {

HTMLStyleElement::HTMLStyleElement(Document& document)
    : HTMLElement(html_names::kStyle, &document), StyleElement(&document, false) {}

HTMLStyleElement::~HTMLStyleElement() = default;

NativeValue HTMLStyleElement::HandleCallFromDartSide(const webf::AtomicString& method,
                                                     int32_t argc,
                                                     const webf::NativeValue* argv,
                                                     Dart_Handle dart_object) {
  return Native_NewNull();
}

void HTMLStyleElement::ParseAttribute(const webf::Element::AttributeModificationParams& params) {
  HTMLElement::ParseAttribute(params);
  if (GetExecutingContext()->isBlinkEnabled()) {
    // Changes like media/type/disabled can affect matching; mark active
    // stylesheets dirty and schedule incremental style recomputation.
    WEBF_LOG(VERBOSE) << "[StyleEngine] UpdateActiveStyleSheets from HTMLStyleElement::ParseAttribute name="
                      << params.name.ToUTF8String();
    GetDocument().EnsureStyleEngine().UpdateActiveStyleSheets();
  }
}

Node::InsertionNotificationRequest HTMLStyleElement::InsertedInto(webf::ContainerNode& insertion_point) {
  HTMLElement::InsertedInto(insertion_point);
  if (isConnected() && GetExecutingContext()->isBlinkEnabled()) {
    StyleElement::ProcessStyleSheet(GetDocument(), *this);
  }
  return kInsertionDone;
}

void HTMLStyleElement::RemovedFrom(webf::ContainerNode& insertion_point) {
  HTMLElement::RemovedFrom(insertion_point);
  if (GetExecutingContext()->isBlinkEnabled()) {
    StyleElement::RemovedFrom(*this, insertion_point);
    // Stylesheet removed; mark active stylesheets dirty and schedule
    // incremental recomputation rather than an immediate full recalc.
    WEBF_LOG(VERBOSE) << "[StyleEngine] UpdateActiveStyleSheets from HTMLStyleElement::RemovedFrom";
    GetDocument().EnsureStyleEngine().UpdateActiveStyleSheets();
  }
}

void HTMLStyleElement::ChildrenChanged(const webf::ContainerNode::ChildrenChange& change) {
  HTMLElement::ChildrenChanged(change);
  if (GetExecutingContext()->isBlinkEnabled()) {
    StyleElement::ChildrenChanged(*this);
    // Style text changed; mark active stylesheets dirty and schedule
    // incremental recomputation.
    WEBF_LOG(VERBOSE) << "[StyleEngine] UpdateActiveStyleSheets from HTMLStyleElement::ChildrenChanged";
    GetDocument().EnsureStyleEngine().UpdateActiveStyleSheets();
  }
}

void HTMLStyleElement::FinishParsingChildren() {
  if (GetExecutingContext()->isBlinkEnabled()) {
    StyleElement::ProcessingResult result = StyleElement::FinishParsingChildren(*this);
    HTMLElement::FinishParsingChildren();
    // After finishing parsing, mark active stylesheets dirty and schedule
    // incremental recomputation.
    WEBF_LOG(VERBOSE) << "[StyleEngine] UpdateActiveStyleSheets from HTMLStyleElement::FinishParsingChildren";
    GetDocument().EnsureStyleEngine().UpdateActiveStyleSheets();
  }
}

NativeValue HTMLStyleElement::HandleParseAuthorStyleSheet(int32_t argc,
                                                          const webf::NativeValue* argv,
                                                          Dart_Handle dart_object) {
  return Native_NewNull();
}

AtomicString HTMLStyleElement::type() const {
  return g_empty_atom;
}

void HTMLStyleElement::Trace(webf::GCVisitor* visitor) const {
  HTMLElement::Trace(visitor);
  StyleElement::Trace(visitor);
}

}  // namespace webf
