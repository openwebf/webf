/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/text.h"
#include "core/dom/character_data.h"

namespace webf {

TextNodeWebFMethods::TextNodeWebFMethods(CharacterDataWebFMethods* super_method)
    : character_data(super_method) {}

}  // namespace webf