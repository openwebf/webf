/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_HTML_BODY_ELEMENT_H_
#define BRIDGE_CORE_HTML_HTML_BODY_ELEMENT_H_

#include "core/dom/document.h"
#include "core/frame/window_event_handlers.h"
#include "html_element.h"
#include "plugin_api/html_body_element.h"

namespace webf {

class HTMLBodyElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLBodyElement*;
  explicit HTMLBodyElement(Document&);

  const HTMLBodyElementPublicMethods* htmlBodyElementPublicMethods() {
    static HTMLBodyElementPublicMethods html_body_element_public_methods;
    return &html_body_element_public_methods;
  }

  DEFINE_WINDOW_ATTRIBUTE_EVENT_LISTENER(blur, kblur);
  DEFINE_WINDOW_ATTRIBUTE_EVENT_LISTENER(error, kerror);
  DEFINE_WINDOW_ATTRIBUTE_EVENT_LISTENER(focus, kfocus);
  DEFINE_WINDOW_ATTRIBUTE_EVENT_LISTENER(load, kload);
  DEFINE_WINDOW_ATTRIBUTE_EVENT_LISTENER(resize, kresize);
  DEFINE_WINDOW_ATTRIBUTE_EVENT_LISTENER(scroll, kscroll);
  DEFINE_WINDOW_ATTRIBUTE_EVENT_LISTENER(orientationchange, korientationchange);
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_BODY_ELEMENT_H_
