/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:playground_app/webf_screen.dart';
import 'package:playground_app/qr_scanner_screen.dart';
import 'package:webf/webf.dart';

class AppRouterConfig {
  // Cache for WebF route widgets to prevent rebuilds
  static final Map<String, Widget> _webfRouteCache = {};
  
  // Track the currently active WebF controller for routing
  static String? _activeWebFController;
  
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      // Home route - shows the main WebFScreen
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const WebFScreen(),
      ),
      
      // QR Scanner route
      GoRoute(
        path: '/qr-scanner',
        name: 'qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      
      // WebF view route for specific controllers
      GoRoute(
        path: '/webf/:controllerName',
        name: 'webf-view',
        builder: (context, state) {
          final controllerName = state.pathParameters['controllerName']!;
          final url = state.uri.queryParameters['url'];
          final isDirect = state.uri.queryParameters['direct'] == 'true';
          
          return WebFViewScreen(
            controllerName: controllerName,
            url: url ?? 'https://example.com',
            isDirect: isDirect,
          );
        },
      ),
      
      
      // Universal WebF route handler - catches ALL WebF paths
      GoRoute(
        path: '/:webfPath(.*)',
        name: 'webf-route',
        pageBuilder: (context, state) {
          final capturedPath = state.pathParameters['webfPath']!;
          final path = capturedPath.startsWith('/') ? capturedPath : '/$capturedPath';
          
          return NoTransitionPage(
            key: ValueKey('webf-page-$path'),
            child: _getCachedWebFRouteView(path, state.extra),
          );
        },
      ),
    ],
    
    // Error handling - improved for go_router 16.0.0
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Route Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Route not found: ${state.uri.path}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${state.error.toString()}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    
    // Enhanced debugging for go_router 16.0.0
    debugLogDiagnostics: true,
  );

  static GoRouter get router => _router;
  
  /// Get cached WebF route view to prevent rebuilds
  static Widget _getCachedWebFRouteView(String path, Object? extra) {
    final cacheKey = path;
    
    // Check if we already have this route cached
    if (_webfRouteCache.containsKey(cacheKey)) {
      return _webfRouteCache[cacheKey]!;
    }
    
    // Create new widget and cache it
    final widget = _WebFRouteWrapper(
      key: ValueKey('webf-route-$path'),
      path: path,
      extra: extra,
    );
    
    _webfRouteCache[cacheKey] = widget;
    return widget;
  }
  
  /// Clear cache when needed (e.g., when disposing)
  static void clearWebFRouteCache() {
    _webfRouteCache.clear();
  }



  /// Navigate to a WebF route using go_router 16.0.0 best practices
  static void navigateToWebFRoute(String path, {Object? arguments}) {
    // For WebF routes, we'll use the path directly since our catch-all handles it
    final routePath = path.startsWith('/') ? path : '/$path';
    
    if (arguments != null) {
      _router.push(routePath, extra: arguments);
    } else {
      _router.push(routePath);
    }
  }
  
  /// Navigate to a specific WebF controller view with improved URL building
  static void navigateToWebFController(String controllerName, {String? url, bool isDirect = false}) {
    // Set the active controller when navigating to it
    _activeWebFController = controllerName;
    
    final queryParams = <String, String>{};
    if (url != null) queryParams['url'] = url;
    if (isDirect) queryParams['direct'] = 'true';
    
    final uri = Uri(
      path: '/webf/$controllerName', 
      queryParameters: queryParams.isNotEmpty ? queryParams : null
    );
    
    _router.push(uri.toString());
  }
  
  /// Get the currently active WebF controller
  static String? getActiveWebFController() {
    return _activeWebFController;
  }
  
  /// Get current route location - useful for debugging
  static String getCurrentLocation() {
    return _router.routeInformationProvider.value.uri.toString();
  }
  
  /// Check if router can pop - useful for back button handling
  static bool canPop() {
    return _router.canPop();
  }
}

/// Wrapper widget that maintains state for WebF routes to prevent rebuilds
class _WebFRouteWrapper extends StatefulWidget {
  final String path;
  final Object? extra;
  
  const _WebFRouteWrapper({
    super.key,
    required this.path,
    required this.extra,
  });
  
  @override
  State<_WebFRouteWrapper> createState() => _WebFRouteWrapperState();
}

class _WebFRouteWrapperState extends State<_WebFRouteWrapper> 
    with AutomaticKeepAliveClientMixin {
  Widget? _cachedChild;
  
  @override
  bool get wantKeepAlive => true; // Keep this widget alive
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // Only build once and cache the result
    _cachedChild ??= _buildWebFRouteView(widget.path, widget.extra);
    
    return _cachedChild!;
  }
  
  Widget _buildWebFRouteView(String path, Object? extra) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Get available WebF controllers
    final controllerNames = WebFControllerManager.instance.controllerNames;
    
    if (controllerNames.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Route: $path'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.web, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('No active WebF controllers found'),
              SizedBox(height: 16),
              Text('Please load a WebF application first'),
            ],
          ),
        ),
      );
    }
    
    // Smart controller selection using active controller tracking
    String controllerName;
    
    final activeController = AppRouterConfig.getActiveWebFController();
    
    if (activeController != null && controllerNames.contains(activeController)) {
      // Use the tracked active controller if it still exists
      controllerName = activeController;
    } else {
      // Fallback to most recent controller
      controllerName = controllerNames.last;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(path),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/');
            }
          },
        ),
      ),
      body: WebFRouterView.fromControllerName(
        controllerName: controllerName,
        path: path,
        builder: (context, controller) {
          print('[_WebFRouteWrapper] [$timestamp] WebFRouterView builder called for path: $path');
          return WebFRouterView(
            controller: controller,
            path: path,
          );
        },
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading WebF route...'),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}