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
  int syncBufferSize() {
    return 4;
  }
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
  final double? _identity;

  DedicatedThread([this._identity]);

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

  DedicatedThread slave() {
    String input = '$_identity.${_slaveCount++}';
    return DedicatedThread(double.parse(input));
  }
}
