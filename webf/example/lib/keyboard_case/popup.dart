import 'package:flutter/material.dart';
import 'common_util.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'popup_bindings_generated.dart';

class FlutterPopup extends FlutterPopupBindings {
  FlutterPopup(super.context);

  @override
  FlutterPopupState? get state => super.state as FlutterPopupState?;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['open'] = ElementAttributeProperty(getter: () {
      return state?.isVisible.toString();
    }, setter: (value) {

    });
  }

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
  ];

  @override
  WebFWidgetElementState createState() {
    return FlutterPopupState(this);
  }

  @override
  bool get open => state?.isVisible ?? false;
  @override
  set open(value) {
    final shouldShow = value == 'true';
    if (shouldShow != state?.isVisible) {
      state?.isVisible = shouldShow;
      state?.handleVisibilityChange();
    }
  }

  bool _showClose = true;
  @override
  bool get showClose => _showClose;
  @override
  set showClose(value) {
    _showClose = value == true || value == 'true' || value == '';
  }

  String _title = '';
  @override
  String get title => _title;
  @override
  set title(value) {
    _title = value?.toString() ?? '';
  }
}

class FlutterPopupState extends WebFWidgetElementState {
  FlutterPopupState(super.widgetElement);

  NavigatorState? _navigator;
  bool isVisible = false;

  NavigatorState? get navigator => _navigator;

  /// 是否是通过属性关闭弹窗的
  bool _closeFromAttribute = false;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void handleVisibilityChange() {
    if (isVisible) {
      // show 的时候重置
      _closeFromAttribute = false;
      _showModal();
    } else {
      _closeFromAttribute = true;
      _navigator?.pop();
    }
  }

  void _showModal() {
    if (!mounted) {
      return;
    }

    bool parseBoolAttr(String name, {required bool defaultValue}) {
      final String? raw = widgetElement.getAttribute(name);
      if (raw == null) return defaultValue;
      final String v = raw.trim().toLowerCase();
      if (v.isEmpty) return true; // HTML boolean attribute
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
      return defaultValue;
    }

    final BuildContext context = this.context;
    final title = widgetElement.getAttribute('title') ?? '';
    final showClose = parseBoolAttr('show-close', defaultValue: false);
    final showBack = parseBoolAttr('show-back', defaultValue: false);
    final leftButtonText = widgetElement.getAttribute('left-button-text') ?? '';
    final rightButtonText = widgetElement.getAttribute('right-button-text') ?? '';
    final maskClosable = parseBoolAttr('mask-closable', defaultValue: true);
    final isCenterTitle = parseBoolAttr('is-center-title', defaultValue: false);
    final isVerticalButton = parseBoolAttr('is-vertical-button', defaultValue: false);

    final contents = widgetElement.childNodes.whereType<FlutterPopupItem>();
    assert(contents.isNotEmpty && contents.length == 1, 'Popup content should be a single child.');
    Widget contentWidget = WebFWidgetElementChild(child: contents.first.toWidget());

    showBottom(
      context,
      title: title,
      showClose: showClose,
      showBack: showBack,
      content: contentWidget,
      leftButtonText: leftButtonText,
      rightButtonText: rightButtonText,
      isDismissible: maskClosable,
      onLeftButtonPressed: () {
        widgetElement.dispatchEvent(Event('oncancel'));
      },
      onRightButtonPressed: () {
        widgetElement.dispatchEvent(Event('onconfirm'));
      },
      onClosePressed: () {
        widgetElement.dispatchEvent(Event('onclose'));
      },
      onDismiss: () {
        isVisible = false;
        if (!_closeFromAttribute) {
          widgetElement.dispatchEvent(Event('onmask'));
        }
      },
      popupContext: (context) {
        _navigator = Navigator.of(context);
      },
      isCenterTitle: isCenterTitle,
      isVerticalButton: isVerticalButton,
    );
  }
}

class FlutterPopupItem extends WidgetElement {
  FlutterPopupItem(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterPopupItemState(this);
  }
}

class FlutterPopupItemState extends WebFWidgetElementState {
  FlutterPopupItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
          tagName: 'DIV',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList()),
    );
  }
}
