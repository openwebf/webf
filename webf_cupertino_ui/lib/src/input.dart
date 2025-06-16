/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';
import 'package:collection/collection.dart';
import 'package:webf/dom.dart' as dom;
import 'input_bindings_generated.dart';

class FlutterCupertinoInput extends FlutterCupertinoInputBindings {
  FlutterCupertinoInput(super.context);

  String _val = '';
  String _placeholder = '';
  String _type = 'text';
  bool _disabled = false;
  bool _autofocus = false;
  bool _clearable = false;
  int? _maxLength;
  bool _readOnly = false;

  @override
  String? get val => state?._controller.text;
  @override
  set val(value) {
    if (value != state?._controller.text) {
      state?._controller.text = value ?? '';
    }
  }

  @override
  String? get placeholder => _placeholder;
  @override
  set placeholder(value) {
    _placeholder = value ?? '';
  }

  @override
  String? get type => _type;
  @override
  set type(value) {
    _type = value ?? 'text';
  }

  @override
  bool? get disabled => _disabled;
  @override
  set disabled(value) {
    _disabled = value != 'false';
  }

  @override
  bool get autofocus => _autofocus;
  @override
  set autofocus(value) {
    _autofocus = value != 'false';
  }

  @override
  bool? get clearable => _clearable;
  @override
  set clearable(value) {
    _clearable = value != 'false';
  }

  @override
  int? get maxlength => _maxLength;
  @override
  set maxlength(value) {
    _maxLength = int.tryParse(value.toString());
  }

  @override
  bool? get readonly => _readOnly;
  @override
  set readonly(value) {
    _readOnly = value != 'false';
  }

  @override
  FlutterCupertinoInputState? get state => super.state as FlutterCupertinoInputState?;

  static TextInputType _getKeyboardType(String type) {
    switch (type) {
      case 'number':
        return TextInputType.number;
      case 'tel':
        return TextInputType.phone;
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      case 'search':
        return TextInputType.text;
      case 'password':
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters(String type) {
    final formatters = <TextInputFormatter>[];

    switch (type) {
      case 'number':
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case 'tel':
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
    }

    if (_maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(_maxLength));
    }

    return formatters.isEmpty ? null : formatters;
  }

  @override
  String getValue(List<dynamic> args) {
    return state?._controller.text ?? '';
  }

  @override
  void setValue(List<dynamic> args) {
    if (args.isNotEmpty) {
      state?._controller.text = args[0].toString();
    }
  }

  @override
  void focus(List<dynamic> args) {
    state?._focusNode.requestFocus();
  }

  @override
  void blur(List<dynamic> args) {
    state?._focusNode.unfocus();
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoInputState(this);
  }
}

class FlutterCupertinoInputState extends WebFWidgetElementState {
  FlutterCupertinoInputState(super.widgetElement);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  FlutterCupertinoInput get widgetElement => super.widgetElement as FlutterCupertinoInput;

  Widget? _buildSlotWidget(String slotName) {
    final slotNode = widgetElement.childNodes.firstWhereOrNull((node) {
      if (node is dom.Element) {
        return node.getAttribute('slotName') == slotName;
      }
      return false;
    });

    if (slotNode != null) {
      return SizedBox(
        width: slotName == 'prefix' ? 60 : 100,
        child: Center(
          child: slotNode.toWidget(),
        ),
      );
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get renderStyle
    final renderStyle = widgetElement.renderStyle;
    final hasHeight = renderStyle.height.value != null;
    final hasBorderRadius = renderStyle.borderRadius != null;
    final hasPadding = renderStyle.padding != EdgeInsets.zero;
    final textAlign = renderStyle.textAlign ?? TextAlign.left;

    // Build prefix and suffix
    final prefixWidget = _buildSlotWidget('prefix');
    final suffixWidget = _buildSlotWidget('suffix');

    return SizedBox(
      height: hasHeight ? renderStyle.height.value : 44.0,
      child: CupertinoTextField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widgetElement.placeholder,
        enabled: !widgetElement.disabled!,
        readOnly: widgetElement.readonly!,
        autofocus: widgetElement.autofocus!,
        obscureText: widgetElement.type == 'password',
        keyboardType: FlutterCupertinoInput._getKeyboardType(widgetElement.type!),
        textAlign: textAlign,
        inputFormatters: widgetElement._getInputFormatters(widgetElement.type!),
        onChanged: (value) {
          widgetElement.dispatchEvent(CustomEvent('input', detail: value));
        },
        onSubmitted: (value) {
          widgetElement.dispatchEvent(CustomEvent('submit', detail: value));
        },
        prefix: prefixWidget,
        suffix: suffixWidget,
        clearButtonMode: widgetElement.clearable! ? OverlayVisibilityMode.editing : OverlayVisibilityMode.never,
        decoration: BoxDecoration(
          color: isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.white,
          borderRadius: hasBorderRadius
              ? BorderRadius.circular(renderStyle.borderRadius!.first.x)
              : BorderRadius.circular(8),
        ),
        style: TextStyle(
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
            height: 1
        ),
        placeholderStyle: TextStyle(
            color: isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey,
            height: 1
        ),
        padding: hasPadding ? renderStyle.padding : const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }
}
