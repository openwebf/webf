/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

/// WebF custom element that wraps shadcn_ui [ShadBreadcrumb].
///
/// Exposed as `<flutter-shadcn-breadcrumb>` in the DOM.
class FlutterShadcnBreadcrumb extends WidgetElement {
  FlutterShadcnBreadcrumb(super.context);

  double? _spacing;
  String? _separator;

  double? get spacing => _spacing;

  set spacing(dynamic value) {
    final newValue = double.tryParse(value?.toString() ?? '');
    if (newValue != _spacing) {
      _spacing = newValue;
      state?.requestUpdateState(() {});
    }
  }

  String? get separator => _separator;

  set separator(dynamic value) {
    final newValue = value?.toString();
    if (newValue != _separator) {
      _separator = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['spacing'] = ElementAttributeProperty(
      getter: () => _spacing?.toString(),
      setter: (v) => spacing = v,
      deleter: () => spacing = null,
    );
    attributes['separator'] = ElementAttributeProperty(
      getter: () => _separator,
      setter: (v) => separator = v,
      deleter: () => separator = null,
    );
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnBreadcrumbState(this);
}

class FlutterShadcnBreadcrumbState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbState(super.widgetElement);

  @override
  FlutterShadcnBreadcrumb get widgetElement =>
      super.widgetElement as FlutterShadcnBreadcrumb;

  Widget? _buildSeparator(BuildContext context) {
    final separatorValue = widgetElement.separator;
    if (separatorValue == null) return null;

    final theme = ShadTheme.of(context);
    final color = theme.colorScheme.mutedForeground;

    // Support predefined separator types
    switch (separatorValue.toLowerCase()) {
      case 'slash':
      case '/':
        return Text('/', style: TextStyle(color: color));
      case 'arrow':
      case '>':
        return Text('>', style: TextStyle(color: color));
      case 'dash':
      case '-':
        return Text('-', style: TextStyle(color: color));
      case 'dot':
      case '.':
        return Text('•', style: TextStyle(color: color));
      case 'chevron':
        return const ShadBreadcrumbSeparator();
      default:
        // Use custom text as separator
        return Text(separatorValue, style: TextStyle(color: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Collect child widgets for the breadcrumb
    final children = <Widget>[];

    for (final node in widgetElement.childNodes) {
      if (node is FlutterShadcnBreadcrumbItem) {
        children.add(node.toWidget());
      } else if (node is FlutterShadcnBreadcrumbLink) {
        children.add(node.toWidget());
      } else if (node is FlutterShadcnBreadcrumbPage) {
        children.add(node.toWidget());
      } else if (node is FlutterShadcnBreadcrumbEllipsis) {
        children.add(node.toWidget());
      } else if (node is FlutterShadcnBreadcrumbDropdown) {
        children.add(node.toWidget());
      }
    }

    return ShadBreadcrumb(
      spacing: widgetElement.spacing,
      separator: _buildSeparator(context),
      children: children,
    );
  }
}

/// WebF custom element for breadcrumb item container.
class FlutterShadcnBreadcrumbItem extends WidgetElement {
  FlutterShadcnBreadcrumbItem(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbItemState(this);
}

class FlutterShadcnBreadcrumbItemState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // Find the first meaningful child (link, page, ellipsis, or dropdown)
    for (final node in widgetElement.childNodes) {
      if (node is FlutterShadcnBreadcrumbLink) {
        return node.toWidget();
      } else if (node is FlutterShadcnBreadcrumbPage) {
        return node.toWidget();
      } else if (node is FlutterShadcnBreadcrumbEllipsis) {
        return node.toWidget();
      } else if (node is FlutterShadcnBreadcrumbDropdown) {
        return node.toWidget();
      }
    }
    return const SizedBox.shrink();
  }
}

/// WebF custom element for breadcrumb link.
///
/// Exposed as `<flutter-shadcn-breadcrumb-link>` in the DOM.
class FlutterShadcnBreadcrumbLink extends WidgetElement {
  FlutterShadcnBreadcrumbLink(super.context);

  String? _href;

  String? get href => _href;

  set href(dynamic value) {
    final newValue = value?.toString();
    if (newValue != _href) {
      _href = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['href'] = ElementAttributeProperty(
      getter: () => href,
      setter: (v) => href = v,
      deleter: () => href = null,
    );
  }

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbLinkState(this);
}

class FlutterShadcnBreadcrumbLinkState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbLinkState(super.widgetElement);

  @override
  FlutterShadcnBreadcrumbLink get widgetElement =>
      super.widgetElement as FlutterShadcnBreadcrumbLink;

  /// Extract text content from a list of nodes recursively.
  String _extractTextContent(Iterable<Node> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is TextNode) {
        buffer.write(node.data);
      } else if (node.childNodes.isNotEmpty) {
        buffer.write(_extractTextContent(node.childNodes));
      }
    }
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final textContent = _extractTextContent(widgetElement.childNodes);

    return ShadBreadcrumbLink(
      onPressed: () {
        widgetElement.dispatchEvent(Event('click'));
      },
      child: Text(textContent),
    );
  }
}

/// WebF custom element for current breadcrumb page.
///
/// Exposed as `<flutter-shadcn-breadcrumb-page>` in the DOM.
class FlutterShadcnBreadcrumbPage extends WidgetElement {
  FlutterShadcnBreadcrumbPage(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbPageState(this);
}

class FlutterShadcnBreadcrumbPageState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbPageState(super.widgetElement);

  /// Extract text content from a list of nodes recursively.
  String _extractTextContent(Iterable<Node> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is TextNode) {
        buffer.write(node.data);
      } else if (node.childNodes.isNotEmpty) {
        buffer.write(_extractTextContent(node.childNodes));
      }
    }
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textContent = _extractTextContent(widgetElement.childNodes);

    // Current page uses foreground color (not muted)
    return Text(
      textContent,
      style: theme.textTheme.small.copyWith(
        color: theme.colorScheme.foreground,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// WebF custom element for breadcrumb separator.
///
/// Exposed as `<flutter-shadcn-breadcrumb-separator>` in the DOM.
class FlutterShadcnBreadcrumbSeparator extends WidgetElement {
  FlutterShadcnBreadcrumbSeparator(super.context);

  double? _size;

  double? get size => _size;

  set size(dynamic value) {
    final newValue = double.tryParse(value?.toString() ?? '');
    if (newValue != _size) {
      _size = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['size'] = ElementAttributeProperty(
      getter: () => _size?.toString(),
      setter: (v) => size = v,
      deleter: () => size = null,
    );
  }

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbSeparatorState(this);
}

class FlutterShadcnBreadcrumbSeparatorState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbSeparatorState(super.widgetElement);

  @override
  FlutterShadcnBreadcrumbSeparator get widgetElement =>
      super.widgetElement as FlutterShadcnBreadcrumbSeparator;

  @override
  Widget build(BuildContext context) {
    return ShadBreadcrumbSeparator(
      size: widgetElement.size,
    );
  }
}

/// WebF custom element for breadcrumb ellipsis.
///
/// Exposed as `<flutter-shadcn-breadcrumb-ellipsis>` in the DOM.
class FlutterShadcnBreadcrumbEllipsis extends WidgetElement {
  FlutterShadcnBreadcrumbEllipsis(super.context);

  double? _size;

  double? get size => _size;

  set size(dynamic value) {
    final newValue = double.tryParse(value?.toString() ?? '');
    if (newValue != _size) {
      _size = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['size'] = ElementAttributeProperty(
      getter: () => _size?.toString(),
      setter: (v) => size = v,
      deleter: () => size = null,
    );
  }

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbEllipsisState(this);
}

class FlutterShadcnBreadcrumbEllipsisState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbEllipsisState(super.widgetElement);

  @override
  FlutterShadcnBreadcrumbEllipsis get widgetElement =>
      super.widgetElement as FlutterShadcnBreadcrumbEllipsis;

  @override
  Widget build(BuildContext context) {
    return ShadBreadcrumbEllipsis(
      size: widgetElement.size,
    );
  }
}

/// WebF custom element for breadcrumb dropdown.
///
/// Exposed as `<flutter-shadcn-breadcrumb-dropdown>` in the DOM.
class FlutterShadcnBreadcrumbDropdown extends WidgetElement {
  FlutterShadcnBreadcrumbDropdown(super.context);

  bool _showArrow = true;

  bool get showArrow => _showArrow;

  set showArrow(dynamic value) {
    final newValue = value == true || value == 'true' || value == '';
    if (newValue != _showArrow) {
      _showArrow = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['show-arrow'] = ElementAttributeProperty(
      getter: () => _showArrow ? 'true' : null,
      setter: (v) => showArrow = v,
      deleter: () => showArrow = true,
    );
  }

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbDropdownState(this);
}

class FlutterShadcnBreadcrumbDropdownState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbDropdownState(super.widgetElement);

  @override
  FlutterShadcnBreadcrumbDropdown get widgetElement =>
      super.widgetElement as FlutterShadcnBreadcrumbDropdown;

  /// Extract text content from a list of nodes recursively.
  String _extractTextContent(Iterable<Node> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is TextNode) {
        buffer.write(node.data);
      } else if (node.childNodes.isNotEmpty) {
        buffer.write(_extractTextContent(node.childNodes));
      }
    }
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    // Collect dropdown menu items
    final items = <ShadBreadcrumbDropMenuItem>[];
    Widget? triggerChild;

    for (final node in widgetElement.childNodes) {
      if (node is FlutterShadcnBreadcrumbDropdownItem) {
        final itemText = _extractTextContent(node.childNodes);
        items.add(
          ShadBreadcrumbDropMenuItem(
            onPressed: () {
              node.dispatchEvent(Event('click'));
            },
            child: Text(itemText),
          ),
        );
      } else if (node is FlutterShadcnBreadcrumbEllipsis) {
        triggerChild = const ShadBreadcrumbEllipsis();
      }
    }

    // Default trigger is ellipsis if none specified
    triggerChild ??= const ShadBreadcrumbEllipsis();

    return ShadBreadcrumbDropdown(
      showDropdownArrow: widgetElement.showArrow,
      items: items,
      child: triggerChild,
    );
  }
}

/// WebF custom element for breadcrumb dropdown menu item.
///
/// Exposed as `<flutter-shadcn-breadcrumb-dropdown-item>` in the DOM.
class FlutterShadcnBreadcrumbDropdownItem extends WidgetElement {
  FlutterShadcnBreadcrumbDropdownItem(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbDropdownItemState(this);
}

class FlutterShadcnBreadcrumbDropdownItemState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbDropdownItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This widget is rendered by the parent dropdown
    return const SizedBox.shrink();
  }
}

/// Kept for backwards compatibility - wraps breadcrumb list
class FlutterShadcnBreadcrumbList extends WidgetElement {
  FlutterShadcnBreadcrumbList(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnBreadcrumbListState(this);
}

class FlutterShadcnBreadcrumbListState extends WebFWidgetElementState {
  FlutterShadcnBreadcrumbListState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // Collect child widgets
    final children = <Widget>[];

    for (final node in widgetElement.childNodes) {
      if (node is FlutterShadcnBreadcrumbItem) {
        children.add(node.toWidget());
      } else if (node is FlutterShadcnBreadcrumbLink) {
        children.add(node.toWidget());
      } else if (node is FlutterShadcnBreadcrumbPage) {
        children.add(node.toWidget());
      } else if (node is FlutterShadcnBreadcrumbSeparator) {
        // Skip separators - ShadBreadcrumb handles them automatically
        continue;
      } else if (node is FlutterShadcnBreadcrumbEllipsis) {
        children.add(node.toWidget());
      } else if (node is FlutterShadcnBreadcrumbDropdown) {
        children.add(node.toWidget());
      }
    }

    return ShadBreadcrumb(
      children: children,
    );
  }
}
