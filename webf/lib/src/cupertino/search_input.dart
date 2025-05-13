/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoSearchInput extends WidgetElement {
  FlutterCupertinoSearchInput(super.context);

  @override
  FlutterCupertinoSearchInputState? get state => super.state as FlutterCupertinoSearchInputState?;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    // Input value
    attributes['val'] = ElementAttributeProperty(
      getter: () => state?._controller.text,
      setter: (value) {
        if (value != state?._controller.text) {
          state?._controller.text = value;
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

    // Disabled state
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value != 'false';
      }
    );

    // Input type
    attributes['type'] = ElementAttributeProperty(
      getter: () => _type,
      setter: (value) {
        _type = value;
      }
    );

    // Prefix icon
    attributes['prefix-icon'] = ElementAttributeProperty(
      getter: () => _prefixIcon,
      setter: (value) {
        _prefixIcon = value;
      }
    );

    // Suffix icon
    attributes['suffix-icon'] = ElementAttributeProperty(
      getter: () => _suffixIcon,
      setter: (value) {
        _suffixIcon = value;
      }
    );

    // Suffix visibility mode
    attributes['suffix-mode'] = ElementAttributeProperty(
      getter: () => _suffixMode,
      setter: (value) {
        _suffixMode = value;
      }
    );

    // Item color (icon color)
    attributes['item-color'] = ElementAttributeProperty(
      getter: () => _itemColor,
      setter: (value) {
        _itemColor = value;
      }
    );

    // Item size (icon size)
    attributes['item-size'] = ElementAttributeProperty(
      getter: () => _itemSize.toString(),
      setter: (value) {
        _itemSize = double.tryParse(value) ?? 20.0;
      }
    );

    // Autofocus
    attributes['autofocus'] = ElementAttributeProperty(
      getter: () => _autofocus.toString(),
      setter: (value) {
        _autofocus = value != 'false';
      }
    );
  }

  String _placeholder = 'Search';
  bool _disabled = false;
  String _type = 'text';
  String _prefixIcon = 'search';
  String _suffixIcon = 'xmark_circle_fill';
  String _suffixMode = 'editing';
  String _itemColor = '';
  double _itemSize = 20.0;
  bool _autofocus = false;

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

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap searchInputSyncMethods = {
    'getValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        return searchInput.state?._controller.text;
      },
    ),
    'setValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        if (args.isEmpty) return;
        searchInput.state?._controller.text = args[0].toString();
      },
    ),
    'focus': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        searchInput.state?._focusNode.requestFocus();
      },
    ),
    'blur': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        searchInput.state?._focusNode.unfocus();
      },
    ),
    'clear': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        searchInput.state?._controller.clear();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    searchInputSyncMethods,
  ];

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
    Color iconColor = widgetElement._itemColor.isNotEmpty
        ? Color(int.parse(widgetElement._itemColor.replaceAll('#', '0xFF')))
        : (isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey);

    return CupertinoSearchTextField(
      controller: _controller,
      focusNode: _focusNode,
      placeholder: widgetElement._placeholder,
      enabled: !widgetElement._disabled,
      keyboardType: widgetElement._getKeyboardType(widgetElement._type),
      autofocus: widgetElement._autofocus,
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
      prefixIcon: Icon(widgetElement._getIconData(widgetElement._prefixIcon) ?? CupertinoIcons.search),
      suffixIcon: Icon(widgetElement._getIconData(widgetElement._suffixIcon) ?? CupertinoIcons.xmark_circle_fill),
      suffixMode: widgetElement._getSuffixMode(widgetElement._suffixMode),
      itemColor: iconColor,
      itemSize: widgetElement._itemSize,
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
