/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/document_fragment.h"
#include "core/dom/container_node.h"

namespace webf {

DocumentFragmentWebFMethods::DocumentFragmentWebFMethods(ContainerNodeWebFMethods* super_methods)
    : container_node(super_methods) {}

}  // namespace webf
