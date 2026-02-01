import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart' as webf_rendering;

class _TestLeafRenderObjectWidget extends LeafRenderObjectWidget {
  const _TestLeafRenderObjectWidget({super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderConstrainedBox(
      additionalConstraints: BoxConstraints.tight(const Size(1, 1)),
    );
  }
}

class _TestRenderBoxModel extends webf_rendering.RenderBoxModel {
  _TestRenderBoxModel({required super.renderStyle});

  @override
  void calculateBaseline() {}

  @override
  void performLayout() {
    size = constraints.constrain(const Size(1, 1));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Element keeps renderStyle pairing until didDetachRenderer', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: const [
            _TestLeafRenderObjectWidget(key: ValueKey('k1')),
            _TestLeafRenderObjectWidget(key: ValueKey('k2')),
          ],
        ),
      ),
    );

    final roElement1 =
        tester.element(find.byKey(const ValueKey('k1'))) as RenderObjectElement;
    final roElement2 =
        tester.element(find.byKey(const ValueKey('k2'))) as RenderObjectElement;

    final el = HTMLElement();
    final rs = el.renderStyle;

    rs.addOrUpdateWidgetRenderObjects(roElement1, _TestRenderBoxModel(renderStyle: rs));
    rs.addOrUpdateWidgetRenderObjects(roElement2, _TestRenderBoxModel(renderStyle: rs));

    expect(rs.hasRenderBox(), isTrue);
    expect(rs.getWidgetPairedRenderBoxModel(roElement1), isNotNull);
    expect(rs.getWidgetPairedRenderBoxModel(roElement2), isNotNull);

    el.willDetachRenderer(roElement1);
    // Pairing should remain until `didDetachRenderer`, because Flutter can still
    // hit-test the render tree during unmount.
    expect(rs.getWidgetPairedRenderBoxModel(roElement1), isNotNull);

    el.didDetachRenderer(roElement1);
    expect(rs.getWidgetPairedRenderBoxModel(roElement1), isNull);
    expect(rs.getWidgetPairedRenderBoxModel(roElement2), isNotNull);
  });
}
