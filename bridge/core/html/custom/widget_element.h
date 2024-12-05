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

  bool NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state);
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&);

  ScriptValue item(const AtomicString& key, ExceptionState& exception_state);
  bool SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state);
  bool DeleteItem(const AtomicString& key, ExceptionState& exception_state);

  bool IsWidgetElement() const override;

  void Trace(GCVisitor* visitor) const override;
 private:
  ScriptValue CreateSyncMethodFunc(const AtomicString& method_name);
  ScriptValue CreateAsyncMethodFunc(const AtomicString& method_name);
  const WidgetElementShape* SaveWidgetElementsShapeData(const NativeValue* argv);
  std::unordered_map<AtomicString, ScriptValue, AtomicString::KeyHasher> cached_methods_;
  std::unordered_map<AtomicString, ScriptValue, AtomicString::KeyHasher> async_cached_methods_;
  std::unordered_map<AtomicString, ScriptValue, AtomicString::KeyHasher> unimplemented_properties_;
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
