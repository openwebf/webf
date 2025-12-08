/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'form_section_bindings_generated.dart';
import 'text_form_field_row.dart';

/// WebF custom element that wraps Flutter's [CupertinoFormSection].
///
/// Exposed as `<flutter-cupertino-form-section>` in the DOM, with optional
/// header/footer slots and `<flutter-cupertino-form-row>` children.
class FlutterCupertinoFormSection extends FlutterCupertinoFormSectionBindings {
  FlutterCupertinoFormSection(super.context);

  bool _insetGrouped = false;
  String? _clipBehavior;

  @override
  bool get insetGrouped => _insetGrouped;

  @override
  bool get allowsInfiniteHeight => true;

  @override
  set insetGrouped(value) {
    final bool next = value == true;
    if (next != _insetGrouped) {
      _insetGrouped = next;
      state?.requestUpdateState(() {});
    }
  }

  bool get isInsetGrouped => _insetGrouped;

  @override
  String? get clipBehavior => _clipBehavior;

  @override
  set clipBehavior(value) {
    final String? next = value?.toString();
    if (next != _clipBehavior) {
      _clipBehavior = next;
      state?.requestUpdateState(() {});
    }
  }

  Clip get resolvedClipBehavior {
    switch ((_clipBehavior ?? 'hardEdge').trim()) {
      case 'none':
        return Clip.none;
      case 'antiAlias':
        return Clip.antiAlias;
      case 'antiAliasWithSaveLayer':
        return Clip.antiAliasWithSaveLayer;
      case 'hardEdge':
      default:
        return Clip.hardEdge;
    }
  }

  @override
  FlutterCupertinoFormSectionState createState() =>
      FlutterCupertinoFormSectionState(this);

  @override
  FlutterCupertinoFormSectionState? get state =>
      super.state as FlutterCupertinoFormSectionState?;
}

class FlutterCupertinoFormSectionState extends WebFWidgetElementState {
  FlutterCupertinoFormSectionState(super.widgetElement);

  @override
  FlutterCupertinoFormSection get widgetElement =>
      super.widgetElement as FlutterCupertinoFormSection;

  Widget? _getSlotChild(String slotName) {
    final dom.Node? slotNode = widgetElement.childNodes.firstWhereOrNull(
      (node) =>
          node is dom.Element &&
          node.getAttribute('slotName') == slotName,
    );
    if (slotNode == null) {
      return null;
    }
    return WebFWidgetElementChild(child: slotNode.toWidget());
  }

  List<Widget> _getFormRows() {
    return widgetElement.childNodes
        .where((node) {
          if (node is dom.Element) {
            // Exclude header/footer/helper/error slots and only keep rows.
            final String? slotName = node.getAttribute('slotName');
            if (slotName == 'header' ||
                slotName == 'footer' ||
                slotName == 'helper' ||
                slotName == 'error') {
              return false;
            }
            return node is FlutterCupertinoFormRow ||
                node is FlutterCupertinoTextFormFieldRow;
          }
          return false;
        })
        .map((node) => WebFWidgetElementChild(child: node.toWidget()))
        .nonNulls
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final CSSRenderStyle renderStyle = widgetElement.renderStyle;

    final EdgeInsetsGeometry styleMargin = renderStyle.margin;
    final Color? backgroundColor = renderStyle.backgroundColor?.value;
    final BoxDecoration? decoration =
        renderStyle.decoration as BoxDecoration?;
    final Clip clipBehavior = widgetElement.resolvedClipBehavior;

    final Widget? headerWidget = _getSlotChild('header');
    final Widget? footerWidget = _getSlotChild('footer');
    final List<Widget> rows = _getFormRows();

    final bool useInsetGrouped = widgetElement.isInsetGrouped;

    // Only override margin when the author provided a non-zero margin.
    // Otherwise rely on CupertinoFormSection's own defaults.
    final EdgeInsetsGeometry? customMargin =
        styleMargin != EdgeInsets.zero ? styleMargin : null;

    final Widget sectionWidget;
    if (useInsetGrouped) {
      if (customMargin != null) {
        sectionWidget = CupertinoFormSection.insetGrouped(
          key: ObjectKey(widgetElement),
          header: headerWidget,
          footer: footerWidget,
          margin: customMargin,
          backgroundColor:
              backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
          decoration: decoration,
          clipBehavior: clipBehavior,
          children: rows,
        );
      } else {
        sectionWidget = CupertinoFormSection.insetGrouped(
          key: ObjectKey(widgetElement),
          header: headerWidget,
          footer: footerWidget,
          backgroundColor:
              backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
          decoration: decoration,
          clipBehavior: clipBehavior,
          children: rows,
        );
      }
    } else {
      if (customMargin != null) {
        sectionWidget = CupertinoFormSection(
          key: ObjectKey(widgetElement),
          header: headerWidget,
          footer: footerWidget,
          margin: customMargin,
          backgroundColor:
              backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
          decoration: decoration,
          clipBehavior: clipBehavior,
          children: rows,
        );
      } else {
        sectionWidget = CupertinoFormSection(
          key: ObjectKey(widgetElement),
          header: headerWidget,
          footer: footerWidget,
          backgroundColor:
              backgroundColor ?? CupertinoColors.systemGroupedBackground.resolveFrom(context),
          decoration: decoration,
          clipBehavior: clipBehavior,
          children: rows,
        );
      }
    }

    return sectionWidget;
  }
}

/// Single row inside a [FlutterCupertinoFormSection].
///
/// Exposed as `<flutter-cupertino-form-row>` in the DOM.
class FlutterCupertinoFormRow extends WidgetElement {
  FlutterCupertinoFormRow(super.context);

  @override
  bool get allowsInfiniteHeight => true;

  @override
  WebFWidgetElementState createState() => FlutterCupertinoFormRowState(this);
}

class FlutterCupertinoFormRowState extends WebFWidgetElementState {
  FlutterCupertinoFormRowState(super.widgetElement);

  Widget? _getSlotChild(String slotName) {
    final dom.Node? slotNode = widgetElement.childNodes.firstWhereOrNull(
      (node) =>
          node is dom.Element &&
          node.getAttribute('slotName') == slotName,
    );
    if (slotNode == null) {
      return null;
    }
    return WebFWidgetElementChild(child: slotNode.toWidget());
  }

  Widget? _getDefaultChild() {
    final dom.Node? defaultNode = widgetElement.childNodes.firstWhereOrNull(
      (node) {
        if (node is! dom.Element) return false;
        final String? slotName = node.getAttribute('slotName');
        return slotName == null ||
            (slotName != 'prefix' &&
                slotName != 'helper' &&
                slotName != 'error');
      },
    );
    if (defaultNode == null) {
      return null;
    }
    return WebFWidgetElementChild(child: defaultNode.toWidget());
  }

  @override
  Widget build(BuildContext context) {
    final Widget? prefix = _getSlotChild('prefix');
    final Widget? helper = _getSlotChild('helper');
    final Widget? error = _getSlotChild('error');
    final Widget? child = _getDefaultChild();

    return CupertinoFormRow(
      prefix: prefix,
      helper: helper,
      error: error,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
