/*
 * Copyright (C) 2023-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/svg.dart';
import 'package:webf/widget.dart';

class DefsAttributeConfig {
  // attribute name, using kabab case;
  final String name;

  // property name or style name
  final String camelName;

  // should add property binding
  final bool property;

  DefsAttributeConfig(this.name, {this.property = false}) : camelName = camelize(name);
}

class DefsAttributeElement extends WidgetElement {
  DefsAttributeElement(BindingContext? context) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => {'display': 'none'};

  Map<String, dynamic> attributeStyle = {};

  // Presentation attribute config cache
  List<DefsAttributeConfig>? _presentationAttributesConfigsCache;

  // Sub SVG element must to override this getter to add custom attributes
  get presentationAttributeConfigs => [
    DefsAttributeConfig('font-size'),
    DefsAttributeConfig('font-family'),
    DefsAttributeConfig('fill'),
    DefsAttributeConfig('fill-rule'),
    DefsAttributeConfig('clip-path'),
    DefsAttributeConfig('stroke'),
    DefsAttributeConfig('stroke-width'),
    DefsAttributeConfig('stroke-linecap'),
    DefsAttributeConfig('stroke-linejoin'),
    DefsAttributeConfig('transform')
  ];

  DefsAttributeElement? findRoot() {
    var parent = parentElement;
    while (parent is DefsAttributeElement) {
      if (parent is SVGDefsElement) {
        return parent;
      }
      parent = parent.parentElement;
    }

    return null;
  }

  @override
  void updateRenderBoxModel({ bool forceUpdate = false }) {
    // do not needs to update
  }

  @override
  void applyAttributeStyle(CSSStyleDeclaration style) {
    attributeStyle.forEach((key, value) {
      style.setProperty(key, value, isImportant: true);
    });
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    final configs = _presentationAttributesConfigsCache ??= presentationAttributeConfigs;
    for (var config in configs) {
      if (config.property) {
        properties[config.camelName] = BindingObjectProperty(getter: () => {});
      }
    }
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return SizedBox.shrink();
  }
}
