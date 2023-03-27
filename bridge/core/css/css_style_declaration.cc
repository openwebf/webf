/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_style_declaration.h"

namespace webf {

CSSStyleDeclaration::CSSStyleDeclaration(JSContext* ctx) : BindingObject(ctx) {}
CSSStyleDeclaration::CSSStyleDeclaration(JSContext* ctx, NativeBindingObject* native_binding_object)
    : BindingObject(ctx, native_binding_object) {}

}  // namespace webf