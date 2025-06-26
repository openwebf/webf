import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:playground_app/main.dart';
import 'package:webf/webf.dart';
import 'qr_scanner_screen.dart';

class WebFScreen extends StatefulWidget {
  const WebFScreen({super.key});

  @override
  State<WebFScreen> createState() => _WebFScreenState();
}

class _WebFScreenState extends State<WebFScreen> {
  static const String initialControllerName = 'miracle_plus_demo';
  static const String initialUrl = 'https://miracleplus.openwebf.com/';

  final TextEditingController _urlController = TextEditingController(text: initialUrl);

  String currentControllerName = initialControllerName;
  String currentUrl = initialUrl;
  bool isLoading = false;
  bool isLoadingComplete = false;
  String? loadingError;
  double loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkInitialController();
  }

  Future<void> _checkInitialController() async {
    setState(() {
      isLoading = true;
    });

    try {
      final controller = await WebFControllerManager.instance.getController(initialControllerName);
      if (controller != null) {
        setState(() {
          isLoading = false;
          isLoadingComplete = true;
          loadingProgress = 1.0;
        });
      } else {
        setState(() {
          isLoading = false;
          loadingError = 'Initial controller not found';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingError = e.toString();
      });
    }
  }

  Future<void> _loadUrl(String url) async {
    // Validate URL
    if (!_isValidUrl(url)) {
      setState(() {
        loadingError = 'Invalid URL format';
      });
      return;
    }

    setState(() {
      isLoading = true;
      isLoadingComplete = false;
      loadingError = null;
      loadingProgress = 0.0;
      currentUrl = url;
    });

    // Generate a unique controller name
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newControllerName = 'webf_page_$timestamp';

    try {
      // Add new controller with prerendering
      await WebFControllerManager.instance.addWithPrerendering(
        name: newControllerName,
        createController: () => WebFController(
          initialRoute: '/home',
          routeObserver: routeObserver,
        ),
        bundle: WebFBundle.fromUrl(url),
        setup: (controller) {
          // controller.onLoadError = (FlutterError error, stack) {
          //   if (mounted) {
          //     setState(() {
          //       isLoading = false;
          //       loadingError = error.message;
          //     });
          //   }
          // };
        },
      );

      // The Future completes when prerendering is done
      setState(() {
        isLoading = false;
        isLoadingComplete = true;
        currentControllerName = newControllerName;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingError = e.toString();
      });
    }
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && result.isNotEmpty) {
      _urlController.text = result;
      await _loadUrl(result);
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  void _navigateToWebFPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebFViewScreen(
          controllerName: currentControllerName,
          url: currentUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebF Browser'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // URL Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter URL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              hintText: 'https://example.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            keyboardType: TextInputType.url,
                            onSubmitted: isLoading ? null : _loadUrl,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: isLoading ? null : _scanQRCode,
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: 'Scan QR Code',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading
                          ? null
                          : () => _loadUrl(_urlController.text),
                        icon: const Icon(Icons.download),
                        label: const Text('Load with Prerendering'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Status Section
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.language,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current URL',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUrl,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    if (isLoading) ...[
                      Column(
                        children: [
                          const CupertinoActivityIndicator(radius: 16),
                          const SizedBox(height: 16),
                          Text(
                            'Prerendering... ${(loadingProgress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: loadingProgress,
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ] else if (loadingError != null) ...[
                      Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading failed',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loadingError!,
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ] else if (isLoadingComplete) ...[
                      Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 48,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Page ready!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The page has been prerendered',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _navigateToWebFPage,
                            icon: const Icon(Icons.launch),
                            label: const Text('View Page'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}

class WebFViewScreen extends StatelessWidget {
  final String controllerName;
  final String url;

  const WebFViewScreen({
    super.key,
    required this.controllerName,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Uri.parse(url).host),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final controller = await WebFControllerManager.instance.getController(controllerName);
              controller?.reload();
            },
          ),
        ],
      ),
      body: WebF.fromControllerName(
        controllerName: controllerName,
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoActivityIndicator(radius: 16),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }
}
