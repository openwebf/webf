import 'package:flutter/material.dart';
import 'package:webf_example/keyboard_case/popup_view.dart';
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
    final BuildContext context = this.context;
    if (!context.mounted) {
      return;
    }

    final title = widgetElement.getAttribute('title') ?? '';
    final showClose = bool.parse(widgetElement.getAttribute('show-close') ?? '') ?? false;
    final showBack = bool.parse(widgetElement.getAttribute('show-back') ?? '') ?? false;
    final leftButtonText = widgetElement.getAttribute('left-button-text') ?? '';
    final rightButtonText = widgetElement.getAttribute('right-button-text') ?? '';
    final maskClosable = bool.parse(widgetElement.getAttribute('mask-closable') ?? '') ?? true;
    final isCenterTitle = bool.parse(widgetElement.getAttribute('is-center-title') ?? '') ?? false;
    final isVerticalButton =
        bool.parse(widgetElement.getAttribute('is-vertical-button') ?? '') ?? false;

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

  PopupDirection _getPopupDirection(String? direction) {
    return PopupDirection.bottom;
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
