/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_STYLE_DECLARATION_H_
#define WEBF_CORE_CSS_CSS_STYLE_DECLARATION_H_

#include "bindings/qjs/script_wrappable.h"

namespace webf {

class CSSStyleDeclaration : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CSSStyleDeclaration*;
  explicit CSSStyleDeclaration(JSContext* ctx);

  virtual AtomicString item(const AtomicString& key, ExceptionState& exception_state) = 0;
  virtual bool SetItem(const AtomicString& key, const AtomicString& value, ExceptionState& exception_state) = 0;
  virtual int64_t length() const = 0;

  virtual AtomicString getPropertyValue(const AtomicString& key, ExceptionState& exception_state) = 0;
  virtual void setProperty(const AtomicString& key, const AtomicString& value, ExceptionState& exception_state) = 0;
  virtual AtomicString removeProperty(const AtomicString& key, ExceptionState& exception_state) = 0;

  virtual bool NamedPropertyQuery(const AtomicString&, ExceptionState&) = 0;
  virtual void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) = 0;

  //  virtual AtomicString cssText() const = 0;
  //  virtual void setCssText(const AtomicString& value, ExceptionState& exception_state) = 0;

 private:
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_STYLE_DECLARATION_H_
