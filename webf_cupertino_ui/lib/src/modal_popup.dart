/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'modal_popup_bindings_generated.dart';

class FlutterCupertinoModalPopup extends FlutterCupertinoModalPopupBindings {
  FlutterCupertinoModalPopup(super.context);

  bool _visible = false;
  int? _height;
  bool _surfacePainted = true;
  bool _maskClosable = true;
  double _backgroundOpacity = 0.4;
  NavigatorState? _navigator;

  @override
  bool? get visible => _visible;
  @override
  set visible(value) {
    final shouldShow = value == 'true';
    if (shouldShow != _visible) {
      _visible = shouldShow;
      _handleVisibilityChange();
    }
  }

  @override
  int? get height => _height;
  @override
  set height(value) {
    _height = int.tryParse(value.toString());
  }

  @override
  bool? get surfacePainted => _surfacePainted;
  @override
  set surfacePainted(value) {
    _surfacePainted = value != 'false';
  }

  @override
  bool? get maskClosable => _maskClosable;
  @override
  set maskClosable(value) {
    _maskClosable = value != 'false';
  }

  @override
  double? get backgroundOpacity => _backgroundOpacity;
  @override
  set backgroundOpacity(value) {
    _backgroundOpacity = double.tryParse(value.toString()) ?? 0.4;
  }

  @override
  FlutterCupertinoModalPopupState? get state => super.state as FlutterCupertinoModalPopupState?;

  void _handleVisibilityChange() {
    if (_visible) {
      state?._showModal();
    } else {
      _navigator?.pop();
    }
  }

  @override
  void show(List<dynamic> args) {
    visible = 'true';
  }

  @override
  void hide(List<dynamic> args) {
    visible = 'false';
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
      barrierDismissible: widgetElement.maskClosable!,
      barrierColor: CupertinoColors.black.withOpacity(widgetElement.backgroundOpacity!),
      builder: (BuildContext context) {
        widgetElement._navigator = Navigator.of(context);
        return Container(
          height: widgetElement.height?.toDouble() ?? 300,
          child: CupertinoPopupSurface(
            isSurfacePainted: widgetElement.surfacePainted!,
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
        widgetElement._visible = false;
        widgetElement.visible = 'false';
        widgetElement.dispatchEvent(CustomEvent('close'));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
