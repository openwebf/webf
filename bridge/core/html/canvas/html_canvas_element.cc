/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_canvas_element.h"
#include "binding_call_methods.h"
#include "canvas_rendering_context_2d.h"
#include "canvas_types.h"
#include "foundation/native_value_converter.h"
#include "html_names.h"
#include "qjs_html_canvas_element.h"

namespace webf {

HTMLCanvasElement::HTMLCanvasElement(Document& document) : HTMLElement(html_names::kCanvas, &document) {}

CanvasRenderingContext2D* HTMLCanvasElement::getContext(const AtomicString& type, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), type)};
  NativeValue value = InvokeBindingMethod(binding_call_methods::kgetContext, 1, arguments,
                                          FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);

  if (native_binding_object == nullptr)
    return nullptr;

  if (type == canvas_types::k2d) {
    auto* context =
        MakeGarbageCollected<CanvasRenderingContext2D>(GetExecutingContext(), native_binding_object);
    running_context_2ds_.emplace_back(context);
    return context;
  }

  return nullptr;
}

void HTMLCanvasElement::Trace(GCVisitor* visitor) const {
  for (auto&& context : running_context_2ds_) {
    visitor->TraceMember(context);
  }
  HTMLElement::Trace(visitor);
}

const HTMLCanvasElementPublicMethods* HTMLCanvasElement::htmlCanvasElementPublicMethods() {
  static HTMLCanvasElementPublicMethods html_canvas_element_public_methods;
  return &html_canvas_element_public_methods;
}

}  // namespace webf
