/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'node.dart';


abstract class NodeList<T extends Node> extends Iterable<T> {
  // Constructor for NodeList
  NodeList();

  // DOM methods & attributes for NodeList
  bool get isEmptyNodeList => false;

  bool get isChildNodeList => false;

  Node get ownerNode;

  @override
  Iterator<T> get iterator;
}
