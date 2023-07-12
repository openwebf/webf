/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_NODE_DATA_H_
#define BRIDGE_CORE_DOM_NODE_DATA_H_

#include <cinttypes>
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

class ChildNodeList;
class EmptyNodeList;
class ContainerNode;
class NodeList;
class Node;

class NodeData {
 public:
  enum class ClassType : uint8_t {
    kNodeRareData,
    kElementRareData,
  };

  ChildNodeList* GetChildNodeList(ContainerNode& node);

  ChildNodeList* EnsureChildNodeList(ContainerNode& node);
  NodeList* NodeLists() { return child_node_list_; }

  EmptyNodeList* EnsureEmptyChildNodeList(Node& node);

  void Trace(GCVisitor* visitor) const;

 private:
  Member<NodeList> child_node_list_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_NODE_DATA_H_
