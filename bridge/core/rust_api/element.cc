/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "element.h"
#include "core/dom/container_node.h"

namespace webf {

ElementRustMethods::ElementRustMethods(ContainerNodeRustMethods* super_rust_methods)
    : container_node(super_rust_methods) {}

}  // namespace webf