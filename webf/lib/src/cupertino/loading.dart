/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoLoading extends WidgetElement {
  FlutterCupertinoLoading(super.context);

  OverlayEntry? _overlayEntry;

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap loadingSyncMethods = {
    'show': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final loading = castToType<FlutterCupertinoLoading>(element);
        String? text;
        if (args.isNotEmpty) {
          final Map<String, dynamic> params = args[0] as Map<String, dynamic>;
          text = params['text']?.toString();
        }
        loading._show(text);
      },
    ),
    'hide': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final loading = castToType<FlutterCupertinoLoading>(element);
        loading._hide();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        loadingSyncMethods,
      ];

  void _show(String? text) {
    if (state == null) return;

    _hide(); // Hide existing overlay if any

    final overlay = Overlay.maybeOf(state!.context);
    if (overlay == null) return;

    final bool maskClosable = attributes['maskClosable'] != null && attributes['maskClosable'] != 'false';

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(
        text: text,
        onMaskTap: maskClosable ? _hide : null,
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hide() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        print('Error hiding loading: $e');
      }
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoLoadingState(this);
  }
}

class FlutterCupertinoLoadingState extends WebFWidgetElementState {
  FlutterCupertinoLoadingState(super.widgetElement);

  @override
  FlutterCupertinoLoading get widgetElement => super.widgetElement as FlutterCupertinoLoading;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _LoadingWidget extends StatelessWidget {
  final String? text;
  final VoidCallback? onMaskTap;

  const _LoadingWidget({
    this.text,
    this.onMaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onMaskTap,
              child: Container(
                color: CupertinoColors.black.withOpacity(0.1),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 200,
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
                  const CupertinoActivityIndicator(
                    color: CupertinoColors.white,
                    radius: 14,
                  ),
                  if (text != null) ...[
                    const SizedBox(height: 8),
                    DefaultTextStyle(
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                      child: Text(
                        text!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
