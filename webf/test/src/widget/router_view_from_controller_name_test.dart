import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';

import '../../setup.dart';

class _LifecycleProbe extends StatefulWidget {
  const _LifecycleProbe({required this.onDispose});

  final VoidCallback onDispose;

  @override
  State<_LifecycleProbe> createState() => _LifecycleProbeState();
}

class _LifecycleProbeState extends State<_LifecycleProbe> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

void main() {
  setUp(() {
    setupTest();
  });

  testWidgets('WebFRouterView.fromControllerName keeps subtree alive on rebuild when controller is evaluated',
      (WidgetTester tester) async {
    final controllerName = 'router-view-test-${DateTime.now().millisecondsSinceEpoch}';

    await tester.runAsync(() async {
      final created = await WebFControllerManager.instance.addWithPreload(
        name: controllerName,
        createController: () => WebFController(viewportWidth: 360, viewportHeight: 640),
        bundle: WebFBundle.fromContent('<div></div>', url: 'test://$controllerName/', contentType: htmlContentType),
      );
      created!.evaluated = true;
    });

    var disposeCount = 0;
    Widget buildApp() {
      return MaterialApp(
        home: WebFRouterView.fromControllerName(
          controllerName: controllerName,
          path: '/a',
          builder: (context, controller) => _LifecycleProbe(
            onDispose: () => disposeCount++,
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp());
    await tester.pump();
    expect(find.byType(_LifecycleProbe), findsOneWidget);
    expect(disposeCount, 0);

    // Simulate a declarative router rebuild (e.g. go_router rebuilding the pages list).
    // Previously this could transiently switch to a loading widget and dispose the subtree.
    await tester.pumpWidget(buildApp());
    await tester.pump();
    expect(find.byType(_LifecycleProbe), findsOneWidget);
    expect(disposeCount, 0);
  });
}
