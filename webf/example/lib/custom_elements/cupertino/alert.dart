import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoAlert extends WidgetElement {
  FlutterCupertinoAlert(super.context);

  String? _tempTitle;
  String? _tempMessage;

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

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);

    methods['show'] = BindingObjectMethodSync(call: (args) {
      if (args.isNotEmpty) {
        final Map<String, dynamic> options = args[0];
        _tempTitle = options['title']?.toString();
        _tempMessage = options['message']?.toString();
      }
      print('showCupertinoDialog');
      print(_tempTitle);
      print(_tempMessage);
      showCupertinoDialog(
        context: context!,
        builder: (BuildContext context) => build(context, childNodes),
      );
    });

    methods['hide'] = BindingObjectMethodSync(call: (args) {
      _tempTitle = null;
      _tempMessage = null;
      Navigator.of(context!).pop();
    });
  }
}
