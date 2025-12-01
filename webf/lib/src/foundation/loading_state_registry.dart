/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:webf/launcher.dart';

/// A global registry to access LoadingStateDumper instances by contextId.
/// This allows network requests and other low-level components to report
/// loading state without direct access to the controller.
class LoadingStateRegistry {
  static final LoadingStateRegistry _instance = LoadingStateRegistry._internal();

  LoadingStateRegistry._internal();

  static LoadingStateRegistry get instance => _instance;

  final Map<double, LoadingState> _dumpers = {};

  /// Register a LoadingStateDumper for a specific contextId
  void register(double contextId, LoadingState dumper) {
    _dumpers[contextId] = dumper;
  }

  /// Unregister a LoadingStateDumper when the context is disposed
  void unregister(double contextId) {
    _dumpers.remove(contextId);
  }

  /// Get the LoadingStateDumper for a specific contextId
  LoadingState? getDumper(double contextId) {
    return _dumpers[contextId];
  }

  /// Clear all registered dumpers
  void clear() {
    _dumpers.clear();
  }
}
