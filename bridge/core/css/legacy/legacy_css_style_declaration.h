/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_LEGACY_CSS_STYLE_DECLARATION_H_
#define WEBF_CORE_CSS_LEGACY_CSS_STYLE_DECLARATION_H_

#include "../../../foundation/string/string_view.h"
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/script_wrappable.h"
#include "code_gen/css_property_names.h"
#include "core/binding_object.h"
#include "defined_properties.h"
#include "plugin_api/css_style_declaration.h"

namespace webf {
struct LegacyCssStyleDeclarationPublicMethods;
class CSSRule;
class CSSValue;
class CSSStyleSheet;
class ExecutingContext;
}
namespace webf {
namespace legacy {

static bool IsPrototypeMethods(const AtomicString& key) {
  return key == defined_properties::kgetPropertyValue || key == defined_properties::kremoveProperty ||
         key == defined_properties::ksetProperty || key == defined_properties::kcssText ||
         key == defined_properties::klength;
}

class LegacyCssStyleDeclaration : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = LegacyCssStyleDeclaration*;
  explicit LegacyCssStyleDeclaration(JSContext* ctx);
  explicit LegacyCssStyleDeclaration(JSContext* ctx, NativeBindingObject* native_binding_object);

  virtual ScriptValue item(const AtomicString& key, ExceptionState& exception_state) { return ScriptValue(ctx(), AtomicString()); }
  virtual AtomicString item(unsigned index) const { return AtomicString(); }
  virtual bool SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state) { return false; }
  virtual bool DeleteItem(const AtomicString& key, ExceptionState& exception_state) { return false; }
  virtual unsigned length() const { return 0; }
  virtual AtomicString cssText() const { return AtomicString(); }
  virtual void setCssText(const AtomicString& value, ExceptionState& exception_state) {}

  virtual AtomicString getPropertyValue(const AtomicString& key, ExceptionState& exception_state) { return AtomicString(); }
  virtual void setProperty(const AtomicString& key, const ScriptValue& value, const AtomicString& priority, ExceptionState& exception_state) {}
  virtual AtomicString removeProperty(const AtomicString& key, ExceptionState& exception_state) { return AtomicString(); }

  virtual bool NamedPropertyQuery(const AtomicString&, ExceptionState&) { return false; }
  virtual void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) {}

  // Additional virtual methods required for AbstractPropertySetCssStyleDeclaration
  virtual AtomicString GetPropertyValueInternal(CSSPropertyID) { return AtomicString(); }
  virtual void SetPropertyInternal(CSSPropertyID,
                                   const AtomicString& custom_property_name,
                                   StringView value,
                                   bool important,
                                   ExceptionState&) {}
  virtual bool IsAbstractPropertySet() const { return false; }
  virtual CSSRule* parentRule() const { return nullptr; }
  virtual AtomicString getPropertyPriority(const AtomicString& property_name) { return AtomicString(); }
  virtual AtomicString GetPropertyShorthand(const AtomicString& property_name) { return AtomicString(); }
  virtual bool IsPropertyImplicit(const AtomicString& property_name) { return false; }
  virtual void setProperty(const ExecutingContext*,
                           const AtomicString& property_name,
                           const AtomicString& value,
                           const AtomicString& priority,
                           ExceptionState&) {}
  virtual const std::shared_ptr<const CSSValue>* GetPropertyCSSValueInternal(CSSPropertyID) { return nullptr; }
  virtual const std::shared_ptr<const CSSValue>* GetPropertyCSSValueInternal(
      const AtomicString& custom_property_name) { return nullptr; }
  virtual AtomicString GetPropertyValueWithHint(const AtomicString& property_name, unsigned index) { return AtomicString(); }
  virtual AtomicString GetPropertyPriorityWithHint(const AtomicString& property_name, unsigned index) { return AtomicString(); }
  virtual bool CssPropertyMatches(CSSPropertyID, const CSSValue&) const { return false; }
  virtual bool FastPathSetProperty(CSSPropertyID unresolved_property, double value) { return false; }
  virtual CSSStyleSheet* ParentStyleSheet() const { return nullptr; }

  //  virtual AtomicString cssText() const = 0;
  //  virtual void setCssText(const AtomicString& value, ExceptionState& exception_state) = 0;

  virtual bool IsComputedCssStyleDeclaration() const override;
  virtual bool IsInlineCssStyleDeclaration() const;

  const LegacyCssStyleDeclarationPublicMethods* legacyCssStyleDeclarationPublicMethods();

 private:
};

}

using legacy::LegacyCssStyleDeclaration;

}  // namespace webf

#endif  // WEBF_CORE_CSS_LEGACY_CSS_STYLE_DECLARATION_H_
