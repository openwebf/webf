import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/html.dart' as html;
import 'package:webf/painting.dart';
import 'package:webf/webf.dart';

import '../../setup.dart';

Future<void> _waitUntil(bool Function() predicate, {Duration timeout = const Duration(seconds: 3)}) async {
  final DateTime end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (predicate()) return;
    await Future.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for condition');
}

void main() {
  setUp(() {
    setupTest();
  });

  test('img should prefetch/decode during prerendering (no Flutter attachment)', () async {
    final String name = 'prerender-img-${DateTime.now().microsecondsSinceEpoch}';
    final WebFBundle bundle = WebFBundle.fromContent(
      '''
      <html>
        <body>
          <img id="img" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2L0VQAAAAASUVORK5CYII=" />
        </body>
      </html>
      ''',
      url: 'test://$name/',
      contentType: ContentType.html,
    );

    final WebFController? controller = await WebFControllerManager.instance.addWithPrerendering(
      name: name,
      createController: () => WebFController(viewportWidth: 360, viewportHeight: 640),
      bundle: bundle,
    );
    expect(controller, isNotNull);
    expect(controller!.isFlutterAttached, isFalse);

    await _waitUntil(() {
      final el = controller.view.document.getElementById(['img']);
      return el != null;
    });

    final html.ImageElement img = controller.view.document.getElementById(['img'])! as html.ImageElement;

    await _waitUntil(() => img.naturalWidth > 0 && img.naturalHeight > 0);
    expect(img.renderStyle.aspectRatio, closeTo(1.0, 0.0001));

    final BoxFitImageKey key = BoxFitImageKey(url: Uri.parse(img.src), configuration: ImageConfiguration.empty);
    await _waitUntil(() => PaintingBinding.instance.imageCache.statusForKey(key) != null);

    await WebFControllerManager.instance.removeAndDisposeController(name);
  });
}

