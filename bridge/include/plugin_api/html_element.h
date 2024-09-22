/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_CORE_RUST_API_HTML_ELEMENT_H_
#define WEBF_CORE_RUST_API_HTML_ELEMENT_H_

#include "element.h"

namespace webf {

struct HTMLElementPublicMethods : WebFPublicMethods {
 double version{1.0};
 ElementPublicMethods element_public_methods;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_HTML_ELEMENT_H_
