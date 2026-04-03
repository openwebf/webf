import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/src/rendering/event_listener.dart';
import 'package:webf/src/rendering/layout_box.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUp(() {
    setupTest();
  });

  testWidgets('semantics traversal should not visit a dirty transparent event-listener wrapper', (
    WidgetTester tester,
  ) async {
    final html = '''
      <div id="container" style="display: block; width: 220px;">
        <div id="row"
             onclick="void 0"
             class="mb-2 flex min-h-[30px] w-full flex-wrap justify-start text-text-primary"
             style="display: flex; min-height: 30px; width: 100%; flex-wrap: wrap; justify-content: flex-start; margin-bottom: 8px;">
          <span id="text">Order 1</span>
        </div>
      </div>
    ''';

    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '<body>$html</body>',
      controllerName: 'a11y-dirty-wrapper-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) => MaterialApp(home: Scaffold(body: child)),
    );

    final dom.Element container = prepared.getElementById('container');
    final dom.Element row = prepared.getElementById('row');

    final RenderLayoutBox layoutBox =
        container.renderStyle.attachedRenderBoxModel! as RenderLayoutBox;
    final RenderEventListener eventListener = row.attachedRendererEventListener!;

    eventListener.markNeedsLayout();

    final List<RenderObject> visited = <RenderObject>[];
    layoutBox.visitChildrenForSemantics(visited.add);

    expect(eventListener.debugNeedsLayout, isTrue);
    expect(
      visited.any((RenderObject child) => identical(child, eventListener)),
      isFalse,
      reason: 'Semantics traversal should unwrap or skip transparent dirty wrappers.',
    );
  });
}
