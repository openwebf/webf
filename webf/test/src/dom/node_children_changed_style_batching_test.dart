/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:webf/dom.dart';

class MockDocument extends Mock implements Document {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => 'MockDocument';
}

class TestNode extends Node {
  final Document _document;

  TestNode(this._document) : super(NodeType.ELEMENT_NODE);

  @override
  Document get ownerDocument => _document;

  @override
  String get nodeName => 'TEST';

  @override
  Node? get firstChild => null;

  @override
  Node? get lastChild => null;

  @override
  RenderBox? get attachedRenderer => null;

  @override
  bool get isRendererAttached => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Node.childrenChanged style batching', () {
    test('schedules style update instead of flushing synchronously', () {
      final doc = MockDocument();
      final node = TestNode(doc)..isConnected = true;

      node.childrenChanged(ChildrenChange(
        type: ChildrenChangeType.ELEMENT_INSERTED,
        byParser: ChildrenChangeSource.API,
        affectsElements: ChildrenChangeAffectsElements.YES,
      ));

      verify(doc.scheduleStyleUpdate()).called(1);
      verifyNever(doc.updateStyleIfNeeded());
    });

    test('does nothing when node is disconnected', () {
      final doc = MockDocument();
      final node = TestNode(doc)..isConnected = false;

      node.childrenChanged(ChildrenChange(
        type: ChildrenChangeType.ELEMENT_INSERTED,
        byParser: ChildrenChangeSource.API,
        affectsElements: ChildrenChangeAffectsElements.YES,
      ));

      verifyNever(doc.scheduleStyleUpdate());
      verifyNever(doc.updateStyleIfNeeded());
    });
  });
}
