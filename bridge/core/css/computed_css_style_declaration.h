/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_CORE_CSS_COMPUTED_CSS_STYLE_DECLARATION_H_
#define WEBF_CORE_CSS_COMPUTED_CSS_STYLE_DECLARATION_H_

#include "core/binding_object.h"
#include "code_gen/css_property_names.h"
#include "core/css/css_value.h"
#include "css_style_declaration.h"
#include "plugin_api/computed_css_style_declaration.h"

namespace webf {

class Element;

class ComputedCssStyleDeclaration : public CSSStyleDeclaration {
 DEFINE_WRAPPERTYPEINFO();

public:
 using ImplType = ComputedCssStyleDeclaration;
 ComputedCssStyleDeclaration() = delete;

 explicit ComputedCssStyleDeclaration(ExecutingContext* context);
 explicit ComputedCssStyleDeclaration(ExecutingContext* context, NativeBindingObject* nativeBindingObject);

 //  ScriptValue item(const AtomicString& key, ExceptionState& exception_state) override;
 unsigned length() const override;

 ScriptValue item(const AtomicString& key, ExceptionState& exception_state);
 AtomicString getPropertyValue(const AtomicString& key, ExceptionState& exception_state) override;
 AtomicString removeProperty(const AtomicString& key, ExceptionState& exception_state) override;

 bool NamedPropertyQuery(const AtomicString&, ExceptionState&) override;
 void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) override;

 bool IsComputedCssStyleDeclaration() const override;

 AtomicString cssText() const override;
 void setCssText(const AtomicString& value, ExceptionState& exception_state) override;

 // Pure virtual methods from CSSStyleDeclaration
 CSSRule* parentRule() const override;
 AtomicString getPropertyPriority(const AtomicString& property_name) override;
 AtomicString GetPropertyShorthand(const AtomicString& property_name) override;
 bool IsPropertyImplicit(const AtomicString& property_name) override;
  void setProperty(const AtomicString& property_name,
                   const AtomicString& value,
                   const AtomicString& priority,
                   ExceptionState& exception_state) override;
 const std::shared_ptr<const CSSValue>* GetPropertyCSSValueInternal(CSSPropertyID property_id) override;
 const std::shared_ptr<const CSSValue>* GetPropertyCSSValueInternal(const AtomicString& custom_property_name) override;
 AtomicString GetPropertyValueInternal(CSSPropertyID property_id) override;
 AtomicString GetPropertyValueWithHint(const AtomicString& property_name, unsigned index) override;
 AtomicString GetPropertyPriorityWithHint(const AtomicString& property_name, unsigned index) override;
 void SetPropertyInternal(CSSPropertyID property_id,
                         const AtomicString& property_name,
                         StringView value,
                         bool important,
                         ExceptionState& exception_state) override;
 bool CssPropertyMatches(CSSPropertyID property_id, const CSSValue& value) const override;
 const ComputedCssStyleDeclarationPublicMethods* computedCssStyleDeclarationPublicMethods();


private:
};

template <>
struct DowncastTraits<ComputedCssStyleDeclaration> {
 static bool AllowFrom(const BindingObject& binding_object) { return binding_object.IsComputedCssStyleDeclaration(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_COMPUTED_CSS_STYLE_DECLARATION_H_
