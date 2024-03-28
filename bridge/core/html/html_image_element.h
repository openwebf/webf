/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_
#define BRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_

#include "html_element.h"

namespace webf {

class HTMLImageElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLImageElement*;
  explicit HTMLImageElement(Document& document);
  AtomicString src() const;
  void setSrc(const AtomicString& value, ExceptionState& exception_state);

  DispatchEventResult FireEventListeners(Event&, ExceptionState&) override;
  DispatchEventResult FireEventListeners(Event&, bool isCapture, ExceptionState&) override;

  ScriptPromise decode(ExceptionState& exception_state) const;

 private:
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_
