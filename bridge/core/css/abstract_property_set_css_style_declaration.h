//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_ABSTRACT_PROPERTY_SET_CSS_STYLE_DECLARATION_H
#define WEBF_ABSTRACT_PROPERTY_SET_CSS_STYLE_DECLARATION_H

#include "core/css/css_style_declaration.h"

namespace webf {


class CSSRule;
class CSSValue;
class Element;
class ExceptionState;
class ExecutingContext;
class MutableCSSPropertyValueSet;
class StyleSheetContents;


class AbstractPropertySetCSSStyleDeclaration
    : public CSSStyleDeclaration {
 public:
  virtual Element* ParentElement() const { return nullptr; }
  StyleSheetContents* ContextStyleSheet() const;
  explicit AbstractPropertySetCSSStyleDeclaration(ExecutingContext* context)
      : CSSStyleDeclaration(context->ctx()) {}

  // Some subclasses only allow a subset of the properties, for example
  // CSSPositionTryDescriptors only allows inset and sizing properties.
  virtual bool IsPropertyValid(CSSPropertyID) const = 0;

  void Trace(GCVisitor*) const override;

//  AtomicString GetPropertyValueInternal(CSSPropertyID) final;
//  void SetPropertyInternal(CSSPropertyID,
//                           const AtomicString& custom_property_name,
//                           StringView value,
//                           bool important,
//                           ExceptionState&) final;

 private:
  bool IsAbstractPropertySet() const final { return true; }
//  CSSRule* parentRule() const override { return nullptr; }
  unsigned length() const final;
//  AtomicString item(unsigned index) const final;
//  AtomicString getPropertyValue(const AtomicString& property_name) final;
//  AtomicString getPropertyPriority(const AtomicString& property_name) final;
//  AtomicString GetPropertyShorthand(const AtomicString& property_name) final;
//  bool IsPropertyImplicit(const AtomicString& property_name) final;
//  void setProperty(const ExecutingContext*,
//                   const AtomicString& property_name,
//                   const AtomicString& value,
//                   const AtomicString& priority,
//                   ExceptionState&) final;
  AtomicString removeProperty(const AtomicString& property_name, ExceptionState&) final;
  AtomicString CssFloat() const;
  void SetCSSFloat(const AtomicString&, ExceptionState&);
  AtomicString cssText() const final;
//  void setCSSText(const ExecutingContext*,
//                  const AtomicString&,
//                  ExceptionState&) final;
  /*const CSSValue* GetPropertyCSSValueInternal(CSSPropertyID) final;
  const CSSValue* GetPropertyCSSValueInternal(
      const AtomicString& custom_property_name) final;
  AtomicString GetPropertyValueWithHint(const AtomicString& property_name,
                                  unsigned index) final;
  AtomicString GetPropertyPriorityWithHint(const AtomicString& property_name,
                                     unsigned index) final;

  bool CssPropertyMatches(CSSPropertyID, const CSSValue&) const final;*/

 protected:
  enum MutationType {
    kNoChanges,
    // Only properties that were independent changed, so that if there are
    // no other changes and this is on the inline style, it may be
    // possible to reuse an already-computed style and just apply
    // the new changes on top of it.
    kIndependentPropertyChanged,
    kPropertyChanged
  };
  virtual void WillMutate() {}
  virtual void DidMutate(MutationType) {}
  virtual MutableCSSPropertyValueSet& PropertySet() const = 0;
  virtual bool IsKeyframeStyle() const { return false; }
  bool FastPathSetProperty(CSSPropertyID unresolved_property,
                           double value) override;
};

template <>
struct DowncastTraits<AbstractPropertySetCSSStyleDeclaration> {
  static bool AllowFrom(const CSSStyleDeclaration& declaration) {
    return declaration.IsAbstractPropertySet();
  }
};


}  // namespace webf

#endif  // WEBF_ABSTRACT_PROPERTY_SET_CSS_STYLE_DECLARATION_H
