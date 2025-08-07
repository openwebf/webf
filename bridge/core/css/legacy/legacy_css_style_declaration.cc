/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "legacy_css_style_declaration.h"
#include "plugin_api/legacy_css_style_declaration.h"

namespace webf {
namespace legacy {


LegacyCssStyleDeclaration::LegacyCssStyleDeclaration(JSContext* ctx) : BindingObject(ctx) {}
LegacyCssStyleDeclaration::LegacyCssStyleDeclaration(JSContext* ctx, NativeBindingObject* native_binding_object)
    : BindingObject(ctx, native_binding_object) {}

bool LegacyCssStyleDeclaration::IsComputedCssStyleDeclaration() const {
  return false;
}

bool LegacyCssStyleDeclaration::IsInlineCssStyleDeclaration() const {
  return false;
}

const LegacyCssStyleDeclarationPublicMethods* LegacyCssStyleDeclaration::legacyCssStyleDeclarationPublicMethods() {
  static LegacyCssStyleDeclarationPublicMethods css_style_declaration_public_methods;
  return &css_style_declaration_public_methods;
}

}
}  // namespace webf
