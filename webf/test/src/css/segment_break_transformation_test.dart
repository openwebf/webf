/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
import 'package:webf/src/css/whitespace_processor.dart';
import 'package:webf/src/css/east_asian_width.dart';

void main() {
  group('SegmentBreakTransformer', () {
    test('should transform to space for Latin text', () {
      // 'A' (U+0041) and 'B' (U+0042) are Latin characters
      final result = SegmentBreakTransformer.transformSegmentBreak(
        0x0041, // 'A'
        0x0042, // 'B'
        null,
      );
      expect(result, equals(' '));
    });

    test('should remove break between CJK characters', () {
      // Chinese characters
      final result = SegmentBreakTransformer.transformSegmentBreak(
        0x4E2D, // 中
        0x6587, // 文
        null,
      );
      expect(result, isNull);
    });

    test('should remove break between Japanese characters', () {
      // Hiragana characters
      final result = SegmentBreakTransformer.transformSegmentBreak(
        0x3042, // あ
        0x3044, // い
        null,
      );
      expect(result, isNull);

      // Katakana characters
      final result2 = SegmentBreakTransformer.transformSegmentBreak(
        0x30A2, // ア
        0x30A4, // イ
        null,
      );
      expect(result2, isNull);
    });

    test('should keep space between Korean characters', () {
      // Hangul Syllables - Korean uses spaces between words
      final result = SegmentBreakTransformer.transformSegmentBreak(
        0xC774, // 이
        0xC790, // 자
        null,
      );
      expect(result, equals(' ')); // Korean preserves spaces
      
      // Another example
      final result2 = SegmentBreakTransformer.transformSegmentBreak(
        0xAC00, // 가
        0xB098, // 나
        null,
      );
      expect(result2, equals(' '));
    });

    test('should handle ambiguous characters with CJK context', () {
      // Chinese quote with Chinese text
      final result = SegmentBreakTransformer.transformSegmentBreak(
        0x201C, // Left double quotation mark "
        0x4E2D, // 中
        'zh',
      );
      expect(result, isNull);

      // Chinese text with closing quote
      final result2 = SegmentBreakTransformer.transformSegmentBreak(
        0x6587, // 文
        0x201D, // Right double quotation mark "
        'zh',
      );
      expect(result2, isNull);
    });

    test('should handle ambiguous characters without language context', () {
      // Ambiguous quote with CJK should remove break (heuristic)
      final result = SegmentBreakTransformer.transformSegmentBreak(
        0x201C, // Left double quotation mark "
        0x4E2D, // 中
        null,
      );
      expect(result, isNull);
    });

    test('should not remove break for Hangul Jamo', () {
      final result = SegmentBreakTransformer.transformSegmentBreak(
        0x1100, // Hangul Jamo
        0x4E2D, // Chinese character
        null,
      );
      expect(result, equals(' '));
    });

    test('should handle zero-width space', () {
      // Zero-width space always removes the break
      final result = SegmentBreakTransformer.transformSegmentBreak(
        0x200B, // Zero-width space
        0x0041, // 'A'
        null,
      );
      expect(result, isNull);

      final result2 = SegmentBreakTransformer.transformSegmentBreak(
        0x0041, // 'A'
        0x200B, // Zero-width space
        null,
      );
      expect(result2, isNull);
    });
    
  });

  group('WhitespaceProcessor with language context', () {
    test('should handle English text with line breaks', () {
      final input = 'Hello\nworld\nfrom\nWebF';
      final result = WhitespaceProcessor.processPhaseOne(input, WhiteSpace.normal, 'en');
      expect(result, equals('Hello world from WebF'));
    });

    test('should handle Chinese text with line breaks', () {
      final input = '你好\n世界\n来自\nWebF';
      final result = WhitespaceProcessor.processPhaseOne(input, WhiteSpace.normal, 'zh');
      expect(result, equals('你好世界来自 WebF')); // Space before Latin text
    });
    
    test('should handle CJK text with punctuation and line breaks', () {
      final input = '在一行寫不行。最好\n用三行寫。';
      final result = WhitespaceProcessor.processPhaseOne(input, WhiteSpace.normal, 'zh');
      expect(result, equals('在一行寫不行。最好用三行寫。')); // No space - both are CJK
    });

    test('should handle mixed English and Chinese text', () {
      final input = 'Hello\n你好\nworld\n世界';
      final result = WhitespaceProcessor.processPhaseOne(input, WhiteSpace.normal, 'zh');
      expect(result, equals('Hello 你好 world 世界'));
    });

    test('should handle Chinese text with quotation marks', () {
      final input = '他说：\n"你好\n世界"';
      final result = WhitespaceProcessor.processPhaseOne(input, WhiteSpace.normal, 'zh');
      expect(result, equals('他说："你好世界"')); // No space - colon and quote are both treated as CJK
    });

    test('should handle Japanese text with line breaks', () {
      final input = 'こんにちは\n世界\nから\nWebF';
      final result = WhitespaceProcessor.processPhaseOne(input, WhiteSpace.normal, 'ja');
      expect(result, equals('こんにちは世界から WebF')); // Space before Latin text
    });

    test('should handle Korean text with line breaks', () {
      final input = '안녕하세요\n세계\n에서\nWebF';
      final result = WhitespaceProcessor.processPhaseOne(input, WhiteSpace.normal, 'ko');
      expect(result, equals('안녕하세요 세계 에서 WebF')); // Korean preserves spaces between words
    });

    test('should preserve line breaks in pre-line mode', () {
      final input = '你好\n世界\n来自\nWebF';
      final result = WhitespaceProcessor.processPhaseOne(input, WhiteSpace.preLine, 'zh');
      expect(result, equals('你好\n世界\n来自\nWebF'));
    });
  });

  group('EastAsianWidth', () {
    test('should classify CJK characters as Wide', () {
      expect(EastAsianWidth.getEastAsianWidth(0x4E2D), equals('W')); // 中
      expect(EastAsianWidth.getEastAsianWidth(0x3042), equals('W')); // あ
      expect(EastAsianWidth.getEastAsianWidth(0x30A2), equals('W')); // ア
      expect(EastAsianWidth.getEastAsianWidth(0xAC00), equals('W')); // 가
    });

    test('should classify fullwidth characters', () {
      expect(EastAsianWidth.getEastAsianWidth(0xFF21), equals('F')); // Ａ
      expect(EastAsianWidth.getEastAsianWidth(0x3000), equals('F')); // Ideographic space
    });

    test('should classify halfwidth characters', () {
      expect(EastAsianWidth.getEastAsianWidth(0xFF61), equals('H')); // ｡
      expect(EastAsianWidth.getEastAsianWidth(0xFF9D), equals('H')); // ﾝ
    });

    test('should classify ambiguous characters', () {
      expect(EastAsianWidth.getEastAsianWidth(0x201C), equals('A')); // "
      expect(EastAsianWidth.getEastAsianWidth(0x201D), equals('A')); // "
      expect(EastAsianWidth.getEastAsianWidth(0x0028), equals('A')); // (
      expect(EastAsianWidth.getEastAsianWidth(0x0029), equals('A')); // )
    });

    test('should classify narrow characters', () {
      expect(EastAsianWidth.getEastAsianWidth(0x0041), equals('Na')); // A
      expect(EastAsianWidth.getEastAsianWidth(0x0061), equals('Na')); // a
      expect(EastAsianWidth.getEastAsianWidth(0x0030), equals('Na')); // 0
    });
  });
}