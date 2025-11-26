/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Color;
import 'package:webf/css.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'sliding_segmented_control_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoSlidingSegmentedControl].
///
/// Exposed as `<flutter-cupertino-sliding-segmented-control>` in the DOM.
class FlutterCupertinoSlidingSegmentedControl
    extends FlutterCupertinoSlidingSegmentedControlBindings {
  FlutterCupertinoSlidingSegmentedControl(super.context);

  int _currentIndex = 0;
  String? _backgroundColor;
  String? _thumbColor;

  @override
  int? get currentIndex => _currentIndex;

  @override
  set currentIndex(value) {
    int next = 0;
    if (value is int) {
      next = value;
    } else if (value is num) {
      next = value.toInt();
    } else if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        next = parsed;
      }
    }
    if (next != _currentIndex) {
      _currentIndex = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get backgroundColor => _backgroundColor;

  @override
  set backgroundColor(value) {
    final String? next = value?.toString();
    if (next != _backgroundColor) {
      _backgroundColor = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get thumbColor => _thumbColor;

  @override
  set thumbColor(value) {
    final String? next = value?.toString();
    if (next != _thumbColor) {
      _thumbColor = next;
      state?.requestUpdateState(() {});
    }
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    return CSSColor.parseColor(colorString);
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSlidingSegmentedControlState(this);
  }
}

class FlutterCupertinoSlidingSegmentedControlState
    extends WebFWidgetElementState {
  FlutterCupertinoSlidingSegmentedControlState(super.widgetElement);

  @override
  FlutterCupertinoSlidingSegmentedControl get widgetElement =>
      super.widgetElement as FlutterCupertinoSlidingSegmentedControl;

  @override
  Widget build(BuildContext context) {
    final segments = <int, Widget>{};

    int index = 0;
    for (final item in widgetElement.childNodes
        .whereType<FlutterCupertinoSlidingSegmentedControlItem>()) {
      segments[index] = WebFWidgetElementChild(
        child: item.toWidget(key: ObjectKey(item)),
      );
      index++;
    }

    if (segments.isNotEmpty) {
      final maxIndex = segments.length - 1;
      if (widgetElement._currentIndex < 0) {
        widgetElement._currentIndex = 0;
      } else if (widgetElement._currentIndex > maxIndex) {
        widgetElement._currentIndex = maxIndex;
      }
    }

    final Color background =
        widgetElement._parseColor(widgetElement.backgroundColor) ??
            CupertinoColors.tertiarySystemFill;
    final Color thumb =
        widgetElement._parseColor(widgetElement.thumbColor) ??
            CupertinoColors.white;

    return CupertinoSlidingSegmentedControl<int>(
      children: segments,
      groupValue: segments.isEmpty ? null : widgetElement._currentIndex,
      backgroundColor: background,
      thumbColor: thumb,
      onValueChanged: (int? value) {
        if (segments.isEmpty || value == null) return;
        if (value != widgetElement._currentIndex) {
          widgetElement._currentIndex = value;
          setState(() {});
          widgetElement.dispatchEvent(
            CustomEvent('change', detail: value),
          );
        }
      },
    );
  }
}

/// Item used inside [FlutterCupertinoSlidingSegmentedControl].
///
/// Exposed as `<flutter-cupertino-sliding-segmented-control-item>` in the DOM.
class FlutterCupertinoSlidingSegmentedControlItem extends WidgetElement {
  FlutterCupertinoSlidingSegmentedControlItem(super.context);

  String? _title;
  String? get title => _title;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['title'] = ElementAttributeProperty(
      getter: () => _title,
      setter: (value) {
        _title = value;
        state?.requestUpdateState(() {});
      },
      deleter: () {
        _title = null;
        state?.requestUpdateState(() {});
      },
    );
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSlidingSegmentedControlItemState(this);
  }
}

class FlutterCupertinoSlidingSegmentedControlItemState
    extends WebFWidgetElementState {
  FlutterCupertinoSlidingSegmentedControlItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    if (widgetElement.childNodes.isNotEmpty) {
      // Render any inner WebF/HTML children as the segment content.
      return WebFHTMLElement(
        tagName: 'DIV',
        parentElement: widgetElement,
        controller: widgetElement.ownerDocument.controller,
        children: widgetElement.childNodes.toWidgetList(),
      );
    }

    // Fallback to the title text when no inner children are provided.
    final host = widgetElement as FlutterCupertinoSlidingSegmentedControlItem;
    return Text(
      host.title ?? '',
      style: CSSTextMixin.createTextStyle(widgetElement.renderStyle),
      textAlign: TextAlign.center,
    );
  }
}
