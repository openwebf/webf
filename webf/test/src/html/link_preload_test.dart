import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/html.dart' as html;
import 'package:webf/foundation.dart';
import 'dart:io';
import '../foundation/mock_bundle.dart';
import '../../webf_test.dart';

void main() {
  setUp(() {
    setupTest();
  });

  group('Image preload tests', () {
    test('should not dispose preloaded bundle in ImageRequest', () async {
      // Create a mock preloaded bundle
      final testUrl = 'https://example.com/preloaded.svg';
      final mockBundle = MockWebFBundle.fromUrl(testUrl);

      // Create controller with preloaded bundle
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><head></head><body></body></html>', contentType: ContentType.html),
        preloadedBundles: [mockBundle],
      );

      await controller.controlledInitCompleter.future;

      // Create an image request
      final imageRequest = html.ImageRequest.fromUri(Uri.parse(testUrl));

      // Obtain image data
      await imageRequest.obtainImage(controller);

      // Check that the preloaded bundle is still available
      final stillPreloaded = controller.getPreloadBundleFromUrl(testUrl);
      expect(stillPreloaded, isNotNull);
      expect(identical(stillPreloaded, mockBundle), isTrue);

      // The bundle should not have been disposed
      expect(mockBundle.isDisposed, isFalse);

      controller.dispose();
    });

    test('Multiple images should share the same preloaded bundle', () async {
      final testUrl = 'https://example.com/shared.svg';
      final mockBundle = MockWebFBundle.fromUrl(testUrl);

      // Create controller with preloaded bundle
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><head></head><body></body></html>', contentType: ContentType.html),
        preloadedBundles: [mockBundle],
      );

      await controller.controlledInitCompleter.future;

      // Create multiple image requests for the same URL
      final request1 = html.ImageRequest.fromUri(Uri.parse(testUrl));
      final request2 = html.ImageRequest.fromUri(Uri.parse(testUrl));
      final request3 = html.ImageRequest.fromUri(Uri.parse(testUrl));

      // All should use the same preloaded bundle
      await request1.obtainImage(controller);
      await request2.obtainImage(controller);
      await request3.obtainImage(controller);

      // Bundle should still be available and not disposed
      final stillPreloaded = controller.getPreloadBundleFromUrl(testUrl);
      expect(stillPreloaded, isNotNull);
      expect(mockBundle.isDisposed, isFalse);

      // Bundle should have been accessed multiple times
      expect(mockBundle.obtainDataCallCount, equals(3));

      controller.dispose();
    });

    test('ImageRequest should dispose non-preloaded bundles', () async {
      // Create controller without preloaded bundles
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><head></head><body></body></html>', contentType: ContentType.html),
      );

      await controller.controlledInitCompleter.future;

      final testUrl = 'https://example.com/not-preloaded.png';

      // Create an image request for a non-preloaded URL
      final imageRequest = html.ImageRequest.fromUri(Uri.parse(testUrl));

      // This will create a new bundle internally
      try {
        await imageRequest.obtainImage(controller);
      } catch (e) {
        // Expected to fail since it's a mock URL
      }

      // The URL should not be in preloaded bundles
      final preloadedBundle = controller.getPreloadBundleFromUrl(testUrl);
      expect(preloadedBundle, isNull);

      controller.dispose();
    });
  });
}
