/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';

class Comment extends CharacterData {
  Comment() : super(NodeType.COMMENT_NODE, null);

  @override
  String get nodeName => '#comment';

  @override
  RenderBox? get domRenderer => null;

  // @TODO: Get data from bridge side.
  String get data => '';

  @override
  int get length => data.length;

  @override
  String toString() {
    return 'Comment()';
  }
}
