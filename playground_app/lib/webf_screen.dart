import 'package:flutter/material.dart';
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
    // Remove the unnecessary initial controller check
    // _checkInitialController();
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
        await WebFControllerManager.instance.addWithPrerendering(
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
    context.push('/showcase');
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
              // Minimalist Header
              const Text(
                'WebF',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter a URL to preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                  letterSpacing: 0.2,
                ),
              ),
              
              const SizedBox(height: 48),

              // URL Input Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          hintText: 'https://example.com',
                          hintStyle: TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                        onSubmitted: isLoadingComplete ? null : (url) => _loadUrl(url, withPrerendering: true),
                      ),
                    ),
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
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Column(
                children: [
                  // Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
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
                            isLoadingComplete ? 'View Page' : 'Prerender',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
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
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Status Indicators
              if (isLoading || isLoadingComplete || loadingError != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: loadingError != null 
                      ? const Color(0xFFFEF2F2)
                      : isLoadingComplete 
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: loadingError != null 
                        ? const Color(0xFFFEE2E2)
                        : isLoadingComplete 
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFE5E5E5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (isLoading) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF666666)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Prerendering...',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ] else if (loadingError != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 20,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loadingError!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFDC2626),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (isLoadingComplete) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Page ready! Click View Page to continue',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 48),
              
              // Divider
              Container(
                height: 1,
                color: const Color(0xFFE5E5E5),
              ),
              
              const SizedBox(height: 48),
              
              // Quick Links
              const Text(
                'Quick Links',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 16),
              
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
                                'Browse example applications',
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

