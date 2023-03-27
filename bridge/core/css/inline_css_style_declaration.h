/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CSS_STYLE_DECLARATION_H
#define BRIDGE_CSS_STYLE_DECLARATION_H

#include <unordered_map>
#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/script_wrappable.h"
#include "css_style_declaration.h"

namespace webf {

class Element;

class InlineCssStyleDeclaration : public CSSStyleDeclaration {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = InlineCssStyleDeclaration*;
  static InlineCssStyleDeclaration* Create(ExecutingContext* context, ExceptionState& exception_state);
  explicit InlineCssStyleDeclaration(ExecutingContext* context, Element* owner_element_);

  AtomicString item(const AtomicString& key, ExceptionState& exception_state) override;
  bool SetItem(const AtomicString& key, const AtomicString& value, ExceptionState& exception_state) override;
  [[nodiscard]] int64_t length() const override;

  AtomicString getPropertyValue(const AtomicString& key, ExceptionState& exception_state) override;
  void setProperty(const AtomicString& key, const AtomicString& value, ExceptionState& exception_state) override;
  AtomicString removeProperty(const AtomicString& key, ExceptionState& exception_state) override;

  [[nodiscard]] std::string ToString() const;

  bool NamedPropertyQuery(const AtomicString&, ExceptionState&) override;
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) override;

  void CopyWith(InlineCssStyleDeclaration* inline_style);

  //  AtomicString cssText() const override;
  //  void setCssText(const AtomicString &value, ExceptionState &exception_state) override;

  void Trace(GCVisitor* visitor) const override;

 private:
  AtomicString InternalGetPropertyValue(std::string& name);
  bool InternalSetProperty(std::string& name, const AtomicString& value);
  AtomicString InternalRemoveProperty(std::string& name);
  std::unordered_map<std::string, AtomicString> properties_;
  Member<Element> owner_element_;
};

}  // namespace webf

#endif  // BRIDGE_CSS_STYLE_DECLARATION_H
