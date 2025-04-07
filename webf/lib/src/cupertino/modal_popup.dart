import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoModalPopup extends WidgetElement {
  FlutterCupertinoModalPopup(super.context);
  
  bool _isVisible = false;
  NavigatorState? _navigator;

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
      }
    );

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
      _showModal();
    } else {
      _navigator?.pop();
    }
  }

  void _showModal() {
    final BuildContext? context = this.context as BuildContext?;
    if (context == null) return;
    
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: attributes['maskClosable'] != 'false',
      barrierColor: CupertinoColors.black.withOpacity(
        double.tryParse(attributes['backgroundOpacity'] ?? '0.4') ?? 0.4
      ),
      builder: (BuildContext context) {
        _navigator = Navigator.of(context);
        return Container(
          height: double.tryParse(attributes['height'] ?? '300'),
          child: CupertinoPopupSurface(
            isSurfacePainted: attributes['surfacePainted'] != 'false',
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
                  child: childNodes.isEmpty 
                      ? const SizedBox() 
                      : childNodes.first.toWidget(key: ObjectKey(childNodes.first)),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isVisible = false;
        setAttribute('show', 'false');
        dispatchEvent(CustomEvent('close'));
      });
    });
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return const SizedBox();
  }
}