/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

import 'logger.dart';

/// Implementation categories for WidgetElement/RenderWidget logs.
enum WidgetImpl { widget }

/// Feature buckets for grouping RenderWidget diagnostics.
enum WidgetFeature {
  constraints,
  sizing,
  layout,
  intrinsic,
}

String _implLabel(WidgetImpl impl) {
  switch (impl) {
    case WidgetImpl.widget:
      return 'Widget';
  }
}

String _featureLabel(WidgetFeature feature) {
  switch (feature) {
    case WidgetFeature.constraints:
      return 'Constraints';
    case WidgetFeature.sizing:
      return 'Sizing';
    case WidgetFeature.layout:
      return 'Layout';
    case WidgetFeature.intrinsic:
      return 'Intrinsic';
  }
}

/// Centralized helper for grouped RenderWidget logs with per-feature/impl filters.
class WidgetLog {
  static Set<WidgetImpl>? _enabledImpls;
  static Set<WidgetFeature>? _enabledFeatures;

  static Set<WidgetImpl>? get enabledImpls => _enabledImpls;
  static Set<WidgetFeature>? get enabledFeatures => _enabledFeatures;

  static void enableImpls(Iterable<WidgetImpl> impls) {
    _enabledImpls = impls.toSet();
  }

  static void enableFeatures(Iterable<WidgetFeature> features) {
    _enabledFeatures = features.toSet();
  }

  static void enableAll() {
    _enabledImpls = WidgetImpl.values.toSet();
    _enabledFeatures = WidgetFeature.values.toSet();
  }

  static void disableAll() {
    _enabledImpls = <WidgetImpl>{};
    _enabledFeatures = <WidgetFeature>{};
  }

  static bool _allowed(WidgetImpl impl, WidgetFeature feature) {
    // No global switch; logging is enabled only by selecting implementations/features.
    // If both filters are null (never configured), treat as disabled.
    if (_enabledImpls == null && _enabledFeatures == null) return false;
    if (_enabledImpls != null && !_enabledImpls!.contains(impl)) return false;
    if (_enabledFeatures != null && !_enabledFeatures!.contains(feature)) return false;
    return true;
  }

  static void log({
    required WidgetImpl impl,
    required WidgetFeature feature,
    required String Function() message,
    Level level = Level.FINER,
  }) {
    // Only emit logs in debug mode.
    if (!kDebugMode) return;
    if (!_allowed(impl, feature)) return;
    final prefix = '[Widget/${_implLabel(impl)}/${_featureLabel(feature)}]';
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

