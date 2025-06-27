import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:webf/module.dart';

class DeepLinkModule extends WebFBaseModule {
  DeepLinkModule(super.moduleManager);
  
  // Store registered deep link handlers
  static final Map<String, Function> _deepLinkHandlers = {};
  
  // Global navigation callback
  static Function(String, Map<String, String>)? _navigationCallback;

  @override
  void dispose() {
    _deepLinkHandlers.clear();
  }

  @override
  invoke(String method, params) async {
    switch (method) {
      case 'openDeepLink':
        return await handleOpenDeepLink(params);
      case 'registerDeepLinkHandler':
        return await handleRegisterDeepLinkHandler(params);
      case 'handleIncomingDeepLink':
        return await handleIncomingDeepLink(params);
      default:
        return {'success': false, 'error': 'Method not found: $method'};
    }
  }
  
  /// Set global navigation callback
  static void setNavigationCallback(Function(String, Map<String, String>) callback) {
    _navigationCallback = callback;
  }
  
  /// Handle incoming deep link (from app launch or while running)
  static Future<Map<String, dynamic>> processDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Check if it's our custom scheme
      if (uri.scheme == 'webfdemo') {
        return await _handleWebFDemoDeepLink(uri);
      }
      
      return {
        'success': false,
        'error': 'Unsupported URL scheme: ${uri.scheme}'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to process deep link: $e'
      };
    }
  }
  
  /// Handle webfdemo:// deep links
  static Future<Map<String, dynamic>> _handleWebFDemoDeepLink(Uri uri) async {
    try {
      // Parse the URL: webfdemo://app/react_use_cases?page=deeplink
      final path = uri.path;
      final queryParams = uri.queryParameters;
      
      print('Processing webfdemo deep link: $uri');
      print('Path: $path');
      print('Query params: $queryParams');
      
      // Handle different path patterns
      if (path.startsWith('/react_use_cases')) {
        // Direct navigation to react use cases
        if (_navigationCallback != null) {
          _navigationCallback!('react_use_cases', queryParams);
          return {
            'success': true,
            'action': 'navigate',
            'target': 'react_use_cases',
            'params': queryParams
          };
        } else {
          return {
            'success': false,
            'error': 'Navigation callback not set'
          };
        }
      } else if (path == '/app' || path == '/') {
        // General app deep link with query params
        final target = queryParams['target'] ?? 'home';
        final page = queryParams['page'];
        
        if (target == 'react_use_cases' && _navigationCallback != null) {
          _navigationCallback!('react_use_cases', queryParams);
          return {
            'success': true,
            'action': 'navigate',
            'target': 'react_use_cases',
            'params': queryParams
          };
        } else {
          return {
            'success': true,
            'action': 'open_app',
            'params': queryParams
          };
        }
      }
      
      return {
        'success': false,
        'error': 'Unrecognized deep link path: $path'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to handle webfdemo deep link: $e'
      };
    }
  }

  /// Open a deep link URL
  Future<Map<String, dynamic>> handleOpenDeepLink(params) async {
    try {
      // Handle both List<dynamic> and direct Map parameters
      Map paramMap;
      if (params is List && params.isNotEmpty) {
        paramMap = params[0] as Map;
      } else {
        paramMap = params as Map;
      }
      
      final url = paramMap['url'] as String?;
      final fallbackUrl = paramMap['fallbackUrl'] as String?;
      
      if (url == null || url.isEmpty) {
        return {
          'success': false,
          'error': 'URL is required'
        };
      }

      print('Opening deep link: $url');
      
      final uri = Uri.parse(url);
      
      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external app
        );
        
        if (launched) {
          return {
            'success': true,
            'url': url,
            'message': 'Deep link opened successfully'
          };
        } else {
          // Try fallback URL if main URL failed
          if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
            final fallbackUri = Uri.parse(fallbackUrl);
            if (await canLaunchUrl(fallbackUri)) {
              await launchUrl(fallbackUri);
              return {
                'success': true,
                'url': fallbackUrl,
                'message': 'Opened fallback URL',
                'fallback': true
              };
            }
          }
          
          return {
            'success': false,
            'error': 'Failed to open URL',
            'url': url
          };
        }
      } else {
        // URL scheme not supported
        print('URL scheme not supported: ${uri.scheme}');
        
        // Special handling for certain schemes on different platforms
        if (Platform.isIOS || Platform.isMacOS) {
          // iOS/macOS specific handling
          if (uri.scheme == 'tel' || uri.scheme == 'sms') {
            return {
              'success': false,
              'error': 'Scheme "${uri.scheme}" not supported on this platform',
              'platform': Platform.operatingSystem
            };
          }
        }
        
        // Try fallback URL
        if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
          final fallbackUri = Uri.parse(fallbackUrl);
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri);
            return {
              'success': true,
              'url': fallbackUrl,
              'message': 'Opened fallback URL',
              'fallback': true
            };
          }
        }
        
        return {
          'success': false,
          'error': 'URL scheme not supported: ${uri.scheme}',
          'url': url,
          'platform': Platform.operatingSystem
        };
      }
    } catch (e, stackTrace) {
      print('Open deep link failed: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to open deep link'
      };
    }
  }

  /// Register a deep link handler for custom URL schemes
  Future<Map<String, dynamic>> handleRegisterDeepLinkHandler(params) async {
    try {
      // Handle both List<dynamic> and direct Map parameters
      Map paramMap;
      if (params is List && params.isNotEmpty) {
        paramMap = params[0] as Map;
      } else {
        paramMap = params as Map;
      }
      
      final scheme = paramMap['scheme'] as String?;
      final host = paramMap['host'] as String?;
      
      if (scheme == null || scheme.isEmpty) {
        return {
          'success': false,
          'error': 'URL scheme is required'
        };
      }

      print('Registering deep link handler for scheme: $scheme');
      
      // Store the handler configuration
      final handlerKey = '$scheme://${host ?? ''}';
      _deepLinkHandlers[handlerKey] = (Uri uri) {
        // This would be called when the app receives a deep link
        // In a real implementation, this would integrate with platform-specific
        // deep link handling (iOS Universal Links, Android App Links)
        print('Deep link received: $uri');
      };
      
      // Note: Actual deep link registration requires platform-specific setup:
      // - iOS: Info.plist configuration for URL schemes
      // - Android: AndroidManifest.xml intent filters
      // - This is just storing the configuration for reference
      
      return {
        'success': true,
        'scheme': scheme,
        'host': host,
        'message': 'Deep link handler registered (requires platform configuration)',
        'platform': Platform.operatingSystem,
        'note': _getPlatformSpecificNote()
      };
    } catch (e, stackTrace) {
      print('Register deep link handler failed: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to register deep link handler'
      };
    }
  }

  String _getPlatformSpecificNote() {
    if (Platform.isIOS) {
      return 'iOS: Add URL scheme to Info.plist under CFBundleURLTypes';
    } else if (Platform.isAndroid) {
      return 'Android: Add intent-filter to AndroidManifest.xml';
    } else if (Platform.isMacOS) {
      return 'macOS: Add URL scheme to Info.plist similar to iOS';
    } else {
      return 'Platform-specific configuration required';
    }
  }

  /// Handle incoming deep link from WebF
  Future<Map<String, dynamic>> handleIncomingDeepLink(params) async {
    try {
      // Handle both List<dynamic> and direct Map parameters
      Map paramMap;
      if (params is List && params.isNotEmpty) {
        paramMap = params[0] as Map;
      } else {
        paramMap = params as Map;
      }
      
      final url = paramMap['url'] as String?;
      
      if (url == null || url.isEmpty) {
        return {
          'success': false,
          'error': 'URL is required'
        };
      }
      
      return await processDeepLink(url);
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to handle incoming deep link: $e'
      };
    }
  }

  @override
  String get name => 'DeepLink';
}