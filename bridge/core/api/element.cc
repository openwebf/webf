/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/element.h"
#include "core/api/exception_state.h"
#include "core/dom/container_node.h"
#include "core/dom/element.h"

namespace webf {

WebFValue<CSSStyleDeclaration, CSSStyleDeclarationPublicMethods> ElementPublicMethods::Style(Element* ptr) {
  auto* element = static_cast<webf::Element*>(ptr);
  MemberMutationScope member_mutation_scope{element->GetExecutingContext()};
  auto style = element->style();
  WebFValueStatus* status_block = style->KeepAlive();
  return WebFValue<CSSStyleDeclaration, CSSStyleDeclarationPublicMethods>(
      style, style->cssStyleDeclarationPublicMethods(), status_block);
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
