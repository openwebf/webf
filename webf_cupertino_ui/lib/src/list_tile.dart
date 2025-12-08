/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'list_tile_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoListTile].
///
/// Exposed as `<flutter-cupertino-list-tile>` in the DOM.
class FlutterCupertinoListTile extends FlutterCupertinoListTileBindings {
  FlutterCupertinoListTile(super.context);

  bool _showChevron = false;
  bool _notched = false;

  @override
  bool get showChevron => _showChevron;

  @override
  bool get allowsInfiniteHeight => true;

  @override
  set showChevron(value) {
    final bool next = value == true;
    if (next != _showChevron) {
      _showChevron = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get notched => _notched;

  @override
  set notched(value) {
    final bool next = value == true;
    if (next != _notched) {
      _notched = next;
      state?.requestUpdateState(() {});
    }
  }

  bool get isNotched => _notched;

  bool get shouldShowChevron => _showChevron;

  @override
  FlutterCupertinoListTileState createState() =>
      FlutterCupertinoListTileState(this);

  @override
  FlutterCupertinoListTileState? get state =>
      super.state as FlutterCupertinoListTileState?;
}

class FlutterCupertinoListTileState extends WebFWidgetElementState {
  FlutterCupertinoListTileState(super.widgetElement);

  @override
  FlutterCupertinoListTile get widgetElement =>
      super.widgetElement as FlutterCupertinoListTile;

  Widget? _buildSlotChild<T>() {
    for (final node in widgetElement.childNodes) {
      if (node is T) {
        if (node is dom.Node) {
          final widget = node.toWidget();
          if (widget != null) {
            return WebFWidgetElementChild(child: widget);
          }
        }
      }
    }
    return null;
  }

  Widget? _buildTitle() {
    final List<Widget> children = <Widget>[];

    for (final node in widgetElement.childNodes) {
      if (node is FlutterCupertinoListTileLeading ||
          node is FlutterCupertinoListTileSubtitle ||
          node is FlutterCupertinoListTileAdditionalInfo ||
          node is FlutterCupertinoListTileTrailing) {
        continue;
      }
      final widget = node.toWidget();
      if (widget != null) {
        children.add(WebFWidgetElementChild(child: widget));
      }
    }

    if (children.isEmpty) {
      return null;
    }
    if (children.length == 1) {
      return children.first;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final CSSRenderStyle renderStyle = widgetElement.renderStyle;
    final Color? backgroundColor = renderStyle.backgroundColor?.value;

    final Widget? leading =
        _buildSlotChild<FlutterCupertinoListTileLeading>();
    final Widget? subtitle =
        _buildSlotChild<FlutterCupertinoListTileSubtitle>();
    final Widget? additionalInfo =
        _buildSlotChild<FlutterCupertinoListTileAdditionalInfo>();
    Widget? trailing =
        _buildSlotChild<FlutterCupertinoListTileTrailing>();

    if (trailing == null && widgetElement.shouldShowChevron) {
      trailing = const CupertinoListTileChevron();
    }

    final Widget title = _buildTitle() ?? const SizedBox.shrink();

    onTap() {
      widgetElement.dispatchEvent(Event('click'));
    }

    if (widgetElement.isNotched) {
      return CupertinoListTile.notched(
        leading: leading,
        title: title,
        subtitle: subtitle,
        additionalInfo: additionalInfo,
        trailing: trailing,
        backgroundColor: backgroundColor,
        onTap: onTap,
      );
    }

    return CupertinoListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      additionalInfo: additionalInfo,
      trailing: trailing,
      backgroundColor: backgroundColor,
      onTap: onTap,
    );
  }
}

/// Slot container for the leading widget of a list tile.
class FlutterCupertinoListTileLeading extends WidgetElement {
  FlutterCupertinoListTileLeading(super.context);

  @override
  bool get allowsInfiniteHeight => true;


  @override
  WebFWidgetElementState createState() =>
      FlutterCupertinoListTileLeadingState(this);
}

class FlutterCupertinoListTileLeadingState extends WebFWidgetElementState {
  FlutterCupertinoListTileLeadingState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: widgetElement.childNodes.firstOrNull?.toWidget(),
    );
  }
}

/// Slot container for the subtitle widget of a list tile.
class FlutterCupertinoListTileSubtitle extends WidgetElement {
  FlutterCupertinoListTileSubtitle(super.context);

  @override
  bool get allowsInfiniteHeight => true;


  @override
  WebFWidgetElementState createState() =>
      FlutterCupertinoListTileSubtitleState(this);
}

class FlutterCupertinoListTileSubtitleState extends WebFWidgetElementState {
  FlutterCupertinoListTileSubtitleState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: widgetElement.childNodes.firstOrNull?.toWidget(),
    );
  }
}

/// Slot container for the additionalInfo widget of a list tile.
class FlutterCupertinoListTileAdditionalInfo extends WidgetElement {
  FlutterCupertinoListTileAdditionalInfo(super.context);

  @override
  bool get allowsInfiniteHeight => true;


  @override
  WebFWidgetElementState createState() =>
      FlutterCupertinoListTileAdditionalInfoState(this);
}

class FlutterCupertinoListTileAdditionalInfoState
    extends WebFWidgetElementState {
  FlutterCupertinoListTileAdditionalInfoState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: widgetElement.childNodes.firstOrNull?.toWidget(),
    );
  }
}

/// Slot container for the trailing widget of a list tile.
class FlutterCupertinoListTileTrailing extends WidgetElement {
  FlutterCupertinoListTileTrailing(super.context);

  @override
  bool get allowsInfiniteHeight => true;


  @override
  WebFWidgetElementState createState() =>
      FlutterCupertinoListTileTrailingState(this);
}

class FlutterCupertinoListTileTrailingState extends WebFWidgetElementState {
  FlutterCupertinoListTileTrailingState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: widgetElement.childNodes.firstOrNull?.toWidget(),
    );
  }
}
