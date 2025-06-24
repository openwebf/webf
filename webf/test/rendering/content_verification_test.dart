/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/foundation.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

void main() {
  group('ContentVerification', () {
    setUpAll(() {
      WebFBundle.enableAssertionInRelease = true;
    });

    setUp(() {
      setupTest();
    });

    test('detects blank page', () async {
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent(
          '<html><body></body></html>',
          contentType: ContentType.html,
        ),
      );

      await controller.controlledInitCompleter.future;
      
      // Check for visible content
      expect(ContentVerification.hasVisibleContent(controller), isFalse);
      
      final info = ContentVerification.getContentInfo(controller);
      expect(info.isBlank, isTrue);
      expect(info.totalElements, equals(0));
      expect(info.description, equals('Page is blank (no visible content)'));
      
      controller.dispose();
    });

    test('detects text content', () async {
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent(
          '<html><body><h1>Hello World</h1></body></html>',
          contentType: ContentType.html,
        ),
      );

      await controller.controlledInitCompleter.future;
      
      // Wait for rendering to complete
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(ContentVerification.hasVisibleContent(controller), isTrue);
      
      final info = ContentVerification.getContentInfo(controller);
      expect(info.isBlank, isFalse);
      expect(info.textElements, greaterThan(0));
      expect(info.description, contains('text'));
      
      controller.dispose();
    });

    test('detects background colors', () async {
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent(
          '<html><body style="background: red;"></body></html>',
          contentType: ContentType.html,
        ),
      );

      await controller.controlledInitCompleter.future;
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(ContentVerification.hasVisibleContent(controller), isTrue);
      
      final info = ContentVerification.getContentInfo(controller);
      expect(info.isBlank, isFalse);
      expect(info.decoratedElements, greaterThan(0));
      
      controller.dispose();
    });

    test('detects images', () async {
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent(
          '''<html><body>
            <img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" width="100" height="100">
          </body></html>''',
          contentType: ContentType.html,
        ),
      );

      await controller.controlledInitCompleter.future;
      await Future.delayed(Duration(milliseconds: 200));
      
      expect(ContentVerification.hasVisibleContent(controller), isTrue);
      
      final info = ContentVerification.getContentInfo(controller);
      expect(info.isBlank, isFalse);
      expect(info.imageElements, greaterThan(0));
      expect(info.description, contains('images'));
      
      controller.dispose();
    });

    test('ignores invisible content', () async {
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent(
          '''<html><body>
            <div style="display: none;">Hidden text</div>
            <div style="opacity: 0;">Transparent text</div>
            <div style="visibility: hidden;">Invisible text</div>
          </body></html>''',
          contentType: ContentType.html,
        ),
      );

      await controller.controlledInitCompleter.future;
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(ContentVerification.hasVisibleContent(controller), isFalse);
      
      final info = ContentVerification.getContentInfo(controller);
      expect(info.isBlank, isTrue);
      expect(info.totalElements, equals(0));
      
      controller.dispose();
    });

    test('waitForVisibleContent works', () async {
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent(
          '''<html><body>
            <div id="content"></div>
            <script>
              setTimeout(() => {
                document.getElementById('content').textContent = 'Delayed content';
              }, 200);
            </script>
          </body></html>''',
          contentType: ContentType.html,
        ),
      );

      await controller.controlledInitCompleter.future;
      
      // Initially no visible content
      expect(ContentVerification.hasVisibleContent(controller), isFalse);
      
      // Wait for content to appear
      final hasContent = await ContentVerification.waitForVisibleContent(
        controller,
        timeout: Duration(seconds: 1),
      );
      
      expect(hasContent, isTrue);
      expect(ContentVerification.hasVisibleContent(controller), isTrue);
      
      controller.dispose();
    });

    test('detects Flutter widgets', () async {
      final controller = WebFController(
        viewportWidth: 360,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent(
          '<html><body><flutter>Container</flutter></body></html>',
          contentType: ContentType.html,
        ),
      );

      // Define a custom Flutter widget element
      WebF.defineCustomElement('flutter', (context, attributes) {
        return Container(
          width: 100,
          height: 100,
          color: Colors.blue,
          child: Center(child: Text('Flutter Widget')),
        );
      });

      await controller.controlledInitCompleter.future;
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(ContentVerification.hasVisibleContent(controller), isTrue);
      
      final info = ContentVerification.getContentInfo(controller);
      expect(info.isBlank, isFalse);
      expect(info.widgetElements, greaterThan(0));
      expect(info.description, contains('widgets'));
      
      controller.dispose();
    });
  });
}