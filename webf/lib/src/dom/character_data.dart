/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';

abstract class CharacterData extends Node {
  CharacterData(NodeType type, [context]) : super(type, context);

  @override
  String get nodeName => throw UnimplementedError();

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  RenderBox? get attachedRenderer => null;

  @override
  flutter.Widget toWidget({Key? key}) {
    return flutter.ConstrainedBox(constraints: BoxConstraints(maxWidth: 0, minHeight: 0, minWidth: 0, maxHeight: 0));
  }

  @override
  Node? get firstChild => null;

  @override
  Node? get lastChild => null;

  @override
  bool get isRendererAttached => false;

  @override
  bool get isRendererAttachedToSegmentTree => false;
}
