import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoModalPopup extends WidgetElement {
  FlutterCupertinoModalPopup(super.context);

  bool _isVisible = false;
  NavigatorState? _navigator;

  @override
  FlutterCupertinoModalPopupState? get state => super.state as FlutterCupertinoModalPopupState?;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['show'] = ElementAttributeProperty(
        getter: () => _isVisible.toString(),
        setter: (value) {
          final shouldShow = value == 'true';
          if (shouldShow != _isVisible) {
            _isVisible = shouldShow;
            _handleVisibilityChange();
          }
        });

    // 高度，默认 300
    attributes['height'] = ElementAttributeProperty();

    // 是否显示背景色，默认 true
    attributes['surfacePainted'] = ElementAttributeProperty();

    // 是否允许点击背景关闭，默认 true
    attributes['maskClosable'] = ElementAttributeProperty();

    // 背景颜色透明度，默认 0.4
    attributes['backgroundOpacity'] = ElementAttributeProperty();
  }

  static StaticDefinedSyncBindingObjectMethodMap modalPopupSyncMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final popup = castToType<FlutterCupertinoModalPopup>(element);
        popup.setAttribute('show', 'true');
      },
    ),
    'hide': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final popup = castToType<FlutterCupertinoModalPopup>(element);
        popup.setAttribute('show', 'false');
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        modalPopupSyncMethods,
      ];

  void _handleVisibilityChange() {
    if (_isVisible) {
      state?._showModal();
    } else {
      _navigator?.pop();
    }
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoModalPopupState(this);
  }
}

class FlutterCupertinoModalPopupState extends WebFWidgetElementState {
  FlutterCupertinoModalPopupState(super.widgetElement);

  @override
  FlutterCupertinoModalPopup get widgetElement => super.widgetElement as FlutterCupertinoModalPopup;

  void _showModal() {
    final BuildContext? context = this.context as BuildContext?;
    if (context == null) return;

    showCupertinoModalPopup(
      context: context,
      barrierDismissible: widgetElement.attributes['maskClosable'] != 'false',
      barrierColor: CupertinoColors.black.withOpacity(double.tryParse(widgetElement.attributes['backgroundOpacity'] ?? '0.4') ?? 0.4),
      builder: (BuildContext context) {
        widgetElement._navigator = Navigator.of(context);
        return Container(
          height: double.tryParse(widgetElement.attributes['height'] ?? '300'),
          child: CupertinoPopupSurface(
            isSurfacePainted: widgetElement.attributes['surfacePainted'] != 'false',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: widgetElement.childNodes.isEmpty
                      ? const SizedBox()
                      : widgetElement.childNodes.first.toWidget(),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        widgetElement._isVisible = false;
        widgetElement.setAttribute('show', 'false');
        widgetElement.dispatchEvent(CustomEvent('close'));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
