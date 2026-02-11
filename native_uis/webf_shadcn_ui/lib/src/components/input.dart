/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'input_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadInput].
///
/// Exposed as `<flutter-shadcn-input>` in the DOM.
class FlutterShadcnInput extends FlutterShadcnInputBindings {
  FlutterShadcnInput(super.context);

  String _value = '';
  String? _placeholder;
  String _type = 'text';
  bool _disabled = false;
  bool _readonly = false;
  int? _maxLength;
  int? _minLength;
  String? _pattern;
  bool _required = false;
  bool _autofocus = false;
  TextAlign _textAlign = TextAlign.start;
  TextCapitalization _textCapitalization = TextCapitalization.none;
  bool _autocorrect = true;
  bool _enableSuggestions = true;
  TextInputAction? _textInputAction;
  int? _maxLines = 1;
  int? _minLines;
  Color? _cursorColor;
  Color? _selectionColor;
  String _obscuringCharacter = '•';

  @override
  String get value => _value;

  @override
  set value(value) {
    final newValue = value?.toString() ?? '';
    if (newValue != _value) {
      _value = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get placeholder => _placeholder;

  @override
  set placeholder(value) {
    final newValue = value?.toString();
    if (newValue != _placeholder) {
      _placeholder = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get type => _type;

  @override
  set type(value) {
    final newValue = value?.toString() ?? 'text';
    if (newValue != _type) {
      _type = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final newValue = value == true;
    if (newValue != _disabled) {
      _disabled = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get readonly => _readonly;

  @override
  set readonly(value) {
    final newValue = value == true;
    if (newValue != _readonly) {
      _readonly = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get maxlength => _maxLength?.toString();

  @override
  set maxlength(value) {
    final newValue = value != null ? int.tryParse(value.toString()) : null;
    if (newValue != _maxLength) {
      _maxLength = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get minlength => _minLength?.toString();

  @override
  set minlength(value) {
    final newValue = value != null ? int.tryParse(value.toString()) : null;
    if (newValue != _minLength) {
      _minLength = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get pattern => _pattern;

  @override
  set pattern(value) {
    final newValue = value?.toString();
    if (newValue != _pattern) {
      _pattern = newValue;
    }
  }

  @override
  bool get required => _required;

  @override
  set required(value) {
    final newValue = value == true;
    if (newValue != _required) {
      _required = newValue;
    }
  }

  @override
  bool get autofocus => _autofocus;

  @override
  set autofocus(value) {
    final newValue = value == true;
    if (newValue != _autofocus) {
      _autofocus = newValue;
    }
  }

  @override
  String get textalign => _textAlign.name;

  @override
  set textalign(value) {
    final newValue = _parseTextAlign(value?.toString() ?? 'start');
    if (newValue != _textAlign) {
      _textAlign = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get autocapitalize => _textCapitalizationToString(_textCapitalization);

  @override
  set autocapitalize(value) {
    final newValue = _parseTextCapitalization(value?.toString() ?? 'none');
    if (newValue != _textCapitalization) {
      _textCapitalization = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get autocorrect => _autocorrect;

  @override
  set autocorrect(value) {
    final newValue = value != false;
    if (newValue != _autocorrect) {
      _autocorrect = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get enablesuggestions => _enableSuggestions;

  @override
  set enablesuggestions(value) {
    final newValue = value != false;
    if (newValue != _enableSuggestions) {
      _enableSuggestions = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get enterkeyhint =>
      _textInputAction != null ? _textInputActionToString(_textInputAction!) : null;

  @override
  set enterkeyhint(value) {
    final newValue = value != null ? _parseTextInputAction(value.toString()) : null;
    if (newValue != _textInputAction) {
      _textInputAction = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get maxlines => _maxLines?.toString();

  @override
  set maxlines(value) {
    final newValue = value != null ? int.tryParse(value.toString()) : null;
    if (newValue != _maxLines) {
      _maxLines = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get minlines => _minLines?.toString();

  @override
  set minlines(value) {
    final newValue = value != null ? int.tryParse(value.toString()) : null;
    if (newValue != _minLines) {
      _minLines = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get cursorcolor => _cursorColor != null
      ? '#${_cursorColor!.value.toRadixString(16).padLeft(8, '0')}'
      : null;

  @override
  set cursorcolor(value) {
    final newValue = value != null ? _parseColor(value.toString()) : null;
    if (newValue != _cursorColor) {
      _cursorColor = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get selectioncolor => _selectionColor != null
      ? '#${_selectionColor!.value.toRadixString(16).padLeft(8, '0')}'
      : null;

  @override
  set selectioncolor(value) {
    final newValue = value != null ? _parseColor(value.toString()) : null;
    if (newValue != _selectionColor) {
      _selectionColor = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get obscuringcharacter => _obscuringCharacter;

  @override
  set obscuringcharacter(value) {
    final newValue = value?.toString() ?? '•';
    if (newValue.isNotEmpty && newValue != _obscuringCharacter) {
      _obscuringCharacter = newValue.characters.first;
      state?.requestUpdateState(() {});
    }
  }

  // --- Parsing helpers ---

  static TextAlign _parseTextAlign(String value) {
    switch (value.toLowerCase()) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      case 'end':
        return TextAlign.end;
      case 'start':
      default:
        return TextAlign.start;
    }
  }

  static TextCapitalization _parseTextCapitalization(String value) {
    switch (value.toLowerCase()) {
      case 'sentences':
        return TextCapitalization.sentences;
      case 'words':
        return TextCapitalization.words;
      case 'characters':
        return TextCapitalization.characters;
      case 'none':
      default:
        return TextCapitalization.none;
    }
  }

  static String _textCapitalizationToString(TextCapitalization value) {
    switch (value) {
      case TextCapitalization.sentences:
        return 'sentences';
      case TextCapitalization.words:
        return 'words';
      case TextCapitalization.characters:
        return 'characters';
      case TextCapitalization.none:
        return 'none';
    }
  }

  static TextInputAction _parseTextInputAction(String value) {
    switch (value.toLowerCase()) {
      case 'done':
        return TextInputAction.done;
      case 'go':
        return TextInputAction.go;
      case 'next':
        return TextInputAction.next;
      case 'search':
        return TextInputAction.search;
      case 'send':
        return TextInputAction.send;
      case 'previous':
        return TextInputAction.previous;
      case 'newline':
        return TextInputAction.newline;
      default:
        return TextInputAction.done;
    }
  }

  static String _textInputActionToString(TextInputAction value) {
    switch (value) {
      case TextInputAction.done:
        return 'done';
      case TextInputAction.go:
        return 'go';
      case TextInputAction.next:
        return 'next';
      case TextInputAction.search:
        return 'search';
      case TextInputAction.send:
        return 'send';
      case TextInputAction.previous:
        return 'previous';
      case TextInputAction.newline:
        return 'newline';
      default:
        return 'done';
    }
  }

  static Color? _parseColor(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.startsWith('#')) {
      final hex = trimmed.substring(1);
      if (hex.length == 6) {
        final intValue = int.tryParse(hex, radix: 16);
        if (intValue != null) return Color(0xFF000000 | intValue);
      } else if (hex.length == 8) {
        final intValue = int.tryParse(hex, radix: 16);
        if (intValue != null) return Color(intValue);
      }
    }
    return null;
  }

  TextInputType get keyboardType {
    switch (_type.toLowerCase()) {
      case 'email':
        return TextInputType.emailAddress;
      case 'number':
        return TextInputType.number;
      case 'tel':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  bool get obscureText => _type.toLowerCase() == 'password';

  @override
  WebFWidgetElementState createState() => FlutterShadcnInputState(this);
}

class FlutterShadcnInputState extends WebFWidgetElementState {
  FlutterShadcnInputState(super.widgetElement);

  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  FlutterShadcnInput get widgetElement =>
      super.widgetElement as FlutterShadcnInput;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widgetElement.value);
    _focusNode = FocusNode();

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      widgetElement.dispatchEvent(Event('focus'));
    } else {
      widgetElement.dispatchEvent(Event('blur'));
      widgetElement.dispatchEvent(Event('change'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sync controller with external value changes
    if (_controller.text != widgetElement.value) {
      _controller.text = widgetElement.value;
    }

    List<TextInputFormatter>? inputFormatters;
    if (widgetElement._maxLength != null) {
      inputFormatters = [
        LengthLimitingTextInputFormatter(widgetElement._maxLength),
      ];
    }

    return ShadInput(
      controller: _controller,
      focusNode: _focusNode,
      placeholder: widgetElement.placeholder != null
          ? Text(widgetElement.placeholder!)
          : null,
      enabled: !widgetElement.disabled,
      readOnly: widgetElement.readonly,
      obscureText: widgetElement.obscureText,
      obscuringCharacter: widgetElement._obscuringCharacter,
      keyboardType: widgetElement.keyboardType,
      textInputAction: widgetElement._textInputAction,
      textCapitalization: widgetElement._textCapitalization,
      textAlign: widgetElement._textAlign,
      autofocus: widgetElement.autofocus,
      autocorrect: widgetElement._autocorrect,
      enableSuggestions: widgetElement._enableSuggestions,
      maxLines: widgetElement._maxLines,
      minLines: widgetElement._minLines,
      cursorColor: widgetElement._cursorColor,
      selectionColor: widgetElement._selectionColor,
      inputFormatters: inputFormatters,
      onChanged: (value) {
        widgetElement._value = value;
        widgetElement.dispatchEvent(Event('input'));
      },
      onSubmitted: (value) {
        widgetElement._value = value;
        widgetElement.dispatchEvent(Event('submit'));
      },
    );
  }
}
