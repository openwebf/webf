import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/launcher/render_tree_dump_storage.dart';

import '../../setup.dart';

void main() {
  setupTest();

  group('render tree dump storage', () {
    test('persists dumps into the provided directory', () async {
      final Directory tempDir =
          await Directory.systemTemp.createTemp('webf-render-tree-dump');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final String filePath = await writeRenderTreeDumpToFile(
        'render tree contents',
        routePath: 'foo/bar baz',
        outputDirectory: tempDir,
      );

      final File outputFile = File(filePath);
      expect(await outputFile.exists(), isTrue);
      expect(outputFile.uri.pathSegments.last,
          startsWith('render_tree_foo_bar_baz_'));
      expect(await outputFile.readAsString(), 'render tree contents');
    });

    test('flags oversized dumps for file persistence', () {
      expect(
        shouldPersistRenderTreeDumpToFile(
          ''.padLeft(kRenderTreeClipboardSoftLimit, 'a'),
        ),
        isFalse,
      );
      expect(
        shouldPersistRenderTreeDumpToFile(
          ''.padLeft(kRenderTreeClipboardSoftLimit + 1, 'a'),
        ),
        isTrue,
      );
    });

    test('builds adb pull command for android app storage dumps', () {
      expect(
        buildAndroidRenderTreeDumpPullCommand(
          '/data/user/0/com.example.app/app_flutter/WebF_Debug/render_tree_root_123.txt',
        ),
        'adb shell run-as com.example.app cat app_flutter/WebF_Debug/render_tree_root_123.txt > render_tree_root_123.txt',
      );
      expect(
        buildAndroidRenderTreeDumpPullCommand(
          '/tmp/render_tree_root_123.txt',
        ),
        isNull,
      );
    });
  });
}
