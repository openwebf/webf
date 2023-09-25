/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';
import 'package:webf/dom.dart';

class NthIndexCache {
  final LinkedLruHashMap<ContainerNode, Map<int, int>> _cacheElementIndex = LinkedLruHashMap(maximumSize: 500);

  int? getChildrenIndexFromCache(ContainerNode parent, Element current, String selectorName) {
    if (!_cacheElementIndex.containsKey(parent)) {
      return null;
    }
    int key = hash2(current.hashCode, selectorName);
    return _cacheElementIndex[parent]![key];
  }

  void setChildrenIndexWithParentNode(ContainerNode parent, Element current, String selectorName, int index) {
    if (!_cacheElementIndex.containsKey(parent)) {
      _cacheElementIndex[parent] = {};
    }
    int key = hash2(current.hashCode, selectorName);
    _cacheElementIndex[parent]![key] = index;
  }

  void invalidateWithParentNode(ContainerNode parent) {
    _cacheElementIndex.remove(parent);
  }

  void clearAll() {
    _cacheElementIndex.clear();
  }
}
