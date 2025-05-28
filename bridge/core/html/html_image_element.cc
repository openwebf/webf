/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_image_element.h"
#include "binding_call_methods.h"
#include "bindings/qjs/converter_impl.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "foundation/native_value_converter.h"
#include "html_names.h"
#include "qjs_html_image_element.h"

namespace webf {

HTMLImageElement::HTMLImageElement(Document& document) : HTMLElement(html_names::kImg, &document) {}

ScriptPromise HTMLImageElement::decode(ExceptionState& exception_state) const {
  exception_state.ThrowException(ctx(), ErrorType::InternalError, "Not implemented.");
  // @TODO not implemented.
  return ScriptPromise();
}

AtomicString HTMLImageElement::src() const {
  ExceptionState exception_state;
  NativeValue native_value =
      GetBindingProperty(binding_call_methods::ksrc, FlushUICommandReason::kDependentsOnElement, exception_state);
  typename NativeTypeString::ImplType v =
      NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(native_value));
  if (UNLIKELY(exception_state.HasException())) {
    return AtomicString::Empty();
  }
  return v;
}

void HTMLImageElement::setSrc(const AtomicString& value, ExceptionState& exception_state) {
  SetBindingProperty(binding_call_methods::ksrc, NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), value),
                     exception_state);
  if (!value.IsEmpty() && !keep_alive) {
    KeepAlive();
    keep_alive = true;
  }
}

ScriptPromise HTMLImageElement::src_async(webf::ExceptionState& exception_state) {
  return GetBindingPropertyAsync(binding_call_methods::ksrc, exception_state);
}

void HTMLImageElement::setSrc_async(const AtomicString& value, ExceptionState& exception_state) {
  SetBindingPropertyAsync(defined_properties::ksrc, NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), value),
                          exception_state);
  if (!value.IsEmpty() && !keep_alive) {
    KeepAlive();
    keep_alive = true;
  }
}

DispatchEventResult HTMLImageElement::FireEventListeners(Event& event, ExceptionState& exception_state) {
  if (keep_alive && (event.type() == event_type_names::kload || event.type() == event_type_names::kerror)) {
    ReleaseAlive();
  }

  return HTMLElement::FireEventListeners(event, exception_state);
}

DispatchEventResult HTMLImageElement::FireEventListeners(webf::Event& event,
                                                         bool isCapture,
                                                         webf::ExceptionState& exception_state) {
  if (keep_alive && (event.type() == event_type_names::kload || event.type() == event_type_names::kerror)) {
    ReleaseAlive();
  }

  return HTMLElement::FireEventListeners(event, isCapture, exception_state);
}

}  // namespace webf
