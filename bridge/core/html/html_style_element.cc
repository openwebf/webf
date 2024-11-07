
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_style_element.h"
#include "html_names.h"
#include "core/dom/node.h"
#include "core/css/style_element.h"
#include "defined_properties.h"

namespace webf {

HTMLStyleElement::HTMLStyleElement(Document& document):
      HTMLElement(html_names::kstyle, &document),
      StyleElement(&document, false) {}

HTMLStyleElement::~HTMLStyleElement() = default;

NativeValue HTMLStyleElement::HandleCallFromDartSide(const webf::AtomicString& method, int32_t argc, const webf::NativeValue* argv, Dart_Handle dart_object) {

  return Native_NewNull();
}

void HTMLStyleElement::ParseAttribute(const webf::Element::AttributeModificationParams& params) {
  HTMLElement::ParseAttribute(params);
}

Node::InsertionNotificationRequest HTMLStyleElement::InsertedInto(webf::ContainerNode& insertion_point) {
  HTMLElement::InsertedInto(insertion_point);
  if (isConnected()) {
    StyleElement::ProcessStyleSheet(GetDocument(), *this);
  }
  return kInsertionDone;
}

void HTMLStyleElement::RemovedFrom(webf::ContainerNode& insertion_point) {
  HTMLElement::RemovedFrom(insertion_point);
  StyleElement::RemovedFrom(*this, insertion_point);
}

void HTMLStyleElement::ChildrenChanged(const webf::ContainerNode::ChildrenChange& change) {
  HTMLElement::ChildrenChanged(change);
  StyleElement::ChildrenChanged(*this);
}

void HTMLStyleElement::FinishParsingChildren() {
  StyleElement::ProcessingResult result =
      StyleElement::FinishParsingChildren(*this);
  HTMLElement::FinishParsingChildren();
}

NativeValue HTMLStyleElement::HandleParseAuthorStyleSheet(int32_t argc, const webf::NativeValue* argv, Dart_Handle dart_object) {

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
