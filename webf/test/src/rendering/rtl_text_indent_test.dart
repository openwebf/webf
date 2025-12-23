import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/rendering.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

RenderFlowLayout _findRenderFlowLayout(RenderObject root) {
  RenderFlowLayout? found;
  void visit(RenderObject child) {
    if (found != null) return;
    if (child is RenderFlowLayout) {
      found = child;
      return;
    }
    child.visitChildren(visit);
  }

  visit(root);
  if (found == null) {
    throw TestFailure('RenderFlowLayout not found under ${root.runtimeType}.');
  }
  return found!;
}

void main() {
  setUpAll(() {
    setupTest();
  });

  testWidgets('RTL text-indent reserves space on inline-start', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '''
        <p id="p"
          style="
            direction: rtl;
            width: 200px;
            text-indent: 32px;
            font-size: 16px;
            padding: 0;
            border: 0;
            margin: 0;
          "
        >
          هذه فقرة باللغة العربية
        </p>
      ''',
    );

    final p = prepared.getElementById('p');
    final RenderBoxModel renderer = p.attachedRenderer!;
    final flow = _findRenderFlowLayout(renderer);
    final ifc = flow.inlineFormattingContext;
    expect(ifc, isNotNull);

    final ui.Paragraph paragraph = ifc!.paragraph!;
    final List<ui.TextBox> placeholders = paragraph.getBoxesForPlaceholders();
    expect(placeholders, isNotEmpty);

    final ui.TextBox indentBox = placeholders.first;
    final double contentWidth = flow.contentConstraints!.maxWidth;

    expect(indentBox.right, closeTo(contentWidth, 0.6));
    expect(indentBox.left, closeTo(contentWidth - 32.0, 1.2));
  });
}

