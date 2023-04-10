/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'node_list.dart';
import 'child_node_list.dart';
import 'container_node.dart';
import 'empty_child_node_list.dart';
import 'node.dart';

class NodeData {
  NodeList? _node_list;

  ChildNodeList ensureChildNodeList(ContainerNode node) {
    _node_list ??= ChildNodeList(node);
    return _node_list! as ChildNodeList;
  }

  NodeList ensureEmptyChildNodeList(Node node) {
    _node_list ??= EmptyNodeList(node);
    return _node_list!;
  }
}
