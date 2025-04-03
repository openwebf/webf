import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';
import 'package:collection/collection.dart';
import 'package:webf/dom.dart' as dom;

class FlutterCupertinoInput extends WidgetElement {
  FlutterCupertinoInput(super.context);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    
    // Input value
    attributes['val'] = ElementAttributeProperty(
      getter: () => _controller.text,
      setter: (val) {
        if (val != _controller.text) {
          _controller.text = val;
          setState(() {});
        }
      }
    );

    // Placeholder text
    attributes['placeholder'] = ElementAttributeProperty(
      getter: () => _placeholder,
      setter: (value) {
        _placeholder = value;
        setState(() {});
      }
    );

    // Input type
    attributes['type'] = ElementAttributeProperty(
      getter: () => _type,
      setter: (value) {
        _type = value;
        setState(() {});
      }
    );

    // Whether the input is disabled
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value != 'false';
        setState(() {});
      }
    );

    // Whether the input is autofocused
    attributes['autofocus'] = ElementAttributeProperty(
      getter: () => _autofocus.toString(),
      setter: (value) {
        _autofocus = value != 'false';
        setState(() {});
      }
    );

    // Whether to show the clear button
    attributes['clearable'] = ElementAttributeProperty(
      getter: () => _clearable.toString(),
      setter: (value) {
        _clearable = value != 'false';
        setState(() {});
      }
    );

    // Maximum length
    attributes['maxlength'] = ElementAttributeProperty(
      getter: () => _maxLength?.toString() ?? '',
      setter: (value) {
        _maxLength = int.tryParse(value);
        setState(() {});
      }
    );

    // Read-only mode
    attributes['readonly'] = ElementAttributeProperty(
      getter: () => _readOnly.toString(),
      setter: (value) {
        _readOnly = value != 'false';
        setState(() {});
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

  TextInputFormatter? _getInputFormatter(String? type) {
    switch (type) {
      case 'number':
      case 'tel':
        return FilteringTextInputFormatter.digitsOnly;
      default:
        return null;
    }
  }

  TextInputType _getKeyboardType(String type) {
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

  Widget? _buildSlotWidget(String slotName) {
    final slotNode = childNodes.firstWhereOrNull((node) {
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
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get renderStyle
    final style = renderStyle;
    final hasHeight = style?.height?.value != null;
    final hasBorderRadius = style?.borderRadius != null;
    final hasPadding = style?.padding != null && style!.padding != EdgeInsets.zero;
    final textAlign = style?.textAlign ?? TextAlign.left;

    // Build prefix and suffix
    final prefixWidget = _buildSlotWidget('prefix');
    final suffixWidget = _buildSlotWidget('suffix');

    return SizedBox(
      height: hasHeight ? style!.height!.value : 44.0,
      child: CupertinoTextField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: _placeholder,
        enabled: !_disabled,
        readOnly: _readOnly,
        autofocus: _autofocus,
        obscureText: _type == 'password',
        keyboardType: _getKeyboardType(_type),
        textAlign: textAlign,
        inputFormatters: _getInputFormatters(_type),
        onChanged: (value) {
          dispatchEvent(CustomEvent('input', detail: value));
        },
        onSubmitted: (value) {
          dispatchEvent(CustomEvent('submit', detail: value));
        },
        prefix: prefixWidget,
        suffix: suffixWidget,
        clearButtonMode: _clearable ? OverlayVisibilityMode.editing : OverlayVisibilityMode.never,
        decoration: BoxDecoration(
          color: isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.white,
          borderRadius: hasBorderRadius 
            ? BorderRadius.circular(style!.borderRadius!.first.x)
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
        padding: hasPadding ? style!.padding! : const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
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
        return input._controller.text;
      },
    ),
    'setValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final input = castToType<FlutterCupertinoInput>(element);
        if (args.isNotEmpty) {
          input._controller.text = args[0].toString();
        }
        return null;
      },
    ),
    'focus': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final input = castToType<FlutterCupertinoInput>(element);
        input._focusNode.requestFocus();
        return null;
      },
    ),
    'blur': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final input = castToType<FlutterCupertinoInput>(element);
        input._focusNode.unfocus();
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
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}