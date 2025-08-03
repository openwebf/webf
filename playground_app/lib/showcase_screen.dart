import 'package:flutter/material.dart';
import 'package:playground_app/main.dart';
import 'package:webf/webf.dart';
import 'webf_screen.dart';
import 'go_router_hybrid_history_delegate.dart';

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  // Fixed controller names for each showcase item
  static const String miraclePlusController = 'showcase_miracle_plus';
  static const String reactUseCasesController = 'showcase_react_use_cases';
  static const String vueCupertinoController = 'showcase_vue_cupertino';
  static const String viteVueController = 'showcase_vite_vue';

  // URLs for each showcase item
  static const String miraclePlusUrl = 'https://miracleplus.openwebf.com/';
  static const String reactUseCasesUrl = 'https://usecase.openwebf.com/';
  static const String vueCupertinoUrl = 'https://vue-cupertino-gallery.openwebf.com/';
  static const String viteVueUrl = 'https://vite-vue-demo-ten.vercel.app/';

  final Map<String, bool> _prerenderingStatus = {};

  @override
  void initState() {
    super.initState();
    _startPrerendering();
  }

  Future<void> _startPrerendering() async {
    // Start prerendering all showcase URLs in parallel
    final futures = <Future<void>>[
      _prerenderUrl(miraclePlusController, miraclePlusUrl),
      _prerenderUrl(reactUseCasesController, reactUseCasesUrl),
      _prerenderUrl(vueCupertinoController, vueCupertinoUrl),
      _prerenderUrl(viteVueController, viteVueUrl),
    ];

    // Wait for all prerendering to complete
    await Future.wait(futures);
  }

  Future<void> _prerenderUrl(String controllerName, String url) async {
    try {
      setState(() {
        _prerenderingStatus[controllerName] = false; // In progress
      });

      await WebFControllerManager.instance.addWithPrerendering(
        name: controllerName,
        createController: () => WebFController(
          initialRoute: '/home',
          routeObserver: routeObserver,
        ),
        bundle: WebFBundle.fromUrl(url),
        setup: (controller) {
          controller.hybridHistory.delegate = GoRouterHybridHistoryDelegate();
        },
      );

      setState(() {
        _prerenderingStatus[controllerName] = true; // Completed
      });
    } catch (e) {
      print('Prerendering failed for $controllerName: $e');
      setState(() {
        _prerenderingStatus.remove(controllerName); // Failed
      });
    }
  }

  bool _isPrerendered(String controllerName) {
    return _prerenderingStatus[controllerName] == true;
  }

  bool _isPrerendering(String controllerName) {
    return _prerenderingStatus.containsKey(controllerName) && 
           _prerenderingStatus[controllerName] == false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Showcase'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 8),
          _buildShowcaseCard(
            context,
            title: 'MiraclePlus News App',
            description: 'MiraclePlus App Built with WebF',
            url: miraclePlusUrl,
            controllerName: miraclePlusController,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'React Use Cases',
            description: 'Various React component examples and use cases',
            url: reactUseCasesUrl,
            controllerName: reactUseCasesController,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'Vue Cupertino Gallery',
            description: 'Vue.js components and Cupertino UI gallery',
            url: vueCupertinoUrl,
            controllerName: vueCupertinoController,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          _buildShowcaseCard(
            context,
            title: 'Vite Vue Project',
            description: 'Vite + Vue.js modern development stack',
            url: viteVueUrl,
            controllerName: viteVueController,
            color: const Color(0xFF4FC08D),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildShowcaseCard(
    BuildContext context, {
    required String title,
    required String description,
    required String url,
    required String controllerName,
    required Color color,
  }) {
    final isPrerendered = _isPrerendered(controllerName);
    final isPrerendering = _isPrerendering(controllerName);
    return Container(
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
          onTap: () => _openWebFPage(context, title, url, controllerName),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      title.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      if (isPrerendering) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF999999)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Prerendering...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ] else if (isPrerendered) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Ready',
                              style: TextStyle(
                                fontSize: 12,
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
                isPrerendering
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF999999)),
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_ios,
                      color: isPrerendered 
                        ? const Color(0xFF16A34A) 
                        : const Color(0xFFB0B0B0),
                      size: 16,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openWebFPage(BuildContext context, String title, String url, String controllerName) {
    final isPrerendered = _isPrerendered(controllerName);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebFViewScreen(
          controllerName: controllerName,
          url: url,
          isDirect: !isPrerendered, // Use direct mode if not prerendered
        ),
      ),
    );
  }
} 