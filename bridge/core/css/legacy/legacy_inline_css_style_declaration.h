/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CSS_LEGACY_STYLE_DECLARATION_H
#define BRIDGE_CSS_LEGACY_STYLE_DECLARATION_H

#include <unordered_map>
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/script_wrappable.h"
#include "legacy_css_style_declaration.h"
#include "plugin_api/inline_css_style_declaration.h"

namespace webf {
struct LegacyInlineCssStyleDeclarationPublicMethods;
class Element;

namespace legacy {

class LegacyInlineCssStyleDeclaration : public LegacyCssStyleDeclaration {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = LegacyInlineCssStyleDeclaration*;
  static LegacyInlineCssStyleDeclaration* Create(ExecutingContext* context, ExceptionState& exception_state);
  explicit LegacyInlineCssStyleDeclaration(Element* owner_element_);

  ScriptValue item(const AtomicString& key, ExceptionState& exception_state) override;
  bool SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state) override;
  bool DeleteItem(const webf::AtomicString& key, webf::ExceptionState& exception_state) override;
  void Clear();
  [[nodiscard]] unsigned length() const override;

  AtomicString getPropertyValue(const AtomicString& key, ExceptionState& exception_state) override;
  void setProperty(const AtomicString& key, const ScriptValue& value, const AtomicString& priority, ExceptionState& exception_state) override;
  AtomicString removeProperty(const AtomicString& key, ExceptionState& exception_state) override;

  [[nodiscard]] String ToString() const;

  void InlineStyleChanged();

  bool NamedPropertyQuery(const AtomicString&, ExceptionState&) override;
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) override;

  void CopyWith(LegacyInlineCssStyleDeclaration* inline_style);

  AtomicString cssText() const override;
  void setCssText(const AtomicString& value, ExceptionState& exception_state) override;
  void SetCSSTextInternal(const AtomicString& value);

  void Trace(GCVisitor* visitor) const override;

  bool IsInlineCssStyleDeclaration() const override;
  const LegacyInlineCssStyleDeclarationPublicMethods* legacyInlineCssStyleDeclarationPublicMethods();

 private:
  AtomicString InternalGetPropertyValue(std::string& name);
  bool InternalSetProperty(std::string& name, const AtomicString& value);
  AtomicString InternalRemoveProperty(std::string& name);
  void InternalClearProperty();
  std::unordered_map<std::string, AtomicString> properties_;
  Member<Element> owner_element_;
};

}

using legacy::LegacyInlineCssStyleDeclaration;

template <>
struct DowncastTraits<LegacyInlineCssStyleDeclaration> {
  static bool AllowFrom(const legacy::LegacyCssStyleDeclaration& decl) {
    return decl.IsInlineCssStyleDeclaration();
  }
};

}  // namespace webf

#endif  // BRIDGE_CSS_LEGACY_STYLE_DECLARATION_H
