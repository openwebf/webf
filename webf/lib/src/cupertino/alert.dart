import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoAlert extends WidgetElement {
  FlutterCupertinoAlert(super.context);

  String? _tempTitle;
  String? _tempMessage;

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
        print('showCupertinoDialog');
        print(alert._tempTitle);
        print(alert._tempMessage);
        showCupertinoDialog(
          context: alert.context!,
          builder: (BuildContext context) => alert.build(context, alert.childNodes),
        );
      },
    ),
    'hide': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final alert = castToType<FlutterCupertinoAlert>(element);
        alert._tempTitle = null;
        alert._tempMessage = null;
        Navigator.of(alert.context!, rootNavigator: true).pop();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    alertSyncMethods,
  ];

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
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
          onPressed: () {
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
        isDefaultAction: true,
        onPressed: () {
          dispatchEvent(CustomEvent('confirm'));
        },
        child: Text(confirmText),
      ),
    );

    return actions;
  }
}
