import 'to_native.dart';

abstract class WebFThread {
  double identity();
}

/// Executes your JavaScript code within the Flutter UI thread.
class FlutterUIThread extends WebFThread {
  FlutterUIThread();

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
