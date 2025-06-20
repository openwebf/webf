import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';
import 'package:path/path.dart' as path;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FP Integration Tests', () {
    setUp(() {
      // Initialize WebFControllerManager for each test
      WebFControllerManager.instance.initialize(
        WebFControllerManagerConfig(
          maxAliveInstances: 4,
          maxAttachedInstances: 2,
        ),
      );
    });

    tearDown(() async {
      // Clean up all controllers after each test
      await WebFControllerManager.instance.disposeAll();
    });

    testWidgets('FP tracks background color only', (WidgetTester tester) async {
      bool fpCalled = false;
      double? fpTime;
      bool fcpCalled = false;

      // Add controller with preloading
      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fp_background',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFP: (double time) {
            fpCalled = true;
            fpTime = time;
            print('FP reported: $time ms');
          },
          onFCP: (double time) {
            fcpCalled = true;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                body {
                  background-color: #ff0000;
                }
              </style>
            </head>
            <body>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_background',
            ),
          ),
        ),
      );

      // Wait for rendering
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(fpCalled, isTrue);
      expect(fpTime, isNotNull);
      expect(fpTime! > 0, isTrue);
      // FCP should not be called for background only
      expect(fcpCalled, isFalse);
      print('Test passed: Background FP was $fpTime ms');
    });

    testWidgets('FP tracks borders only', (WidgetTester tester) async {
      bool fpCalled = false;
      double? fpTime;
      bool fcpCalled = false;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fp_borders',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFP: (double time) {
            fpCalled = true;
            fpTime = time;
            print('FP reported: $time ms');
          },
          onFCP: (double time) {
            fcpCalled = true;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                .bordered {
                  width: 200px;
                  height: 200px;
                  border: 5px solid blue;
                }
              </style>
            </head>
            <body>
              <div class="bordered"></div>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_borders',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(fpCalled, isTrue);
      expect(fpTime, isNotNull);
      expect(fpTime! > 0, isTrue);
      // FCP should not be called for borders only
      expect(fcpCalled, isFalse);
      print('Border FP: $fpTime ms');
    });

    testWidgets('FP tracks box shadows only', (WidgetTester tester) async {
      bool fpCalled = false;
      double? fpTime;
      bool fcpCalled = false;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fp_shadows',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFP: (double time) {
            fpCalled = true;
            fpTime = time;
            print('FP reported: $time ms');
          },
          onFCP: (double time) {
            fcpCalled = true;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                .shadow {
                  width: 100px;
                  height: 100px;
                  box-shadow: 10px 10px 20px rgba(0, 0, 0, 0.5);
                }
              </style>
            </head>
            <body>
              <div class="shadow"></div>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_shadows',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(fpCalled, isTrue);
      expect(fpTime, isNotNull);
      expect(fpTime! > 0, isTrue);
      // FCP should not be called for shadows only
      expect(fcpCalled, isFalse);
      print('Shadow FP: $fpTime ms');
    });

    testWidgets('FP fires before FCP with text content', (WidgetTester tester) async {
      bool fpCalled = false;
      double? fpTime;
      bool fcpCalled = false;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fp_before_fcp',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFP: (double time) {
            fpCalled = true;
            fpTime = time;
            print('FP reported: $time ms');
          },
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                body {
                  background-color: #f0f0f0;
                }
              </style>
            </head>
            <body>
              <h1>This is text content</h1>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_before_fcp',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(fpCalled, isTrue);
      expect(fcpCalled, isTrue);
      expect(fpTime, isNotNull);
      expect(fcpTime, isNotNull);
      // FP should fire before or at the same time as FCP
      expect(fpTime! <= fcpTime!, isTrue);
      print('FP: $fpTime ms, FCP: $fcpTime ms');
    });

    testWidgets('FP with gradient background', (WidgetTester tester) async {
      bool fpCalled = false;
      double? fpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fp_gradient',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFP: (double time) {
            fpCalled = true;
            fpTime = time;
            print('FP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                body {
                  background: linear-gradient(45deg, #ff0000, #00ff00);
                }
              </style>
            </head>
            <body>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_gradient',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(fpCalled, isTrue);
      expect(fpTime, isNotNull);
      expect(fpTime! > 0, isTrue);
      print('Gradient FP: $fpTime ms');
    });

    testWidgets('FP with viewport background', (WidgetTester tester) async {
      bool fpCalled = false;
      double? fpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fp_viewport',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          background: Colors.purple,
          onFP: (double time) {
            fpCalled = true;
            fpTime = time;
            print('FP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_viewport',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(fpCalled, isTrue);
      expect(fpTime, isNotNull);
      expect(fpTime! > 0, isTrue);
      print('Viewport background FP: $fpTime ms');
    });

    testWidgets('FP is reported only once', (WidgetTester tester) async {
      int fpCallCount = 0;
      double? fpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fp_once',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFP: (double time) {
            fpCallCount++;
            fpTime = time;
            print('FP call #$fpCallCount: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                body {
                  background-color: yellow;
                }
                .box {
                  width: 100px;
                  height: 100px;
                  border: 2px solid black;
                  margin-top: 20px;
                }
              </style>
            </head>
            <body>
              <div class="box"></div>
              <script>
                // Add more visual elements after a delay
                setTimeout(() => {
                  const div = document.createElement('div');
                  div.className = 'box';
                  div.style.backgroundColor = 'red';
                  document.body.appendChild(div);
                }, 200);
              </script>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_once',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Wait for dynamic content to be added
      await Future.delayed(Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(fpCallCount, equals(1));
      expect(fpTime, isNotNull);
      print('FP was called exactly once');
    });

    testWidgets('FP with navigation resets', (WidgetTester tester) async {
      int page1FPCount = 0;
      int page2FPCount = 0;
      String currentPage = 'page1';

      await WebFControllerManager.instance.addOrUpdateControllerWithLoading(
        name: 'test_fp_navigation',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                body { background-color: #ff0000; }
              </style>
            </head>
            <body>
              <h1>Page 1</h1>
            </body>
          </html>
          ''',
          url: 'about:page1',
          contentType: ContentType.html,
        ),
        mode: WebFLoadingMode.preloading,
        setup: (controller) {
          controller.onFP = (double time) {
            if (currentPage == 'page1') {
              page1FPCount++;
              print('Page 1 FP: $time ms');
            } else if (currentPage == 'page2') {
              page2FPCount++;
              print('Page 2 FP: $time ms');
            }
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_navigation',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(page1FPCount, equals(1));

      // Navigate to second page
      currentPage = 'page2';

      await WebFControllerManager.instance.addOrUpdateControllerWithLoading(
        name: 'test_fp_navigation',
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                body { background-color: #00ff00; }
              </style>
            </head>
            <body>
              <h1>Page 2</h1>
            </body>
          </html>
          ''',
          url: 'about:page2',
          contentType: ContentType.html,
        ),
        forceReplace: true,
        mode: WebFLoadingMode.preloading,
        setup: (controller) {
          controller.onFP = (double time) {
            if (currentPage == 'page1') {
              page1FPCount++;
              print('Page 1 FP: $time ms');
            } else if (currentPage == 'page2') {
              page2FPCount++;
              print('Page 2 FP: $time ms');
            }
          };
        },
      );

      await tester.pump();
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(page2FPCount, equals(1));
      print('Page 1 FP count: $page1FPCount');
      print('Page 2 FP count: $page2FPCount');
    });

    testWidgets('FP timing is always less than or equal to FCP', (WidgetTester tester) async {
      double? fpTime;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fp_fcp_timing',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFP: (double time) {
            fpTime = time;
            print('FP reported: $time ms');
          },
          onFCP: (double time) {
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                body {
                  background-color: #e0e0e0;
                  border: 10px solid #333;
                }
                h1 {
                  color: #333;
                  text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
                }
              </style>
            </head>
            <body>
              <h1>Testing FP and FCP timing</h1>
              <p>This page has both visual changes and content.</p>
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==" width="50" height="50" />
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_fcp_timing',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(fpTime, isNotNull);
      expect(fcpTime, isNotNull);
      expect(fpTime! <= fcpTime!, isTrue);
      print('FP timing ($fpTime ms) is <= FCP timing ($fcpTime ms)');
    });

    testWidgets('FP with mixed visual elements', (WidgetTester tester) async {
      bool fpCalled = false;
      double? fpTime;
      bool fcpCalled = false;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fp_mixed',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFP: (double time) {
            fpCalled = true;
            fpTime = time;
            print('FP reported: $time ms');
          },
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                body {
                  background: linear-gradient(to right, #ff0000, #00ff00);
                }
                .container {
                  width: 300px;
                  padding: 20px;
                  border: 3px dashed #0000ff;
                  box-shadow: 5px 5px 10px rgba(0,0,0,0.3);
                  background-color: rgba(255,255,255,0.8);
                }
                .no-content {
                  width: 50px;
                  height: 50px;
                  background-color: #ffff00;
                  border-radius: 50%;
                }
              </style>
            </head>
            <body>
              <div class="no-content"></div>
              <div class="container">
                <h2>Mixed Content Test</h2>
                <p>This tests various visual elements.</p>
              </div>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_mixed',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(fpCalled, isTrue);
      expect(fcpCalled, isTrue);
      expect(fpTime, isNotNull);
      expect(fcpTime, isNotNull);
      expect(fpTime! <= fcpTime!, isTrue);
      print('Mixed elements - FP: $fpTime ms, FCP: $fcpTime ms');
    });

    testWidgets('FP with prerendering mode', (WidgetTester tester) async {
      bool fpCalled = false;
      double? fpTime;

      // Test with prerendering mode
      await WebFControllerManager.instance.addWithPrerendering(
        name: 'test_fp_prerendering',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFP: (double time) {
            fpCalled = true;
            fpTime = time;
            print('FP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                body {
                  background-color: #663399;
                  padding: 20px;
                }
                .box {
                  width: 200px;
                  height: 100px;
                  border: 5px solid white;
                  box-shadow: 0 0 20px rgba(0,0,0,0.5);
                }
              </style>
            </head>
            <body>
              <div class="box">Prerendered with FP</div>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      // Small delay to let prerendering happen
      await Future.delayed(Duration(milliseconds: 100));

      // Now attach the prerendered page
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fp_prerendering',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(fpCalled, isTrue);
      expect(fpTime, isNotNull);
      print('FP in prerendering mode: $fpTime ms');
    });
  });
}