/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'dart:ui';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:ffi/ffi.dart';
import 'package:webf/bridge.dart';

typedef CleanupTask = void Function();

// FFI binding for the C++ batch free function
typedef NativeBatchFreeFunction = Void Function(Pointer<Void> pointers, Int32 count);
typedef DartBatchFreeFunction = void Function(Pointer<Void> pointers, int count);

late final DartBatchFreeFunction _batchFreeNativeBindingObjects =
    WebFDynamicLibrary.ref.lookupFunction<NativeBatchFreeFunction, DartBatchFreeFunction>(
        'batchFreeNativeBindingObjects');

/// Global idle cleanup manager that batches malloc.free operations for better performance
/// without depending on any WebFController or specific context.
class IdleCleanupManager {
  static final IdleCleanupManager _instance = IdleCleanupManager._internal();
  factory IdleCleanupManager() => _instance;
  IdleCleanupManager._internal();

  // Batched pointer cleanup state
  final List<Pointer> _pendingPointers = [];
  final List<CleanupTask> _pendingCleanupTasks = [];
  bool _cleanupScheduled = false;
  static const int _batchThreshold = 500;
  static const int _maxPointersPerIdle = 100;
  final Map<int, bool> _activeIdleCallbacks = {};

  /// Schedule a cleanup task to be executed during idle time
  static void scheduleIdleCleanup(CleanupTask task) {
    _instance._scheduleTask(task);
  }

  /// Schedule a pointer to be freed in batch during idle time
  /// If threshold is reached, immediately trigger batch free
  static void schedulePointerCleanup(Pointer pointer) {
    _instance._schedulePointer(pointer);
  }

  void _scheduleTask(CleanupTask task) {
    _pendingCleanupTasks.add(task);
    if (!_cleanupScheduled && _pendingCleanupTasks.isNotEmpty) {
      _scheduleCleanupPipeline();
    }
  }

  void _schedulePointer(Pointer pointer) {
    _pendingPointers.add(pointer);

    // If we hit the threshold, trigger immediate batch free
    if (_pendingPointers.length >= _batchThreshold) {
      _batchFreePointers();
    } else if (!_cleanupScheduled) {
      _scheduleCleanupPipeline();
    }
  }

  /// Schedule the cleanup pipeline to run during the next idle period
  void _scheduleCleanupPipeline() {
    if (_cleanupScheduled) return;
    _cleanupScheduled = true;

    // Use a unique idle callback ID for cleanup pipeline
    int cleanupIdleId = DateTime.now().millisecondsSinceEpoch;
    _activeIdleCallbacks[cleanupIdleId] = true;

    // Schedule cleanup to run when frame is idle
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (!_activeIdleCallbacks.containsKey(cleanupIdleId)) return;

      _processCleanupTasks();
      _cleanupScheduled = false;
      _activeIdleCallbacks.remove(cleanupIdleId);

      // If there are more cleanup tasks, schedule another idle callback
      if (_pendingCleanupTasks.isNotEmpty) {
        _scheduleCleanupPipeline();
      }
    });

    SchedulerBinding.instance.scheduleFrame();
  }

  /// Process cleanup tasks and pointers during idle time
  void _processCleanupTasks() {
    if (_pendingCleanupTasks.isEmpty && _pendingPointers.isEmpty) return;

    // Calculate remaining time based on display refresh rate
    Display display = WidgetsBinding.instance.platformDispatcher.views.first.display;
    double maxFrameTime = 1000 / display.refreshRate;

    // Reserve some time for system operations (2ms minimum)
    double timeForCleanup = maxFrameTime - 2.0;
    if (timeForCleanup <= 0) return;

    DateTime startTime = DateTime.now();

    // Process pointers first (batch free is more efficient)
    if (_pendingPointers.isNotEmpty) {
      int pointersToProcess = _pendingPointers.length > _maxPointersPerIdle
          ? _maxPointersPerIdle
          : _pendingPointers.length;

      List<Pointer> batch = _pendingPointers.take(pointersToProcess).toList();
      _pendingPointers.removeRange(0, pointersToProcess);

      try {
        _batchFreePointersArray(batch);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error in batch pointer cleanup: $e');
        }
      }
    }

    // Process remaining cleanup tasks if we have time
    int processedTasks = 0;
    const int maxTasksPerIdle = 10;

    while (_pendingCleanupTasks.isNotEmpty &&
           processedTasks < maxTasksPerIdle &&
           (DateTime.now().difference(startTime).inMilliseconds < timeForCleanup)) {

      CleanupTask task = _pendingCleanupTasks.removeAt(0);
      try {
        task();
        processedTasks++;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error in idle cleanup task: $e');
        }
      }
    }
  }

  /// Batch free all pending pointers immediately
  void _batchFreePointers() {
    if (_pendingPointers.isEmpty) return;

    List<Pointer> pointersToFree = List.from(_pendingPointers);
    _pendingPointers.clear();

    try {
      _batchFreePointersArray(pointersToFree);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in immediate batch pointer cleanup: $e');
      }
    }
  }

  /// Call the C++ batch free function with an array of pointers
  void _batchFreePointersArray(List<Pointer> pointers) {
    if (pointers.isEmpty) return;

    // Convert Dart List<Pointer> to C array
    Pointer<Pointer<Void>> pointersArray = malloc<Pointer<Void>>(pointers.length);

    for (int i = 0; i < pointers.length; i++) {
      pointersArray[i] = pointers[i].cast<Void>();
    }

    try {
      // Call the C++ batch free function
      _batchFreeNativeBindingObjects(pointersArray.cast<Void>(), pointers.length);
    } finally {
      // Always free the temporary array
      malloc.free(pointersArray);
    }
  }

  /// Cancel all pending cleanup tasks
  static void cancelAllCleanupTasks() {
    _instance._cancelAll();
  }

  void _cancelAll() {
    _pendingCleanupTasks.clear();
    _pendingPointers.clear();
    _activeIdleCallbacks.clear();
    _cleanupScheduled = false;
  }

  /// Get the current number of pending cleanup tasks
  static int get pendingTasksCount => _instance._pendingCleanupTasks.length;

  /// Get the current number of pending pointers waiting to be freed
  static int get pendingPointersCount => _instance._pendingPointers.length;

  /// Get the total number of pending cleanup operations
  static int get totalPendingCount => pendingTasksCount + pendingPointersCount;

  /// Check if cleanup is currently scheduled
  static bool get isCleanupScheduled => _instance._cleanupScheduled;

  /// Get the batch threshold for immediate pointer cleanup
  static int get batchThreshold => _batchThreshold;
}
