import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:webf/webf.dart';
import 'dart:convert';

mixin FlutterCupertinoAlertMixin on WidgetElement {
  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap alertSyncMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final alert = castToType<FlutterCupertinoAlert>(element);
        if (alert.state == null) return;

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

        if (alert.state == null) return;

        Navigator.of(alert.state!.context, rootNavigator: true).pop();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    alertSyncMethods,
  ];
}

class FlutterCupertinoAlert extends WidgetElement {
  FlutterCupertinoAlert(super.context);

  String? _tempTitle;
  String? _tempMessage;
  bool _isVisible = false;


  void showDialog() {
    if (!_isVisible) return;

    if (state == null) return;

    showCupertinoDialog(
      context: state!.context,
      builder: (BuildContext context) => FlutterCupertinoDialog(this),
    ).then((_) {
      _isVisible = false;
      _tempTitle = null;
      _tempMessage = null;
    });
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoAlertState(this);
  }
}

class FlutterCupertinoDialog extends StatelessWidget {
  final FlutterCupertinoAlert widgetElement;

  FlutterCupertinoDialog(this.widgetElement);

  TextStyle? _parseTextStyle(String attributeName) {
    final styleStr = widgetElement.getAttribute(attributeName);
    if (styleStr == null) return null;

    try {
      final Map<String, dynamic> styleMap = Map<String, dynamic>.from(const JsonDecoder().convert(styleStr));

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

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    // Cancel button, optional
    final cancelText = widgetElement.getAttribute('cancel-text');
    if (cancelText != null && cancelText != '') {
      actions.add(
        CupertinoDialogAction(
          isDestructiveAction: widgetElement.getAttribute('cancel-destructive') == 'true',
          isDefaultAction: widgetElement.getAttribute('cancel-default') == 'true',
          textStyle: _parseTextStyle('cancel-text-style'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            widgetElement.dispatchEvent(CustomEvent('cancel'));
          },
          child: Text(cancelText),
        ),
      );
    }

    // Confirm button
    final confirmText = widgetElement.getAttribute('confirm-text') ?? '确定';
    actions.add(
      CupertinoDialogAction(
        isDefaultAction: widgetElement.getAttribute('confirm-default') != 'false',
        isDestructiveAction: widgetElement.getAttribute('confirm-destructive') == 'true',
        textStyle: _parseTextStyle('confirm-text-style'),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          widgetElement.dispatchEvent(CustomEvent('confirm'));
        },
        child: Text(confirmText),
      ),
    );

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    if (!widgetElement._isVisible) {
      return const SizedBox.shrink();
    }

    return CupertinoAlertDialog(
      title: Text(
        widgetElement._tempTitle ?? widgetElement.getAttribute('title') ?? '',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        widgetElement._tempMessage ?? widgetElement.getAttribute('message') ?? '',
        style: const TextStyle(
          fontSize: 13,
          color: CupertinoColors.black,
        ),
      ),
      actions: _buildActions(context),
    );
  }
}

class FlutterCupertinoAlertState extends WebFWidgetElementState {
  FlutterCupertinoAlertState(super.widgetElement);

  @override
  FlutterCupertinoAlert get widgetElement => super.widgetElement as FlutterCupertinoAlert;

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
