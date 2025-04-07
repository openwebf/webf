import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'dart:convert';

class FlutterCupertinoAlert extends WidgetElement {
  FlutterCupertinoAlert(super.context);

  String? _tempTitle;
  String? _tempMessage;
  bool _isVisible = false;

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap alertSyncMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final alert = castToType<FlutterCupertinoAlert>(element);
        if (alert.context == null) return;

        if (args.isNotEmpty) {
          final Map<String, dynamic> options = args[0];
          alert._tempTitle = options['title']?.toString();
          alert._tempMessage = options['message']?.toString();
        }
        
        alert._isVisible = true;
        alert.showDialog();
      },
    ),
    'hide': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final alert = castToType<FlutterCupertinoAlert>(element);
        alert._tempTitle = null;
        alert._tempMessage = null;
        alert._isVisible = false;
        Navigator.of(alert.context!, rootNavigator: true).pop();
      },
    ),
  };

  void showDialog() {
    if (!_isVisible) return;
    
    showCupertinoDialog(
      context: context!,
      builder: (BuildContext context) => build(context, childNodes),
    ).then((_) {
      _isVisible = false;
      _tempTitle = null;
      _tempMessage = null;
    });
  }

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    alertSyncMethods,
  ];

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return CupertinoAlertDialog(
      title: Text(
        _tempTitle ?? getAttribute('title') ?? '',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        _tempMessage ?? getAttribute('message') ?? '',
        style: const TextStyle(
          fontSize: 13,
          color: CupertinoColors.black,
        ),
      ),
      actions: _buildActions(),
    );
  }

  List<Widget> _buildActions() {
    final actions = <Widget>[];

    // Cancel button, optional
    final cancelText = getAttribute('cancel-text');
    if (cancelText != null && cancelText != '') {
      actions.add(
        CupertinoDialogAction(
          isDestructiveAction: getAttribute('cancel-destructive') == 'true',
          isDefaultAction: getAttribute('cancel-default') == 'true',
          textStyle: _parseTextStyle('cancel-text-style'),
          onPressed: () {
            Navigator.of(context!, rootNavigator: true).pop();
            dispatchEvent(CustomEvent('cancel'));
          },
          child: Text(cancelText),
        ),
      );
    }

    // Confirm button
    final confirmText = getAttribute('confirm-text') ?? '确定';
    actions.add(
      CupertinoDialogAction(
        isDefaultAction: getAttribute('confirm-default') != 'false',
        isDestructiveAction: getAttribute('confirm-destructive') == 'true',
        textStyle: _parseTextStyle('confirm-text-style'),
        onPressed: () {
          Navigator.of(context!, rootNavigator: true).pop();
          dispatchEvent(CustomEvent('confirm'));
        },
        child: Text(confirmText),
      ),
    );

    return actions;
  }

  TextStyle? _parseTextStyle(String attributeName) {
    final styleStr = getAttribute(attributeName);
    if (styleStr == null) return null;

    try {
      final Map<String, dynamic> styleMap = Map<String, dynamic>.from(
        const JsonDecoder().convert(styleStr)
      );
      
      return TextStyle(
        color: styleMap['color'] != null ? parseColor(styleMap['color']) : null,
        fontSize: styleMap['fontSize']?.toDouble(),
        fontWeight: styleMap['fontWeight'] == 'bold' ? FontWeight.bold : FontWeight.normal,
      );
    } catch (e) {
      print('Error parsing text style: $e');
      return null;
    }
  }

  Color? parseColor(String? value) {
    if (value == null) return null;
    if (value.startsWith('#')) {
      final hex = value.substring(1);
      final int? color = int.tryParse(hex, radix: 16);
      if (color != null) {
        return Color(color | 0xFF000000);
      }
    }
    return null;
  }
}
