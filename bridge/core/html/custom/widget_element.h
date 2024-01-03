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

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;

  ScriptValue item(const AtomicString& key, ExceptionState& exception_state);
  bool SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state);
  bool DeleteItem(const AtomicString& key, ExceptionState& exception_state);

  bool IsWidgetElement() const override;

  void CloneNonAttributePropertiesFrom(const Element&, CloneChildrenFlag) override;

  void Trace(GCVisitor* visitor) const override;

 private:
  ScriptValue CreateSyncMethodFunc(const AtomicString& method_name);
  ScriptValue CreateAsyncMethodFunc(const AtomicString& method_name);
  NativeValue HandleSyncPropertiesAndMethodsFromDart(int32_t argc, const NativeValue* argv);
  std::unordered_map<AtomicString, ScriptValue, AtomicString::KeyHasher> cached_methods_;
  std::unordered_map<AtomicString, ScriptValue, AtomicString::KeyHasher> async_cached_methods_;
  std::unordered_map<AtomicString, ScriptValue, AtomicString::KeyHasher> unimplemented_properties_;
};

template <>
struct DowncastTraits<WidgetElement> {
  static bool AllowFrom(const Element& element) { return element.IsWidgetElement(); }
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_WIDGET_ELEMENT_H_
