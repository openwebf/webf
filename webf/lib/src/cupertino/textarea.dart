import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:webf/webf.dart';

class FlutterCupertinoTextArea extends WidgetElement {
  FlutterCupertinoTextArea(super.context) {
    _controller.addListener(_handleTextChange);
  }

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['val'] = ElementAttributeProperty(
      getter: () => _controller.text,
      setter: (value) {
        if (value != _controller.text) {
          _controller.text = value;
          setState(() {});
        }
      }
    );

    attributes['placeholder'] = ElementAttributeProperty(
      getter: () => _placeholder,
      setter: (value) {
        _placeholder = value;
        setState(() {});
      }
    );

    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value == 'true';
        setState(() {});
      }
    );

    attributes['readonly'] = ElementAttributeProperty(
      getter: () => _readOnly.toString(),
      setter: (value) {
        _readOnly = value == 'true';
        setState(() {});
      }
    );

    attributes['maxLength'] = ElementAttributeProperty(
      getter: () => _maxLength?.toString() ?? '',
      setter: (value) {
        _maxLength = int.tryParse(value);
        setState(() {});
      }
    );

    attributes['rows'] = ElementAttributeProperty(
      getter: () => _rows.toString(),
      setter: (value) {
        _rows = int.tryParse(value) ?? 2;
        setState(() {});
      }
    );

    attributes['showCount'] = ElementAttributeProperty(
      getter: () => _showCount.toString(),
      setter: (value) {
        _showCount = value == 'true';
        setState(() {});
      }
    );

    attributes['autoSize'] = ElementAttributeProperty(
      getter: () => _autoSize.toString(),
      setter: (value) {
        _autoSize = value == 'true';
        setState(() {});
      }
    );

    attributes['transparent'] = ElementAttributeProperty(
      getter: () => _transparent.toString(),
      setter: (value) {
        _transparent = value == 'true';
        setState(() {});
      }
    );
  }

  String _placeholder = '';
  bool _disabled = false;
  bool _readOnly = false;
  int? _maxLength;
  int _rows = 2;
  bool _showCount = false;
  bool _autoSize = false;
  bool _transparent = false;

  void _handleTextChange() {
    if (_showCount && _maxLength != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    // Get theme colors
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define colors based on theme
    final backgroundColor = _transparent 
        ? Colors.transparent
        : _disabled
            ? (isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6)
            : (isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.white);
    
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;
    final placeholderColor = isDark 
        ? CupertinoColors.systemGrey.darkColor 
        : CupertinoColors.placeholderText;
    final countTextColor = isDark
        ? CupertinoColors.systemGrey.darkColor
        : CupertinoColors.systemGrey;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: _autoSize ? double.infinity : (_rows * 24.0 + 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !_disabled,
            readOnly: _readOnly,
            maxLines: _autoSize ? null : _rows,
            minLines: _rows,
            maxLength: _showCount ? null : _maxLength,
            keyboardType: TextInputType.multiline,
            textAlign: renderStyle.textAlign,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              color: textColor,
              fontSize: renderStyle.fontSize.value,
              fontWeight: renderStyle.fontWeight,
              height: 1.2,
            ),
            placeholder: _placeholder,
            placeholderStyle: TextStyle(
              color: placeholderColor,
              fontSize: renderStyle.fontSize.value,
              height: 1.2,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: _transparent ? null : BorderRadius.circular(8),
              border: _transparent ? null : Border.all(
                color: isDark ? CupertinoColors.systemGrey.darkColor : CupertinoColors.systemGrey4,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onChanged: (value) {
              dispatchEvent(CustomEvent('input', detail: value));
            },
            onEditingComplete: () {
              dispatchEvent(Event('complete'));
            },
          ),
          if (_showCount && _maxLength != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.length}/$_maxLength',
                  style: TextStyle(
                    color: countTextColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap textareaSyncMethods = {
    'focus': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final textarea = castToType<FlutterCupertinoTextArea>(element);
        textarea._focusNode.requestFocus();
      },
    ),
    'blur': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final textarea = castToType<FlutterCupertinoTextArea>(element);
        textarea._focusNode.unfocus();
      },
    ),
    'clear': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final textarea = castToType<FlutterCupertinoTextArea>(element);
        textarea._controller.clear();
        textarea.setState(() {});
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    textareaSyncMethods,
  ];

  @override
  void willDetachRenderer([RenderObjectElement? flutterWidgetElement]) {
    super.willDetachRenderer(flutterWidgetElement);
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
