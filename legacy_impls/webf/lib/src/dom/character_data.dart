/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/foundation/binding.dart';
import 'package:webf/widget.dart';

class CharacterData extends Node {
  CharacterData(NodeType type, [context]) : super(type, context);

  WebFCharacterDataToWidgetAdaptor? _flutterWidget;
  @override
  WebFCharacterDataToWidgetAdaptor? get flutterWidget => _flutterWidget;
  set flutterWidget(WebFCharacterDataToWidgetAdaptor? adapter) {
    _flutterWidget = adapter;
  }

  @override
  String get nodeName => throw UnimplementedError();

  @override
  RenderBox? get renderer => throw UnimplementedError();

  @override
  Future<void> dispose() async {
    super.dispose();
    flutterWidget = null;
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
}
