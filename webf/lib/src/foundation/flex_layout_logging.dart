/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:logging/logging.dart';

import 'logger.dart';

/// Implementation buckets for flex layout logging.
/// Keep coarse to avoid excessive categories while providing context.
enum FlexImpl {
  runMetrics,      // Intrinsic pass and flex line computation
  flexibleLengths, // Free space distribution (grow/shrink) and relayout
  container,       // Container sizing and min-content autos
  offset,          // Children offsets / alignment
}

/// Feature buckets for flex layout logging.
enum FlexFeature {
  constraints, // Container and item constraints / available sizes
  baseSize,    // Flex-basis / intrinsic base size and min/max clamping
  wrapping,    // Line breaking and flex-wrap decisions
  distribution,// Free space computation and flexible length resolution
  alignment,   // Justify-content / align-items / align-content behavior
}

String _implLabel(FlexImpl impl) {
  switch (impl) {
    case FlexImpl.runMetrics:
      return 'Run';
    case FlexImpl.flexibleLengths:
      return 'Flex';
    case FlexImpl.container:
      return 'Container';
    case FlexImpl.offset:
      return 'Offset';
  }
}

String _featureLabel(FlexFeature feature) {
  switch (feature) {
    case FlexFeature.constraints:
      return 'Constraints';
    case FlexFeature.baseSize:
      return 'Base';
    case FlexFeature.wrapping:
      return 'Wrap';
    case FlexFeature.distribution:
      return 'Dist';
    case FlexFeature.alignment:
      return 'Align';
  }
}

/// Centralized helper for flex layout diagnostics.
///
/// Disabled by default. Enable by selecting impls/features via the static methods.
/// Example:
/// ```dart
/// FlexLayoutLog.enableImpls([FlexImpl.runMetrics, FlexImpl.flexibleLengths]);
/// FlexLayoutLog.enableFeatures([FlexFeature.baseSize, FlexFeature.distribution]);
/// ```
class FlexLayoutLog {
  static Set<FlexImpl>? _enabledImpls;
  static Set<FlexFeature>? _enabledFeatures;

  static Set<FlexImpl>? get enabledImpls => _enabledImpls;
  static Set<FlexFeature>? get enabledFeatures => _enabledFeatures;

  /// Enable only the specified features. Empty set disables all.
  static void enableFeatures(Iterable<FlexFeature> features) {
    _enabledFeatures = features.toSet();
  }

  /// Enable only the specified implementations.
  static void enableImpls(Iterable<FlexImpl> impls) {
    _enabledImpls = impls.toSet();
  }

  /// Enable all impls/features.
  static void enableAll() {
    _enabledImpls = FlexImpl.values.toSet();
    _enabledFeatures = FlexFeature.values.toSet();
  }

  /// Disable all impls/features (without removing filters object).
  static void disableAll() {
    _enabledImpls = <FlexImpl>{};
    _enabledFeatures = <FlexFeature>{};
  }

  static bool _allowed(FlexImpl impl, FlexFeature feature) {
    // Logging is active only when filters are configured explicitly.
    if (_enabledImpls == null && _enabledFeatures == null) return false;
    if (_enabledImpls != null && !_enabledImpls!.contains(impl)) return false;
    if (_enabledFeatures != null && !_enabledFeatures!.contains(feature)) return false;
    return true;
  }

  static void log({
    required FlexImpl impl,
    required FlexFeature feature,
    required String Function() message,
    Level level = Level.FINER,
  }) {
    if (!_allowed(impl, feature)) return;
    final prefix = '[FLEX/${_implLabel(impl)}/${_featureLabel(feature)}]';
    final text = '$prefix ${message()}';
    if (level == Level.FINE) {
      renderingLogger.fine(text);
    } else if (level == Level.FINER) {
      renderingLogger.finer(text);
    } else if (level == Level.FINEST) {
      renderingLogger.finest(text);
    } else if (level == Level.INFO) {
      renderingLogger.info(text);
    } else if (level == Level.WARNING) {
      renderingLogger.warning(text);
    } else if (level == Level.SEVERE) {
      renderingLogger.severe(text);
    } else {
      renderingLogger.finer(text);
    }
  }
}

