import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:playground_app/main.dart';
import 'package:webf/webf.dart';
import 'qr_scanner_screen.dart';
import 'showcase_screen.dart';

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
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

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
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebFViewScreen(
          controllerName: controllerName,
          url: targetUrl,
          isDirect: url != null,
        ),
      ),
    );
  }

  void _navigateToShowcase() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShowcaseScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'WebF Explorer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              // URL Input Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card URL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _urlController,
                              decoration: const InputDecoration(
                                hintText: 'Enter Card URL',
                                hintStyle: TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              onSubmitted: (url) => _loadUrl(url),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: isLoading ? null : _scanQRCode,
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: Color(0xFF666666),
                                size: 20,
                              ),
                              tooltip: 'Scan QR Code',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Two action buttons - vertical layout
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (isLoading || isLoadingComplete)
                                ? null 
                                : () => _loadUrl(_urlController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Go',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (isLoading || isLoadingComplete)
                                ? null 
                                : () => _loadUrl(_urlController.text, withPrerendering: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4444),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading 
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Prerender',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Helper text when buttons are disabled
                      if (isLoadingComplete) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Page is ready! Use "View Page" below or "Reset" to try another URL.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Prerendering Status Card - only show when there's actual loading/result
              if (isLoading || isLoadingComplete || loadingError != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        if (isLoading) ...[
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF4444),
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Prerendering... ${(loadingProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentUrl,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else if (loadingError != null) ...[
                          const Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Color(0xFFFF4444),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Loading Failed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loadingError!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _resetState,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4444),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ] else if (isLoadingComplete) ...[
                          const Icon(
                            Icons.check_circle,
                            size: 32,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Page Ready!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The page has been prerendered successfully',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: _navigateToWebFPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'View Page',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: _resetState,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF8F8F8),
                                    foregroundColor: const Color(0xFF666666),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

              if (isLoading || isLoadingComplete || loadingError != null)
                const SizedBox(height: 24),

              // Showcase Option
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToShowcase,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Showcase',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFFB0B0B0),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40), // Add some bottom padding
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebFViewScreen(
                      controllerName: 'direct_access_${DateTime.now().millisecondsSinceEpoch}',
                      url: url,
                      isDirect: true,
                    ),
                  ),
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

