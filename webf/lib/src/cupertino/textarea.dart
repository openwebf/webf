/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:webf/webf.dart';

class FlutterCupertinoTextArea extends WidgetElement {
  FlutterCupertinoTextArea(super.context);

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['val'] = ElementAttributeProperty(
      getter: () => state?._controller.text,
      setter: (value) {
        if (value != state?._controller.text) {
          state?._controller.text = value;
        }
      }
    );

    attributes['placeholder'] = ElementAttributeProperty(
      getter: () => _placeholder,
      setter: (value) {
        _placeholder = value;
      }
    );

    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value != 'false';
      }
    );

    attributes['readonly'] = ElementAttributeProperty(
      getter: () => _readOnly.toString(),
      setter: (value) {
        _readOnly = value != 'false';
      }
    );

    attributes['maxLength'] = ElementAttributeProperty(
      getter: () => _maxLength?.toString() ?? '',
      setter: (value) {
        _maxLength = int.tryParse(value);
      }
    );

    attributes['rows'] = ElementAttributeProperty(
      getter: () => _rows.toString(),
      setter: (value) {
        _rows = int.tryParse(value) ?? 2;
      }
    );

    attributes['showCount'] = ElementAttributeProperty(
      getter: () => _showCount.toString(),
      setter: (value) {
        _showCount = value != 'false';
      }
    );

    attributes['autoSize'] = ElementAttributeProperty(
      getter: () => _autoSize.toString(),
      setter: (value) {
        _autoSize = value != 'false';
      }
    );

    attributes['transparent'] = ElementAttributeProperty(
      getter: () => _transparent.toString(),
      setter: (value) {
        _transparent = value != 'false';
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

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap textareaSyncMethods = {
    'focus': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final textarea = castToType<FlutterCupertinoTextArea>(element);
        textarea.state?._focusNode.requestFocus();
      },
    ),
    'blur': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final textarea = castToType<FlutterCupertinoTextArea>(element);
        textarea.state?._focusNode.unfocus();
      },
    ),
    'clear': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final textarea = castToType<FlutterCupertinoTextArea>(element);
        textarea.state?._controller.clear();
        textarea.state?.requestUpdateState();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    textareaSyncMethods,
  ];

  @override
  FlutterCupertinoTextAreaState? get state => super.state as FlutterCupertinoTextAreaState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoTextAreaState(this);
  }
}

class FlutterCupertinoTextAreaState extends WebFWidgetElementState {
  FlutterCupertinoTextAreaState(super.widgetElement);

  @override
  FlutterCupertinoTextArea get widgetElement => super.widgetElement as FlutterCupertinoTextArea;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    if (widgetElement._showCount && widgetElement._maxLength != null) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define colors based on theme
    final backgroundColor = widgetElement._transparent
        ? Colors.transparent
        : widgetElement._disabled
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
        maxHeight: widgetElement._autoSize ? double.infinity : (widgetElement._rows * 24.0 + 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !widgetElement._disabled,
            readOnly: widgetElement._readOnly,
            maxLines: widgetElement._autoSize ? null : widgetElement._rows,
            minLines: widgetElement._rows,
            maxLength: widgetElement._showCount ? null : widgetElement._maxLength,
            keyboardType: widgetElement._autoSize ? TextInputType.multiline : TextInputType.text,
            textAlign: widgetElement.renderStyle.textAlign,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              color: textColor,
              fontSize: widgetElement.renderStyle.fontSize.value,
              fontWeight: widgetElement.renderStyle.fontWeight,
              height: 1.2,
            ),
            placeholder: widgetElement._placeholder,
            placeholderStyle: TextStyle(
              color: placeholderColor,
              fontSize: widgetElement.renderStyle.fontSize.value,
              height: 1.2,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: widgetElement._transparent ? null : BorderRadius.circular(8),
              border: widgetElement._transparent ? null : Border.all(
                color: isDark ? CupertinoColors.systemGrey.darkColor : CupertinoColors.systemGrey4,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onChanged: (value) {
              widgetElement.dispatchEvent(CustomEvent('input', detail: value));
            },
            onEditingComplete: () {
              widgetElement.dispatchEvent(Event('complete'));
            },
          ),
          if (widgetElement._showCount && widgetElement._maxLength != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.length}/${widgetElement._maxLength}',
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
}
