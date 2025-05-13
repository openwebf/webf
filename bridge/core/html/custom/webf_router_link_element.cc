/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */

#include "webf_router_link_element.h"
#include "webf_element_names.h"

namespace webf {

WebFRouterLinkElement::WebFRouterLinkElement(webf::Document& document)
    : WidgetElement(webf_element_names::kWebfRouterLink, &document) {}

bool WebFRouterLinkElement::IsRouterLinkElement() const {
  return true;
}

}  // namespace webf