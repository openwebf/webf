/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';

abstract class CharacterData extends Node {
  CharacterData(super.type, [super.context]);

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

  bool get isRendererAttachedToSegmentTree => false;
}
