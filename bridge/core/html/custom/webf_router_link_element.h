/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#ifndef WEBF_CORE_HTML_HYBRID_ROUTER_WEBF_ROUTER_LINK_H_
#define WEBF_CORE_HTML_HYBRID_ROUTER_WEBF_ROUTER_LINK_H_

#include "widget_element.h"

namespace webf {

class WebFRouterLinkElement : public WidgetElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit WebFRouterLinkElement(Document&);

  bool IsRouterLinkElement() const override;
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_HYBRID_ROUTER_WEBF_ROUTER_LINK_H_
