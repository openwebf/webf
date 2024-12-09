/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/src/foundation/binding.dart';
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
  flutter.Widget toWidget() {
    return const flutter.SizedBox.shrink();
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
  }

  @override
  Node? get firstChild => null;

  @override
  Node? get lastChild => null;

  @override
  bool get isRendererAttached => throw UnimplementedError();

  @override
  bool get isRendererAttachedToSegmentTree => throw UnimplementedError();
}
