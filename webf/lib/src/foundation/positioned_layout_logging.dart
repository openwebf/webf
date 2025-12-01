/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:logging/logging.dart';

import 'logger.dart';

/// Implementation buckets for positioned layout logging.
/// Keep coarse to avoid excessive categories while providing context.
enum PositionedImpl {
  build,       // Widget/build-time wiring and attachment
  placeholder, // Placeholder creation/layout
  layout,      // Positioned child layout and offset resolution
}

/// Feature buckets for positioned layout logging.
enum PositionedFeature {
  wiring,           // Attaching/detaching placeholder ↔ positioned box
  layout,           // Layout passes and constraints/sizes
  staticPosition,   // Static-position computation/adjustments
  offsets,          // Final offset computation/application
  sticky,           // Sticky positioning updates
  fixed,            // Fixed-position paint-time adjustments
}

String _implLabel(PositionedImpl impl) {
  switch (impl) {
    case PositionedImpl.build:
      return 'Build';
    case PositionedImpl.placeholder:
      return 'Placeholder';
    case PositionedImpl.layout:
      return 'Layout';
  }
}

String _featureLabel(PositionedFeature feature) {
  switch (feature) {
    case PositionedFeature.wiring:
      return 'Wiring';
    case PositionedFeature.layout:
      return 'Layout';
    case PositionedFeature.staticPosition:
      return 'Static';
    case PositionedFeature.offsets:
      return 'Offsets';
    case PositionedFeature.sticky:
      return 'Sticky';
    case PositionedFeature.fixed:
      return 'Fixed';
  }
}

/// Centralized helper for positioned layout diagnostics.
///
/// Disabled by default. Enable by selecting impls/features via the static methods.
class PositionedLayoutLog {
  static Set<PositionedImpl>? _enabledImpls;
  static Set<PositionedFeature>? _enabledFeatures;

  static Set<PositionedImpl>? get enabledImpls => _enabledImpls;
  static Set<PositionedFeature>? get enabledFeatures => _enabledFeatures;

  /// Enable only the specified features. Empty set disables all.
  static void enableFeatures(Iterable<PositionedFeature> features) {
    _enabledFeatures = features.toSet();
  }

  /// Enable only the specified implementations.
  static void enableImpls(Iterable<PositionedImpl> impls) {
    _enabledImpls = impls.toSet();
  }

  /// Enable all impls/features.
  static void enableAll() {
    _enabledImpls = PositionedImpl.values.toSet();
    _enabledFeatures = PositionedFeature.values.toSet();
  }

  /// Disable all impls/features (without removing filters object).
  static void disableAll() {
    _enabledImpls = <PositionedImpl>{};
    _enabledFeatures = <PositionedFeature>{};
  }

  static bool _allowed(PositionedImpl impl, PositionedFeature feature) {
    // Logging is active only when filters are configured explicitly.
    if (_enabledImpls == null && _enabledFeatures == null) return false;
    if (_enabledImpls != null && !_enabledImpls!.contains(impl)) return false;
    if (_enabledFeatures != null && !_enabledFeatures!.contains(feature)) return false;
    return true;
  }

  static void log({
    required PositionedImpl impl,
    required PositionedFeature feature,
    required String Function() message,
    Level level = Level.FINER,
  }) {
    if (!_allowed(impl, feature)) return;
    final prefix = '[POS/${_implLabel(impl)}/${_featureLabel(feature)}]';
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

