/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'input_bindings_generated.dart';

/// WebF custom element that wraps Flutter's [CupertinoTextField].
///
/// Exposed as `<flutter-cupertino-input>` in the DOM.
class FlutterCupertinoInput extends FlutterCupertinoInputBindings {
  FlutterCupertinoInput(super.context);

  String _val = '';
  String? _placeholder;
  String _type = 'text';
  bool _disabled = false;
  bool _autofocus = false;
  bool _clearable = false;
  int? _maxlength;
  bool _readonly = false;

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

  void _updateValueFromController(String text) {
    if (text != _val) {
      _val = text;
    }
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

  static StaticDefinedSyncBindingObjectMethodMap inputMethods =
      <String, StaticDefinedSyncBindingObjectMethod>{
    'focus': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoInput>(element)._focusSync(args);
        return null;
      },
    ),
    'blur': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoInput>(element)._blurSync(args);
        return null;
      },
    ),
    'clear': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoInput>(element)._clearSync(args);
        return null;
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods =>
      <StaticDefinedSyncBindingObjectMethodMap>[
        ...super.methods,
        inputMethods,
      ];

  @override
  FlutterCupertinoInputState? get state =>
      super.state as FlutterCupertinoInputState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoInputState(this);
  }
}

class FlutterCupertinoInputState extends WebFWidgetElementState {
  FlutterCupertinoInputState(super.widgetElement);

  @override
  FlutterCupertinoInput get widgetElement =>
      super.widgetElement as FlutterCupertinoInput;

  late final TextEditingController _controller;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widgetElement.val ?? '');
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
    _controller.clear();
    widgetElement._updateValueFromController('');
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
    for (final node in widgetElement.childNodes) {
      if (node is dom.Element &&
          node.getAttribute('slotName') == slotName) {
        return WebFWidgetElementChild(child: node.toWidget());
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final CSSRenderStyle renderStyle = widgetElement.renderStyle;

    // Keep controller text in sync with widgetElement.val.
    final String elementText = widgetElement.val ?? '';
    if (_controller.text != elementText) {
      _controller.value = _controller.value.copyWith(
        text: elementText,
        selection:
            TextSelection.collapsed(offset: elementText.length),
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

    final EdgeInsetsGeometry padding =
        renderStyle.padding != EdgeInsets.zero
            ? renderStyle.padding
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    final Color? backgroundColor = renderStyle.backgroundColor?.value;
    final BoxDecoration? decoration =
        renderStyle.decoration as BoxDecoration?;
    final BorderRadius borderRadius = renderStyle.borderRadius != null
        ? BorderRadius.only(
            topLeft: renderStyle.borderRadius![0],
            topRight: renderStyle.borderRadius![1],
            bottomRight: renderStyle.borderRadius![2],
            bottomLeft: renderStyle.borderRadius![3],
          )
        : BorderRadius.circular(8);

    final TextAlign textAlign = renderStyle.textAlign;

    final Widget? prefix = _getSlotChild('prefix');
    final Widget? suffix = _getSlotChild('suffix');

    Widget textField = CupertinoTextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: !isDisabled,
      readOnly: isReadOnly,
      autofocus: widgetElement.autofocus,
      keyboardType: keyboardType,
      obscureText: obscureText,
      placeholder: widgetElement.placeholder,
      padding: padding,
      decoration: decoration ??
          BoxDecoration(
            color:
                backgroundColor ?? CupertinoColors.systemGrey6.resolveFrom(context),
            borderRadius: borderRadius,
          ),
      prefix: prefix,
      suffix: suffix ??
          (widgetElement.clearable && _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: _clear,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      CupertinoIcons.clear_thick_circled,
                      size: 18,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                )
              : null),
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      onChanged: (String value) {
        widgetElement._updateValueFromController(value);
        widgetElement.dispatchEvent(
          CustomEvent('input', detail: value),
        );
      },
      onSubmitted: (String value) {
        widgetElement._updateValueFromController(value);
        widgetElement.dispatchEvent(
          CustomEvent('submit', detail: value),
        );
      },
    );

    final double height = renderStyle.height.computedValue;
    if (height > 0) {
      textField = SizedBox(
        height: height,
        child: Center(child: textField),
      );
    }

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: textField,
    );
  }
}
