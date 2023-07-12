/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'node_list.dart';
import 'child_node_list.dart';
import 'container_node.dart';
import 'empty_child_node_list.dart';
import 'node.dart';

class NodeData {
  NodeList? _nodeList;
  NodeList? get nodeList => _nodeList;

  ChildNodeList ensureChildNodeList(ContainerNode node) {
    _nodeList ??= ChildNodeList(node);
    return _nodeList! as ChildNodeList;
  }

  NodeList ensureEmptyChildNodeList(Node node) {
    _nodeList ??= EmptyNodeList(node);
    return _nodeList!;
  }
}
