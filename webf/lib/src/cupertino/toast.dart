/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, MaterialType, Colors;
import 'package:webf/webf.dart';
import 'dart:async';

enum ToastType {
  normal,
  success,
  warning,
  error,
  loading,
}

class FlutterCupertinoToast extends WidgetElement {
  FlutterCupertinoToast(super.context);

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap toastSyncMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final toast = castToType<FlutterCupertinoToast>(element);
        if (args.isEmpty) return;

        final Map<String, dynamic> params = args[0] as Map<String, dynamic>;
        final String content = params['content']?.toString() ?? '';
        final String? typeStr = params['type']?.toString();
        final int? durationMs = params['duration'] as int?;

        final type = typeStr != null ? toast._parseToastType(typeStr) : ToastType.normal;
        final duration = durationMs != null ? Duration(milliseconds: durationMs) : const Duration(milliseconds: 2000);

        toast.state?._show(content, type, duration);
      },
    ),
    'close': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final toast = castToType<FlutterCupertinoToast>(element);
        toast.state?._hide();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        toastSyncMethods,
      ];

  ToastType _parseToastType(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return ToastType.success;
      case 'warning':
        return ToastType.warning;
      case 'error':
        return ToastType.error;
      case 'loading':
        return ToastType.loading;
      default:
        return ToastType.normal;
    }
  }

  @override
  FlutterCupertinoToastState? get state => super.state as FlutterCupertinoToastState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoToastState(this);
  }
}

class FlutterCupertinoToastState extends WebFWidgetElementState {
  FlutterCupertinoToastState(super.widgetElement);

  OverlayEntry? _overlayEntry;
  Timer? _timer;

  @override
  FlutterCupertinoToast get widgetElement => super.widgetElement as FlutterCupertinoToast;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  void _show(String message, ToastType type, Duration duration) {
    _hide();

    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    if (duration.inMilliseconds > 0) {
      _timer = Timer(duration, () {
        _hide();
      });
    }
  }

  void _hide() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final ToastType type;

  const _ToastWidget({
    required this.message,
    this.type = ToastType.normal,
  });

  IconData _getIcon() {
    switch (type) {
      case ToastType.success:
        return CupertinoIcons.check_mark_circled;
      case ToastType.warning:
        return CupertinoIcons.exclamationmark_triangle;
      case ToastType.error:
        return CupertinoIcons.xmark_circle;
      case ToastType.loading:
        return CupertinoIcons.refresh;
      default:
        return CupertinoIcons.info_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 270,
                    minWidth: 120,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (type != ToastType.normal) ...[
                        type == ToastType.loading
                            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                            : Icon(
                                _getIcon(),
                                color: CupertinoColors.white,
                                size: 28,
                              ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
