import 'package:flutter/material.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

class FlutterBottomSheetElement extends WidgetElement {
  FlutterBottomSheetElement(super.context);

  @override
  FlutterBottomSheetElementState? get state =>
      super.state as FlutterBottomSheetElementState?;

  static StaticDefinedAsyncBindingObjectMethodMap customAsyncMethods = {
    'open': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        return castToType<FlutterBottomSheetElement>(element)
            .state
            ?.showBottomSheet();
      },
    ),
    'close': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        return castToType<FlutterBottomSheetElement>(element)
            .state
            ?.closeBottomSheet();
      },
    ),
  };

  @override
  List<StaticDefinedAsyncBindingObjectMethodMap> get asyncMethods => [
        ...super.asyncMethods,
        FlutterBottomSheetElement.customAsyncMethods,
      ];

  @override
  WebFWidgetElementState createState() => FlutterBottomSheetElementState(this);
}

class FlutterBottomSheetElementState extends WebFWidgetElementState {
  FlutterBottomSheetElementState(super.widgetElement);

  NavigatorState? _navigator;
  bool _closeFromAttribute = false;

  @override
  FlutterBottomSheetElement get widgetElement =>
      super.widgetElement as FlutterBottomSheetElement;

  Future<void> showBottomSheet() async {
    if (!mounted) return;

    final String title = widgetElement.getAttribute('title') ?? '';
    final String primaryBtnTitle =
        widgetElement.getAttribute('primary-btn-title') ?? '';
    final bool isDismissible =
        _parseBool(widgetElement.getAttribute('is-dismissible')) ?? true;
    final bool enableDrag =
        _parseBool(widgetElement.getAttribute('enable-drag')) ?? true;

    final Iterable<FlutterPopupItemElement> contents =
        widgetElement.childNodes.whereType<FlutterPopupItemElement>();
    assert(
      contents.isNotEmpty && contents.length == 1,
      'flutter-bottom-sheet expects exactly one flutter-popup-item child.',
    );

    final Widget contentWidget =
        WebFWidgetElementChild(child: contents.first.toWidget());

    _closeFromAttribute = false;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        useSafeArea: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          minHeight: 176 + MediaQuery.of(context).padding.bottom,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext modalContext) {
          _navigator = Navigator.of(modalContext);
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.of(modalContext).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                if (title.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 26,
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else
                  const SizedBox(height: 8),
                Flexible(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: contentWidget,
                    ),
                  ),
                ),
                if (primaryBtnTitle.isNotEmpty) const SizedBox(height: 16),
                if (primaryBtnTitle.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widgetElement.dispatchEvent(Event('onconfirm'));
                      },
                      child: Text(primaryBtnTitle),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    } finally {
      _navigator = null;
    }

    if (!_closeFromAttribute) {
      widgetElement.dispatchEvent(Event('onmask'));
    }
    _closeFromAttribute = false;
  }

  void closeBottomSheet() {
    _closeFromAttribute = true;
    _navigator?.pop();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  bool? _parseBool(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value == 'true' || value == '1') return true;
    if (value == 'false' || value == '0') return false;
    return null;
  }
}

class FlutterPopupItemElement extends WidgetElement {
  FlutterPopupItemElement(super.context);

  @override
  Map<String, dynamic> get defaultStyle => const {
        'display': 'block',
      };

  @override
  WebFWidgetElementState createState() => FlutterPopupItemElementState(this);
}

class FlutterPopupItemElementState extends WebFWidgetElementState {
  FlutterPopupItemElementState(super.widgetElement);

  @override
  FlutterPopupItemElement get widgetElement =>
      super.widgetElement as FlutterPopupItemElement;

  @override
  Widget build(BuildContext context) {
    if (widgetElement.childNodes.length == 1) {
      return WebFWidgetElementChild(
        child: widgetElement.childNodes.first.toWidget(),
      );
    }

    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'DIV',
        controller: widgetElement.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}
