/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'to_native.dart';

abstract class WebFThread {
  /// The unique ID for the current thread.
  /// [identity] < 0 represent running in Flutter UI Thread.
  /// [identity] >= 0 represent running in dedicated thread.
  /// [identity] with integer part are the same represent they are running in the same thread, for example, 1.1 and 1.2
  ///   will the grouped into one thread.
  double identity();

  /// In dedicated thread mode, WebF creates a shared buffer to record the UI operations that are generated from the JS thread.
  /// This approach allows the UI and JavaScript threads to run concurrently as much as possible in most use cases.
  /// Once the recorded commands reach the maximum buffer size, commands will be packaged by the JS thread and sent to
  /// the UI thread to be executed and apply visual UI changes.
  /// Setting this value to 0 in dedicated thread mode can achieve 100% concurrency but may reduce page speed because the
  /// generated UI commands will be executed on the UI thread immediately while the JS thread is still running.
  /// However, this concurrency sometimes leads to inconsistent UI rendering results,
  /// so it's advisable to adjust this value based on specific use cases.
  int syncBufferSize();
}

bool isContextDedicatedThread(double contextId) {
  return contextId >= 0;
}

/// Executes your JavaScript code within the Flutter UI thread.
class FlutterUIThread extends WebFThread {
  FlutterUIThread();

  @override
  int syncBufferSize() {
    return 0;
  }

  @override
  double identity() {
    return (-newPageId()).toDouble();
  }
}

/// Executes your JavaScript code in a dedicated thread.
class DedicatedThread extends WebFThread {
  double? _identity;
  final int _syncBufferSize;

  DedicatedThread({ int syncBufferSize = 4 }): _syncBufferSize = syncBufferSize;
  DedicatedThread._(this._identity, { int syncBufferSize = 4 }): _syncBufferSize = syncBufferSize;

  @override
  int syncBufferSize() {
    return _syncBufferSize;
  }

  @override
  double identity() {
    return _identity ?? (newPageId()).toDouble();
  }
}

/// Executes multiple JavaScript contexts in a single thread.
class DedicatedThreadGroup {
  int _slaveCount = 0;
  final int _identity = newPageId();

  DedicatedThreadGroup();

  DedicatedThread slave({ int syncBufferSize = 4 }) {
    String input = '$_identity.${_slaveCount++}';
    return DedicatedThread._(double.parse(input), syncBufferSize: syncBufferSize);
  }
}
