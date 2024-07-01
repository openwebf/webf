//
// Created by 谢作兵 on 05/06/24.
//

#include "html_style_element.h"
#include "html_names.h"
#include "core/css/style_element.h"

namespace webf {

HTMLStyleElement::HTMLStyleElement(Document& document):
      HTMLElement(html_names::kstyle, &document),
      // TODO(xiezuobing): 先静态设置成false吧
      StyleElement(&document, false) {}

HTMLStyleElement::~HTMLStyleElement() = default;

NativeValue HTMLStyleElement::HandleCallFromDartSide(const webf::AtomicString& method, int32_t argc, const webf::NativeValue* argv, Dart_Handle dart_object) {

  return Native_NewNull();
}

NativeValue HTMLStyleElement::createStyleSheet(webf::AtomicString& cssString, webf::AtomicString& href) {

  return Native_NewNull();
}

NativeValue HTMLStyleElement::HandleParseAuthorStyleSheet(int32_t argc, const webf::NativeValue* argv, Dart_Handle dart_object) {

  return Native_NewNull();
}

void HTMLStyleElement::FinishParsingChildren() {
  StyleElement::ProcessingResult result =
      StyleElement::FinishParsingChildren(*this);
  HTMLElement::FinishParsingChildren();
  if (result == StyleElement::kProcessingFatalError) {
    // TODO(xiezuobing):
  }
}

const AtomicString& HTMLStyleElement::media() const {
  // TODO(xiezuobing): 取值啊
  return AtomicString();
}

const AtomicString& HTMLStyleElement::type() const {
  // TODO(xiezuobing): 取值啊
  return AtomicString();
}

}  // namespace webf