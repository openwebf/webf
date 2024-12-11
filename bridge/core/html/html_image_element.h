/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_
#define BRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_

#include "html_element.h"
#include "html_names.h"
#include "plugin_api/html_image_element.h"

namespace webf {

class HTMLImageElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLImageElement*;
  explicit HTMLImageElement(Document& document);
  AtomicString src() const;
  void setSrc(const AtomicString& value, ExceptionState& exception_state);

  ScriptPromise src_async(ExceptionState& exception_state);
  ScriptPromise setSrc_async(const AtomicString& value, ExceptionState& exception_state);

  DispatchEventResult FireEventListeners(Event&, ExceptionState&) override;
  DispatchEventResult FireEventListeners(Event&, bool isCapture, ExceptionState&) override;

  ScriptPromise decode(ExceptionState& exception_state) const;

  const HTMLImageElementPublicMethods* htmlImageElementPublicMethods() {
    static HTMLImageElementPublicMethods html_image_element_public_methods;
    return &html_image_element_public_methods;
  }

 private:
  bool keep_alive = false;
};

template <>
struct DowncastTraits<HTMLImageElement> {
  static bool AllowFrom(const EventTarget& event_target) {
    return event_target.IsNode() && To<Node>(event_target).IsHTMLElement() &&
           To<HTMLElement>(event_target).tagName() == html_names::kimg;
  }
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_IMAGE_ELEMENT_H_
