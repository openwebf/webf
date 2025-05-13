/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';
import 'package:collection/collection.dart';
import 'package:webf/dom.dart' as dom;

class FlutterCupertinoInput extends WidgetElement {
  FlutterCupertinoInput(super.context);

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    // Input value
    attributes['val'] = ElementAttributeProperty(
      getter: () => state?._controller.text,
      setter: (val) {
        if (val != state?._controller.text) {
          state?._controller.text = val;
        }
      }
    );

    // Placeholder text
    attributes['placeholder'] = ElementAttributeProperty(
      getter: () => _placeholder,
      setter: (value) {
        _placeholder = value;
      }
    );

    // Input type
    attributes['type'] = ElementAttributeProperty(
      getter: () => _type,
      setter: (value) {
        _type = value;
      }
    );

    // Whether the input is disabled
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value != 'false';
      }
    );

    // Whether the input is autofocused
    attributes['autofocus'] = ElementAttributeProperty(
      getter: () => _autofocus.toString(),
      setter: (value) {
        _autofocus = value != 'false';
      }
    );

    // Whether to show the clear button
    attributes['clearable'] = ElementAttributeProperty(
      getter: () => _clearable.toString(),
      setter: (value) {
        _clearable = value != 'false';
      }
    );

    // Maximum length
    attributes['maxlength'] = ElementAttributeProperty(
      getter: () => _maxLength?.toString() ?? '',
      setter: (value) {
        _maxLength = int.tryParse(value);
      }
    );

    // Read-only mode
    attributes['readonly'] = ElementAttributeProperty(
      getter: () => _readOnly.toString(),
      setter: (value) {
        _readOnly = value != 'false';
      }
    );
  }

  String _placeholder = '';
  String _type = 'text';
  bool _disabled = false;
  bool _autofocus = false;
  bool _clearable = false;
  int? _maxLength;
  bool _readOnly = false;

  @override
  FlutterCupertinoInputState? get state => super.state as FlutterCupertinoInputState?;

  static TextInputFormatter? _getInputFormatter(String? type) {
    switch (type) {
      case 'number':
      case 'tel':
        return FilteringTextInputFormatter.digitsOnly;
      default:
        return null;
    }
  }

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

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap inputSyncMethods = {
    'getValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final input = castToType<FlutterCupertinoInput>(element);
        return input.state?._controller.text;
      },
    ),
    'setValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final input = castToType<FlutterCupertinoInput>(element);
        if (args.isNotEmpty) {
          input.state?._controller.text = args[0].toString();
        }
        return null;
      },
    ),
    'focus': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final input = castToType<FlutterCupertinoInput>(element);
        input.state?._focusNode.requestFocus();
        return null;
      },
    ),
    'blur': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final input = castToType<FlutterCupertinoInput>(element);
        input.state?._focusNode.unfocus();
        return null;
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    inputSyncMethods,
  ];

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
        placeholder: widgetElement._placeholder,
        enabled: !widgetElement._disabled,
        readOnly: widgetElement._readOnly,
        autofocus: widgetElement._autofocus,
        obscureText: widgetElement._type == 'password',
        keyboardType: FlutterCupertinoInput._getKeyboardType(widgetElement._type),
        textAlign: textAlign,
        inputFormatters: widgetElement._getInputFormatters(widgetElement._type),
        onChanged: (value) {
          widgetElement.dispatchEvent(CustomEvent('input', detail: value));
        },
        onSubmitted: (value) {
          widgetElement.dispatchEvent(CustomEvent('submit', detail: value));
        },
        prefix: prefixWidget,
        suffix: suffixWidget,
        clearButtonMode: widgetElement._clearable ? OverlayVisibilityMode.editing : OverlayVisibilityMode.never,
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
