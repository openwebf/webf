/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/element.h"
#include "core/api/exception_state.h"
#include "core/css/legacy/legacy_inline_css_style_declaration.h"
#include "core/dom/container_node.h"
#include "core/dom/element.h"
#include "foundation/utility/make_visitor.h"

namespace webf {

WebFValue<LegacyCssStyleDeclaration, LegacyCssStyleDeclarationPublicMethods> ElementPublicMethods::Style(Element* ptr) {
  auto* element = static_cast<webf::Element*>(ptr);
  MemberMutationScope member_mutation_scope{element->GetExecutingContext()};
  auto style = element->style();

  return std::visit(
      MakeVisitor(
          [&](legacy::LegacyInlineCssStyleDeclaration* styleDeclaration) {
            WebFValueStatus* status_block = styleDeclaration->KeepAlive();
            return WebFValue<LegacyCssStyleDeclaration, LegacyCssStyleDeclarationPublicMethods>(
                styleDeclaration, styleDeclaration->legacyCssStyleDeclarationPublicMethods(), status_block);
          },
          [](auto&&) { return WebFValue<LegacyCssStyleDeclaration, LegacyCssStyleDeclarationPublicMethods>::Null(); }),
      style);
}

void ElementPublicMethods::ToBlob(Element* ptr,
                                  WebFNativeFunctionContext* callback_context,
                                  SharedExceptionState* shared_exception_state) {
  auto* element = static_cast<webf::Element*>(ptr);
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);
  return element->toBlob(callback_impl, shared_exception_state->exception_state);
}

void ElementPublicMethods::ToBlobWithDevicePixelRatio(Element* ptr,
                                                      double device_pixel_ratio,
                                                      WebFNativeFunctionContext* callback_context,
                                                      SharedExceptionState* shared_exception_state) {
  auto* element = static_cast<webf::Element*>(ptr);
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);
  return element->toBlob(device_pixel_ratio, callback_impl, shared_exception_state->exception_state);
}

}  // namespace webf
