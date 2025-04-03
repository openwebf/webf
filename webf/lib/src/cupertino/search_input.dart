import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoSearchInput extends WidgetElement {
  FlutterCupertinoSearchInput(super.context);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    // Input value
    attributes['val'] = ElementAttributeProperty(
      getter: () => _controller.text,
      setter: (value) {
        if (value != _controller.text) {
          _controller.text = value;
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

    // Disabled state
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (value) {
        _disabled = value != 'false';
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

    // Prefix icon
    attributes['prefix-icon'] = ElementAttributeProperty(
      getter: () => _prefixIcon,
      setter: (value) {
        _prefixIcon = value;
        setState(() {});
      }
    );

    // Suffix icon
    attributes['suffix-icon'] = ElementAttributeProperty(
      getter: () => _suffixIcon,
      setter: (value) {
        _suffixIcon = value;
        setState(() {});
      }
    );

    // Suffix visibility mode
    attributes['suffix-mode'] = ElementAttributeProperty(
      getter: () => _suffixMode,
      setter: (value) {
        _suffixMode = value;
        setState(() {});
      }
    );

    // Item color (icon color)
    attributes['item-color'] = ElementAttributeProperty(
      getter: () => _itemColor,
      setter: (value) {
        _itemColor = value;
        setState(() {});
      }
    );

    // Item size (icon size)
    attributes['item-size'] = ElementAttributeProperty(
      getter: () => _itemSize.toString(),
      setter: (value) {
        _itemSize = double.tryParse(value) ?? 20.0;
        setState(() {});
      }
    );

    // Autofocus
    attributes['autofocus'] = ElementAttributeProperty(
      getter: () => _autofocus.toString(),
      setter: (value) {
        _autofocus = value != 'false';
        setState(() {});
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

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    // Get renderStyle
    final style = renderStyle;
    final hasBorderRadius = style?.borderRadius != null;
    final hasPadding = style?.padding != null && style!.padding != EdgeInsets.zero;
    
    // Get theme colors
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get icon color
    Color iconColor = _itemColor.isNotEmpty 
      ? Color(int.parse(_itemColor.replaceAll('#', '0xFF')))
      : (isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey);
    
    return CupertinoSearchTextField(
      controller: _controller,
      focusNode: _focusNode,
      placeholder: _placeholder,
      enabled: !_disabled,
      keyboardType: _getKeyboardType(_type),
      autofocus: _autofocus,
      onChanged: (value) {
        dispatchEvent(CustomEvent('input', detail: value));
      },
      onSubmitted: (value) {
        dispatchEvent(CustomEvent('search', detail: value));
      },
      backgroundColor: isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6.color,
      borderRadius: hasBorderRadius 
        ? BorderRadius.circular(style!.borderRadius!.first.x)
        : BorderRadius.circular(8),
      padding: hasPadding ? style!.padding! : const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      style: TextStyle(
        color: isDark ? CupertinoColors.white : CupertinoColors.black,
      ),
      placeholderStyle: TextStyle(
        color: isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey,
      ),
      prefixIcon: Icon(_getIconData(_prefixIcon) ?? CupertinoIcons.search),
      suffixIcon: Icon(_getIconData(_suffixIcon) ?? CupertinoIcons.xmark_circle_fill),
      suffixMode: _getSuffixMode(_suffixMode),
      itemColor: iconColor,
      itemSize: _itemSize,
      onSuffixTap: () {
        _controller.clear();
        dispatchEvent(CustomEvent('clear'));
      },
    );
  }

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap searchInputSyncMethods = {
    'getValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        return searchInput._controller.text;
      },
    ),
    'setValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        if (args.isEmpty) return;
        searchInput._controller.text = args[0].toString();
      },
    ),
    'focus': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        searchInput._focusNode.requestFocus();
      },
    ),
    'blur': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        searchInput._focusNode.unfocus();
      },
    ),
    'clear': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final searchInput = castToType<FlutterCupertinoSearchInput>(element);
        searchInput._controller.clear();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    searchInputSyncMethods,
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}