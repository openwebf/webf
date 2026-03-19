/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:webf/dom.dart';

class MockDocument extends Mock implements Document {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'MockDocument';
}

class MockElement extends Mock implements Element {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'MockElement';
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

  group('pruneNestedDirtyStyleElements', () {
    test('drops dirty descendants covered by an ancestor subtree recalc', () {
      final outer = MockElement();
      final middle = MockElement();
      final inner = MockElement();

      when(outer.pointer).thenReturn(Pointer.fromAddress(1));
      when(outer.parentElement).thenReturn(null);

      when(middle.pointer).thenReturn(Pointer.fromAddress(2));
      when(middle.parentElement).thenReturn(outer);

      when(inner.pointer).thenReturn(Pointer.fromAddress(3));
      when(inner.parentElement).thenReturn(middle);

      final effectiveDirty =
          pruneNestedDirtyStyleElements(<MapEntry<Element, bool>>[
        MapEntry<Element, bool>(outer, true),
        MapEntry<Element, bool>(middle, true),
        MapEntry<Element, bool>(inner, false),
      ]);

      expect(effectiveDirty.map((entry) => entry.key),
          orderedEquals(<Element>[outer]));
      expect(effectiveDirty.single.value, isTrue);
    });

    test('keeps dirty elements when no ancestor subtree rebuild covers them',
        () {
      final outer = MockElement();
      final middle = MockElement();

      when(outer.pointer).thenReturn(Pointer.fromAddress(11));
      when(outer.parentElement).thenReturn(null);

      when(middle.pointer).thenReturn(Pointer.fromAddress(12));
      when(middle.parentElement).thenReturn(outer);

      final effectiveDirty =
          pruneNestedDirtyStyleElements(<MapEntry<Element, bool>>[
        MapEntry<Element, bool>(outer, false),
        MapEntry<Element, bool>(middle, true),
      ]);

      expect(
        effectiveDirty.map((entry) => entry.key),
        orderedEquals(<Element>[outer, middle]),
      );
    });
  });
}
