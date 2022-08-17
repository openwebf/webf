/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_FRAME_WINDOW_EVENT_HANDLERS_H_
#define BRIDGE_CORE_FRAME_WINDOW_EVENT_HANDLERS_H_

#include "core/dom/document.h"
#include "event_type_names.h"
#include "foundation/macros.h"

namespace webf {

class WindowEventHandlers {
  WEBF_STATIC_ONLY(WindowEventHandlers);

 public:
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(beforeunload, kbeforeunload);
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(hashchange, khashchange);
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(message, kmessage);
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(messageerror, kmessageerror);
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(pagehide, kpagehide);
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(pageshow, kpageshow);
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(popstate, kpopstate);
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(rejectionhandled, krejectionhandled);
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(unhandledrejection, kunhandledrejection);
  DEFINE_STATIC_WINDOW_ATTRIBUTE_EVENT_LISTENER(unload, kunload);
};

}  // namespace webf

#endif  // BRIDGE_CORE_FRAME_WINDOW_EVENT_HANDLERS_H_
