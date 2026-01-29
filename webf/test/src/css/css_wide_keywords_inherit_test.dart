import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
import '../../setup.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  test('CSSStyleDeclaration accepts `inherit` for inset properties', () {
    final style = CSSStyleDeclaration();

    style.setProperty(TOP, INHERIT);
    style.setProperty(RIGHT, INHERIT);
    style.setProperty(BOTTOM, INHERIT);
    style.setProperty(LEFT, INHERIT);

    expect(style.getPropertyValue(TOP), INHERIT);
    expect(style.getPropertyValue(RIGHT), INHERIT);
    expect(style.getPropertyValue(BOTTOM), INHERIT);
    expect(style.getPropertyValue(LEFT), INHERIT);
  });
}
