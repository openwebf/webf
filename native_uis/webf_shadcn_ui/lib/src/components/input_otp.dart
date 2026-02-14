/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'input_otp_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadInputOTP].
///
/// Exposed as `<flutter-shadcn-input-otp>` in the DOM.
class FlutterShadcnInputOtp extends FlutterShadcnInputOtpBindings {
  FlutterShadcnInputOtp(super.context);

  String? _maxlength;
  String? _value;
  bool _disabled = false;

  @override
  String? get maxlength => _maxlength;

  @override
  set maxlength(value) {
    final String? v = value?.toString();
    if (v != _maxlength) {
      _maxlength = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get value => _value;

  @override
  set value(value) {
    final String? v = value?.toString();
    if (v != _value) {
      _value = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _disabled) {
      _disabled = v;
      state?.requestUpdateState(() {});
    }
  }

  int get maxLength => int.tryParse(_maxlength ?? '') ?? 6;

  @override
  WebFWidgetElementState createState() => FlutterShadcnInputOtpState(this);
}

class FlutterShadcnInputOtpState extends WebFWidgetElementState {
  FlutterShadcnInputOtpState(super.widgetElement);

  @override
  FlutterShadcnInputOtp get widgetElement =>
      super.widgetElement as FlutterShadcnInputOtp;

  List<Widget> _buildChildren() {
    final List<Widget> children = [];

    for (final child in widgetElement.childNodes) {
      if (child is FlutterShadcnInputOtpGroup) {
        final slotCount =
            child.childNodes.whereType<FlutterShadcnInputOtpSlot>().length;
        children.add(
          ShadInputOTPGroup(
            children: List.generate(slotCount, (_) => const ShadInputOTPSlot()),
          ),
        );
      } else if (child is FlutterShadcnInputOtpSeparator) {
        children.add(const Icon(Icons.remove, size: 16));
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return ShadInputOTP(
      maxLength: widgetElement.maxLength,
      enabled: !widgetElement.disabled,
      initialValue: widgetElement._value,
      onChanged: (value) {
        widgetElement._value = value;
        widgetElement.dispatchEvent(Event('change'));
        if (value.length == widgetElement.maxLength) {
          widgetElement.dispatchEvent(Event('complete'));
        }
      },
      children: _buildChildren(),
    );
  }
}

/// WebF custom element for grouping OTP slots.
///
/// Exposed as `<flutter-shadcn-input-otp-group>` in the DOM.
class FlutterShadcnInputOtpGroup extends WidgetElement {
  FlutterShadcnInputOtpGroup(super.context);

  void _notifyParent() {
    final parent = parentNode;
    if (parent is FlutterShadcnInputOtp) {
      parent.state?.requestUpdateState(() {});
    }
  }

  @override
  void connectedCallback() {
    super.connectedCallback();
    _notifyParent();
  }

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnInputOtpGroupState(this);
}

class FlutterShadcnInputOtpGroupState extends WebFWidgetElementState {
  FlutterShadcnInputOtpGroupState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// WebF custom element for individual OTP character slots.
///
/// Exposed as `<flutter-shadcn-input-otp-slot>` in the DOM.
class FlutterShadcnInputOtpSlot extends WidgetElement {
  FlutterShadcnInputOtpSlot(super.context);

  void _notifyParent() {
    final group = parentNode;
    if (group is FlutterShadcnInputOtpGroup) {
      group._notifyParent();
    }
  }

  @override
  void connectedCallback() {
    super.connectedCallback();
    _notifyParent();
  }

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnInputOtpSlotState(this);
}

class FlutterShadcnInputOtpSlotState extends WebFWidgetElementState {
  FlutterShadcnInputOtpSlotState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// WebF custom element for visual separator between OTP groups.
///
/// Exposed as `<flutter-shadcn-input-otp-separator>` in the DOM.
class FlutterShadcnInputOtpSeparator extends WidgetElement {
  FlutterShadcnInputOtpSeparator(super.context);

  void _notifyParent() {
    final parent = parentNode;
    if (parent is FlutterShadcnInputOtp) {
      parent.state?.requestUpdateState(() {});
    }
  }

  @override
  void connectedCallback() {
    super.connectedCallback();
    _notifyParent();
  }

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnInputOtpSeparatorState(this);
}

class FlutterShadcnInputOtpSeparatorState extends WebFWidgetElementState {
  FlutterShadcnInputOtpSeparatorState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
