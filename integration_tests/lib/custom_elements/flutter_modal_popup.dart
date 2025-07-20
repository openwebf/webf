import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';

class FlutterModalPopup extends WidgetElement {
  FlutterModalPopup(super.context);

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['open'] = ElementAttributeProperty(getter: () {
      return (_state?.isOpen ?? false).toString();
    }, setter: (value) {
      if (_state != null) {
        _state!.isOpen = value == 'true';
      }
    });
  }

  FlutterModalPopupState? get _state => state as FlutterModalPopupState?;

  static Map<String, StaticDefinedSyncBindingObjectMethod> syncMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(call: (element, args) {
      (element as FlutterModalPopup).show();
      return null;
    }),
    'hide': StaticDefinedSyncBindingObjectMethod(call: (element, args) {
      (element as FlutterModalPopup).hide();
      return null;
    }),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods =>
      [...super.methods, syncMethods];

  void show() {
    _state?.show();
  }

  void hide() {
    _state?.hide();
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterModalPopupState(this);
  }
}

class FlutterModalPopupState extends WebFWidgetElementState {
  FlutterModalPopupState(super.widgetElement);

  bool isOpen = false;

  void show() {
    if (!isOpen) {
      isOpen = true;
      _showModal();
    }
  }

  void hide() {
    if (isOpen) {
      isOpen = false;
      Navigator.of(context).pop();
    }
  }

  void _showModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: EdgeInsets.all(20),
          child: WebFWidgetElementChild(
              child: Column(
            children: widgetElement.childNodes.toWidgetList(),
          )),
        );
      },
    ).then((_) {
      isOpen = false;
    });
  }

  @override
  void dispose() {
    hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
