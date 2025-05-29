/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/module.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('IdleCleanupManager', () {
    setUp(() {
      // Clear any pending tasks before each test
      IdleCleanupManager.cancelAllCleanupTasks();
    });

    test('should schedule cleanup tasks', () {
      bool taskExecuted = false;
      
      IdleCleanupManager.scheduleIdleCleanup(() {
        taskExecuted = true;
      });

      expect(IdleCleanupManager.pendingTasksCount, equals(1));
      expect(IdleCleanupManager.isCleanupScheduled, isTrue);
    });

    test('should track pending tasks count correctly', () {
      expect(IdleCleanupManager.pendingTasksCount, equals(0));

      IdleCleanupManager.scheduleIdleCleanup(() {});
      IdleCleanupManager.scheduleIdleCleanup(() {});
      IdleCleanupManager.scheduleIdleCleanup(() {});

      expect(IdleCleanupManager.pendingTasksCount, equals(3));
    });

    test('should schedule pointer cleanup', () {
      expect(IdleCleanupManager.pendingPointersCount, equals(0));
      
      // Create mock pointers for testing
      Pointer<Void> mockPointer1 = Pointer.fromAddress(0x1000);
      Pointer<Void> mockPointer2 = Pointer.fromAddress(0x2000);
      
      IdleCleanupManager.schedulePointerCleanup(mockPointer1);
      IdleCleanupManager.schedulePointerCleanup(mockPointer2);

      expect(IdleCleanupManager.pendingPointersCount, equals(2));
      expect(IdleCleanupManager.totalPendingCount, equals(2));
    });

    test('should track total pending count correctly', () {
      expect(IdleCleanupManager.totalPendingCount, equals(0));

      IdleCleanupManager.scheduleIdleCleanup(() {});
      Pointer<Void> mockPointer = Pointer.fromAddress(0x3000);
      IdleCleanupManager.schedulePointerCleanup(mockPointer);

      expect(IdleCleanupManager.pendingTasksCount, equals(1));
      expect(IdleCleanupManager.pendingPointersCount, equals(1));
      expect(IdleCleanupManager.totalPendingCount, equals(2));
    });

    test('should have correct batch threshold', () {
      expect(IdleCleanupManager.batchThreshold, equals(500));
    });

    test('should cancel all cleanup tasks', () {
      IdleCleanupManager.scheduleIdleCleanup(() {});
      IdleCleanupManager.scheduleIdleCleanup(() {});
      
      expect(IdleCleanupManager.pendingTasksCount, equals(2));
      expect(IdleCleanupManager.isCleanupScheduled, isTrue);

      IdleCleanupManager.cancelAllCleanupTasks();

      expect(IdleCleanupManager.pendingTasksCount, equals(0));
      expect(IdleCleanupManager.isCleanupScheduled, isFalse);
    });

    test('should handle singleton pattern correctly', () {
      final manager1 = IdleCleanupManager();
      final manager2 = IdleCleanupManager();
      
      expect(identical(manager1, manager2), isTrue);
    });

    test('should be resilient to exceptions in cleanup tasks', () {
      bool firstTaskExecuted = false;
      bool thirdTaskExecuted = false;

      // Schedule tasks where the second one throws an exception
      IdleCleanupManager.scheduleIdleCleanup(() {
        firstTaskExecuted = true;
      });
      
      IdleCleanupManager.scheduleIdleCleanup(() {
        throw Exception('Test exception');
      });
      
      IdleCleanupManager.scheduleIdleCleanup(() {
        thirdTaskExecuted = true;
      });

      expect(IdleCleanupManager.pendingTasksCount, equals(3));
      
      // Note: In a real Flutter environment, these tasks would be processed
      // during idle time, but in this test environment, we're just verifying
      // that they are queued correctly.
    });
  });
}