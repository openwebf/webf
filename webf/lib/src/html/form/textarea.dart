/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/html.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';
import 'package:webf/css.dart';

import 'base_input.dart';

// ignore: constant_identifier_names
const TEXTAREA = 'TEXTAREA';

const Map<String, dynamic> _textAreaDefaultStyle = {
  BORDER: '1px solid rgb(118, 118, 118)',
  DISPLAY: INLINE_BLOCK,
};

class FlutterTextAreaElement extends WidgetElement with BaseInputElement {
  FlutterTextAreaElement(super.context);

  @override
  Map<String, dynamic> get defaultStyle => _textAreaDefaultStyle;


  @override
  void initializeDynamicProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeDynamicProperties(properties);
    // Ensure `textarea.value` property maps to element value storage.
    properties['value'] = BindingObjectProperty(getter: () => value, setter: (v) => value = v);
    // Optionally expose defaultValue for symmetry; this mirrors BaseInputElement behavior.
    properties['defaultValue'] = BindingObjectProperty(getter: () => defaultValue, setter: (v) => defaultValue = v);
  }

  @override
  void initializeDynamicMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeDynamicMethods(methods);
    methods['blur'] = BindingObjectMethodSync(call: (List args) {
      state?.blur();
    });
    methods['focus'] = BindingObjectMethodSync(call: (List args) {
      if (state != null) {
        state?.focus();
      } else {
        (this as BaseInputElement).markPendingFocus();
      }
    });
  }

  // The concatenation of the data of all the Text node descendants of node.
  // https://dom.spec.whatwg.org/#concept-descendant-text-content
  String get textContent {
    String str = '';
    // Set data of all text node children as value of textarea.
    for (Node child in childNodes) {
      if (child is TextNode) {
        str += child.data;
      }
    }
    return str;
  }

  @override
  void childrenChanged(ChildrenChange change) {
    super.childrenChanged(change);
    // Sync live value from text content when not dirty.
    if (!isValueDirty) {
      setElementValue(textContent, markDirty: false);
    }
  }

  // For textarea, defaultValue reflects its text content.
  @override
  String? get defaultValue => textContent;

  @override
  set defaultValue(String? text) {
    final String v = text?.toString() ?? '';
    // Find all text nodes and prefer updating the first one (original node passed in creation),
    // then remove other text siblings to keep a single text node, preserving external references.
    List<TextNode> textNodes = [];
    Node? cursor = firstChild;
    while (cursor != null) {
      if (cursor is TextNode) textNodes.add(cursor);
      cursor = cursor.nextSibling;
    }

    if (textNodes.isNotEmpty) {
      TextNode keep = textNodes.first;
      keep.data = v;
      for (final tn in textNodes) {
        if (!identical(tn, keep)) {
          removeChild(tn);
        }
      }
    } else {
      // No existing text nodes; create one.
      appendChild(TextNode(v));
    }
    // If value isn't dirty, sync live value as well without marking dirty.
    if (!isValueDirty) {
      setElementValue(v, markDirty: false);
    }
  }

  // When value hasn't been changed programmatically (not dirty), reflect text content.
  @override
  get value => isValueDirty ? elementValue : textContent;

  @override
  WebFWidgetElementState createState() {
    return FlutterTextAreaElementState(this);
  }
}

class FlutterTextAreaElementState extends FlutterInputElementState {
  FlutterTextAreaElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // Honor the `rows` attribute when height is not explicitly set.
    int? rows;
    final String? rowsAttr = widgetElement.getAttribute('rows');
    if (rowsAttr != null) {
      final int? parsed = int.tryParse(rowsAttr);
      if (parsed != null && parsed > 0) rows = parsed;
    }

    final bool isAutoHeight = widgetElement.renderStyle.height.isAuto;
    if (rows != null && isAutoHeight) {
      // Fix the visible rows by setting both min and max lines.
      return createInput(context, minLines: rows, maxLines: rows);
    }

    // Fallback defaults when no rows provided or height is explicitly set.
    return createInput(context, minLines: 3, maxLines: 5);
  }
}
