import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/bridge.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/widget.dart';

/// A repro custom element that shows its children inside a Cupertino modal popup.
///
/// The popup content uses Align + SingleChildScrollView (loose width constraints),
/// then bridges those constraints into the WebF subtree via [WebFWidgetElementChild].
///
/// Without the core fix, auto-width WidgetElements inside the popup could incorrectly
/// resolve their used width against the original DOM containing block (e.g. 36px),
/// causing the popup viewport width to shrink to 36.
class FlutterCupertinoPortalModalPopup extends WidgetElement {
  FlutterCupertinoPortalModalPopup(super.context);

  static Map<String, StaticDefinedSyncBindingObjectMethod> syncMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(call: (element, args) {
      (element as FlutterCupertinoPortalModalPopup).show();
      return null;
    }),
    'hide': StaticDefinedSyncBindingObjectMethod(call: (element, args) {
      (element as FlutterCupertinoPortalModalPopup).hide();
      return null;
    }),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods =>
      [...super.methods, syncMethods];

  FlutterCupertinoPortalModalPopupState? get _state =>
      state as FlutterCupertinoPortalModalPopupState?;

  void show() => _state?.show();

  void hide() => _state?.hide();

  @override
  WebFWidgetElementState createState() => FlutterCupertinoPortalModalPopupState(this);
}

class FlutterCupertinoPortalModalPopupState extends WebFWidgetElementState {
  FlutterCupertinoPortalModalPopupState(super.widgetElement);

  bool _isShowing = false;

  @override
  FlutterCupertinoPortalModalPopup get widgetElement =>
      super.widgetElement as FlutterCupertinoPortalModalPopup;

  Future<void> show() async {
    if (_isShowing) return;
    if (!mounted) return;
    _isShowing = true;

    try {
      await showCupertinoModalPopup<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) => _buildPopupContent(dialogContext),
      );
    } finally {
      _isShowing = false;
    }
  }

  void hide() {
    if (!_isShowing) return;
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Widget _buildPopupContent(BuildContext dialogContext) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        child: WebFWidgetElementChild(
          child: WebFHTMLElement(
            tagName: 'DIV',
            controller: widgetElement.controller,
            parentElement: widgetElement,
            children: widgetElement.childNodes.toWidgetList(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Host element itself does not render anything; the popup is shown modally.
    return const SizedBox.shrink();
  }
}

