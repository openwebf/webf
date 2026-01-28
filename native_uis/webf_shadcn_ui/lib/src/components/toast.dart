/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'toast_bindings_generated.dart';

/// WebF custom element that displays a toast notification.
///
/// Exposed as `<flutter-shadcn-toast>` in the DOM.
/// Note: This is a simplified implementation. For full toast functionality,
/// use the ShadToaster widget at the app level.
class FlutterShadcnToast extends FlutterShadcnToastBindings {
  FlutterShadcnToast(super.context);

  String _variant = 'default';
  String? _title;
  String? _description;
  int _duration = 5000;
  bool _closable = true;

  @override
  String get variant => _variant;

  @override
  set variant(value) {
    final newValue = value?.toString() ?? 'default';
    if (newValue != _variant) {
      _variant = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get title => _title;

  @override
  set title(value) {
    final newValue = value?.toString();
    if (newValue != _title) {
      _title = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get description => _description;

  @override
  set description(value) {
    final newValue = value?.toString();
    if (newValue != _description) {
      _description = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get duration => _duration.toString();

  @override
  set duration(value) {
    final newValue = int.tryParse(value?.toString() ?? '') ?? 5000;
    if (newValue != _duration) {
      _duration = newValue;
    }
  }

  @override
  bool get closable => _closable;

  @override
  set closable(value) {
    final newValue = value == true;
    if (newValue != _closable) {
      _closable = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnToastState(this);
}

class FlutterShadcnToastState extends WebFWidgetElementState {
  FlutterShadcnToastState(super.widgetElement);

  @override
  FlutterShadcnToast get widgetElement =>
      super.widgetElement as FlutterShadcnToast;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDestructive = widgetElement.variant == 'destructive';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border.all(
          color: isDestructive
              ? theme.colorScheme.destructive
              : theme.colorScheme.border,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widgetElement.title != null)
                  Text(
                    widgetElement.title!,
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? theme.colorScheme.destructive
                          : null,
                    ),
                  ),
                if (widgetElement.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widgetElement.description!,
                    style: theme.textTheme.muted,
                  ),
                ],
              ],
            ),
          ),
          if (widgetElement.closable)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () {
                widgetElement.dispatchEvent(Event('close'));
              },
            ),
        ],
      ),
    );
  }
}
