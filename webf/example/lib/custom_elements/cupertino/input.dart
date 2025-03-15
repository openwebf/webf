import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';
import 'package:collection/collection.dart';
import 'package:webf/dom.dart' as dom;

class FlutterCupertinoInput extends WidgetElement {
  FlutterCupertinoInput(super.context);

  final TextEditingController _controller = TextEditingController();

  static final Map<String, IconData> _iconMap = {
    'phone': CupertinoIcons.phone,
    'shield': CupertinoIcons.shield,
    'lock': CupertinoIcons.lock,
    'search': CupertinoIcons.search,
    // ...
  };

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    
    attributes['val'] = ElementAttributeProperty(
      getter: () => _controller.text,
      setter: (val) {
        if (val != _controller.text) {
          _controller.text = val;
          setState(() {});
        }
      }
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextInputFormatter? _getInputFormatter(String? type) {
    switch (type) {
      case 'number':
      case 'tel':
        return FilteringTextInputFormatter.digitsOnly;
      default:
        return null;
    }
  }

  TextInputType _getKeyboardType(String? type) {
    switch (type) {
      case 'number':
        return TextInputType.number;
      case 'tel':
        return TextInputType.phone;
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
    final placeholder = getAttribute('placeholder') ?? '';
    final type = getAttribute('type');
    final isPassword = type == 'password';
    final height = renderStyle.height.value ?? 44.0;

    final inputFormatter = _getInputFormatter(type);
    final List<TextInputFormatter> formatters = [];
    if (inputFormatter != null) {
      formatters.add(inputFormatter);
    }
    
    // Get prefix and suffix from slots
    final prefixWidget = _buildSlotWidget('prefix');
    final suffixWidget = _buildSlotWidget('suffix');
    
    return SizedBox(
      height: height,
      child: CupertinoTextField(
        controller: _controller,
        placeholder: placeholder,
        obscureText: isPassword,
        keyboardType: _getKeyboardType(type),
        inputFormatters: formatters.isEmpty ? null : formatters,
        onChanged: (value) {
          dispatchEvent(CustomEvent('input', detail: value));
        },
        prefix: prefixWidget,
        suffix: suffixWidget,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        style: TextStyle(height: 1),  
      ),
    );
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);

    methods['getValue'] = BindingObjectMethodSync(call: (args) {
      return _controller.text;
    });
  }
}