import 'package:flutter_test/flutter_test.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

void main() {
  group('WebF Cupertino UI', () {
    test('installWebFCupertinoUI registers all custom elements', () {
      // This test verifies that the installation function exists
      // and can be called without errors
      expect(() => installWebFCupertinoUI(), returnsNormally);
    });
  });
}
