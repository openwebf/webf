import 'dart:ui';

import 'package:test/test.dart';
import 'package:webf/css.dart';

void main() {
  group('CSSColor', () {
    test('parses hex colors', () {
      expect(CSSColor.parseColor('#abc')!.value, const Color(0xFFAABBCC).value);
      expect(CSSColor.parseColor('#abcd')!.value, const Color(0xDDAABBCC).value);
      expect(CSSColor.parseColor('#AABBCC')!.value, const Color(0xFFAABBCC).value);
      expect(CSSColor.parseColor('#AABBCCDD')!.value, const Color(0xDDAABBCC).value);
    });

    test('parses rgb()/rgba() comma and space syntaxes', () {
      expect(CSSColor.parseColor('rgb(255,0,128)')!.value, const Color(0xFFFF0080).value);
      expect(CSSColor.parseColor('rgb(255 0 128)')!.value, const Color(0xFFFF0080).value);
      expect(
        CSSColor.parseColor('rgba(255, 0, 128, 0.5)')!.value,
        Color.fromRGBO(255, 0, 128, 0.5).value,
      );
      expect(
        CSSColor.parseColor('rgb(255 0 128 / 50%)')!.value,
        Color.fromRGBO(255, 0, 128, 0.5).value,
      );
    });

    test('parses hsl()/hsla() comma and space syntaxes', () {
      expect(CSSColor.parseColor('hsl(0, 100%, 50%)')!.value, const Color(0xFFFF0000).value);
      expect(CSSColor.parseColor('hsl(120 100% 50%)')!.value, const Color(0xFF00FF00).value);
      expect(
        CSSColor.parseColor('hsla(240, 100%, 50%, 0.25)')!.value,
        Color.fromRGBO(0, 0, 255, 0.25).value,
      );
      expect(
        CSSColor.parseColor('hsl(240 100% 50% / 0.25)')!.value,
        Color.fromRGBO(0, 0, 255, 0.25).value,
      );
    });
  });
}

