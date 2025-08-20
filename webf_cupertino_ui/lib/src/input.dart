/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';
import 'package:collection/collection.dart';
import 'package:webf/dom.dart' as dom;
import 'input_bindings_generated.dart';

class FlutterCupertinoInput extends FlutterCupertinoInputBindings {
  FlutterCupertinoInput(super.context);

  String _placeholder = '';
  String _type = 'text';
  bool _disabled = false;
  bool _autofocus = false;
  bool _clearable = false;
  int? _maxLength;
  bool _readOnly = false;

  @override
  bool get disableBoxModelPaint => true;

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
  bool get disabled => _disabled;
  @override
  set disabled(value) {
    _disabled = value != 'false';
  }

  @override
  bool get autofocus => _autofocus;
  @override
  set autofocus(value) {
    _autofocus = value;
  }

  @override
  bool get clearable => _clearable;
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
  bool get readonly => _readOnly;
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
  bool _isFocused = false;

  @override
  FlutterCupertinoInput get widgetElement => super.widgetElement as FlutterCupertinoInput;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  Border? _getBorder(CSSRenderStyle renderStyle) {
    // Check if any border is defined by checking if any border has non-zero width
    final hasTopBorder = renderStyle.effectiveBorderTopWidth.computedValue > 0;
    final hasRightBorder = renderStyle.effectiveBorderRightWidth.computedValue > 0;
    final hasBottomBorder = renderStyle.effectiveBorderBottomWidth.computedValue > 0;
    final hasLeftBorder = renderStyle.effectiveBorderLeftWidth.computedValue > 0;

    if (hasTopBorder || hasRightBorder || hasBottomBorder || hasLeftBorder) {
      // Get the border width (assuming uniform border)
      final borderWidth = renderStyle.effectiveBorderTopWidth.computedValue;

      if (_isFocused) {
        // Use blue color when focused
        return Border.all(
          color: CupertinoColors.activeBlue,
          width: borderWidth,
        );
      } else {
        // Use the original border color when not focused
        final borderColor = renderStyle.borderTopColor.value;
        return Border.all(
          color: borderColor,
          width: borderWidth,
        );
      }
    }

    // Default border behavior if no border is defined
    if (_isFocused) {
      return Border.all(
        color: CupertinoColors.activeBlue,
        width: 1.0,
      );
    }

    return null;
  }

  Widget? _buildSlotWidget<T>(String slotName) {
    final slotNode = widgetElement.childNodes.firstWhereOrNull((node) {
      return node is T;
    });

    if (slotNode != null) {
      return SizedBox(
        width: slotName == 'prefix' ? 60 : 100,
        child: Center(
          child: WebFWidgetElementChild(child: slotNode.toWidget()),
        ),
      );
    }
    return null;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
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
    final textAlign = renderStyle.textAlign;

    // Build prefix and suffix
    final prefixWidget = _buildSlotWidget<FlutterCupertinoInputPrefix>('prefix');
    final suffixWidget = _buildSlotWidget<FlutterCupertinoInputSuffix>('suffix');

    return SizedBox(
      height: hasHeight ? renderStyle.height.value : 44.0,
      child: CupertinoTextField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widgetElement.placeholder,
        enabled: !widgetElement.disabled,
        readOnly: widgetElement.readonly,
        autofocus: widgetElement.autofocus,
        obscureText: widgetElement.type == 'password',
        keyboardType: FlutterCupertinoInput._getKeyboardType(widgetElement.type ?? 'text'),
        textAlign: textAlign,
        inputFormatters: widgetElement._getInputFormatters(widgetElement.type ?? 'text'),
        onChanged: (value) {
          widgetElement.dispatchEvent(CustomEvent('input', detail: value));
        },
        onSubmitted: (value) {
          widgetElement.dispatchEvent(CustomEvent('submit', detail: value));
        },
        prefix: prefixWidget,
        suffix: suffixWidget,
        clearButtonMode: widgetElement.clearable ? OverlayVisibilityMode.editing : OverlayVisibilityMode.never,
        decoration: BoxDecoration(
          color: isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.white,
          borderRadius: hasBorderRadius
              ? BorderRadius.circular(renderStyle.borderRadius!.first.x)
              : BorderRadius.circular(8),
          border: _getBorder(renderStyle),
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

// Sub-component classes for input slots
class FlutterCupertinoInputPrefix extends WidgetElement {
  FlutterCupertinoInputPrefix(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoInputPrefixState(this);
  }
}

class FlutterCupertinoInputPrefixState extends WebFWidgetElementState {
  FlutterCupertinoInputPrefixState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList()));
  }
}

class FlutterCupertinoInputSuffix extends WidgetElement {
  FlutterCupertinoInputSuffix(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoInputSuffixState(this);
  }
}

class FlutterCupertinoInputSuffixState extends WebFWidgetElementState {
  FlutterCupertinoInputSuffixState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
        child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.ownerDocument.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList()));
  }
}
