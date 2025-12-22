import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/src/painting/box_fit_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('debugDecodeGifForTest decodes GIF without ImageDescriptor', () async {
    // 1x1 GIF89a
    final bytes = base64Decode('R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==');

    final decoded = await debugDecodeGifForTest(
      bytes,
      boxFit: BoxFit.contain,
      preferredWidth: 100,
      preferredHeight: 100,
    );

    expect(decoded.naturalWidth, 1);
    expect(decoded.naturalHeight, 1);
    expect(decoded.codec.frameCount, greaterThanOrEqualTo(1));

    final frame = await decoded.codec.getNextFrame();
    expect(frame.image.width, 1);
    expect(frame.image.height, 1);

    decoded.codec.dispose();
  });
}

