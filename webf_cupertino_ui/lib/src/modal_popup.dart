/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'modal_popup_bindings_generated.dart';
import 'logger.dart';

/// WebF custom element that wraps Flutter's [showCupertinoModalPopup].
///
/// Exposed as `<flutter-cupertino-modal-popup>` in the DOM.
/// The element's children are rendered as the popup content.
class FlutterCupertinoModalPopup extends FlutterCupertinoModalPopupBindings {
  FlutterCupertinoModalPopup(super.context);

  bool _visible = false;
  double? _height;
  bool _surfacePainted = true;
  bool _maskClosable = true;
  double _backgroundOpacity = 0.4;

  @override
  bool get visible => _visible;

  @override
  set visible(value) {
    final bool next = value == true;
    if (next == _visible) {
      return;
    }
    _visible = next;
    if (state == null) {
      return;
    }
    if (next) {
      state!.showPopup();
    } else {
      state!.hidePopup();
      // When JS explicitly hides the popup, fire close immediately.
      dispatchEvent(CustomEvent('close'));
    }
  }

  void _onPopupClosedFromFlutter() {
    if (!_visible) {
      return;
    }
    _visible = false;
    dispatchEvent(CustomEvent('close'));
  }

  @override
  double? get height => _height;

  @override
  set height(value) {
    if (value == null) {
      _height = null;
    } else if (value is num) {
      _height = value.toDouble();
    } else {
      _height = double.tryParse(value.toString());
    }
  }

  @override
  bool get surfacePainted => _surfacePainted;

  @override
  set surfacePainted(value) {
    _surfacePainted = value == true;
  }

  @override
  bool get maskClosable => _maskClosable;

  @override
  set maskClosable(value) {
    _maskClosable = value == true;
  }

  @override
  double? get backgroundOpacity => _backgroundOpacity;

  @override
  set backgroundOpacity(value) {
    if (value == null) {
      _backgroundOpacity = 0.4;
    } else if (value is num) {
      _backgroundOpacity = value.toDouble().clamp(0.0, 1.0);
    } else {
      final double? parsed = double.tryParse(value.toString());
      _backgroundOpacity = (parsed ?? 0.4).clamp(0.0, 1.0);
    }
  }

  /// Imperative show() entry point from JavaScript.
  void _showSync(List<dynamic> args) {
    visible = true;
  }

  /// Imperative hide() entry point from JavaScript.
  void _hideSync(List<dynamic> args) {
    visible = false;
  }

  static StaticDefinedSyncBindingObjectMethodMap modalPopupMethods =
      <String, StaticDefinedSyncBindingObjectMethod>{
    'show': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final popup = castToType<FlutterCupertinoModalPopup>(element);
        popup._showSync(args);
        return null;
      },
    ),
    'hide': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final popup = castToType<FlutterCupertinoModalPopup>(element);
        popup._hideSync(args);
        return null;
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => <StaticDefinedSyncBindingObjectMethodMap>[
        ...super.methods,
        modalPopupMethods,
      ];

  @override
  FlutterCupertinoModalPopupState? get state =>
      super.state as FlutterCupertinoModalPopupState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoModalPopupState(this);
  }
}

class FlutterCupertinoModalPopupState extends WebFWidgetElementState {
  FlutterCupertinoModalPopupState(super.widgetElement);

  @override
  FlutterCupertinoModalPopup get widgetElement =>
      super.widgetElement as FlutterCupertinoModalPopup;

  bool _isShowing = false;

  Future<void> showPopup() async {
    if (_isShowing) {
      return;
    }

    final BuildContext? buildContext = context;
    if (buildContext == null || !buildContext.mounted) {
      logger.e('Element BuildContext is null or unmounted. Cannot show modal popup');
      return;
    }

    _isShowing = true;

    final bool maskClosable = widgetElement.maskClosable;
    final double backgroundOpacity = widgetElement.backgroundOpacity ?? 0.4;

    try {
      await showCupertinoModalPopup<void>(
        context: buildContext,
        useRootNavigator: true,
        barrierDismissible: maskClosable,
        barrierColor: CupertinoColors.black.withOpacity(
          backgroundOpacity.clamp(0.0, 1.0),
        ),
        builder: (BuildContext dialogContext) {
          return _buildPopupContent(dialogContext);
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Error showing CupertinoModalPopup',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isShowing = false;
      widgetElement._onPopupClosedFromFlutter();
    }
  }

  void hidePopup() {
    if (!_isShowing) {
      return;
    }
    final BuildContext? buildContext = context;
    if (buildContext == null) {
      return;
    }
    Navigator.of(buildContext, rootNavigator: true).pop();
  }

  Widget _buildPopupContent(BuildContext dialogContext) {
    Widget child;
    var node = widgetElement.childNodes.first;
    if (widgetElement.childNodes.isEmpty) {
      child = const SizedBox.shrink();
    } else {
      child = WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'BUG',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      );
    }

    final double? fixedHeight = widgetElement.height;
    Widget content = child;

    if (fixedHeight != null && fixedHeight > 0) {
      content = SizedBox(
        height: fixedHeight,
        width: double.infinity,
        child: child,
      );
    }

    if (widgetElement.surfacePainted) {
      content = CupertinoPopupSurface(
        isSurfacePainted: true,
        child: content,
      );
    }

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Host element itself does not render anything; the popup is shown modally.
    return const SizedBox.shrink();
  }
}
