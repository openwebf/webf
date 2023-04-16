/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/dom.dart';

class InclusiveDescendantsOfIterator<T extends Node> extends Iterator<T> {
  T? _current;
  final T? _root;

  InclusiveDescendantsOfIterator(this._root);

  @override
  T get current => _current!;

  @override
  bool moveNext() {
    if (_current == null) {
      _current = _root;
      return true;
    }

    if (current.hasChildren()) {
      _current = current.firstChild as T?;
      return true;
    }
    if (current.nextSibling != null) {
      _current = current.nextSibling as T?;
      return true;
    }
    _current = NodeTraversal.nextAncestorSibling(current) as T?;
    return _current != null;
  }
}

class InclusiveDescendantsOfIterable<T extends Node> extends Iterable<T> {
  final T? _root;
  InclusiveDescendantsOfIterable(this._root);

  @override
  Iterator<T> get iterator => InclusiveDescendantsOfIterator(_root);
}

class AncestorsOfTraversal<T extends Node> extends Iterator<T> {
  T? _current;

  AncestorsOfTraversal(this._current);

  @override
  T get current => _current!;

  @override
  bool moveNext() {
    _current = _current?.parentNode as T?;
    return _current != null;
  }
}

class AncestorOfIterable<T extends Node> extends Iterable<T> {
  final T? _root;
  AncestorOfIterable(this._root);

  @override
  Iterator<T> get iterator => AncestorsOfTraversal<T>(_root);
}

class NodeTraversal {
  static Node? nextAncestorSibling(Node current) {
    assert(current.nextSibling == null);
    for (Node parent in ancestorsOf(current)) {
      if (parent.nextSibling != null) {
        return parent.nextSibling;
      }
    }
    return null;
  }

  static Iterable<Node> ancestorsOf(Node node) {
    return AncestorOfIterable(node);
  }

  static Iterable<Node> inclusiveDescendantsOf(Node node) {
    return InclusiveDescendantsOfIterable(node);
  }
}

