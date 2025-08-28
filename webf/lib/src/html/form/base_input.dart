/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:webf/rendering.dart';
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/html.dart';
import 'package:webf/widget.dart';

import 'form_element_base.dart';

const Map<String, dynamic> _inputDefaultStyle = {
  BORDER: '2px solid rgb(118, 118, 118)',
  DISPLAY: INLINE_BLOCK,
  MAX_WIDTH: '140px',
  MIN_HEIGHT: '25px',
  COLOR: '#000'
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

  @override
  Map<String, dynamic> get defaultStyle {
    switch (type) {
      case 'text':
      case 'time':
        return _inputDefaultStyle;
      case 'radio':
      case 'checkbox':
        return _checkboxDefaultStyle;
    }
    return super.defaultStyle;
  }

  @override
  FlutterInputElementState? get state => super.state as FlutterInputElementState?;

  String get value => state?.controller.value.text ?? '';

  set value(value) {
    if (value == null) {
      state?.controller.value = TextEditingValue.empty;
    } else {
      value = value.toString();
      if (state?.controller.value.text != value) {
        state?.controller.value = TextEditingValue(text: value.toString());
      }
    }
  }

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

  String get type => getAttribute('type') ?? 'text';

  String? get inputMode => getAttribute('inputmode');

  String? get enterKeyHint => getAttribute('enterkeyhint');

  void set type(value) {
    internalSetAttribute('type', value?.toString() ?? '');
    resetInputDefaultStyle();
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

  TextStyle get _textStyle => TextStyle(
        color: renderStyle.color.value,
        fontSize: fontSize,
        fontWeight: renderStyle.fontWeight,
        fontFamily: renderStyle.fontFamily?.join(' '),
        height: 1.0,
      );

  StrutStyle get _textStruct => StrutStyle(
        leading: leading,
      );

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
  }

  void handleFocusChange() {
    if (_isFocus) {
      print('[WebF][Input] Focus gained on ${widgetElement.tagName}#${(widgetElement as dom.Element).id ?? ''}');
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
            WebFEnsureVisible.acrossScrollables(context);
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

  // Adjust ancestor scrollables (inner → outer) so this input becomes visible on screen.
  void _scrollIntoNearestOverflow() {
    print('[WebF][Input] Begin scroll-into-view for ${widgetElement.tagName}');
    // Ensure latest layout values.
    RendererBinding.instance.rootPipelineOwner.flushLayout();

    // Walk up DOM to collect all scrollable ancestors (nearest first).
    dom.Node? node = widgetElement.parentNode;
    final List<dom.Element> scrollChain = [];
    int hops = 0;
    while (node is dom.Element) {
      final idOrEmpty = node.id ?? '';
      print('[WebF][Input] Visit ancestor ${node.tagName}#$idOrEmpty hasY=${node.scrollControllerY != null} hasX=${node.scrollControllerX != null}');
      if (node.scrollControllerY != null) {
        scrollChain.add(node);
      }
      node = node.parentNode;
      if (++hops > 32) { print('[WebF][Input] Ancestor search bailout at depth 32'); break; }
    }
    if (scrollChain.isEmpty) {
      print('[WebF][Input] No scrollable ancestors found');
      return;
    }

    // Get render objects for target and scroll container.
    final RenderObject? targetRO = widgetElement.attachedRenderer;
    final RenderViewportBox? root = widgetElement.ownerDocument.viewport;
    if (targetRO is! RenderBox || root == null) {
      print('[WebF][Input] Missing RenderBox/Root: targetRO=${targetRO.runtimeType}, root=$root');
      return;
    }

    // Compute target rect relative to root viewport.
    Offset targetToRoot = getLayoutTransformTo(targetRO, root);
    final double targetHeight = (targetRO is RenderBoxModel)
        ? (targetRO as RenderBoxModel).boxSize?.height ?? targetRO.size.height
        : targetRO.size.height;

    // Compute visible screen height considering keyboard/host resize.
    double visibleScreenHeight = 0.0;
    final view = View.maybeOf(context);
    final mq = MediaQuery.maybeOf(context);
    final double rawHeight = view != null ? (view.physicalSize.height / view.devicePixelRatio) : 0.0;
    final double inset = (view?.viewInsets.bottom ?? 0.0) > 0.0
        ? (view?.viewInsets.bottom ?? 0.0)
        : (mq?.viewInsets.bottom ?? 0.0);
    if (rawHeight > 0) {
      visibleScreenHeight = (rawHeight - inset).clamp(0.0, rawHeight);
    }
    if (visibleScreenHeight == 0.0 && (mq?.size.height ?? 0) > 0) {
      visibleScreenHeight = mq!.size.height;
    }

    // Compute necessary translation on screen: positive = scroll ancestors up; negative = down.
    final double targetTopOnScreen = targetToRoot.dy;
    final double targetBottomOnScreen = targetToRoot.dy + targetHeight;
    double delta = 0.0;
    if (targetBottomOnScreen > visibleScreenHeight) {
      delta = targetBottomOnScreen - visibleScreenHeight;
    } else if (targetTopOnScreen < 0) {
      delta = targetTopOnScreen; // negative => scroll down
    }
    print('[WebF][Input] screenVisible=$visibleScreenHeight targetTop=$targetTopOnScreen targetBottom=$targetBottomOnScreen initialDelta=$delta');

    if (delta == 0.0) {
      print('[WebF][Input] Target already fully visible on screen');
      return;
    }

    // Apply delta across inner→outer scrollables, limited by each one's available extent.
    double remaining = delta;
    for (final el in scrollChain) {
      final ctrl = el.scrollControllerY!;
      if (!ctrl.hasClients) continue;
      final current = ctrl.position.pixels;
      final minExtent = ctrl.position.minScrollExtent;
      final maxExtent = ctrl.position.maxScrollExtent;
      double available = 0.0;
      if (remaining > 0) {
        available = (maxExtent - current).clamp(0.0, double.infinity);
      } else if (remaining < 0) {
        available = (current - minExtent).clamp(0.0, double.infinity);
      }
      final double consume = remaining.sign * math.min(available, remaining.abs());
      if (consume != 0.0) {
        final double target = (current + consume).clamp(minExtent, maxExtent);
        try {
          ctrl.jumpTo(target);
          print('[WebF][Input] Scrolled ${el.tagName}#${el.id ?? ''} by ${consume.toStringAsFixed(1)} -> $target');
        } catch (e) {
          print('[WebF][Input] jumpTo error on ${el.tagName}: $e');
        }
        remaining -= consume;
        if (remaining.abs() < 1.0) break;
      }
    }

    // Recompute after scrolling to verify.
    RendererBinding.instance.rootPipelineOwner.flushLayout();
    targetToRoot = getLayoutTransformTo(targetRO, root);
    final double top2 = targetToRoot.dy;
    final double bottom2 = targetToRoot.dy + targetHeight;
    print('[WebF][Input] after-scroll top=$top2 bottom=$bottom2 visible=$visibleScreenHeight remaining=${remaining.toStringAsFixed(1)}');
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

        dom.InputEvent inputEvent = dom.InputEvent(inputType: '', data: newValue);
        widgetElement.dispatchEvent(inputEvent);
      });
    }

    _updateSelection();

    InputDecoration decoration = InputDecoration(
        label: widgetElement.label != null ? Text(widgetElement.label!) : null,
        border: InputBorder.none,
        isDense: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.fromLTRB(0, widgetElement._defaultPadding, 0, widgetElement._defaultPadding),
        hintText: widgetElement.placeholder,
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
    late Widget widget = TextField(
      controller: controller,
      cursorHeight: widgetElement.renderStyle.fontSize.computedValue,
      enabled: !widgetElement.disabled && !widgetElement.readonly,
      style: widgetElement._textStyle,
      strutStyle: widgetElement._textStruct,
      autofocus: widgetElement.autofocus,
      minLines: widgetElement.minLines,
      maxLines: widgetElement.maxLines,
      maxLength: widgetElement.maxLength,
      onChanged: onChanged,
      textAlign: widgetElement.renderStyle.textAlign,
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
    return widget;
  }

  void disposeBaseInput() {
    _focusNode?.removeListener(handleFocusChange);
    _focusNode?.unfocus();
  }
}
