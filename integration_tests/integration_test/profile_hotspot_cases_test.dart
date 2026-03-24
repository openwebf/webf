import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

final developer.UserTag _paragraphRebuildProfileTag =
    developer.UserTag('profile_hotspots.paragraph_rebuild');

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _configureProfileTestEnvironment();
  });

  setUp(() {
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 8,
        maxAttachedInstances: 8,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    await WebFControllerManager.instance.disposeAll();
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });

  group('profile hotspot cases', () {
    testWidgets('profiles deep direction inheritance hotspot',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-direction-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildDirectionInheritanceHtml(depth: 32, runCount: 56),
      );

      final dom.Element host = prepared.getElementById('host');
      expect(host.renderStyle.direction, TextDirection.rtl);

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['direction_inheritance_meta'] = <String, dynamic>{
        'depth': 32,
        'runCount': 56,
        'mutationIterations': 18,
      };

      await _toggleWidths(prepared, 'host',
          widths: const <String>['320px', '220px'], iterations: 4);

      await binding.traceAction(
        () async {
          await _toggleWidths(prepared, 'host',
              widths: const <String>['320px', '220px', '280px'],
              iterations: 18);
        },
        reportKey: 'direction_inheritance_timeline',
      );

      expect(host.renderStyle.direction, TextDirection.rtl);
    });

    testWidgets('profiles deep textAlign inheritance hotspot',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-text-align-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildTextAlignInheritanceHtml(depth: 28, runCount: 64),
      );

      final dom.Element host = prepared.getElementById('host');
      expect(host.renderStyle.textAlign, TextAlign.center);

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['text_align_inheritance_meta'] = <String, dynamic>{
        'depth': 28,
        'runCount': 64,
        'mutationIterations': 18,
      };

      await _toggleWidths(prepared, 'host',
          widths: const <String>['300px', '210px'], iterations: 4);

      await binding.traceAction(
        () async {
          await _toggleWidths(prepared, 'host',
              widths: const <String>['300px', '210px', '260px'],
              iterations: 18);
        },
        reportKey: 'text_align_inheritance_timeline',
      );

      expect(host.renderStyle.textAlign, TextAlign.center);
    });

    testWidgets('profiles inline paragraph rebuild hotspot',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-paragraph-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildParagraphRebuildHtml(chipCount: 72),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element paragraph = prepared.getElementById('paragraph');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['paragraph_rebuild_meta'] = <String, dynamic>{
        'chipCount': 72,
        'mutationIterations': 48,
        'styleMutationPhases': 4,
      };

      await _runParagraphRebuildLoop(
        prepared,
        mutationIterations: 12,
        widths: const <String>['340px', '190px', '260px', '220px'],
      );

      binding.reportData!['paragraph_rebuild_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _paragraphRebuildProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runParagraphRebuildLoop(
                prepared,
                mutationIterations: 48,
                widths: const <String>[
                  '340px',
                  '190px',
                  '260px',
                  '220px',
                ],
              );
            },
            reportKey: 'paragraph_rebuild_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(paragraph.getBoundingClientRect().height, greaterThan(0));
    });

    testWidgets('profiles opacity transition hotspot',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-opacity-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildOpacityTransitionHtml(tileCount: 144),
      );

      final dom.Element stage = prepared.getElementById('stage');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['opacity_transition_meta'] = <String, dynamic>{
        'tileCount': 144,
        'forwardFrames': 24,
        'reverseFrames': 24,
      };

      await _runOpacityCycle(prepared, 'stage',
          forwardFrames: 8, reverseFrames: 8);

      await binding.traceAction(
        () async {
          await _runOpacityCycle(prepared, 'stage',
              forwardFrames: 24, reverseFrames: 24);
        },
        reportKey: 'opacity_transition_timeline',
      );

      expect(stage.className, isEmpty);
    });
  });
}

Future<Map<String, dynamic>> _captureCpuSamples({
  required Future<void> Function() action,
  required developer.UserTag userTag,
}) async {
  final developer.ServiceProtocolInfo info = await developer.Service.getInfo();
  final Uri? serviceUri = info.serverWebSocketUri;
  if (serviceUri == null) {
    throw StateError('VM service websocket URI is unavailable.');
  }

  // ignore: deprecated_member_use
  final String? isolateId = developer.Service.getIsolateID(Isolate.current);
  if (isolateId == null) {
    throw StateError('Current isolate is not visible to the VM service.');
  }

  final vm.VmService service = await vmServiceConnectUri(serviceUri.toString());
  try {
    final int startMicros = (await service.getVMTimelineMicros()).timestamp!;
    final developer.UserTag previousTag = userTag.makeCurrent();
    try {
      await action();
    } finally {
      previousTag.makeCurrent();
    }

    final int endMicros = (await service.getVMTimelineMicros()).timestamp!;
    final int timeExtentMicros =
        endMicros > startMicros ? endMicros - startMicros : 1;
    final vm.CpuSamples samples =
        await service.getCpuSamples(isolateId, startMicros, timeExtentMicros);

    return <String, dynamic>{
      'profileLabel': userTag.label,
      'isolateId': isolateId,
      'timeOriginMicros': startMicros,
      'timeExtentMicros': timeExtentMicros,
      'samples': samples.toJson(),
    };
  } finally {
    await service.dispose();
  }
}

Future<void> _configureProfileTestEnvironment() async {
  NavigatorModule.setCustomUserAgent('webf/profile-tests');

  final String? externalBridgePath =
      Platform.environment['WEBF_PROFILE_EXTERNAL_BRIDGE_PATH'];
  if (externalBridgePath != null && externalBridgePath.isNotEmpty) {
    // The macOS test app already embeds libwebf.dylib. Forcing another path
    // here loads a second copy of the bridge and splits bridge globals/TLS.
    WebFDynamicLibrary.dynamicLibraryPath = path.normalize(externalBridgePath);
  }

  final Directory tempDirectory = Directory(
    path.join(Directory.current.path, 'build', 'profile_test_temp'),
  )..createSync(recursive: true);

  final MethodChannel webfChannel = getWebFMethodChannel();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    webfChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return tempDirectory.path;
      }
      throw FlutterError('Not implemented for method ${methodCall.method}.');
    },
  );

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    pathProviderChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return tempDirectory.path;
      }
      throw FlutterError('Not implemented for method ${methodCall.method}.');
    },
  );
}

Future<_PreparedProfileCase> _prepareProfileCase(
  WidgetTester tester, {
  required String controllerName,
  required String html,
  double viewportWidth = 390,
  double viewportHeight = 844,
}) async {
  tester.view.physicalSize = ui.Size(viewportWidth, viewportHeight);
  tester.view.devicePixelRatio = 1.0;

  WebFController? controller;
  await tester.runAsync(() async {
    controller = await WebFControllerManager.instance.addWithPreload(
      name: controllerName,
      createController: () => WebFController(
        viewportWidth: viewportWidth,
        viewportHeight: viewportHeight,
      ),
      bundle: WebFBundle.fromContent(
        html,
        url: 'test://$controllerName/',
        contentType: htmlContentType,
      ),
    );
    await controller!.controlledInitCompleter.future;
  });

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WebF.fromControllerName(controllerName: controllerName),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));

  await tester.runAsync(() async {
    await controller!.controllerPreloadingCompleter.future;
    await Future.wait<void>(<Future<void>>[
      controller!.controllerOnDOMContentLoadedCompleter.future,
      controller!.viewportLayoutCompleter.future,
    ]);
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));

  return _PreparedProfileCase(
    controller: controller!,
    tester: tester,
  );
}

Future<void> _toggleWidths(
  _PreparedProfileCase prepared,
  String elementId, {
  required List<String> widths,
  required int iterations,
}) async {
  for (int i = 0; i < iterations; i++) {
    final String width = widths[i % widths.length];
    await prepared.evaluate(
      'document.getElementById(${jsonEncode(elementId)}).style.width = '
      '${jsonEncode(width)};',
    );
    await _pumpFrames(prepared.tester, 2);
  }
}

Future<void> _runOpacityCycle(
  _PreparedProfileCase prepared,
  String elementId, {
  required int forwardFrames,
  required int reverseFrames,
}) async {
  await prepared.evaluate(
    'document.getElementById(${jsonEncode(elementId)}).className = "dim";',
  );
  await _pumpFrames(prepared.tester, forwardFrames);

  await prepared.evaluate(
    'document.getElementById(${jsonEncode(elementId)}).className = "";',
  );
  await _pumpFrames(prepared.tester, reverseFrames);
}

Future<void> _runParagraphRebuildLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element paragraph = prepared.getElementById('paragraph');
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;

    paragraph.setInlineStyle('width', widths[phase]);
    paragraph.setInlineStyle('fontSize', phase.isEven ? '16px' : '17px');
    paragraph.setInlineStyle('lineHeight', phase >= 2 ? '24px' : '22px');
    paragraph.setInlineStyle('letterSpacing', phase == 1 ? '0.2px' : '0px');
    paragraph.style.flushPendingProperties();
    paragraph.className = 'phase-$phase';

    paragraph.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 2);
  }
}

Future<void> _pumpFrames(
  WidgetTester tester,
  int frames, {
  Duration frameDuration = const Duration(milliseconds: 16),
}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(frameDuration);
  }
}

String _buildDirectionInheritanceHtml({
  required int depth,
  required int runCount,
}) {
  final String openNodes =
      List<String>.filled(depth, '<div class="level">').join();
  final String closeNodes = List<String>.filled(depth, '</div>').join();
  final String content = List<String>.generate(
    runCount,
    (int index) =>
        '<span class="token">مرحبا اتجاه ${index + 1} nested text sample</span>',
  ).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 16px/1.4 AlibabaSans, sans-serif;
    }
    #host {
      width: 320px;
      padding: 8px;
      border: 1px solid #d8dde6;
      direction: rtl;
    }
    .level {
      display: block;
      padding-inline-start: 1px;
    }
    .token {
      display: inline;
      margin-inline-end: 4px;
    }
  </style>
</head>
<body>
  <div id="host">$openNodes$content$closeNodes</div>
</body>
</html>
''';
}

String _buildTextAlignInheritanceHtml({
  required int depth,
  required int runCount,
}) {
  final String openNodes =
      List<String>.filled(depth, '<div class="level">').join();
  final String closeNodes = List<String>.filled(depth, '</div>').join();
  final String content = List<String>.generate(
    runCount,
    (int index) => '<span class="token">alignment sample ${index + 1}</span>',
  ).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 16px/1.4 AlibabaSans, sans-serif;
    }
    #host {
      width: 300px;
      padding: 8px;
      border: 1px solid #d8dde6;
      text-align: center;
    }
    .level {
      display: block;
      padding-left: 1px;
    }
    .token {
      display: inline;
      margin: 0 3px;
    }
  </style>
</head>
<body>
  <div id="host">$openNodes$content$closeNodes</div>
</body>
</html>
''';
}

String _buildParagraphRebuildHtml({
  required int chipCount,
}) {
  final String chips = List<String>.generate(
    chipCount,
    (int index) {
      final int tone = index % 4;
      final int badge = index % 3;
      return '''
<span class="run tone$tone">
  <span class="label">series ${index + 1}</span>
  <span class="pill badge$badge">item ${index + 1}</span>
  <span class="value">wrapped inline metrics sample ${index + 1}</span>
</span>
''';
    },
  ).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 16px/1.4 AlibabaSans, sans-serif;
    }
    #host {
      width: 340px;
      padding: 8px;
      border: 1px solid #d8dde6;
    }
    #paragraph {
      width: 340px;
      line-height: 22px;
      word-break: normal;
    }
    #paragraph.phase-1 {
      letter-spacing: 0.15px;
    }
    #paragraph.phase-2 .pill {
      margin: 0 6px;
      padding: 1px 8px;
      font-size: 12px;
      vertical-align: baseline;
    }
    #paragraph.phase-3 .value {
      font-style: normal;
      font-weight: 700;
      letter-spacing: 0.2px;
    }
    #paragraph.phase-3 .pill {
      padding: 3px 8px;
    }
    #paragraph.phase-1 .label {
      font-weight: 700;
    }
    #paragraph.phase-2 .value {
      font-style: normal;
    }
    #paragraph.phase-0 .pill {
      vertical-align: middle;
    }
    .run {
      display: inline;
      margin-right: 6px;
      padding: 0 2px;
      border-right: 1px solid rgba(80, 108, 144, 0.2);
    }
    .label {
      color: #4b5563;
      letter-spacing: 0.15px;
    }
    .value {
      color: #0f172a;
      font-style: italic;
    }
    .pill {
      display: inline-block;
      margin: 0 4px;
      padding: 2px 6px;
      border-radius: 999px;
      border: 1px solid rgba(59, 130, 246, 0.28);
      vertical-align: middle;
      font-size: 13px;
      line-height: 18px;
      background: rgba(191, 219, 254, 0.35);
    }
    .tone0 .label {
      font-weight: 600;
    }
    .tone1 .value {
      text-decoration: underline;
    }
    .tone2 .label {
      letter-spacing: 0.35px;
    }
    .tone3 .value {
      font-weight: 700;
    }
    .badge0 {
      background: rgba(253, 230, 138, 0.55);
    }
    .badge1 {
      background: rgba(187, 247, 208, 0.55);
    }
    .badge2 {
      background: rgba(216, 180, 254, 0.4);
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="paragraph">$chips</div>
  </div>
</body>
</html>
''';
}

String _buildOpacityTransitionHtml({
  required int tileCount,
}) {
  final String tiles = List<String>.generate(
    tileCount,
    (int index) =>
        '<span class="tile" style="background-color: hsl(${(index * 11) % 360}, 70%, 55%);"></span>',
  ).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      padding: 0;
      background: #ffffff;
    }
    #stage {
      width: 360px;
      padding: 8px;
      transition: opacity 180ms linear;
      opacity: 1;
    }
    #stage.dim {
      opacity: 0.2;
    }
    .tile {
      display: inline-block;
      width: 24px;
      height: 24px;
      margin: 1px;
    }
  </style>
</head>
<body>
  <div id="stage">$tiles</div>
</body>
</html>
''';
}

class _PreparedProfileCase {
  const _PreparedProfileCase({
    required this.controller,
    required this.tester,
  });

  final WebFController controller;
  final WidgetTester tester;

  dom.Element getElementById(String id) {
    final dom.Element? element =
        controller.view.document.getElementById(<String>[id]);
    expect(element, isNotNull, reason: 'Expected element with id "$id".');
    return element!;
  }

  Future<void> evaluate(String script) async {
    await tester.runAsync(() async {
      await controller.view.evaluateJavaScripts(script);
    });
  }
}
