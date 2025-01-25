/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart' as flutter;
import 'node.dart';
import 'element.dart';
import 'node_list.dart';
import 'container_node.dart';
import 'collection_index_cache.dart';

class _ChildNodeListIterator extends Iterator<Node> {
  final ChildNodeList collection;
  int _index = -1;
  Node? _current;

  _ChildNodeListIterator(this.collection);

  @override
  Node get current {
    return _current!;
  }

  @override
  bool moveNext() {
    if (_current == null) {
      _current = collection.ownerNode.firstChild;
      if (_current == null) return false;
    } else {
      _current = collection.traverseForwardToOffset(_index + 1, _current!, [_index]);
    }
    _index++;
    return _current != null;
  }
}

class ChildNodeList extends NodeList {
  ChildNodeList(ContainerNode rootNode)
      : _owner = rootNode,
        _collectionIndexCache = CollectionIndexCache<ChildNodeList, Node>();

  final ContainerNode _owner;
  final CollectionIndexCache<ChildNodeList, Node> _collectionIndexCache;
  List<flutter.Widget>? _cachedWidgetList;

  @override
  int get length => _collectionIndexCache.nodeCount(this);

  @override
  bool get isChildNodeList => true;

  @override
  Node get ownerNode => _owner;

  Node? item(int index) {
    return _collectionIndexCache.nodeAt(this, index);
  }

  List<flutter.Widget> toWidgetList() {
    // if (_cachedWidgetList != null) {
    //   return _cachedWidgetList!;
    // }
    List<flutter.Widget> result = map((node) => node.toWidget()).toList();
    return result;
  }

  void childrenChanged(ChildrenChange change) {
    if (change.isChildInsertion()) {
      _collectionIndexCache.nodeInserted();
    } else if (change.isChildRemoval()) {
      _collectionIndexCache.nodeRemoved();
    } else {
      _collectionIndexCache.invalidate();
    }
    _cachedWidgetList = null;
  }

  void invalidateCache() {
    _collectionIndexCache.invalidate();
    _cachedWidgetList = null;
  }

  bool get canTraverseBackward => true;

  T? traverseToFirst<T extends Node>() => _owner.firstChild as T?;
  T? traverseToLast<T extends Node>() => _owner.lastChild as T?;

  T? traverseForwardToOffset<T extends Node>(int offset, Node currentNode, List<int> currentOffset) {
    assert(currentOffset.length == 1);
    assert(currentOffset[0] < offset);
    assert(ownerNode.childNodes == this);
    assert(ownerNode == currentNode.parentNode);
    Node? next = currentNode.nextSibling;
    while (next != null) {
      currentOffset[0]++;
      if (currentOffset[0] == offset) {
        return next as T?;
      }
      next = next.nextSibling;
    }
    return null;
  }

  T? traverseBackwardToOffset<T extends Node>(int offset, Node currentNode, List<int> currentOffset) {
    assert(currentOffset.length == 1);
    assert(currentOffset[0] > offset);
    assert(ownerNode.childNodes == this);
    assert(ownerNode == currentNode.parentNode);
    Node? previous = currentNode.previousSibling;
    while (previous != null) {
      currentOffset[0]--;
      if (currentOffset[0] == offset) {
        return previous as T?;
      }
      previous = previous.previousSibling;
    }
    return null;
  }

  @override
  bool get isEmpty => _collectionIndexCache.isEmpty(this);

  @override
  bool get isNotEmpty => !_collectionIndexCache.isEmpty(this);

  @override
  Iterator<Node> get iterator => _ChildNodeListIterator(this);

  @override
  String hashKey() {
    String key = '';
    for (int i = 0; i < length; i ++) {
      key += '_' + elementAt(i).hashKey;
    }
    return key;
  }
}
