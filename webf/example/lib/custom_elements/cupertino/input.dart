import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';
import 'package:flutter/material.dart';

class FlutterCupertinoInput extends WidgetElement {
  FlutterCupertinoInput(super.context);

  static final Map<String, IconData> _iconMap = {
    'phone': CupertinoIcons.phone,
    'shield': CupertinoIcons.shield,
    'lock': CupertinoIcons.lock,
    'search': CupertinoIcons.search,
    // ...
  };

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

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final placeholder = getAttribute('placeholder') ?? '';
    final icon = getAttribute('icon');
    final type = getAttribute('type');
    final isPassword = type == 'password';
    final suffixText = getAttribute('suffix-text');

    final inputFormatter = _getInputFormatter(type);
    final List<TextInputFormatter> formatters = [];
    if (inputFormatter != null) {
      formatters.add(inputFormatter);
    }
    
    return CupertinoTextField(
      placeholder: placeholder,
      obscureText: isPassword,
      keyboardType: _getKeyboardType(type),
      inputFormatters: formatters.isEmpty ? null : formatters,
      onChanged: (value) {
        dispatchEvent(CustomEvent('input', detail: value));
      },
      prefix: icon != null ? Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Icon(
          _iconMap[icon] ?? CupertinoIcons.circle,
          color: CupertinoColors.systemGrey,
        ),
      ) : null,
      // TODO: support custom elements for suffix
      suffix: suffixText != null ? CupertinoButton(
        padding: const EdgeInsets.only(right: 10),
        child: Text(
          suffixText,
          style: const TextStyle(
            color: CupertinoColors.activeBlue,
          ),
        ),
        onPressed: () {
          dispatchEvent(Event('suffix-click'));
        },
      ) : null,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      // TODO: support custom padding
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);

    methods['getValue'] = BindingObjectMethodSync(call: (args) {
      return getAttribute('value') ?? '';
    });

    methods['setValue'] = BindingObjectMethodSync(call: (args) {
      if (args.isEmpty) return;
      setAttribute('value', args[0].toString());
    });
  }
}