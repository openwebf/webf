/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:io';

import 'package:webf/launcher.dart';
import 'package:webf/module.dart';
import 'package:test/test.dart';

import '../../local_http_server.dart';

void main() {
  group('fetch', () {
    FetchModule fetchModule = FetchModule(null);
    var server = LocalHttpServer.getInstance();

    test('Custom Headers', () async {
      var request =
          await fetchModule.getRequest(server.getUri('plain_text'), 'POST', <String, dynamic>{'foo': 'bar'}, null);
      expect(request.uri.path, '/plain_text');
      expect(request.method, 'POST');
      expect(request.headers.value('foo'), 'bar');
      await request.close();
    });

    test('aborting one request must not abort other concurrent requests', () async {
      // Exercise the HttpClient path (no controller/moduleManager required).
      WebFControllerManager.instance.initialize(const WebFControllerManagerConfig(useDioForNetwork: false));

      // A server that delays its response so requests stay in-flight while we abort.
      final HttpServer slowServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      slowServer.listen((HttpRequest request) {
        Future.delayed(const Duration(milliseconds: 800), () {
          request.response
            ..statusCode = 200
            ..write('ok');
          request.response.close();
        });
      });
      final String base = 'http://${InternetAddress.loopbackIPv4.host}:${slowServer.port}';

      final module = FetchModule(null);

      // Start two concurrent requests, each carrying its own request id.
      final Future f1 = module.invoke('$base/a', [null, null, 'GET', 'req-1']) as Future;
      final Future f2 = module.invoke('$base/b', [null, null, 'GET', 'req-2']) as Future;

      // Let both requests reach the network before aborting.
      await Future.delayed(const Duration(milliseconds: 200));

      // Abort ONLY the first request.
      module.invoke('abortRequest', ['req-1']);

      // The aborted request must fail.
      await expectLater(f1, throwsA(anything));

      // The untouched request must still complete successfully.
      final result = await f2;
      expect(result[1], 200);

      await slowServer.close(force: true);
    });
  });
}
