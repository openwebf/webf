/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';

import 'search_text_field_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoSearchTextField].
///
/// Exposed as `<flutter-cupertino-search-text-field>` in the DOM.
class FlutterCupertinoSearchTextField
    extends FlutterCupertinoSearchTextFieldBindings {
  FlutterCupertinoSearchTextField(super.context);

  String _val = '';
  String? _placeholder;
  bool _autofocus = false;
  bool _disabled = false;

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
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final bool next = value == true;
    if (next != _disabled) {
      _disabled = next;
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

  static StaticDefinedSyncBindingObjectMethodMap searchTextFieldMethods =
      <String, StaticDefinedSyncBindingObjectMethod>{
    'focus': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoSearchTextField>(element)._focusSync(args);
        return null;
      },
    ),
    'blur': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoSearchTextField>(element)._blurSync(args);
        return null;
      },
    ),
    'clear': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoSearchTextField>(element)._clearSync(args);
        return null;
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods =>
      <StaticDefinedSyncBindingObjectMethodMap>[
        ...super.methods,
        searchTextFieldMethods,
      ];

  @override
  FlutterCupertinoSearchTextFieldState? get state =>
      super.state as FlutterCupertinoSearchTextFieldState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSearchTextFieldState(this);
  }
}

class FlutterCupertinoSearchTextFieldState extends WebFWidgetElementState {
  FlutterCupertinoSearchTextFieldState(super.widgetElement);

  @override
  FlutterCupertinoSearchTextField get widgetElement =>
      super.widgetElement as FlutterCupertinoSearchTextField;

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

  TextInputType _keyboardTypeFor() {
    return TextInputType.text;
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

    final TextInputType keyboardType = _keyboardTypeFor();

    final EdgeInsetsGeometry padding =
        renderStyle.padding != EdgeInsets.zero
            ? renderStyle.padding
            : const EdgeInsetsDirectional.fromSTEB(5.5, 8, 5.5, 8);

    final Color? backgroundColor = renderStyle.backgroundColor?.value;
    final BoxDecoration decoration = BoxDecoration(
      color: backgroundColor ?? CupertinoColors.tertiarySystemFill,
      borderRadius:
          renderStyle.borderRadius != null && renderStyle.borderRadius!.isNotEmpty
              ? BorderRadius.only(
                  topLeft: renderStyle.borderRadius![0],
                  topRight: renderStyle.borderRadius![1],
                  bottomRight: renderStyle.borderRadius![2],
                  bottomLeft: renderStyle.borderRadius![3],
                )
              : const BorderRadius.all(Radius.circular(9.0)),
    );

    final TextAlign textAlign = renderStyle.textAlign;

    final Widget prefixIcon = Icon(
      CupertinoIcons.search,
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
      size: 20.0,
    );
    final Widget suffixIcon = Icon(
      CupertinoIcons.xmark_circle_fill,
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
      size: 20.0,
    );

    final Widget prefix = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 8, 0, 8),
      child: prefixIcon,
    );

    final Widget suffix = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 5, 8),
      child: GestureDetector(
        onTap: _clear,
        child: suffixIcon,
      ),
    );

    return CupertinoTextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      enabled: !isDisabled,
      autofocus: widgetElement.autofocus,
      cursorWidth: 2.0,
      cursorRadius: const Radius.circular(2.0),
      cursorOpacityAnimates: true,
      suffixMode: OverlayVisibilityMode.editing,
      placeholder: widgetElement.placeholder,
      padding: padding,
      textAlign: textAlign,
      prefix: prefix,
      suffix: suffix,
      inputFormatters: const <TextInputFormatter>[],
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
  }
}
