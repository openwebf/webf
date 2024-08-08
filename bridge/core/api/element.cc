/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/element.h"
#include "core/dom/container_node.h"

namespace webf {

ElementWebFMethods::ElementWebFMethods(ContainerNodeWebFMethods* super_methods)
    : container_node(super_methods) {}

}  // namespace webf