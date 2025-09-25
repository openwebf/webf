import 'package:logging/logging.dart';

import 'debug_flags.dart';
import 'logger.dart';

/// Implementation categories for flow layout logs.
enum FlowImpl { flow, ifc, overflow }

/// Feature buckets for grouping flow diagnostics.
enum FlowFeature {
  constraints,
  sizing,
  layout,
  painting,
  child,
  runs,
  marginCollapse,
  scrollable,
  shrinkToFit,
  widthBreakdown,
  setup,
}

String _implLabel(FlowImpl impl) {
  switch (impl) {
    case FlowImpl.flow:
      return 'Flow';
    case FlowImpl.ifc:
      return 'IFC';
    case FlowImpl.overflow:
      return 'Overflow';
  }
}

String _featureLabel(FlowFeature feature) {
  switch (feature) {
    case FlowFeature.constraints:
      return 'Constraints';
    case FlowFeature.sizing:
      return 'Sizing';
    case FlowFeature.layout:
      return 'Layout';
    case FlowFeature.painting:
      return 'Painting';
    case FlowFeature.child:
      return 'Child';
    case FlowFeature.runs:
      return 'Runs';
    case FlowFeature.marginCollapse:
      return 'MarginCollapse';
    case FlowFeature.scrollable:
      return 'Scrollable';
    case FlowFeature.shrinkToFit:
      return 'ShrinkToFit';
    case FlowFeature.widthBreakdown:
      return 'WidthBreakdown';
    case FlowFeature.setup:
      return 'Setup';
  }
}

/// Centralized helper for grouped Flow logs with per-feature/impl filters.
class FlowLog {
  static Set<FlowImpl>? _enabledImpls;
  static Set<FlowFeature>? _enabledFeatures;

  static Set<FlowImpl>? get enabledImpls => _enabledImpls;
  static Set<FlowFeature>? get enabledFeatures => _enabledFeatures;

  static void enableImpls(Iterable<FlowImpl> impls) {
    _enabledImpls = impls.toSet();
  }

  static void enableFeatures(Iterable<FlowFeature> features) {
    _enabledFeatures = features.toSet();
  }

  static void enableAll() {
    _enabledImpls = FlowImpl.values.toSet();
    _enabledFeatures = FlowFeature.values.toSet();
  }

  static void disableAll() {
    _enabledImpls = <FlowImpl>{};
    _enabledFeatures = <FlowFeature>{};
  }

  static bool _allowed(FlowImpl impl, FlowFeature feature) {
    // No global switch; logging enabled by selected impls/features only.
    if (_enabledImpls == null && _enabledFeatures == null) return false;
    if (_enabledImpls != null && !_enabledImpls!.contains(impl)) return false;
    if (_enabledFeatures != null && !_enabledFeatures!.contains(feature)) return false;
    return true;
  }

  static void log({
    required FlowImpl impl,
    required FlowFeature feature,
    required String Function() message,
    Level level = Level.FINER,
  }) {
    if (!_allowed(impl, feature)) return;
    final prefix = '[Flow/${_implLabel(impl)}/${_featureLabel(feature)}]';
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
