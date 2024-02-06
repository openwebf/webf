/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/dom/container_node.h"
#include "element.h"

namespace webf {

ElementRustMethods::ElementRustMethods() {
  container_node = ContainerNode::rustMethodPointer();
}

}