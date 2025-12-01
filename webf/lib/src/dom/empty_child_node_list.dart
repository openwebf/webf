/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'node_list.dart';
import 'node.dart';

class EmptyIterator implements Iterator<Node> {
  @override
  Node get current => throw UnsupportedError('Empty child nodes have no value.');

  @override
  bool moveNext() {
    return false;
  }
}

class EmptyNodeList extends NodeList {
  EmptyNodeList(Node rootNode) : _owner = rootNode;

  final Node _owner;

  @override
  int get length => 0;

  @override
  bool get isEmptyNodeList => true;

  @override
  Node get ownerNode => _owner;

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  Iterator<Node> get iterator => EmptyIterator();

  String hashKey() {
    return '_EMPTY_';
  }
}
