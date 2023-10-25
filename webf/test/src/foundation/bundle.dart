/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:webf/foundation.dart';

void main() {
  group('Bundle', () {
    test('FileBundle basic', () async {
      var filename = '${Directory.current.path}/example/assets/bundle.js';
      var bundle = FileBundle('file://$filename');
      await bundle.resolve();

      expect(bundle.isResolved, true);
    });

    test('DataBundle string', () async {
      var content = 'hello world';
      var bundle = DataBundle.fromString(content, 'about:blank');
      await bundle.resolve();
      expect(bundle.isResolved, true);
      expect(utf8.decode(bundle.data!), content);
    });

    test('DataBundle with non-latin string', () async {
      var content = '你好,世界😈';
      var bundle = DataBundle.fromString(content, 'about:blank');
      await bundle.resolve();
      expect(bundle.isResolved, true);
      expect(utf8.decode(bundle.data!), content);
    });

    test('DataBundle data', () async {
      Uint8List bytecode = Uint8List.fromList(List.generate(10, (index) => index, growable: false));
      var bundle = DataBundle(bytecode, 'about:blank');
      await bundle.resolve();
      expect(bundle.isResolved, true);
      expect(bundle.data, bytecode);
    });

    test('WebFBundle', () async {
      Uint8List bytecode = Uint8List.fromList(List.generate(10, (index) => index, growable: false));
      var bundle = WebFBundle.fromBytecode(bytecode);
      await bundle.resolve();
      expect(bundle.contentType.mimeType, 'application/vnd.webf.bc1');
    });
  });
}
