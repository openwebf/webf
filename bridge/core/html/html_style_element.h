
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_HTML_STYLE_ELEMENT_H
#define WEBF_HTML_STYLE_ELEMENT_H

#include "html_element.h"
#include "core/css/style_element.h"

namespace webf {

class HTMLStyleElement: public HTMLElement, private StyleElement {

 public:
  explicit HTMLStyleElement(Document& document);
  ~HTMLStyleElement() override;
  void FinishParsingChildren() override;

  NativeValue HandleCallFromDartSide(const webf::AtomicString &method, int32_t argc, const webf::NativeValue *argv, Dart_Handle dart_object) override;

  NativeValue createStyleSheet(AtomicString& cssString, AtomicString& href);

  const AtomicString& media() const override;
  const AtomicString& type() const override;
  bool IsSameObject(const Node& node) const override { return this == &node; }

 protected:
  NativeValue HandleParseAuthorStyleSheet(int32_t argc, const NativeValue* argv, Dart_Handle dart_object);
};

}  // namespace webf

#endif  // WEBF_HTML_STYLE_ELEMENT_H
