/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_WEBF_API_CSS_STYLE_DECLARATION_H_
#define WEBF_CORE_WEBF_API_CSS_STYLE_DECLARATION_H_

#include "webf_value.h"
#include "foundation/native_value.h"

namespace webf {

class CSSStyleDeclaration;
class SharedExceptionState;

using PublicCSSStyleDeclarationSetProperty = void (*)(CSSStyleDeclaration*,
                                                      const char* property,
                                                      NativeValue value,
                                                      SharedExceptionState* shared_exception_state);

struct CSSStyleDeclarationPublicMethods : public WebFPublicMethods {

  static void SetProperty(CSSStyleDeclaration* self,
                          const char* property,
                          NativeValue value,
                          SharedExceptionState* shared_exception_state);
  double version{1.0};
  PublicCSSStyleDeclarationSetProperty css_style_declaration_set_property{SetProperty};

};

}  // namespace webf

#endif  // WEBF_CORE_WEBF_API_CSS_STYLE_DECLARATION_H_
