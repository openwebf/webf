/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';

class Comment extends CharacterData {
  Comment([BindingContext? context]) : super(NodeType.COMMENT_NODE, context);

  @override
  String get nodeName => '#comment';

  // Comment nodes have no renderer or hash key.


  // @TODO: Get data from bridge side.
  String get data => '';

  @override
  int get length => data.length;

  @override
  String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'Comment()';
  }
}
