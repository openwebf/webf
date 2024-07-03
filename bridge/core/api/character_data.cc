/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/character_data.h"
#include "core/dom/node.h"

namespace webf {

CharacterDataWebFMethods::CharacterDataWebFMethods(NodeWebFMethods* super_method) : node(super_method) {}

}  // namespace webf