/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#include "html_head_element.h"
#include "html_names.h"

namespace kraken {

HTMLHeadElement::HTMLHeadElement(Document& document) : HTMLElement(html_names::khead, &document) {}

}  // namespace kraken
