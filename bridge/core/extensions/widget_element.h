/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_WIDGET_ELEMENT_H_
#define WEBF_CORE_DOM_WIDGET_ELEMENT_H_

#include "core/html/html_element.h"

namespace webf {

// All properties and methods from WidgetElement are defined in Dart side.
//
// There must be a corresponding Dart WidgetElement class implements the properties and methods with this element.
// The WidgetElement class in C++ is a wrapper and proxy all operations to the dart side.
class WidgetElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = WidgetElement*;
  WidgetElement(const AtomicString& tag_name, Document* document);

  bool NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state);
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&);

  ScriptValue item(const AtomicString& key, ExceptionState& exception_state);
  bool SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state);

 private:
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_WIDGET_ELEMENT_H_
