/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/widget.dart';

/// Base interface for all form elements (input, textarea, etc.)
/// This provides a common interface that state mixins can rely on
abstract class FormElementBase implements WidgetElement {
  // Common properties that all form elements should have
  String get type;
  bool get disabled;
  String? get value;
  set value(dynamic value);
}

/// Base mixin for form element state classes
/// This ensures all state classes have access to a properly typed widgetElement
mixin FormElementStateMixin<T extends FormElementBase> on WebFWidgetElementState {
  @override
  T get widgetElement => super.widgetElement as T;
}