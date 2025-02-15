/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/css_style_declaration.h"
#include "core/api/exception_state.h"
#include "core/css/css_style_declaration.h"

namespace webf {

void CSSStyleDeclarationPublicMethods::SetProperty(CSSStyleDeclaration* self,
                                                   const char* property,
                                                   NativeValue value,
                                                   SharedExceptionState* shared_exception_state) {
  webf::AtomicString property_atomic = webf::AtomicString(self->ctx(), property);
  ScriptValue value_script_value = ScriptValue(self->ctx(), value);

  self->setProperty(property_atomic, value_script_value, shared_exception_state->exception_state);
};

}  // namespace webf
