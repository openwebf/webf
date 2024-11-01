/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_HTML_LINK_ELEMENT_H_
#define WEBF_CORE_HTML_HTML_LINK_ELEMENT_H_

#include "html_element.h"

namespace webf {

class HTMLLinkElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLLinkElement(Document& document);
  NativeValue HandleCallFromDartSide(const webf::AtomicString &method, int32_t argc, const webf::NativeValue *argv, Dart_Handle dart_object) override;

  NativeValue parseAuthorStyleSheet(AtomicString& cssString, AtomicString& href);

 protected:
  NativeValue HandleParseAuthorStyleSheet(int32_t argc, const NativeValue* argv, Dart_Handle dart_object);
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_HTML_LINK_ELEMENT_H_
