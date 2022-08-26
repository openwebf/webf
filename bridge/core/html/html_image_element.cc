/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "html_image_element.h"
#include "html_names.h"

namespace webf {

HTMLImageElement::HTMLImageElement(Document& document) : HTMLElement(html_names::kimg, &document) {}

ScriptPromise HTMLImageElement::decode(ExceptionState& exception_state) const {
  exception_state.ThrowException(ctx(), ErrorType::InternalError, "Not implemented.");
  // @TODO not implemented.
  return ScriptPromise();
}

bool HTMLImageElement::KeepAlive() const {
  return true;
}

}  // namespace webf
