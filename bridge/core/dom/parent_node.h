/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_BOM_PARENT_NODE_H_
#define BRIDGE_BINDINGS_QJS_BOM_PARENT_NODE_H_

#include <cstdint>
#include <vector>
#include "foundation/macros.h"

namespace webf {

class Element;
class ContainerNode;

class ParentNode {
  WEBF_STATIC_ONLY(ParentNode);

 public:
  static Element* firstElementChild(ContainerNode& node);
  static Element* lastElementChild(ContainerNode& node);
  static std::vector<Element*> children(ContainerNode& node);
  static int64_t childElementCount(ContainerNode& node);
};

}  // namespace webf

#endif
