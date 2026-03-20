import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
import 'package:webf/html.dart';

import '../../setup.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('CSSRenderStyle parsed value cache', () {
    test('reuses parse-time objects for context-free values', () {
      final CSSRenderStyle firstStyle = CSSRenderStyle(target: HTMLElement(null));
      final CSSRenderStyle secondStyle =
          CSSRenderStyle(target: HTMLElement(null));

      final List<String> firstValue = firstStyle.resolveValue(
          TRANSITION_PROPERTY, 'opacity, transform') as List<String>;
      final List<String> secondValue = secondStyle.resolveValue(
          TRANSITION_PROPERTY, 'opacity, transform') as List<String>;

      expect(identical(firstValue, secondValue), isTrue);
      expect(firstValue, <String>['opacity', 'transform']);
    });

    test('resolves relative lengths per render style', () {
      final CSSRenderStyle firstStyle = CSSRenderStyle(target: HTMLElement(null));
      final CSSRenderStyle secondStyle =
          CSSRenderStyle(target: HTMLElement(null));

      firstStyle.fontSize = CSSLengthValue(10, CSSLengthType.PX);
      secondStyle.fontSize = CSSLengthValue(20, CSSLengthType.PX);

      final CSSLengthValue firstValue =
          firstStyle.resolveValue(WIDTH, '2em') as CSSLengthValue;
      final CSSLengthValue secondValue =
          secondStyle.resolveValue(WIDTH, '2em') as CSSLengthValue;

      expect(identical(firstValue, secondValue), isFalse);
      expect(firstValue.computedValue, 20);
      expect(secondValue.computedValue, 40);
    });
  });
}
