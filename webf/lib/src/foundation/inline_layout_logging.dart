import 'package:logging/logging.dart';

import 'debug_flags.dart';
import 'logger.dart';

/// Implementation flavors that emit inline layout logs.
enum InlineImpl { paragraphIFC, legacyIFC, flow }

/// Feature areas for grouping inline layout diagnostics.
enum InlineFeature {
  decision,
  sizing,
  baselines,
  offsets,
  scrollable,
  painting,
  placeholders,
  text,
  metrics,
}

String _implLabel(InlineImpl impl) {
  switch (impl) {
    case InlineImpl.paragraphIFC:
      return 'Paragraph';
    case InlineImpl.legacyIFC:
      return 'Legacy';
    case InlineImpl.flow:
      return 'Flow';
  }
}

String _featureLabel(InlineFeature feature) {
  switch (feature) {
    case InlineFeature.decision:
      return 'Decision';
    case InlineFeature.sizing:
      return 'Sizing';
    case InlineFeature.baselines:
      return 'Baselines';
    case InlineFeature.offsets:
      return 'Offsets';
    case InlineFeature.scrollable:
      return 'Scrollable';
    case InlineFeature.painting:
      return 'Painting';
    case InlineFeature.placeholders:
      return 'Placeholders';
    case InlineFeature.text:
      return 'Text';
    case InlineFeature.metrics:
      return 'Metrics';
  }
}

/// Centralized helper to print grouped inline layout debug logs.
/// No global toggle; enable by selecting impls/features below.
class InlineLayoutLog {
  // Optional filters. When null, all impls/features are allowed while the global flag is on.
  static Set<InlineImpl>? _enabledImpls;
  static Set<InlineFeature>? _enabledFeatures;

  static Set<InlineImpl>? get enabledImpls => _enabledImpls;
  static Set<InlineFeature>? get enabledFeatures => _enabledFeatures;

  /// Enable only specific features. Pass empty to disable all inline logs when the global flag is on.
  static void enableFeatures(Iterable<InlineFeature> features) {
    _enabledFeatures = features.toSet();
  }

  /// Enable only specific implementations (Paragraph, Legacy, Flow).
  static void enableImpls(Iterable<InlineImpl> impls) {
    _enabledImpls = impls.toSet();
  }

  /// Reset filters to allow all impls/features.
  static void enableAll() {
    _enabledImpls = InlineImpl.values.toSet();
    _enabledFeatures = InlineFeature.values.toSet();
  }

  /// Disable all inline logs without changing the global flag.
  static void disableAll() {
    _enabledImpls = <InlineImpl>{};
    _enabledFeatures = <InlineFeature>{};
  }

  

  static bool _allowed(InlineImpl impl, InlineFeature feature) {
    // Logging enabled only when at least one filter is configured.
    if (_enabledImpls == null && _enabledFeatures == null) return false;
    if (_enabledImpls != null && !_enabledImpls!.contains(impl)) return false;
    if (_enabledFeatures != null && !_enabledFeatures!.contains(feature)) return false;
    return true;
  }

  /// Log a message grouped by implementation and feature.
  static void log({
    required InlineImpl impl,
    required InlineFeature feature,
    required String Function() message,
    Level level = Level.FINER,
  }) {
    if (!_allowed(impl, feature)) return;
    final prefix = '[IFC/${_implLabel(impl)}/${_featureLabel(feature)}]';
    final text = '$prefix ${message()}';
    // Use the rendering logger; categories are encoded in the prefix for grouping.
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
