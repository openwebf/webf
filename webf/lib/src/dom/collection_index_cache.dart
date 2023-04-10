/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'node.dart';
import 'child_node_list.dart';

class CollectionIndexCache<Collection extends ChildNodeList, NodeType extends Node> {
  NodeType? _currentNode;
  int _cachedNodeCount;
  int _cachedNodeIndex;
  bool _isLengthCacheValid;

  CollectionIndexCache()
      : _currentNode = null,
        _cachedNodeCount = 0,
        _cachedNodeIndex = 0,
        _isLengthCacheValid = false;

  bool isEmpty(Collection collection) {
    if (isLengthCacheValid()) return _cachedNodeCount == 0;
    if (_currentNode != null) return false;
    return nodeAt(collection, 0) == null;
  }

  bool hasExactlyOneNode(Collection collection) {
    if (isLengthCacheValid()) return _cachedNodeCount == 1;
    if (_currentNode != null) return _cachedNodeIndex == 0 && nodeAt(collection, 1) == null;
    return nodeAt(collection, 0) != null && nodeAt(collection, 1) == null;
  }

  int nodeCount(Collection collection) {
    if (isLengthCacheValid()) return _cachedNodeCount;
    nodeAt(collection, 0xFFFFFFFF);
    assert(isLengthCacheValid());
    return _cachedNodeCount;
  }

  NodeType? nodeAt(Collection collection, int index) {
    if (isLengthCacheValid() && index >= _cachedNodeCount) return null;

    if (_currentNode != null) {
      if (index > _cachedNodeIndex) return _nodeAfterCachedNode(collection, index);
      if (index < _cachedNodeIndex) return _nodeBeforeCachedNode(collection, index);
      return _currentNode;
    }
    // No valid cache yet, let's find the first matching element.
    NodeType? firstNode = collection.traverseToFirst();
    if (firstNode == null) {
      // The collection is empty.
      _setCachedNodeCount(0);
      return null;
    }
    _setCachedNode(firstNode, 0);
    return index != 0 ? _nodeAfterCachedNode(collection, index) : firstNode;
  }

  void invalidate() {
    _currentNode = null;
    _isLengthCacheValid = false;
  }

  void nodeInserted() {
    _cachedNodeCount++;
    _currentNode = null;
  }

  void nodeRemoved() {
    _cachedNodeCount--;
    _currentNode = null;
  }

  NodeType? _nodeBeforeCachedNode(Collection collection, int index) {
    assert(_currentNode != null); // Cache should be valid.
    List<int> currentIndex = [_cachedNodeIndex];
    assert(currentIndex[0] > index);
    // Determine if we should traverse from the beginning of the collection
    // instead of the cached node.
    bool firstIsCloser = index < currentIndex[0] - index;
    if (firstIsCloser || !collection.canTraverseBackward) {
      NodeType? firstNode = collection.traverseToFirst();
      assert(firstNode != null);
      _setCachedNode(firstNode, 0);
      return index != 0 ? _nodeAfterCachedNode(collection, index) : firstNode;
    }
    // Backward traversal from the cached node to the requested index.
    assert(collection.canTraverseBackward);
    NodeType? currentNode = collection.traverseBackwardToOffset(index, _currentNode!, currentIndex);
    assert(currentNode != null);
    _setCachedNode(currentNode, currentIndex[0]);
    return currentNode;
  }

  NodeType? _nodeAfterCachedNode(Collection collection, int index) {
    assert(_currentNode != null); // Cache should be valid.
    List<int> currentIndex = [_cachedNodeIndex];
    assert(currentIndex[0] < index);

    // Determine if we should traverse from the end of the collection instead of
    // the cached node.
    bool lastIsCloser = _isLengthCacheValid && _cachedNodeCount - index < index - currentIndex[0];
    if (lastIsCloser && collection.canTraverseBackward) {
      NodeType? lastItem = collection.traverseToLast();
      assert(lastItem != null);
      _setCachedNode(lastItem, _cachedNodeCount - 1);
      if (index < _cachedNodeCount - 1) return _nodeBeforeCachedNode(collection, index);
      return lastItem;
    }
    // Forward traversal from the cached node to the requested index.
    NodeType? currentNode = collection.traverseForwardToOffset(index, _currentNode!, currentIndex);
    if (currentNode == null) {
      // Did not find the node. On the plus side, we now know the length.
      if (_isLengthCacheValid) assert(currentIndex[0] + 1 == _cachedNodeCount);
      _setCachedNodeCount(currentIndex[0] + 1);
      return null;
    }

    _setCachedNode(currentNode, currentIndex[0]);
    return currentNode;
  }

  bool isLengthCacheValid() => _isLengthCacheValid;

  int cachedNodeCount() => _cachedNodeCount;

  void _setCachedNodeCount(int length) {
    _cachedNodeCount = length;
    _isLengthCacheValid = true;
  }

  NodeType? cachedNode() => _currentNode;

  int cachedNodeIndex() {
    assert(_currentNode != null);
    return _cachedNodeIndex;
  }

  void _setCachedNode(NodeType? node, int index) {
    assert(node != null);
    _currentNode = node;
    _cachedNodeIndex = index;
  }

  Iterator<NodeType> get iterator => throw UnimplementedError();
}
