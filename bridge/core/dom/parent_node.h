/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_BINDINGS_QJS_BOM_PARENT_NODE_H_
#define BRIDGE_BINDINGS_QJS_BOM_PARENT_NODE_H_

#include "foundation/macros.h"

namespace webf {

class ParentNode {
  WEBF_STATIC_ONLY(ParentNode);
 public:

  static std::vector<Element*> children(ContainerNode& node) {
    return node.Children();
  }
};

}

#endif
