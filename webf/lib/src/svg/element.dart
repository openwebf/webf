/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:meta/meta.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/svg.dart';

class SVGPresentationAttributeConfig {
  // attribute name, using kabab case;
  final String name;

  // property name or style name
  final String camelName;

  // should add property binding
  final bool property;

  SVGPresentationAttributeConfig(this.name, {this.property = false})
      : camelName = camelize(name);
}

class SVGElement extends Element {
  Map<String, dynamic> attributeStyle = {};

  // Presentation attribute config cache
  List<SVGPresentationAttributeConfig>? _presentationAttributesConfigsCache;

  // Sub SVG element must to override this getter to add custom attributes
  @visibleForOverriding
  List<SVGPresentationAttributeConfig> get presentationAttributeConfigs => [];

  SVGElement([BindingContext? context]) : super(context);

  SVGSVGElement? findRoot() {
    var parent = parentElement;
    while (parent is SVGElement) {
      if (parent is SVGSVGElement) {
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
  void updateRenderBoxModel() {
    // do not needs to update
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
    final configs =
        _presentationAttributesConfigsCache ??= presentationAttributeConfigs;
    for (final config in configs) {
      attributes[config.name] = ElementAttributeProperty(
          setter: (value) => setAttributeStyle(config.camelName, value));
    }
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    final configs =
        _presentationAttributesConfigsCache ??= presentationAttributeConfigs;
    for (var config in configs) {
      if (config.property) {
        // TODO: implements
        properties[config.camelName] = BindingObjectProperty(getter: () => {});
      }
    }
  }
}
