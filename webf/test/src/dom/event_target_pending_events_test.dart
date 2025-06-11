/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart';

// Mock EventTarget for testing
class MockEventTarget extends EventTarget {
  MockEventTarget() : super(null);
  
  @override
  EventTarget? get parentEventTarget => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('EventTarget Pending Events', () {
    late MockEventTarget eventTarget;

    setUp(() {
      eventTarget = MockEventTarget();
    });

    test('should track pending dispatchEvent operations', () async {
      // Initially no pending events
      expect(eventTarget.hasPendingEvents(), isFalse);
      
      // Create a slow event handler
      bool eventHandled = false;
      eventTarget.addEventListener('test', (event) async {
        await Future.delayed(Duration(milliseconds: 100));
        eventHandled = true;
      });
      
      // Dispatch event without awaiting
      Event testEvent = Event('test');
      Future<void> dispatchFuture = eventTarget.dispatchEvent(testEvent);
      
      // Should have pending events
      expect(eventTarget.hasPendingEvents(), isTrue);
      
      // Wait for event to complete
      await dispatchFuture;
      
      // Should no longer have pending events
      expect(eventTarget.hasPendingEvents(), isFalse);
      expect(eventHandled, isTrue);
    });

    test('should wait for all pending events to complete', () async {
      bool event1Handled = false;
      bool event2Handled = false;
      
      // Add event handlers with different delays
      eventTarget.addEventListener('test1', (event) async {
        await Future.delayed(Duration(milliseconds: 50));
        event1Handled = true;
      });
      
      eventTarget.addEventListener('test2', (event) async {
        await Future.delayed(Duration(milliseconds: 100));
        event2Handled = true;
      });
      
      // Dispatch events without awaiting
      Event event1 = Event('test1');
      Event event2 = Event('test2');
      eventTarget.dispatchEvent(event1); // Don't await
      eventTarget.dispatchEvent(event2); // Don't await
      
      // Should have pending events
      expect(eventTarget.hasPendingEvents(), isTrue);
      
      // Wait for all pending events
      await eventTarget.waitForPendingEvents();
      
      // All events should be handled
      expect(event1Handled, isTrue);
      expect(event2Handled, isTrue);
      expect(eventTarget.hasPendingEvents(), isFalse);
    });

    test('should handle multiple concurrent dispatch operations', () async {
      int eventsHandled = 0;
      
      eventTarget.addEventListener('test', (event) async {
        await Future.delayed(Duration(milliseconds: 10));
        eventsHandled++;
      });
      
      // Dispatch multiple events concurrently
      List<Future<void>> futures = [];
      for (int i = 0; i < 5; i++) {
        Event event = Event('test');
        futures.add(eventTarget.dispatchEvent(event));
      }
      
      // Should have pending events
      expect(eventTarget.hasPendingEvents(), isTrue);
      
      // Wait for all events to complete
      await Future.wait(futures);
      
      // All events should be handled
      expect(eventsHandled, equals(5));
      expect(eventTarget.hasPendingEvents(), isFalse);
    });

    test('should handle exceptions in event handlers gracefully', () async {
      bool goodEventHandled = false;
      
      // Add handlers - one that throws, one that works
      eventTarget.addEventListener('bad', (event) async {
        await Future.delayed(Duration(milliseconds: 10));
        throw Exception('Test exception');
      });
      
      eventTarget.addEventListener('good', (event) async {
        await Future.delayed(Duration(milliseconds: 20));
        goodEventHandled = true;
      });
      
      // Dispatch both events
      Event badEvent = Event('bad');
      Event goodEvent = Event('good');
      
      // The bad event should not prevent the good event from working
      await eventTarget.dispatchEvent(badEvent);
      await eventTarget.dispatchEvent(goodEvent);
      
      expect(goodEventHandled, isTrue);
      expect(eventTarget.hasPendingEvents(), isFalse);
    });

    test('should clear pending events on dispose', () async {
      eventTarget.addEventListener('test', (event) async {
        await Future.delayed(Duration(milliseconds: 100));
      });
      
      // Start dispatching an event
      Event testEvent = Event('test');
      eventTarget.dispatchEvent(testEvent); // Don't await
      
      // Should have pending events
      expect(eventTarget.hasPendingEvents(), isTrue);
      
      // Dispose the event target
      eventTarget.dispose();
      
      // Pending events should be cleared (though the actual futures may still be running)
      expect(eventTarget.hasPendingEvents(), isFalse);
    });
  });
}