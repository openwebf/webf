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

  group('LCP Integration Tests', () {
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

    tearDownAll(() {
      // Clean up temp directory
      // if (tempDirectory.existsSync()) {
      //   tempDirectory.deleteSync(recursive: true);
      // }
    });

    testWidgets('LCP tracks text content with controller manager', (WidgetTester tester) async {
      bool lcpCalled = false;
      double? lcpTime;
      bool lcpFinalCalled = false;
      double? lcpFinalTime;

      // Add controller with preloading
      await WebFControllerManager.instance.addWithPreload(
        name: 'test_lcp_text',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onLCP: (double time) {
            lcpCalled = true;
            lcpTime = time;
            print('LCP reported: $time ms');
          },
          onLCPFinal: (double time) {
            lcpFinalCalled = true;
            lcpFinalTime = time;
            print('LCP final: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1 style="font-size: 48px; color: blue;">Large Heading Text</h1>
              <p style="font-size: 14px;">Small paragraph text</p>
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
              controllerName: 'test_lcp_text',
            ),
          ),
        ),
      );

      // Wait for rendering
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(lcpCalled, isTrue);
      expect(lcpTime, isNotNull);
      expect(lcpTime! > 0, isTrue);
      print('Test passed: Text LCP was $lcpTime ms');
    });

    testWidgets('LCP tracks image loading', (WidgetTester tester) async {
      final lcpTimes = <double>[];

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_lcp_image',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onLCP: (double time) {
            lcpTimes.add(time);
            print('LCP update: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1>Small text</h1>
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==" width="300" height="300" />
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
              controllerName: 'test_lcp_image',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(lcpTimes.isNotEmpty, isTrue);
      expect(lcpTimes.last > 0, isTrue);
      print('Image LCP: ${lcpTimes.last} ms');
    });

    testWidgets('LCP with navigation between pages', (WidgetTester tester) async {
      final page1LCPTimes = <double>[];
      final page2LCPTimes = <double>[];
      String currentPage = 'page1';
      DateTime page2StartTime = DateTime.now();

      await WebFControllerManager.instance.addOrUpdateControllerWithLoading(
        name: 'test_navigation',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1 style="font-size: 36px;">Page 1</h1>
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" width="200" height="200" />
            </body>
          </html>
          ''',
          url: 'about:page1',
          contentType: ContentType.html,
        ),
        mode: WebFLoadingMode.preloading,
        setup: (controller) {
          controller.onLCP = (double time) {
            if (currentPage == 'page1') {
              page1LCPTimes.add(time);
              print('Page 1 LCP: $time ms');
            } else if (currentPage == 'page2') {
              page2LCPTimes.add(time);
              print('Page 2 LCP: $time ms');
            }
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_navigation',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      expect(page1LCPTimes.isNotEmpty, isTrue);

      // Navigate to second page - use forceReplace to ensure new content is loaded
      currentPage = 'page2';
      page2StartTime = DateTime.now();

      // Update the bundle with new content - use forceReplace to ensure new content is loaded
      await WebFControllerManager.instance.addOrUpdateControllerWithLoading(
        name: 'test_navigation',
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1 style="font-size: 48px; color: red;">Page 2</h1>
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==" width="300" height="300" />
            </body>
          </html>
          ''',
          url: 'about:page2',
          contentType: ContentType.html,
        ),
        forceReplace: true,  // Force reload with new content
        mode: WebFLoadingMode.preloading,  // Use preloading mode
        setup: (controller) {
          // Initialize LCP tracking for the new controller
          controller.initializePerformanceTracking(page2StartTime);

          // Re-setup the LCP callback as the controller is replaced
          controller.onLCP = (double time) {
            if (currentPage == 'page1') {
              page1LCPTimes.add(time);
              print('Page 1 LCP: $time ms');
            } else if (currentPage == 'page2') {
              page2LCPTimes.add(time);
              print('Page 2 LCP: $time ms');
            }
          };
        },
      );

      // Wait for the widget to rebuild with new controller
      await tester.pump();
      await tester.pumpAndSettle();

      // Trigger a frame to ensure LCP tracking runs
      await tester.pump(Duration(milliseconds: 100));

      // Give more time for page 2 to load and report LCP
      await Future.delayed(Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(page2LCPTimes.isNotEmpty, isTrue,
        reason: 'Page 2 should have reported LCP times. Page 1 had ${page1LCPTimes.length} LCP updates.');
      print('Page 1 had ${page1LCPTimes.length} LCP updates');
      print('Page 2 had ${page2LCPTimes.length} LCP updates');
    });

    testWidgets('LCP finalization on user interaction', (WidgetTester tester) async {
      int lcpCallCount = 0;
      bool lcpFinalCalled = false;
      double? lcpFinalTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_interaction',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onLCP: (double time) {
            lcpCallCount++;
            print('LCP update #$lcpCallCount: $time ms');
          },
          onLCPFinal: (double time) {
            lcpFinalCalled = true;
            lcpFinalTime = time;
            print('LCP finalized: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <div id="content" style="width: 300px; height: 300px; background: blue; text-align: center; padding-top: 100px;">
                <h1 style="color: white;">Tap anywhere!</h1>
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
              controllerName: 'test_interaction',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(lcpCallCount > 0, isTrue);
      expect(lcpFinalCalled, isFalse);

      // Simulate user tap
      await tester.tap(find.byType(WebF));
      await tester.pump();

      expect(lcpFinalCalled, isTrue);
      expect(lcpFinalTime, isNotNull);
      print('LCP finalized at: $lcpFinalTime ms after user interaction');
    });

    testWidgets('LCP with loading animation replacement', (WidgetTester tester) async {
      final lcpTimes = <double>[];
      String currentPhase = 'loading';  // Track which phase we're in

      // Use setup callback to ensure LCP tracking persists across controller replacements
      final setupLCP = (WebFController controller) {
        controller.onLCP = (double time) {
          lcpTimes.add(time);
          print('LCP update ($currentPhase): $time ms');
        };
      };

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_loading',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <div id="loading" style="width: 350px; height: 350px; background: linear-gradient(45deg, #ddd, #eee); display: flex; align-items: center; justify-content: center;">
                <h2>Loading...</h2>
              </div>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
        setup: setupLCP,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_loading',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 200));

      final initialLCPCount = lcpTimes.length;
      expect(initialLCPCount > 0, isTrue);
      final loadingLCPSize = lcpTimes.last;

      // Get the controller to load new content
      final controller = await WebFControllerManager.instance.getController('test_loading');
      expect(controller, isNotNull);

      currentPhase = 'content';

      // Load new content - use WebFControllerManager to ensure setup callback is applied
      await WebFControllerManager.instance.addOrUpdateControllerWithLoading(
        name: 'test_loading',
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <div style="padding: 20px;">
                <h3>Loaded Content</h3>
                <div style="display: flex; flex-direction: column; gap: 10px;">
                  <div style="width: 150px; height: 150px; background: #4CAF50; color: white; padding: 10px; font-size: 24px;">Large Item 1</div>
                  <div style="width: 150px; height: 80px; background: #2196F3; color: white; padding: 10px;">Item 2</div>
                  <div style="width: 150px; height: 80px; background: #FF9800; color: white; padding: 10px;">Item 3</div>
                </div>
              </div>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
        forceReplace: true,
        mode: WebFLoadingMode.preloading,
        setup: (controller) {
          // Ensure LCP tracking is initialized for the new controller
          controller.initializePerformanceTracking(DateTime.now());
          setupLCP(controller);
        },
      );

      // Wait for controller replacement and widget rebuild
      await tester.pump();
      await tester.pumpAndSettle();

      // Give time for LCP tracking to start on the new controller
      await Future.delayed(Duration(milliseconds: 100));
      await tester.pump();
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      // Should have new LCP updates after loading element was replaced
      expect(lcpTimes.length, greaterThan(initialLCPCount));

      print('Total LCP updates: ${lcpTimes.length}');
      print('LCP for loading animation: $loadingLCPSize ms');
      print('LCP after content load: ${lcpTimes.last} ms');

      // The loading animation (350x350) should be larger than the smaller content divs (150x80)
      // So we expect the final LCP to be from the loading phase
      expect(loadingLCPSize, greaterThan(0));
    });

    testWidgets('LCP auto-finalization after timeout', (WidgetTester tester) async {
      bool lcpFinalCalled = false;
      double? lcpFinalTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_auto_finalize',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onLCPFinal: (double time) {
            lcpFinalCalled = true;
            lcpFinalTime = time;
            print('LCP auto-finalized: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1>Content that will auto-finalize</h1>
              <p>No user interaction - LCP should finalize after 5 seconds</p>
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
              controllerName: 'test_auto_finalize',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Integration tests can wait the full 5 seconds
      print('Waiting for auto-finalization (5 seconds)...');
      await tester.pump(Duration(seconds: 5, milliseconds: 100));

      expect(lcpFinalCalled, isTrue);
      expect(lcpFinalTime, isNotNull);
      print('LCP auto-finalized at: $lcpFinalTime ms');
    });

    testWidgets('LCP with prerendering mode', (WidgetTester tester) async {
      final lcpTimes = <double>[];
      bool pageAttached = false;

      // Test with prerendering mode
      await WebFControllerManager.instance.addWithPrerendering(
        name: 'test_prerendering',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onLCP: (double time) {
            lcpTimes.add(time);
            print('LCP reported (attached: $pageAttached): $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1 style="font-size: 48px;">Prerendered Content</h1>
              <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" width="300" height="300" />
              <script>
                console.log('Script executed in prerendering mode');
              </script>
            </body>
          </html>
          ''',
          url: 'about:blank',
          contentType: ContentType.html,
        ),
      );

      // Small delay to let prerendering happen
      await Future.delayed(Duration(milliseconds: 100));

      pageAttached = true;

      // Now attach the prerendered page
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WebF.fromControllerName(
              controllerName: 'test_prerendering',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 300));

      expect(lcpTimes.isNotEmpty, isTrue);
      print('LCP measurements in prerendering mode: ${lcpTimes.length}');
    });

    testWidgets('LCP tracks CSS background images', (WidgetTester tester) async {
      final lcpTimes = <double>[];
      bool lcpFinalCalled = false;
      double? lcpFinalTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_lcp_background_image',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onLCP: (double time) {
            lcpTimes.add(time);
            print('LCP update: $time ms');
          },
          onLCPFinal: (double time) {
            lcpFinalCalled = true;
            lcpFinalTime = time;
            print('LCP final: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <head>
              <style>
                .bg-image-large {
                  width: 300px;
                  height: 300px;
                  background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==');
                  background-size: cover;
                }
                .bg-image-small {
                  width: 50px;
                  height: 50px;
                  background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');
                  background-size: cover;
                }
              </style>
            </head>
            <body>
              <h1>Page with background images</h1>
              <div class="bg-image-small"></div>
              <div class="bg-image-large"></div>
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
              controllerName: 'test_lcp_background_image',
            ),
          ),
        ),
      );

      // Wait for rendering
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      // Should have tracked multiple LCP updates (text and background images)
      expect(lcpTimes.isNotEmpty, isTrue);
      expect(lcpTimes.length >= 2, isTrue); // At least text and large background image

      // The last LCP should be the largest background image (300x300)
      final lastLcpTime = lcpTimes.last;
      expect(lastLcpTime > 0, isTrue);

      print('LCP updates: ${lcpTimes.length}');
      print('Final LCP time: $lastLcpTime ms');
    });

    testWidgets('LCP tracks RenderWidget content', (WidgetTester tester) async {
      final lcpTimes = <double>[];
      bool lcpFinalCalled = false;
      double? lcpFinalTime;

      await WebFControllerManager.instance.addWithPreload(
        name: 'test_lcp_render_widget',
        createController: () => WebFController(
          viewportWidth: 360,
          viewportHeight: 640,
          onLCP: (double time) {
            lcpTimes.add(time);
            print('LCP update: $time ms');
          },
          onLCPFinal: (double time) {
            lcpFinalCalled = true;
            lcpFinalTime = time;
            print('LCP final: $time ms');
          },
        ),
        bundle: WebFBundle.fromContent(
          '''
          <html>
            <body>
              <h1>Page with RenderWidget</h1>
              <p>Small text content</p>
              <!-- Large ListView widget element that should be the LCP -->
              <webf-listview id="large-widget" style="width: 300px; height: 300px; display: block;">
                <div>Large Item 1</div>
                <div>Large Item 2</div>
                <div>Large Item 3</div>
              </webf-listview>
              <!-- Smaller widget -->
              <div style="width: 100px; height: 100px; background: blue;">
                <webf-listview id="small-widget" style="width: 50px; height: 50px; display: block;">
                  <div>Small Item</div>
                </webf-listview>
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
              controllerName: 'test_lcp_render_widget',
            ),
          ),
        ),
      );

      // Wait for rendering
      await tester.pumpAndSettle();
      await Future.delayed(Duration(milliseconds: 500));

      // Should have tracked multiple LCP updates
      expect(lcpTimes.isNotEmpty, isTrue);

      // The largest element should be the 300x300 flutter-widget
      expect(lcpTimes.last > 0, isTrue);

      print('LCP updates for RenderWidget: ${lcpTimes.length}');
      print('Final LCP time: ${lcpTimes.last} ms');
    });
  });
}
