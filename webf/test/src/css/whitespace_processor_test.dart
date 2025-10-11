/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
import 'package:webf/src/css/whitespace_processor.dart';

void main() {
  group('WhitespaceProcessor', () {
    group('Character Classification', () {
      test('should identify space characters', () {
        expect(WhitespaceProcessor.isSpace(0x0020), isTrue);
        expect(WhitespaceProcessor.isSpace(0x0009), isFalse); // tab
        expect(WhitespaceProcessor.isSpace(0x000A), isFalse); // line feed
        expect(WhitespaceProcessor.isSpace(0x0041), isFalse); // 'A'
      });

      test('should identify tab characters', () {
        expect(WhitespaceProcessor.isTab(0x0009), isTrue);
        expect(WhitespaceProcessor.isTab(0x0020), isFalse); // space
        expect(WhitespaceProcessor.isTab(0x000A), isFalse); // line feed
      });

      test('should identify segment breaks', () {
        expect(WhitespaceProcessor.isSegmentBreak(0x000A), isTrue); // line feed
        expect(WhitespaceProcessor.isSegmentBreak(0x000D), isTrue); // carriage return
        expect(WhitespaceProcessor.isSegmentBreak(0x0020), isFalse); // space
        expect(WhitespaceProcessor.isSegmentBreak(0x0009), isFalse); // tab
      });

      test('should identify document whitespace', () {
        expect(WhitespaceProcessor.isDocumentWhitespace(0x0020), isTrue); // space
        expect(WhitespaceProcessor.isDocumentWhitespace(0x0009), isTrue); // tab
        expect(WhitespaceProcessor.isDocumentWhitespace(0x000A), isTrue); // line feed
        expect(WhitespaceProcessor.isDocumentWhitespace(0x000D), isTrue); // carriage return
        expect(WhitespaceProcessor.isDocumentWhitespace(0x0041), isFalse); // 'A'
      });

      test('should identify other space separators', () {
        expect(WhitespaceProcessor.isOtherSpaceSeparator(0x1680), isTrue); // OGHAM SPACE MARK
        expect(WhitespaceProcessor.isOtherSpaceSeparator(0x2000), isTrue); // EN QUAD
        expect(WhitespaceProcessor.isOtherSpaceSeparator(0x3000), isTrue); // IDEOGRAPHIC SPACE
        expect(WhitespaceProcessor.isOtherSpaceSeparator(0x0020), isFalse); // regular space
        expect(WhitespaceProcessor.isOtherSpaceSeparator(0x00A0), isFalse); // no-break space
      });
    });

    group('Phase I: Collapsing and Transformation', () {
      test('normal: should collapse whitespace', () {
        expect(
          WhitespaceProcessor.processPhaseOne('  a  b  c  ', WhiteSpace.normal),
          equals(' a b c '),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('a\n\nb\nc', WhiteSpace.normal),
          equals('a b c'),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('  \n  hello  \n  world  \n  ', WhiteSpace.normal),
          equals(' hello world '),
        );
      });

      test('normal: should convert tabs to spaces', () {
        expect(
          WhitespaceProcessor.processPhaseOne('a\tb\tc', WhiteSpace.normal),
          equals('a b c'),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('\t\ta\t\tb\t\t', WhiteSpace.normal),
          equals(' a b '),
        );
      });

      test('normal: should handle segment breaks with adjacent spaces', () {
        expect(
          WhitespaceProcessor.processPhaseOne('a \n b', WhiteSpace.normal),
          equals('a b'),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('a\t\n\tb', WhiteSpace.normal),
          equals('a b'),
        );
      });

      test('normal: should handle multiple consecutive segment breaks', () {
        expect(
          WhitespaceProcessor.processPhaseOne('a\n\n\nb', WhiteSpace.normal),
          equals('a b'),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('a\r\n\r\nb', WhiteSpace.normal),
          equals('a b'),
        );
      });

      test('nowrap: should behave like normal for whitespace processing', () {
        expect(
          WhitespaceProcessor.processPhaseOne('  a  b  c  ', WhiteSpace.nowrap),
          equals(' a b c '),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('a\n\nb\nc', WhiteSpace.nowrap),
          equals('a b c'),
        );
      });

      test('pre: should preserve all whitespace', () {
        expect(
          WhitespaceProcessor.processPhaseOne('  a  b  c  ', WhiteSpace.pre),
          equals('  a  b  c  '),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('a\n\nb\nc', WhiteSpace.pre),
          equals('a\n\nb\nc'),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('\ta\tb\tc\t', WhiteSpace.pre),
          equals('\ta\tb\tc\t'),
        );
      });

      test('pre-wrap: should preserve whitespace like pre', () {
        expect(
          WhitespaceProcessor.processPhaseOne('  a  b  c  ', WhiteSpace.preWrap),
          equals('  a  b  c  '),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('a\n\nb\nc', WhiteSpace.preWrap),
          equals('a\n\nb\nc'),
        );
      });

      test('pre-line: should preserve line breaks but collapse spaces', () {
        expect(
          WhitespaceProcessor.processPhaseOne('  a  b  c  ', WhiteSpace.preLine),
          equals(' a b c '),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('a\n\nb\nc', WhiteSpace.preLine),
          equals('a\n\nb\nc'),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('  a  \n  b  \n  c  ', WhiteSpace.preLine),
          equals(' a \n b \n c '),
        );
      });

      test('break-spaces: should preserve spaces', () {
        expect(
          WhitespaceProcessor.processPhaseOne('  a  b  c  ', WhiteSpace.breakSpaces),
          equals('  a  b  c  '),
        );
        expect(
          WhitespaceProcessor.processPhaseOne('a\n\nb\nc', WhiteSpace.breakSpaces),
          equals('a\n\nb\nc'),
        );
      });

      test('should handle empty strings', () {
        expect(WhitespaceProcessor.processPhaseOne('', WhiteSpace.normal), equals(''));
        expect(WhitespaceProcessor.processPhaseOne('', WhiteSpace.pre), equals(''));
        expect(WhitespaceProcessor.processPhaseOne('', WhiteSpace.preWrap), equals(''));
      });

      test('should handle strings with only whitespace', () {
        expect(WhitespaceProcessor.processPhaseOne('   ', WhiteSpace.normal), equals(' '));
        expect(WhitespaceProcessor.processPhaseOne('\n\n\n', WhiteSpace.normal), equals(' '));
        expect(WhitespaceProcessor.processPhaseOne('\t\t\t', WhiteSpace.normal), equals(' '));
        expect(WhitespaceProcessor.processPhaseOne('   ', WhiteSpace.pre), equals('   '));
        expect(WhitespaceProcessor.processPhaseOne('\n\n\n', WhiteSpace.pre), equals('\n\n\n'));
      });
    });

    group('Phase II: Line Trimming', () {
      test('should trim start of line for normal mode', () {
        expect(LineTrimmer.trimLineStart('  hello', WhiteSpace.normal), equals('hello'));
        expect(LineTrimmer.trimLineStart('  hello', WhiteSpace.nowrap), equals('hello'));
        expect(LineTrimmer.trimLineStart('  hello', WhiteSpace.preLine), equals('hello'));
      });

      test('should not trim start of line for preserved modes', () {
        expect(LineTrimmer.trimLineStart('  hello', WhiteSpace.pre), equals('  hello'));
        expect(LineTrimmer.trimLineStart('  hello', WhiteSpace.preWrap), equals('  hello'));
        expect(LineTrimmer.trimLineStart('  hello', WhiteSpace.breakSpaces), equals('  hello'));
      });

      test('should process line end for normal mode', () {
        final result = LineTrimmer.processLineEnd('hello  ', WhiteSpace.normal, false, false);
        expect(result.trimmedText, equals('hello'));
        expect(result.hangingSpaces.length, equals(2));
        expect(result.hangingSpaces.every((s) => !s.isConditional), isTrue);
      });

      test('should process line end for pre mode', () {
        final result = LineTrimmer.processLineEnd('hello  ', WhiteSpace.pre, false, false);
        expect(result.trimmedText, equals('hello  '));
        expect(result.hangingSpaces, isEmpty);
      });

      test('should process line end for pre-wrap with forced break', () {
        // Without overflow
        final result1 = LineTrimmer.processLineEnd('hello  ', WhiteSpace.preWrap, true, false);
        expect(result1.trimmedText, equals('hello  '));
        expect(result1.hangingSpaces.length, equals(2));
        expect(result1.hangingSpaces.every((s) => s.isConditional), isTrue);

        // With overflow
        final result2 = LineTrimmer.processLineEnd('hello  ', WhiteSpace.preWrap, true, true);
        expect(result2.trimmedText, equals('hello  '));
        expect(result2.hangingSpaces.length, equals(2));
        expect(result2.hangingSpaces.every((s) => s.isConditional), isTrue);
      });

      test('should process line end for pre-wrap without forced break', () {
        final result = LineTrimmer.processLineEnd('hello  ', WhiteSpace.preWrap, false, false);
        expect(result.trimmedText, equals('hello  '));
        expect(result.hangingSpaces.length, equals(2));
        expect(result.hangingSpaces.every((s) => !s.isConditional), isTrue);
      });

      test('should never hang spaces for break-spaces', () {
        final result = LineTrimmer.processLineEnd('hello  ', WhiteSpace.breakSpaces, false, false);
        expect(result.trimmedText, equals('hello  '));
        expect(result.hangingSpaces, isEmpty);
      });
    });
  });
}