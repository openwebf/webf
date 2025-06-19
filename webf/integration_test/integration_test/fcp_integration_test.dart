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

  group('FCP Integration Tests', () {
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

    testWidgets('FCP tracks text content', (WidgetTester tester) async {
      bool fcpCalled = false;
      double? fcpTime;

      // Add controller with preloading
      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fcp_text',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1>First Contentful Paint Test</h1>
              <p>This text should trigger FCP</p>
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
              controllerName: 'test_fcp_text',
            ),
          ),
        ),
      );

      // Wait for rendering
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(fcpCalled, isTrue);
      expect(fcpTime, isNotNull);
      expect(fcpTime! > 0, isTrue);
      print('Test passed: Text FCP was $fcpTime ms');
    });

    testWidgets('FCP tracks image loading', (WidgetTester tester) async {
      bool fcpCalled = false;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fcp_image',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==" width="100" height="100" />
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
              controllerName: 'test_fcp_image',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(fcpCalled, isTrue);
      expect(fcpTime, isNotNull);
      expect(fcpTime! > 0, isTrue);
      print('Image FCP: $fcpTime ms');
    });

    testWidgets('FCP with SVG content', (WidgetTester tester) async {
      bool fcpCalled = false;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fcp_svg',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <!-- SVG as image -->
              <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iZ3JlZW4iIC8+Cjwvc3ZnPg==" width="100" height="100" />
              
              <!-- Inline SVG -->
              <svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
                <circle cx="50" cy="50" r="40" fill="blue" />
              </svg>
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
              controllerName: 'test_fcp_svg',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(fcpCalled, isTrue);
      expect(fcpTime, isNotNull);
      expect(fcpTime! > 0, isTrue);
      print('SVG FCP: $fcpTime ms');
    });

    testWidgets('FCP with canvas content', (WidgetTester tester) async {
      bool fcpCalled = false;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fcp_canvas',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <canvas id="myCanvas" width="200" height="200"></canvas>
              <script>
                const canvas = document.getElementById('myCanvas');
                const ctx = canvas.getContext('2d');
                ctx.fillStyle = 'red';
                ctx.fillRect(0, 0, 100, 100);
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
              controllerName: 'test_fcp_canvas',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(fcpCalled, isTrue);
      expect(fcpTime, isNotNull);
      expect(fcpTime! > 0, isTrue);
      print('Canvas FCP: $fcpTime ms');
    });

    testWidgets('FCP is reported only once', (WidgetTester tester) async {
      int fcpCallCount = 0;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fcp_once',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFCP: (double time) {
            fcpCallCount++;
            fcpTime = time;
            print('FCP call #$fcpCallCount: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <div id="content">
                <h1>First content</h1>
              </div>
              <script>
                // Add more content after a delay
                setTimeout(() => {
                  const div = document.createElement('div');
                  div.innerHTML = '<h2>Second content added later</h2>';
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
              controllerName: 'test_fcp_once',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Wait for dynamic content to be added
      await Future.delayed(Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(fcpCallCount, equals(1));
      expect(fcpTime, isNotNull);
      print('FCP was called exactly once');
    });

    testWidgets('FCP with navigation resets', (WidgetTester tester) async {
      int page1FCPCount = 0;
      int page2FCPCount = 0;
      String currentPage = 'page1';

      await WebFControllerManager.instance.addOrUpdateControllerWithLoading(
        name: 'test_fcp_navigation',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1>Page 1 Content</h1>
            </body>
          </html>
          ''',
          url: 'about:page1',
          contentType: ContentType.html,
        ),
        mode: WebFLoadingMode.preloading,
        setup: (controller) {
          controller.onFCP = (double time) {
            if (currentPage == 'page1') {
              page1FCPCount++;
              print('Page 1 FCP: $time ms');
            } else if (currentPage == 'page2') {
              page2FCPCount++;
              print('Page 2 FCP: $time ms');
            }
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_fcp_navigation',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(page1FCPCount, equals(1));

      // Navigate to second page
      currentPage = 'page2';

      await WebFControllerManager.instance.addOrUpdateControllerWithLoading(
        name: 'test_fcp_navigation',
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1>Page 2 Content</h1>
            </body>
          </html>
          ''',
          url: 'about:page2',
          contentType: ContentType.html,
        ),
        forceReplace: true,
        mode: WebFLoadingMode.preloading,
        setup: (controller) {
          controller.onFCP = (double time) {
            if (currentPage == 'page1') {
              page1FCPCount++;
              print('Page 1 FCP: $time ms');
            } else if (currentPage == 'page2') {
              page2FCPCount++;
              print('Page 2 FCP: $time ms');
            }
          };
        },
      );

      await tester.pump();
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(page2FCPCount, equals(1));
      print('Page 1 FCP count: $page1FCPCount');
      print('Page 2 FCP count: $page2FCPCount');
    });

    testWidgets('FCP ignores invisible content', (WidgetTester tester) async {
      bool fcpCalled = false;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fcp_invisible',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <!-- Invisible content should not trigger FCP -->
              <div style="display: none;">Hidden content</div>
              <div style="visibility: hidden;">Invisible content</div>
              <div style="opacity: 0;">Transparent content</div>
              
              <!-- This visible content should trigger FCP -->
              <div id="visible" style="display: none;">Will be visible</div>
              <script>
                // Make content visible after a delay
                setTimeout(() => {
                  document.getElementById('visible').style.display = 'block';
                  document.getElementById('visible').textContent = 'Now visible!';
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
              controllerName: 'test_fcp_invisible',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Wait for script to make content visible
      await Future.delayed(Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(fcpCalled, isTrue);
      expect(fcpTime, isNotNull);
      print('FCP reported after content became visible');
    });

    testWidgets('FCP with mixed content types', (WidgetTester tester) async {
      bool fcpCalled = false;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fcp_mixed',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <!-- Multiple content types -->
              <h1>Text Content</h1>
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" width="50" height="50" />
              <svg width="50" height="50">
                <rect width="50" height="50" fill="green" />
              </svg>
              <canvas id="canvas" width="50" height="50"></canvas>
              <script>
                const ctx = document.getElementById('canvas').getContext('2d');
                ctx.fillStyle = 'purple';
                ctx.fillRect(0, 0, 50, 50);
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
              controllerName: 'test_fcp_mixed',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(fcpCalled, isTrue);
      expect(fcpTime, isNotNull);
      // FCP should be reported when the first content (likely text) is painted
      print('FCP with mixed content: $fcpTime ms');
    });

    testWidgets('FCP with prerendering mode', (WidgetTester tester) async {
      bool fcpCalled = false;
      double? fcpTime;

      // Test with prerendering mode
      await WebFControllerManager.instance.addWithPrerendering(
        name: 'test_fcp_prerendering',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1>Prerendered Content for FCP</h1>
              <p>This content is prerendered</p>
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
              controllerName: 'test_fcp_prerendering',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(fcpCalled, isTrue);
      expect(fcpTime, isNotNull);
      print('FCP in prerendering mode: $fcpTime ms');
    });

    testWidgets('FCP tracks CSS background images', (WidgetTester tester) async {
      bool fcpCalled = false;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fcp_background_image',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
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
                .bg-image {
                  width: 200px;
                  height: 200px;
                  background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==');
                  background-size: cover;
                }
                .bg-gradient {
                  width: 100px;
                  height: 100px;
                  background: linear-gradient(45deg, #ff0000, #00ff00);
                }
              </style>
            </head>
            <body>
              <!-- CSS gradient should NOT trigger FCP -->
              <div class="bg-gradient"></div>
              <!-- Background image should trigger FCP -->
              <div class="bg-image"></div>
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
              controllerName: 'test_fcp_background_image',
            ),
          ),
        ),
      );

      // Wait for rendering
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(fcpCalled, isTrue);
      expect(fcpTime, isNotNull);
      expect(fcpTime! > 0, isTrue);
      print('FCP reported for CSS background image: $fcpTime ms');
    });

    testWidgets('FCP tracks RenderWidget content', (WidgetTester tester) async {
      bool fcpCalled = false;
      double? fcpTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_fcp_render_widget',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onFCP: (double time) {
            fcpCalled = true;
            fcpTime = time;
            print('FCP reported: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <!-- WebF ListView widget element should trigger FCP when painted -->
              <webf-listview id="test-widget" style="width: 200px; height: 200px;">
                <div>Item 1</div>
                <div>Item 2</div>
                <div>Item 3</div>
              </webf-listview>
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
              controllerName: 'test_fcp_render_widget',
            ),
          ),
        ),
      );

      // Wait for rendering
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(fcpCalled, isTrue);
      expect(fcpTime, isNotNull);
      expect(fcpTime! > 0, isTrue);
      print('FCP reported for RenderWidget: $fcpTime ms');
    });
  });
}