/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:webf/webf.dart';
import 'textarea_bindings_generated.dart';

class FlutterCupertinoTextArea extends FlutterCupertinoTextareaBindings {
  FlutterCupertinoTextArea(super.context);

  String _val = '';
  String _placeholder = '';
  bool _disabled = false;
  bool _readOnly = false;
  int? _maxLength;
  int _rows = 2;
  bool _showCount = false;
  bool _autoSize = false;
  bool _transparent = false;

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
  bool? get disabled => _disabled;
  @override
  set disabled(value) {
    _disabled = value != 'false';
  }

  @override
  bool? get readonly => _readOnly;
  @override
  set readonly(value) {
    _readOnly = value != 'false';
  }

  @override
  int? get maxLength => _maxLength;
  @override
  set maxLength(value) {
    _maxLength = int.tryParse(value.toString());
  }

  @override
  int? get rows => _rows;
  @override
  set rows(value) {
    _rows = int.tryParse(value.toString()) ?? 2;
  }

  @override
  bool? get showCount => _showCount;
  @override
  set showCount(value) {
    _showCount = value != 'false';
  }

  @override
  bool? get autoSize => _autoSize;
  @override
  set autoSize(value) {
    _autoSize = value != 'false';
  }

  @override
  bool? get transparent => _transparent;
  @override
  set transparent(value) {
    _transparent = value != 'false';
  }

  @override
  FlutterCupertinoTextAreaState? get state => super.state as FlutterCupertinoTextAreaState?;

  @override
  void focus(List<dynamic> args) {
    state?._focusNode.requestFocus();
  }

  @override
  void blur(List<dynamic> args) {
    state?._focusNode.unfocus();
  }

  @override
  void clear(List<dynamic> args) {
    state?._controller.clear();
    state?.requestUpdateState();
  }

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
    if (widgetElement.showCount! && widgetElement.maxLength != null) {
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
    final backgroundColor = widgetElement.transparent!
        ? Colors.transparent
        : widgetElement.disabled!
        ? (isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6)
        : (isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.white);

    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;
    final placeholderColor = isDark
        ? CupertinoColors.systemGrey.darkColor
        : CupertinoColors.placeholderText;
    final countTextColor = isDark
        ? CupertinoColors.systemGrey.darkColor
        : CupertinoColors.systemGrey;

    final bottomPadding = widgetElement.showCount! ? 12 : 0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: widgetElement.autoSize! ? double.infinity : (widgetElement.rows! * 24.0 + 16 + bottomPadding),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !widgetElement.disabled!,
            readOnly: widgetElement.readonly!,
            maxLines: widgetElement.autoSize! ? null : widgetElement.rows,
            minLines: widgetElement.rows,
            maxLength: widgetElement.maxLength,
            keyboardType: widgetElement.autoSize! ? TextInputType.multiline : TextInputType.text,
            textAlign: widgetElement.renderStyle.textAlign,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              color: textColor,
              fontSize: widgetElement.renderStyle.fontSize.value,
              fontWeight: widgetElement.renderStyle.fontWeight,
              height: 1.2,
            ),
            placeholder: widgetElement.placeholder,
            placeholderStyle: TextStyle(
              color: placeholderColor,
              fontSize: widgetElement.renderStyle.fontSize.value,
              height: 1.2,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: widgetElement.transparent! ? null : BorderRadius.circular(8),
              border: widgetElement.transparent! ? null : Border.all(
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
          if (widgetElement.showCount! && widgetElement.maxLength != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.length}/${widgetElement.maxLength}',
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
