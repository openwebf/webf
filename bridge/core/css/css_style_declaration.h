/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_STYLE_DECLARATION_H_
#define WEBF_CORE_CSS_CSS_STYLE_DECLARATION_H_

#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"
#include "defined_properties.h"
#include "core/css/css_property_names.h"

namespace webf {

class CSSRule;
class CSSStyleSheet;
class CSSValue;
class ExceptionState;
class ExecutingContext;
enum class SecureContextMode;  //TODO(xiezuobing): 这个可以删除

static bool IsPrototypeMethods(const AtomicString& key) {
  return key == defined_properties::kgetPropertyValue || key == defined_properties::kremoveProperty ||
         key == defined_properties::ksetProperty || key == defined_properties::kcssText ||
         key == defined_properties::klength;
}

class CSSStyleDeclaration : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CSSStyleDeclaration*;
  explicit CSSStyleDeclaration(JSContext* ctx);
  explicit CSSStyleDeclaration(JSContext* ctx, NativeBindingObject* native_binding_object);

  virtual ScriptValue item(const AtomicString& key, ExceptionState& exception_state) = 0;
  virtual bool SetItem(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state) = 0;
  virtual bool DeleteItem(const AtomicString& key, ExceptionState& exception_state) = 0;
  virtual unsigned length() const = 0;
  virtual AtomicString cssText() const = 0;
  virtual void setCssText(const AtomicString& value, ExceptionState& exception_state) = 0;

  virtual AtomicString getPropertyValue(const AtomicString& key, ExceptionState& exception_state) = 0;
  virtual void setProperty(const AtomicString& key, const ScriptValue& value, ExceptionState& exception_state) = 0;
  virtual AtomicString removeProperty(const AtomicString& key, ExceptionState& exception_state) = 0;

  virtual bool NamedPropertyQuery(const AtomicString&, ExceptionState&) = 0;
  virtual void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) = 0;

  //  virtual AtomicString cssText() const = 0;
  //  virtual void setCssText(const AtomicString& value, ExceptionState& exception_state) = 0;

  void Trace(GCVisitor* visitor) const override;

  virtual bool IsAbstractPropertySet() const { return false; }

//  virtual CSSRule* parentRule() const = 0;
//  AtomicString cssFloat() { return GetPropertyValueInternal(CSSPropertyID::kFloat); }
  void setCSSFloat(const ExecutingContext* execution_context,
                   const AtomicString& value,
                   ExceptionState& exception_state);
//  virtual void setCSSText(const ExecutingContext*,
//                          const AtomicString&,
//                          ExceptionState&) = 0;
//  virtual AtomicString item(unsigned index) const = 0;
//  virtual AtomicString getPropertyValue(const AtomicString& property_name) = 0;
//  virtual AtomicString getPropertyPriority(const AtomicString& property_name) = 0;
//  virtual AtomicString GetPropertyShorthand(const AtomicString& property_name) = 0;
//  virtual bool IsPropertyImplicit(const AtomicString& property_name) = 0;
//  virtual void setProperty(const ExecutingContext*,
//                           const AtomicString& property_name,
//                           const AtomicString& value,
//                           const AtomicString& priority,
//                           ExceptionState&) = 0;

  // CSSPropertyID versions of the CSSOM functions to support bindings and
  // editing.
  // Use the non-virtual methods in the concrete subclasses when possible.
  // The CSSValue returned by this function should not be exposed to the web as
  // it may be used by multiple documents at the same time.
//  virtual const CSSValue* GetPropertyCSSValueInternal(CSSPropertyID) = 0;
//  virtual const CSSValue* GetPropertyCSSValueInternal(
//      const AtomicString& custom_property_name) = 0;
//  virtual AtomicString GetPropertyValueInternal(CSSPropertyID) = 0;
  // When determining the index of a css property in CSSPropertyValueSet,
  // the value and priority can be obtained directly through the index.
  // GetPropertyValueWithHint and GetPropertyPriorityWithHint are O(1).
  // getPropertyValue and getPropertyPriority are O(n),
  // because the array needs to be traversed to find the index.
  // See https://crbug.com/1339812 for more details.
//  virtual AtomicString GetPropertyValueWithHint(const AtomicString& property_name,
//                                          unsigned index) = 0;
//  virtual AtomicString GetPropertyPriorityWithHint(const AtomicString& property_name,
//                                             unsigned index) = 0;
//  virtual void SetPropertyInternal(CSSPropertyID,
//                                   const AtomicString& property_value,
//                                   StringView value,
//                                   bool important,
//                                   ExceptionState&) = 0;

//  virtual bool CssPropertyMatches(CSSPropertyID, const CSSValue&) const = 0;
  virtual CSSStyleSheet* ParentStyleSheet() const { return nullptr; }

  AtomicString AnonymousNamedGetter(const AtomicString& name);
//
//  // Note: AnonymousNamedSetter() can end up throwing an exception via
//  // SetPropertyInternal() even though it does not take an |ExceptionState| as
//  // an argument (see bug 829408).
//  NamedPropertySetterResult AnonymousNamedSetter(ScriptState*,
//                                                 const AtomicString& name,
//                                                 v8::Local<v8::Value> value);
//  NamedPropertyDeleterResult AnonymousNamedDeleter(const AtomicString& name);
//  void NamedPropertyEnumerator(Vector<String>& names, ExceptionState&);
//  bool NamedPropertyQuery(const AtomicString&, ExceptionState&);


 protected:
  explicit CSSStyleDeclaration(ExecutingContext* context);

 private:
  // Fast path for when we know the value given from the script
  // is a number, not a string; saves the round-tripping to and from
  // strings in V8.
  //
  // Returns true if the fast path succeeded (in which case we need to
  // go through the normal string path).
  virtual bool FastPathSetProperty(CSSPropertyID unresolved_property,
                                   double value) {
    return false;
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_STYLE_DECLARATION_H_
