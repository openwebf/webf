/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/src/bridge/binding_object.dart';
import 'package:webf/widget.dart';

class CharacterData extends Node {
  CharacterData(NodeType type, [context]) : super(type, context);

  @override
  String get nodeName => throw UnimplementedError();

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  RenderBox? get domRenderer => throw UnimplementedError();

  @override
  RenderBox? get attachedRenderer => throw UnimplementedError();

  @override
  flutter.Widget toWidget({Key? key}) {
    return const flutter.SizedBox.shrink();
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
