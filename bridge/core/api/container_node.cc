/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/container_node.h"
#include "core/dom/node.h"

namespace webf {

ContainerNodeWebFMethods::ContainerNodeWebFMethods(NodeWebFMethods* super_method) : node(super_method) {}

}  // namespace webf