import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoAlert extends WidgetElement {
  FlutterCupertinoAlert(super.context);

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return CupertinoAlertDialog(
      title: Text(
        getAttribute('title') ?? '',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        getAttribute('message') ?? '',
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

    // 取消按钮（可选）
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

    // 确认按钮
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
      showCupertinoDialog(
        context: context!,
        builder: (BuildContext context) => build(context, childNodes),
      );
    });

    methods['hide'] = BindingObjectMethodSync(call: (args) {
      Navigator.of(context!).pop();
    });
  }
}
