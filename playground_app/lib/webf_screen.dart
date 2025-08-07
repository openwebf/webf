import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:playground_app/main.dart';
import 'package:webf/webf.dart';
import 'go_router_hybrid_history_delegate.dart';
import 'router_config.dart';
import 'package:go_router/go_router.dart';

class WebFScreen extends StatefulWidget {
  const WebFScreen({super.key});

  @override
  State<WebFScreen> createState() => _WebFScreenState();
}

class _WebFScreenState extends State<WebFScreen> {
  static const String initialControllerName = 'miracle_plus_demo';
  static const String initialUrl = 'https://miracleplus.openwebf.com/';
  static const String showcaseControllerName = 'react_use_cases';
  static const String showcaseUrl = 'http://localhost:3000';

  final TextEditingController _urlController = TextEditingController();

  String currentControllerName = initialControllerName;
  String currentUrl = initialUrl;
  bool isLoading = false;
  bool isLoadingComplete = false;
  String? loadingError;
  double loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Preload React use cases on app startup
    _preloadShowcase();
  }

  Future<void> _preloadShowcase() async {
    try {
      // Add showcase controller with prerendering
      await WebFControllerManager.instance.addWithPreload(
        name: showcaseControllerName,
        createController: () => WebFController(
          initialRoute: '/',
          routeObserver: routeObserver,
        ),
        bundle: WebFBundle.fromUrl(showcaseUrl),
        setup: (controller) {
          controller.hybridHistory.delegate = GoRouterHybridHistoryDelegate();
        },
      );
      print('React use cases preloaded successfully');
    } catch (e) {
      print('Failed to preload React use cases: $e');
    }
  }

  Future<void> _loadUrl(String url, {bool withPrerendering = false}) async {
    // Clear any previous state
    setState(() {
      isLoading = false;
      isLoadingComplete = false;
      loadingError = null;
      loadingProgress = 0.0;
    });

    // Validate URL
    if (url.trim().isEmpty) {
      setState(() {
        loadingError = 'Please enter a URL';
      });
      return;
    }

    if (!_isValidUrl(url)) {
      setState(() {
        loadingError = 'Invalid URL format';
      });
      return;
    }

    setState(() {
      isLoading = withPrerendering;
      currentUrl = url;
    });

    if (withPrerendering) {
      // Generate a unique controller name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newControllerName = 'webf_page_$timestamp';

      try {
        // Add new controller with prerendering
        await WebFControllerManager.instance.addWithPreload(
          name: newControllerName,
          createController: () => WebFController(
            initialRoute: '/home',
            routeObserver: routeObserver,
          ),
          bundle: WebFBundle.fromUrl(url),
          setup: (controller) {
            controller.hybridHistory.delegate = GoRouterHybridHistoryDelegate();
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
          loadingProgress = 1.0;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          loadingError = e.toString();
        });
      }
    } else {
      // Direct access without prerendering
      _navigateToWebFPage(url);
    }
  }

  void _resetState() {
    setState(() {
      isLoading = false;
      isLoadingComplete = false;
      loadingError = null;
      loadingProgress = 0.0;
      currentUrl = initialUrl;
    });
  }

  Future<void> _scanQRCode() async {
    final result = await context.push<String>('/qr-scanner');

    if (result != null && result.isNotEmpty) {
      _urlController.text = result;
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

  void _navigateToWebFPage([String? url]) {
    final targetUrl = url ?? currentUrl;
    final controllerName = url != null ? 'direct_access_${DateTime.now().millisecondsSinceEpoch}' : currentControllerName;
    
    AppRouterConfig.navigateToWebFController(
      controllerName,
      url: targetUrl,
      isDirect: url != null,
    );
  }

  void _navigateToShowcase() {
    // Navigate to the preloaded React use cases
    AppRouterConfig.navigateToWebFController(
      showcaseControllerName,
      url: showcaseUrl,
      isDirect: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with logo
              Row(
                children: [
                  // WebF Logo
                  Image.network(
                    'https://openwebf.com/img/openwebf.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.web,
                          size: 20,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  // Title
                  const Text(
                    'WebF Explorer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Main Card Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // URL Input Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                            width: 1,
                          ),
                        ),
                        child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          hintText: 'Enter a URL to preview',
                          hintStyle: TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                        onSubmitted: isLoadingComplete ? null : (url) => _loadUrl(url, withPrerendering: true),
                      ),
                    ),
                    // Only show QR scanner button on mobile platforms
                    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android))
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoading ? null : _scanQRCode,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            height: 56,
                            decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Color(0xFFE5E5E5),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner_rounded,
                              color: isLoading ? const Color(0xFFCCCCCC) : const Color(0xFF666666),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),      
              // Error message inline display
              if (loadingError != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loadingError!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFDC2626),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
                      
              const SizedBox(height: 20),
                      
              // Action Buttons - Responsive Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use single row layout when width > 600
                  final bool useRowLayout = constraints.maxWidth > 600;
                  
                  final primaryButton = SizedBox(
                    width: useRowLayout ? null : double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: isLoading 
                        ? null 
                        : isLoadingComplete
                          ? _navigateToWebFPage
                          : () => _loadUrl(_urlController.text, withPrerendering: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: isLoading 
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isLoadingComplete ? 'Ready, go!' : 'Prerender',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                      ),
                    ),
                  );
                  
                  final resetButton = SizedBox(
                    width: useRowLayout ? null : double.infinity,
                    height: 40,
                    child: TextButton(
                      onPressed: _resetState,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF666666),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFFE5E5E5),
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  );
                  
                  if (useRowLayout) {
                    // Wide screen: buttons in a row
                    return Row(
                      children: [
                        Expanded(child: primaryButton),
                        const SizedBox(width: 12),
                        Expanded(child: resetButton),
                      ],
                    );
                  } else {
                    // Narrow screen: buttons in a column
                    return Column(
                      children: [
                        primaryButton,
                        const SizedBox(height: 12),
                        resetButton,
                      ],
                    );
                  }
                },
              ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // Showcase Link
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _navigateToShowcase,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE5E5E5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.apps_rounded,
                            color: Color(0xFF666666),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Showcase',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Browse User Cases',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFFCCCCCC),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24), // Add some bottom padding
            ],
          ),
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
  final bool isDirect;

  const WebFViewScreen({
    super.key,
    required this.controllerName,
    required this.url,
    this.isDirect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Uri.parse(url).host),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              if (isDirect) {
                // For direct access, just reload the current page
                AppRouterConfig.navigateToWebFController(
                  'direct_access_${DateTime.now().millisecondsSinceEpoch}',
                  url: url,
                  isDirect: true,
                );
              } else {
                final controller = await WebFControllerManager.instance.getController(controllerName);
                controller?.reload();
              }
            },
          ),
        ],
      ),
      body: isDirect
        ? WebF.fromControllerName(
            controllerName: controllerName,
            bundle: WebFBundle.fromUrl(url),
            createController: () => WebFController(
              routeObserver: routeObserver,
            ),
            setup: (controller) {
              controller.hybridHistory.delegate = GoRouterHybridHistoryDelegate();
            },
          )
        : WebF.fromControllerName(
            controllerName: controllerName,
            loadingWidget: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          ),
    );
  }
}

