/*
 * Copyright (C) 2023-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
import 'package:webf/bridge.dart';
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

  setAttributeStyle(String property, String value) {
    internalSetAttribute(property, value);
    // TODO: This have some problems about cascading order. I will fixed it later. @XGHeaven
    attributeStyle[property] = value;
  }

  @override
  RenderBoxModel? updateOrCreateRenderBoxModel(
      {flutter.Element? flutterWidgetElement}) {
    // do not needs to update
    return null;
  }

  @override
  void applyAttributeStyle(CSSStyleDeclaration style) {
    attributeStyle.forEach((key, value) {
      style.setProperty(key, value, isImportant: true);
    });
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    final configs = _presentationAttributesConfigsCache ??= presentationAttributeConfigs;
    for (final config in configs) {
      attributes[config.name] = ElementAttributeProperty(setter: (value) => setAttributeStyle(config.camelName, value));
    }
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    final configs = _presentationAttributesConfigsCache ??= presentationAttributeConfigs;
    for (var config in configs) {
      if (config.property) {
        // TODO: implements
        properties[config.camelName] = BindingObjectProperty(getter: () => {});
      }
    }
  }

  @override
  flutter.Widget build(flutter.BuildContext context, ChildNodeList children) {
    return flutter.SizedBox.shrink();
  }
}
