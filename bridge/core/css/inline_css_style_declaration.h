/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CSS_STYLE_DECLARATION_H
#define BRIDGE_CSS_STYLE_DECLARATION_H

#include <unordered_map>
#include "bindings/qjs/cppgc/member.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/script_wrappable.h"
#include "css_style_declaration.h"
#include "plugin_api/inline_css_style_declaration.h"
#include "core/css/abstract_property_set_css_style_declaration.h"
#include "core/dom/element_rare_data_field.h"

namespace webf {

class Element;

class InlineCssStyleDeclaration : public AbstractPropertySetCSSStyleDeclaration {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = InlineCssStyleDeclaration*;
  static InlineCssStyleDeclaration* Create(ExecutingContext* context, ExceptionState& exception_state);
  explicit InlineCssStyleDeclaration(Element* parent_element);

  bool IsPropertyValid(CSSPropertyID) const override { return true; }
  void Trace(GCVisitor*) const override;

  bool IsInlineCssStyleDeclaration() const override;
  const InlineCssStyleDeclarationPublicMethods* inlineCssStyleDeclarationPublicMethods();

  String ToString() const;

  // Support bracket assignment/deletion via generated QuickJS string property hooks.
  // style["background-color"] = "blue" → routes here, then to
  // CSSStyleDeclaration::AnonymousNamedSetter.
  bool SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState&);
  bool DeleteItem(const AtomicString& key, ExceptionState&);

 private:
  MutableCSSPropertyValueSet& PropertySet() const override;
  CSSStyleSheet* ParentStyleSheet() const override;
  Element* ParentElement() const override { return parent_element_.Get(); }

  void DidMutate(MutationType) override;

  Member<Element> parent_element_;
};

template <>
struct DowncastTraits<InlineCssStyleDeclaration> {
  static bool AllowFrom(const CSSStyleDeclaration& binding_object) {
    return binding_object.IsInlineCssStyleDeclaration();
  }
};

}  // namespace webf

#endif  // BRIDGE_CSS_STYLE_DECLARATION_H
