/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/dom.dart';

class HTMLCollectionIterator extends Iterator<Element> {
  final HTMLCollection collection;
  HTMLCollectionIterator(this.collection);
  Element? _current;

  @override
  Element get current => _current!;

  @override
  bool moveNext() {
    Node? node;
    if (_current == null) {
      node = collection.ownerElement.firstChild;
    } else {
      node = _current!.nextSibling;
    }

    while(node != null) {
      if (node is Element) {
        _current = node;
        return true;
      }
      node = node.nextSibling;
    }

    return false;
  }
}

class HTMLCollection extends Iterable<Element> {
  final Element ownerElement;

  HTMLCollection(this.ownerElement);

  @override
  Iterator<Element> get iterator => HTMLCollectionIterator(this);
}
