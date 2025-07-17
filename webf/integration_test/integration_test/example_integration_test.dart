import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webf/webf.dart';
import '../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Example Integration Tests', () {
    testWidgets('App starts and shows home page', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open React Show Case'));
      await tester.pumpAndSettle();
    });
  });
}
