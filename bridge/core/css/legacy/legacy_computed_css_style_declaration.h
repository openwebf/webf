/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_LEGACY_COMPUTED_CSS_STYLE_DECLARATION_H_
#define WEBF_CORE_CSS_LEGACY_COMPUTED_CSS_STYLE_DECLARATION_H_

#include "bindings/qjs/cppgc/member.h"
#include "core/binding_object.h"
#include "legacy_css_style_declaration.h"
#include "plugin_api/computed_css_style_declaration.h"

namespace webf {
struct LegacyComputedCssStyleDeclarationPublicMethods;

class Element;

namespace legacy {

class LegacyComputedCssStyleDeclaration : public LegacyCssStyleDeclaration {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = LegacyComputedCssStyleDeclaration;
  LegacyComputedCssStyleDeclaration() = delete;

  explicit LegacyComputedCssStyleDeclaration(ExecutingContext* context, NativeBindingObject* native_binding_object);

  ScriptValue item(const AtomicString& key, ExceptionState& exception_state) override;
  bool SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state) override;
  bool DeleteItem(const webf::AtomicString& key, webf::ExceptionState& exception_state) override;
  unsigned length() const override;
  ScriptPromise length_async(ExceptionState& exception_state);

  AtomicString getPropertyValue(const AtomicString& key, ExceptionState& exception_state) override;
  void setProperty(const AtomicString& key, const ScriptValue& value, const AtomicString& priority, ExceptionState& exception_state) override;
  void setProperty_async(const AtomicString& key, const ScriptValue& value, const AtomicString& priority, ExceptionState& exception_state);
  AtomicString removeProperty(const AtomicString& key, ExceptionState& exception_state) override;

  bool NamedPropertyQuery(const AtomicString&, ExceptionState&) override;
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) override;

  bool IsComputedCssStyleDeclaration() const override;

  AtomicString cssText() const override;
  ScriptPromise cssText_async(ExceptionState& exception_state);
  void setCssText(const AtomicString& value, ExceptionState& exception_state) override;
  ScriptPromise setCssText_async(const AtomicString& value, ExceptionState& exception_state);

  const LegacyComputedCssStyleDeclarationPublicMethods* legacyComputedCssStyleDeclarationPublicMethods();

 private:
};

}  // namespace legacy


using legacy::LegacyComputedCssStyleDeclaration;

template <>
struct DowncastTraits<LegacyComputedCssStyleDeclaration> {
  static bool AllowFrom(const legacy::LegacyCssStyleDeclaration& decl) {
    return decl.IsComputedCssStyleDeclaration();
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_LEGACY_COMPUTED_CSS_STYLE_DECLARATION_H_
