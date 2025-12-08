/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'text_form_field_row_bindings_generated.dart';

/// WebF custom element that wraps a single [CupertinoFormRow] containing
/// a borderless [CupertinoTextField], similar to Flutter's
/// [CupertinoTextFormFieldRow].
///
/// Exposed as `<flutter-cupertino-text-form-field-row>` in the DOM.
class FlutterCupertinoTextFormFieldRow
    extends FlutterCupertinoTextFormFieldRowBindings {
  FlutterCupertinoTextFormFieldRow(super.context);

  String _val = '';
  String? _placeholder;
  String _type = 'text';
  bool _disabled = false;
  bool _autofocus = false;
  bool _clearable = false;
  int? _maxlength;
  bool _readonly = false;

  @override
  bool get allowsInfiniteHeight => true;

  @override
  String? get val => _val;

  @override
  set val(value) {
    final String next = value?.toString() ?? '';
    if (next != _val) {
      _val = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get placeholder => _placeholder;

  @override
  set placeholder(value) {
    final String? next = value?.toString();
    if (next != _placeholder) {
      _placeholder = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get type => _type;

  @override
  set type(value) {
    final String next = (value?.toString() ?? 'text').toLowerCase();
    if (next != _type) {
      _type = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final bool next = value == true;
    if (next != _disabled) {
      _disabled = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get autofocus => _autofocus;

  @override
  set autofocus(value) {
    final bool next = value == true;
    if (next != _autofocus) {
      _autofocus = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get clearable => _clearable;

  @override
  set clearable(value) {
    final bool next = value == true;
    if (next != _clearable) {
      _clearable = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  int? get maxlength => _maxlength;

  @override
  set maxlength(value) {
    if (value == null) {
      _maxlength = null;
    } else if (value is int) {
      _maxlength = value > 0 ? value : null;
    } else {
      final int? parsed = int.tryParse(value.toString());
      _maxlength = parsed != null && parsed > 0 ? parsed : null;
    }
    state?.requestUpdateState(() {});
  }

  @override
  bool get readonly => _readonly;

  @override
  set readonly(value) {
    final bool next = value == true;
    if (next != _readonly) {
      _readonly = next;
      state?.requestUpdateState(() {});
    }
  }

  void _updateValueFromController(String value) {
    _val = value;
  }

  /// Imperative methods exposed to JavaScript.
  void _focusSync(List<dynamic> args) {
    state?._focus();
  }

  void _blurSync(List<dynamic> args) {
    state?._blur();
  }

  void _clearSync(List<dynamic> args) {
    state?._clear();
  }

  static StaticDefinedSyncBindingObjectMethodMap textFormFieldRowMethods =
      <String, StaticDefinedSyncBindingObjectMethod>{
    'focus': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoTextFormFieldRow>(element)._focusSync(args);
        return null;
      },
    ),
    'blur': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoTextFormFieldRow>(element)._blurSync(args);
        return null;
      },
    ),
    'clear': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoTextFormFieldRow>(element)._clearSync(args);
        return null;
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods =>
      <StaticDefinedSyncBindingObjectMethodMap>[
        ...super.methods,
        textFormFieldRowMethods,
      ];

  @override
  FlutterCupertinoTextFormFieldRowState? get state =>
      super.state as FlutterCupertinoTextFormFieldRowState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoTextFormFieldRowState(this);
  }
}

class FlutterCupertinoTextFormFieldRowState extends WebFWidgetElementState {
  FlutterCupertinoTextFormFieldRowState(super.widgetElement);

  @override
  FlutterCupertinoTextFormFieldRow get widgetElement =>
      super.widgetElement as FlutterCupertinoTextFormFieldRow;

  late final TextEditingController _controller;
  FocusNode? _focusNode;
  String _lastText = '';
  bool _suppressClearEvent = false;

  @override
  void initState() {
    super.initState();
    final String initialText = widgetElement.val ?? '';
    _controller = TextEditingController(text: initialText);
    _lastText = initialText;
    _focusNode = FocusNode();
    _focusNode!.addListener(() {
      if (_focusNode!.hasFocus) {
        widgetElement.dispatchEvent(CustomEvent('focus'));
      } else {
        widgetElement.dispatchEvent(CustomEvent('blur'));
      }
    });
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _focus() {
    if (widgetElement.disabled) return;
    final focusNode = _focusNode;
    if (focusNode == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  void _blur() {
    _focusNode?.unfocus();
  }

  void _clear() {
    _suppressClearEvent = true;
    _controller.clear();
    widgetElement._updateValueFromController('');
    _lastText = '';
    widgetElement.dispatchEvent(CustomEvent('clear'));
    widgetElement.dispatchEvent(CustomEvent('input', detail: ''));
  }

  TextInputType _keyboardTypeFor(String? type) {
    switch ((type ?? 'text').toLowerCase()) {
      case 'number':
        return const TextInputType.numberWithOptions(decimal: true);
      case 'tel':
        return TextInputType.phone;
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  bool _obscureTextFor(String? type) {
    return (type ?? 'text').toLowerCase() == 'password';
  }

  Widget? _getSlotChild(String slotName) {
    final dom.Node? slotNode = widgetElement.childNodes.firstWhereOrNull(
      (node) =>
          node is dom.Element && node.getAttribute('slotName') == slotName,
    );
    if (slotNode == null) {
      return null;
    }
    return WebFWidgetElementChild(child: slotNode.toWidget());
  }

  @override
  Widget build(BuildContext context) {
    final CSSRenderStyle renderStyle = widgetElement.renderStyle;

    // Keep controller text in sync with widgetElement.val.
    final String elementText = widgetElement.val ?? '';
    if (_controller.text != elementText) {
      _controller.value = _controller.value.copyWith(
        text: elementText,
        selection: TextSelection.collapsed(offset: elementText.length),
      );
    }

    final bool isDisabled = widgetElement.disabled;
    final bool isReadOnly = widgetElement.readonly;

    final TextInputType keyboardType =
        _keyboardTypeFor(widgetElement.type);
    final bool obscureText = _obscureTextFor(widgetElement.type);

    final List<TextInputFormatter> inputFormatters = <TextInputFormatter>[];
    final int? maxLength = widgetElement.maxlength;
    if (maxLength != null && maxLength > 0) {
      inputFormatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    final EdgeInsetsGeometry? padding =
        renderStyle.padding != EdgeInsets.zero ? renderStyle.padding : null;

    final TextAlign textAlign = renderStyle.textAlign;

    final Widget? prefix = _getSlotChild('prefix');
    final Widget? helper = _getSlotChild('helper');
    final Widget? error = _getSlotChild('error');

    final Widget? suffix = widgetElement.clearable
        ? ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (BuildContext context, TextEditingValue value, Widget? child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: _clear,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    CupertinoIcons.clear_thick_circled,
                    size: 18,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              );
            },
          )
        : null;

    final Widget textField = CupertinoTextField.borderless(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !isDisabled,
      readOnly: isReadOnly,
      autofocus: widgetElement.autofocus,
      keyboardType: keyboardType,
      obscureText: obscureText,
      placeholder: widgetElement.placeholder,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      suffix: suffix,
      onChanged: (String value) {
        final String previous = _lastText;
        _lastText = value;
        widgetElement._updateValueFromController(value);
        widgetElement.dispatchEvent(
          CustomEvent('input', detail: value),
        );
        if (!_suppressClearEvent &&
            previous.isNotEmpty &&
            value.isEmpty) {
          widgetElement.dispatchEvent(CustomEvent('clear'));
        }
        _suppressClearEvent = false;
      },
      onSubmitted: (String value) {
        widgetElement._updateValueFromController(value);
        widgetElement.dispatchEvent(
          CustomEvent('submit', detail: value),
        );
      },
    );

    return CupertinoFormRow(
      prefix: prefix,
      helper: helper,
      error: error,
      padding: padding,
      child: textField,
    );
  }
}
