/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "text.h"
#include "core/dom/character_data.h"

namespace webf {

TextNodeRustMethods::TextNodeRustMethods(CharacterDataRustMethods* super_rust_method)
    : character_data(super_rust_method) {}

}  // namespace webf