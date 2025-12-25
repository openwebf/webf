/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/html.dart';
import 'package:webf/widget.dart';
import 'package:webf/src/accessibility/semantics.dart';

import 'form_element_base.dart';

const Map<String, dynamic> _inputDefaultStyle = {
  BORDER: '2px solid rgb(118, 118, 118)',
  DISPLAY: INLINE_BLOCK,
  COLOR: '#000',
};

const Map<String, dynamic> _checkboxDefaultStyle = {
  MARGIN: '3px 3px 3px 4px',
  PADDING: INITIAL,
  DISPLAY: INLINE_BLOCK,
  WIDTH: 'auto',
  HEIGHT: 'auto',
  BORDER: '0'
};

/// create a base input widget containing input and textarea
mixin BaseInputElement on WidgetElement implements FormElementBase {
  String? oldValue;
  String _value = '';
  bool _pendingFocus = false;
  bool _dirtyValue = false;

  // Public helper to allow other classes to mark focus request before mount.
  void markPendingFocus() {
    _pendingFocus = true;
  }

  @override
  Map<String, dynamic> get defaultStyle {
    switch (type) {
      case 'text':
      case 'password':
      case 'time':
      case 'button':
      case 'submit':
      case 'reset':
      case 'email':
        return _inputDefaultStyle;
      case 'radio':
      case 'checkbox':
        return _checkboxDefaultStyle;
    }
    return super.defaultStyle;
  }

  @override
  FlutterInputElementState? get state => super.state as FlutterInputElementState?;

  // Expose element value for resolving mixin conflicts from the concrete class.
  String get elementValue => _value;

  @override
  String get value => _value;

  @override
  set value(value) {
    setElementValue(value != null ? value.toString() : '');
  }

  // Internal setter used by FlutterInputElement to avoid naming conflicts.
  void setElementValue(String newValue, {bool markDirty = true}) {
    _value = newValue;
    if (markDirty) _dirtyValue = true;
    // Keep controller in sync when state exists, preserving selection.
    final controller = state?.controller;
    if (controller != null && controller.value.text != newValue) {
      final TextSelection currentSelection = controller.selection;
      final int textLength = newValue.length;
      final int selectionStart = currentSelection.start.clamp(0, textLength);
      final int selectionEnd = currentSelection.end.clamp(0, textLength);
      controller.value = TextEditingValue(
        text: newValue,
        selection: TextSelection(baseOffset: selectionStart, extentOffset: selectionEnd),
      );
    }
  }

  bool get isValueDirty => _dirtyValue;

  TextInputType? getKeyboardType() {
    if (this is FlutterTextAreaElement) {
      return TextInputType.multiline;
    }

    switch (type) {
      case 'text':
        if (inputMode != null) {
          switch (inputMode) {
            case 'numeric':
              return TextInputType.number;
            case 'tel':
              return TextInputType.phone;
            case 'decimal':
              return TextInputType.numberWithOptions(decimal: true, signed: true);
            case 'email':
              return TextInputType.emailAddress;
            case 'url':
              return TextInputType.url;
            case 'text':
            case 'search':
              return TextInputType.text;
            case 'none':
              return TextInputType.none;
          }
        }
        return TextInputType.text;
      case 'number':
        String? step = getAttribute('step');
        if (step == 'any' || step != null && step.contains('.')) {
          return TextInputType.numberWithOptions(decimal: true);
        }
        return TextInputType.number;
      case 'tel':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      case 'email':
        return TextInputType.emailAddress;
      case 'search':
        return TextInputType.text;
    }
    return TextInputType.text;
  }

  TextInputAction getTextInputAction() {
    if (enterKeyHint != null) {
      switch (enterKeyHint) {
        case 'next':
          return TextInputAction.next;
        case 'done':
          return TextInputAction.done;
        case 'search':
          return TextInputAction.search;
        case 'go':
          return TextInputAction.go;
        case 'previous':
          return TextInputAction.previous;
        case 'send':
          return TextInputAction.send;
        default:
          return TextInputAction.unspecified;
      }
    }
    switch (type) {
      case 'search':
        return TextInputAction.search;
      case 'email':
      case 'password':
      case 'tel':
      case 'url':
      case 'number':
        return TextInputAction.done;
      case 'text':
        return TextInputAction.newline;
      default:
        return TextInputAction.unspecified;
    }
  }

  @override
  String get type => getAttribute('type') ?? 'text';

  String? get inputMode => getAttribute('inputmode');

  String? get enterKeyHint => getAttribute('enterkeyhint');

  set type(value) {
    String newType = value.toString();
    String currentType = getAttribute('type') ?? 'text';

    // Only update if type actually changed
    if (newType != currentType) {
      internalSetAttribute('type', newType);
      resetInputDefaultStyle();
    }
  }

  void resetInputDefaultStyle() {
    switch (type) {
      case 'radio':
      case 'checkbox':
        {
          _checkboxDefaultStyle.forEach((key, value) {
            style.setProperty(key, value);
          });
          break;
        }
      default:
        _inputDefaultStyle.forEach((key, value) {
          style.setProperty(key, value);
        });
        break;
    }

    style.flushPendingProperties();
  }

  String get placeholder => getAttribute('placeholder') ?? '';

  set placeholder(value) {
    internalSetAttribute('placeholder', value?.toString() ?? '');
  }

  String? get label => getAttribute('label');

  set label(value) {
    internalSetAttribute('label', value?.toString() ?? '');
  }

  String? get defaultValue => getAttribute('defaultValue') ?? getAttribute('value') ?? '';

  set defaultValue(String? text) {
    internalSetAttribute('defaultValue', text?.toString() ?? '');
    value = text;
  }

  bool _disabled = false;

  @override
  bool get disabled => _disabled;

  set disabled(value) {
    if (value is String) {
      _disabled = true;
      return;
    }
    _disabled = value == true;
  }

  bool get autofocus => getAttribute('autofocus') != null;

  set autofocus(value) {
    internalSetAttribute('autofocus', value?.toString() ?? '');
  }

  bool get readonly => getAttribute('readonly') != null;

  set readonly(value) {
    internalSetAttribute('readonly', value?.toString() ?? '');
  }

  List<BorderSide>? get borderSides => renderStyle.borderSides;

  // for type
  bool get isSearch => type == 'search';

  bool get isPassWord => type == 'password';

  int? get maxLength {
    String? value = getAttribute('maxlength');
    if (value != null) return int.parse(value);
    return null;
  }

  set maxLength(int? value) {
    internalSetAttribute('maxlength', value?.toString() ?? '');
  }

  List<TextInputFormatter>? getInputFormatters() {
    switch (type) {
      case 'number':
        return [];
    }
    return null;
  }

  double? get height => renderStyle.height.value;

  double? get width => renderStyle.width.value;

  double get fontSize => renderStyle.fontSize.computedValue;

  double get lineHeight => renderStyle.lineHeight.computedValue;

  /// input is 1 and textarea is 3
  int minLines = 1;

  /// input is 1 and textarea is 5
  int maxLines = 1;

  /// Use leading to support line height.
  /// 1. LineHeight must greater than fontSize
  /// 2. LineHeight must less than height in input but textarea
  double get leading =>
      lineHeight > fontSize && (maxLines != 1 || height == null || lineHeight < renderStyle.height.computedValue)
          ? (lineHeight - fontSize - _defaultPadding * 2) / fontSize
          : 0;

  TextStyle get _textStyle {
    double? height;

    if (renderStyle.lineHeight != CSSText.defaultLineHeight) {
      double lineHeight = renderStyle.lineHeight.computedValue / renderStyle.fontSize.computedValue;

      if (renderStyle.height.isNotAuto) {
        lineHeight = math.min(lineHeight, renderStyle.height.computedValue / renderStyle.fontSize.computedValue);
      }

      if (lineHeight >= 1) {
        height = lineHeight;
      }
    }

    return TextStyle(
      color: renderStyle.color.value,
      fontSize: fontSize,
      height: height,
      fontWeight: renderStyle.fontWeight,
      fontFamily: renderStyle.fontFamily?.join(' '),
    );
  }

  final double _defaultPadding = 0;

  int? _selectionStart;
  int? _selectionEnd;

  int? get selectionStart => _selectionStart;

  int? get selectionEnd => _selectionEnd;

  set selectionStart(int? value) {
    if (value != null) {
      _selectionStart = value;
    }
  }

  set selectionEnd(int? value) {
    if (value != null) {
      _selectionEnd = value;
    }
  }
}

mixin BaseInputState on WebFWidgetElementState {
  TextEditingController controller = TextEditingController();
  FocusNode? _focusNode;

  @override
  BaseInputElement get widgetElement => super.widgetElement as BaseInputElement;

  bool get _isFocus => _focusNode?.hasFocus ?? false;

  void blur() {
    _focusNode?.unfocus();
  }

  void focus() {
    _focusNode?.requestFocus();
  }

  void initBaseInputState() {
    _focusNode ??= FocusNode();
    _focusNode!.addListener(handleFocusChange);
    // Initialize controller text from element value when state is created.
    controller.value = TextEditingValue(text: widgetElement.elementValue);
    // Honor pending focus requests issued before state existed.
    if (widgetElement._pendingFocus) {
      // Schedule to ensure the widget tree is ready.
      scheduleMicrotask(() {
        if (mounted) {
          focus();
        }
      });
      widgetElement._pendingFocus = false;
    }
  }

  void handleFocusChange() {
    if (_isFocus) {
      widgetElement.oldValue = widgetElement.value;
      scheduleMicrotask(() {
        widgetElement.dispatchEvent(dom.FocusEvent(dom.EVENT_FOCUS, relatedTarget: widgetElement));
      });

      HardwareKeyboard.instance.addHandler(_handleKey);
      // Try to keep the focused input visible within the nearest overflow scroll container.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // A second pass after the keyboard animates in.
        Future.delayed(const Duration(milliseconds: 350), () {
          // if (mounted) _scrollIntoNearestOverflow();
          if (mounted) {
            // Use alignment=1.0 to position input at bottom of viewport for better keyboard visibility
            WebFEnsureVisible.acrossScrollables(context, alignment: 1.0);
          }
        });
      });
    } else {
      if (widgetElement.oldValue != widgetElement.value) {
        scheduleMicrotask(() {
          widgetElement.dispatchEvent(dom.Event('change'));
        });
      }
      scheduleMicrotask(() {
        widgetElement.dispatchEvent(dom.FocusEvent(dom.EVENT_BLUR, relatedTarget: widgetElement));
      });

      HardwareKeyboard.instance.removeHandler(_handleKey);
    }
  }

  bool _handleKey(KeyEvent event) {
    if (event is KeyUpEvent) {
      widgetElement.dispatchEvent(dom.KeyboardEvent(
        dom.EVENT_KEY_UP,
        code: event.physicalKey.debugName ?? '',
        key: event.logicalKey.keyLabel,
      ));
    } else if (event is KeyDownEvent) {
      widgetElement.dispatchEvent(dom.KeyboardEvent(
        dom.EVENT_KEY_DOWN,
        code: event.physicalKey.debugName ?? '',
        key: event.logicalKey.keyLabel,
      ));
    }
    return false;
  }

  void deactivateBaseInput() {
    _focusNode?.unfocus();
    _focusNode?.removeListener(handleFocusChange);
  }

  void _updateSelection() {
    int? start = widgetElement.selectionStart;
    int? end = widgetElement.selectionEnd;
    if (start != null && end != null) {
      controller.selection = TextSelection(baseOffset: start, extentOffset: end);
    }
  }

  Widget createInputWidget(BuildContext context) {
    onChanged(String newValue) {
      setState(() {
        widgetElement._selectionStart = null;
        widgetElement._selectionEnd = null;

        // Keep element value as source of truth.
        widgetElement.setElementValue(newValue);
        dom.InputEvent inputEvent = dom.InputEvent(inputType: '', data: newValue);
        widgetElement.dispatchEvent(inputEvent);
      });
    }

    _updateSelection();


    bool isAutoHeight = widgetElement.renderStyle.height.isAuto;
    bool isAutoWidth = widgetElement.renderStyle.width.isAuto;

    // Accessible name (ARIA or native <label>) for Semantics wrapper.
    final String? accessibleName = WebFAccessibility.computeAccessibleName(widgetElement);

    final double fs = widgetElement.renderStyle.fontSize.computedValue;
    final double nonNegativeFontSize = fs.isFinite && fs >= 0 ? fs : 0.0;

    InputDecoration decoration = InputDecoration(
        label: widgetElement.label != null ? Text(widgetElement.label!) : null,
        border: InputBorder.none,
        isDense: true,
        // Changed to false for better text baseline handling
        isCollapsed: false,
        hintText: widgetElement.placeholder,
        hintStyle: TextStyle(
          fontSize: nonNegativeFontSize,
          height: 1.0, // Ensure hint text has consistent line height
          // Match the main text style for consistent baseline
          fontWeight: widgetElement.renderStyle.fontWeight,
          fontFamily: widgetElement.renderStyle.fontFamily?.join(' '),
        ),
        counterText: '',
        // Hide counter to align with web
        suffix: widgetElement.isSearch && widgetElement.value.isNotEmpty && _isFocus
            ? SizedBox(
          width: 14,
          height: 14,
          child: IconButton(
            iconSize: 14,
            padding: const EdgeInsets.all(0),
            onPressed: () {
              setState(() {
                controller.clear();
                dom.InputEvent inputEvent = dom.InputEvent(inputType: '', data: '');
                widgetElement.dispatchEvent(inputEvent);
              });
            },
            icon: Icon(Icons.clear),
          ),
        )
            : null);
    Widget widget = TextField(
      controller: controller,
      cursorHeight: nonNegativeFontSize,
      enabled: !widgetElement.disabled && !widgetElement.readonly,
      style: widgetElement._textStyle,
      strutStyle: null,
      onTap: () {
        final box = context.findRenderObject() as RenderBox;
        final Offset globalOffset = box.globalToLocal(Offset.zero);
        final double clientX = globalOffset.dx;
        final double clientY = globalOffset.dy;
        widgetElement.dispatchEvent(dom.MouseEvent(dom.EVENT_CLICK,
            clientX: clientX, clientY: clientY, view: widgetElement.ownerDocument.defaultView));
      },
      // Remove StrutStyle to avoid conflicts with text baseline
      autofocus: widgetElement.autofocus,
      minLines: widgetElement.minLines,
      maxLines: widgetElement.maxLines,
      maxLength: widgetElement.maxLength,
      onChanged: onChanged,
      textAlign: widgetElement.renderStyle.textAlign,
      textAlignVertical: TextAlignVertical.center,
      focusNode: _focusNode,
      obscureText: widgetElement.isPassWord,
      cursorColor: widgetElement.renderStyle.caretColor ?? widgetElement.renderStyle.color.value,
      cursorRadius: Radius.circular(4),
      textInputAction: widgetElement.getTextInputAction(),
      keyboardType: widgetElement.getKeyboardType(),
      inputFormatters: widgetElement.getInputFormatters(),
      onSubmitted: (String value) {
        if (widgetElement.isSearch) {
          widgetElement.dispatchEvent(dom.Event('search'));
        }
        widgetElement.dispatchEvent(dom.KeyboardEvent(
          dom.EVENT_KEY_DOWN,
          code: 'Enter',
          key: 'Enter',
        ));
        widgetElement.dispatchEvent(dom.KeyboardEvent(
          dom.EVENT_KEY_UP,
          code: 'Enter',
          key: 'Enter',
        ));
      },
      decoration: decoration,
    );

    widget = IntrinsicHeight(
      child: widget,
    );

    // Align the input if the height was set.
    if (!isAutoHeight && widgetElement is! FlutterTextAreaElement) {
      widget = Align(child: widget);
    }

    // Apply a default min-width of ~20ch when CSS width is auto.
    // Use the width of 18 '0' glyphs with current text style, similar to CSS `ch` unit.
    if (isAutoWidth && widgetElement is! FlutterTextAreaElement) {
      final TextStyle style = widgetElement._textStyle;
      final TextPainter tp = TextPainter(
        text: TextSpan(text: '000000000000000000', style: style), // 18 zeros
        textScaler: widgetElement.renderStyle.textScaler,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )
        ..layout(minWidth: 0, maxWidth: double.infinity);

      final double ch18Width = tp.width;
      // Respect CSS min-width if set (default UA style may set min-width: 140px)
      final double cssMinWidth = widgetElement.renderStyle.minWidth.computedValue;
      final double minWidth = math.max(ch18Width, cssMinWidth);

      widget = ConstrainedBox(constraints: BoxConstraints(maxWidth: minWidth, minWidth: minWidth), child: widget);
    }

    // Apply default width for textarea when CSS width is auto.
    if (isAutoWidth && widgetElement is FlutterTextAreaElement) {
      // Use `cols` attribute if provided; default to 20.
      int columns = 20;
      final String? colsAttr = widgetElement.getAttribute('cols');
      if (colsAttr != null) {
        final int? parsed = int.tryParse(colsAttr);
        if (parsed != null && parsed > 0) columns = parsed;
      }

      final TextStyle style = widgetElement._textStyle;
      final String zeros = List.filled(columns, '0').join();
      final TextPainter tp = TextPainter(
        text: TextSpan(text: zeros, style: style),
        textScaler: widgetElement.renderStyle.textScaler,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(minWidth: 0, maxWidth: double.infinity);

      final double chColsWidth = tp.width;
      final double cssMinWidth = widgetElement.renderStyle.minWidth.computedValue;
      final double minWidth = math.max(chColsWidth, cssMinWidth);

      // Enforce default width using cols; allow grow if CSS or layout expands beyond it.
      widget = ConstrainedBox(constraints: BoxConstraints(minWidth: minWidth, maxWidth: minWidth), child: widget);
    }

    // ARIA semantics for accessible name/description on input controls.
    final String? semanticsHint = WebFAccessibility.computeAccessibleDescription(widgetElement);
    if ((accessibleName != null && accessibleName.isNotEmpty) || (semanticsHint != null && semanticsHint.isNotEmpty)) {
      widget = Semantics(
        container: true,
        label: (accessibleName != null && accessibleName.isNotEmpty) ? accessibleName : null,
        hint: (semanticsHint != null && semanticsHint.isNotEmpty) ? semanticsHint : null,
        textDirection: widgetElement.renderStyle.direction,
        child: widget,
      );
    }

    return widget;
  }

  void disposeBaseInput() {
    _focusNode?.removeListener(handleFocusChange);
    _focusNode?.unfocus();
  }
}
