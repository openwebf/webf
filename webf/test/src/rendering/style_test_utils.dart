/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/dom.dart' as dom;

/// Test utilities for style-related tests.
class StyleTestUtils {
  /// Set a style property and ensure it's properly flushed.
  /// This is needed in tests because style changes are batched and 
  /// not immediately applied to the render style.
  static void setStyleProperty(dom.Element element, String propertyName, String value) {
    element.style.setProperty(propertyName, value);
    element.style.flushPendingProperties();
  }
  
  /// Set multiple style properties and ensure they're properly flushed.
  static void setStyleProperties(dom.Element element, Map<String, String> properties) {
    properties.forEach((propertyName, value) {
      element.style.setProperty(propertyName, value);
    });
    element.style.flushPendingProperties();
  }
}