/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';
import 'search_input_bindings_generated.dart';

class FlutterCupertinoSearchInput extends FlutterCupertinoSearchInputBindings {
  FlutterCupertinoSearchInput(super.context);

  String _placeholder = 'Search';
  bool _disabled = false;
  String _type = 'text';
  String _prefixIcon = 'search';
  String _suffixIcon = 'xmark_circle_fill';
  String _suffixMode = 'editing';
  String _itemColor = '';
  double _itemSize = 20.0;
  bool _autofocus = false;

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
    _placeholder = value ?? 'Search';
  }

  @override
  bool? get disabled => _disabled;
  @override
  set disabled(value) {
    _disabled = value != 'false';
  }

  @override
  String? get type => _type;
  @override
  set type(value) {
    _type = value ?? 'text';
  }

  @override
  String? get prefixIcon => _prefixIcon;
  @override
  set prefixIcon(value) {
    _prefixIcon = value ?? 'search';
  }

  @override
  String? get suffixIcon => _suffixIcon;
  @override
  set suffixIcon(value) {
    _suffixIcon = value ?? 'xmark_circle_fill';
  }

  @override
  String? get suffixModel => _suffixMode;
  @override
  set suffixModel(value) {
    _suffixMode = value ?? 'editing';
  }

  @override
  String? get itemColor => _itemColor;
  @override
  set itemColor(value) {
    _itemColor = value ?? '';
  }

  @override
  double? get itemSize => _itemSize;
  @override
  set itemSize(value) {
    _itemSize = double.tryParse(value.toString()) ?? 20.0;
  }

  @override
  bool get autofocus => _autofocus;
  @override
  set autofocus(value) {
    _autofocus = value != 'false';
  }

  @override
  FlutterCupertinoSearchInputState? get state => super.state as FlutterCupertinoSearchInputState?;

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
      default:
        return TextInputType.text;
    }
  }

  OverlayVisibilityMode _getSuffixMode(String mode) {
    switch (mode) {
      case 'never':
        return OverlayVisibilityMode.never;
      case 'editing':
        return OverlayVisibilityMode.editing;
      case 'notEditing':
        return OverlayVisibilityMode.notEditing;
      case 'always':
        return OverlayVisibilityMode.always;
      default:
        return OverlayVisibilityMode.editing;
    }
  }

  IconData? _getIconData(String iconName) {
    switch (iconName) {
      case 'search':
        return CupertinoIcons.search;
      case 'xmark_circle_fill':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return null;
    }
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
  void clear(List<dynamic> args) {
    state?._controller.clear();
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSearchInputState(this);
  }
}

class FlutterCupertinoSearchInputState extends WebFWidgetElementState {
  FlutterCupertinoSearchInputState(super.widgetElement);

  @override
  FlutterCupertinoSearchInput get widgetElement => super.widgetElement as FlutterCupertinoSearchInput;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // Get renderStyle
    final renderStyle = widgetElement.renderStyle;
    final hasBorderRadius = renderStyle.borderRadius != null;
    final hasPadding = renderStyle.padding != EdgeInsets.zero;

    // Get theme colors
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get icon color
    Color iconColor = widgetElement.itemColor!.isNotEmpty
        ? Color(int.parse(widgetElement.itemColor!.replaceAll('#', '0xFF')))
        : (isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey);

    return CupertinoSearchTextField(
      controller: _controller,
      focusNode: _focusNode,
      placeholder: widgetElement.placeholder,
      enabled: !widgetElement.disabled!,
      keyboardType: widgetElement._getKeyboardType(widgetElement.type!),
      autofocus: widgetElement.autofocus!,
      onChanged: (value) {
        widgetElement.dispatchEvent(CustomEvent('input', detail: value));
      },
      onSubmitted: (value) {
        widgetElement.dispatchEvent(CustomEvent('search', detail: value));
      },
      backgroundColor: isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6.color,
      borderRadius: hasBorderRadius
          ? BorderRadius.circular(renderStyle.borderRadius!.first.x)
          : BorderRadius.circular(8),
      padding: hasPadding ? renderStyle.padding : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      style: TextStyle(
        color: isDark ? CupertinoColors.white : CupertinoColors.black,
      ),
      placeholderStyle: TextStyle(
        color: isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey,
      ),
      prefixIcon: Icon(widgetElement._getIconData(widgetElement.prefixIcon!) ?? CupertinoIcons.search),
      suffixIcon: Icon(widgetElement._getIconData(widgetElement.suffixIcon!) ?? CupertinoIcons.xmark_circle_fill),
      suffixMode: widgetElement._getSuffixMode(widgetElement.suffixModel!),
      itemColor: iconColor,
      itemSize: widgetElement.itemSize!,
      onSuffixTap: () {
        _controller.clear();
        widgetElement.dispatchEvent(CustomEvent('clear'));
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
