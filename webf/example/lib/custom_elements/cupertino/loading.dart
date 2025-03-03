import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoLoading extends WidgetElement {
  FlutterCupertinoLoading(super.context);

  OverlayEntry? _overlayEntry;
  BuildContext? _savedContext;

  @override
  void mount() {
    super.mount();
    // Save context when component is mounted
    _savedContext = context;
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);

    // Show loading method
    methods['show'] = BindingObjectMethodSync(call: (args) {
      String? text;
      if (args.isNotEmpty) {
        final Map<String, dynamic> params = args[0] as Map<String, dynamic>;
        text = params['text']?.toString();
      }
      _show(text);
    });

    // Hide loading method
    methods['hide'] = BindingObjectMethodSync(call: (args) {
      _hide();
    });
  }

  void _show(String? text) {
    _hide(); // Hide existing overlay if any

    if (_savedContext == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(text: text),
    );

    final overlay = Overlay.of(_savedContext!);
    overlay.insert(_overlayEntry!);
  }

  void _hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    return const SizedBox.shrink();
  }
}

class _LoadingWidget extends StatelessWidget {
  final String? text;

  const _LoadingWidget({this.text});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
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