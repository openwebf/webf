/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_WIDGET_ELEMENT_H_
#define WEBF_CORE_DOM_WIDGET_ELEMENT_H_

#include <set>
#include <unordered_map>
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

  static bool IsValidName(const AtomicString& name);

  ScriptValue getPropertyValue(const AtomicString& name, ExceptionState& exception_state);
  ScriptPromise getPropertyValueAsync(const AtomicString& name, ExceptionState& exception_state);

  void setPropertyValue(const AtomicString& name, const ScriptValue& value, ExceptionState& exception_state);
  void setPropertyValueAsync(const AtomicString& name, const ScriptValue& value, ExceptionState& exception_state);

  ScriptValue callMethod(const AtomicString& name, std::vector<ScriptValue>& args, ExceptionState& exception_state);
  ScriptPromise callAsyncMethod(const AtomicString& name, std::vector<ScriptValue>& args, ExceptionState& exception_state);

//  bool SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state);
  bool IsWidgetElement() const override;

  void Trace(GCVisitor* visitor) const override;

 private:
};

template <>
struct DowncastTraits<WidgetElement> {
  static bool AllowFrom(const Element& element) { return element.IsWidgetElement(); }
  static bool AllowFrom(const BindingObject& binding_object) {
    return binding_object.IsEventTarget() && To<EventTarget>(binding_object).IsNode() &&
           To<Node>(binding_object).IsElementNode() && To<Element>(binding_object).IsWidgetElement();
  }
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_WIDGET_ELEMENT_H_
