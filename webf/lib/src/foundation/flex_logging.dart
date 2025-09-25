import 'package:logging/logging.dart';

import 'debug_flags.dart';
import 'logger.dart';

/// Implementation categories for Flex logs.
enum FlexImpl { flex }

/// Feature buckets for grouping Flex diagnostics.
enum FlexFeature {
  container,
  intrinsic,
  basis,
  baseSize,
  runs,
  resolve,
  childConstraints,
  alignment,
}

String _implLabel(FlexImpl impl) {
  switch (impl) {
    case FlexImpl.flex:
      return 'Flex';
  }
}

String _featureLabel(FlexFeature feature) {
  switch (feature) {
    case FlexFeature.container:
      return 'Container';
    case FlexFeature.intrinsic:
      return 'Intrinsic';
    case FlexFeature.basis:
      return 'Basis';
    case FlexFeature.baseSize:
      return 'BaseSize';
    case FlexFeature.runs:
      return 'Runs';
    case FlexFeature.resolve:
      return 'Resolve';
    case FlexFeature.childConstraints:
      return 'ChildConstraints';
    case FlexFeature.alignment:
      return 'Alignment';
  }
}

class FlexLog {
  static Set<FlexImpl>? _enabledImpls;
  static Set<FlexFeature>? _enabledFeatures;

  static Set<FlexImpl>? get enabledImpls => _enabledImpls;
  static Set<FlexFeature>? get enabledFeatures => _enabledFeatures;

  static void enableImpls(Iterable<FlexImpl> impls) {
    _enabledImpls = impls.toSet();
  }

  static void enableFeatures(Iterable<FlexFeature> features) {
    _enabledFeatures = features.toSet();
  }

  static void enableAll() {
    _enabledImpls = FlexImpl.values.toSet();
    _enabledFeatures = FlexFeature.values.toSet();
  }

  static void disableAll() {
    _enabledImpls = <FlexImpl>{};
    _enabledFeatures = <FlexFeature>{};
  }

  static bool _allowed(FlexImpl impl, FlexFeature feature) {
    // No global switch; logging is enabled only by selecting implementations/features.
    // If both filters are null (never configured), treat as disabled.
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
    final prefix = '[Flex/${_implLabel(impl)}/${_featureLabel(feature)}]';
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
