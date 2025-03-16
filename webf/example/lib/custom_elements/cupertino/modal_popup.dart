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
      getter: () {
        return _isVisible.toString();
      },
      setter: (value) {
        final shouldShow = value == 'true';
        if (shouldShow != _isVisible) {
          _isVisible = shouldShow;
          _handleVisibilityChange();
        }
      }
    );
  }

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
      builder: (BuildContext context) {
        _navigator = Navigator.of(context);
        return Container(
          height: double.tryParse(getAttribute('height') ?? '') ?? 300,
          padding: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
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