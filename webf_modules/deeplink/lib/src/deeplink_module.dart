import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:webf/module.dart';
import 'deep_link_module_bindings_generated.dart';

/// WebF module for handling deep links and URL scheme navigation
///
/// This module provides functionality to open deep links in external applications
/// and register handlers for custom URL schemes.
class DeepLinkModule extends DeepLinkModuleBindings {
  DeepLinkModule(super.moduleManager);

  // Store registered deep link handlers
  static final Map<String, Function> _deepLinkHandlers = {};

  @override
  void dispose() {
    _deepLinkHandlers.clear();
  }

  /// Open a deep link URL with optional fallback using typed options.
  @override
  Future<OpenDeepLinkResult> openDeepLink(OpenDeepLinkOptions? options) async {
    try {
      final url = options?.url;
      final fallbackUrl = options?.fallbackUrl;

      if (url == null || url.isEmpty) {
        return OpenDeepLinkResult(
          success: false,
          error: 'URL is required',
          message: 'URL is required',
        );
      }

      final uri = Uri.parse(url);

      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external app
        );

        if (launched) {
          return OpenDeepLinkResult(
            success: true,
            url: url,
            message: 'Deep link opened successfully',
          );
        } else {
          // Try fallback URL if main URL failed
          if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
            final fallbackUri = Uri.parse(fallbackUrl);
            if (await canLaunchUrl(fallbackUri)) {
              await launchUrl(fallbackUri);
              return OpenDeepLinkResult(
                success: true,
                url: fallbackUrl,
                message: 'Opened fallback URL',
                fallback: true,
              );
            }
          }

          return OpenDeepLinkResult(
            success: false,
            url: url,
            error: 'Failed to open URL',
            message: 'Failed to open URL',
          );
        }
      } else {
        // URL scheme not supported
        print('URL scheme not supported: ${uri.scheme}');

        // Special handling for certain schemes on different platforms
        if (Platform.isIOS || Platform.isMacOS) {
          // iOS/macOS specific handling
          if (uri.scheme == 'tel' || uri.scheme == 'sms') {
            return OpenDeepLinkResult(
              success: false,
              error: 'Scheme "${uri.scheme}" not supported on this platform',
              message: 'Scheme "${uri.scheme}" not supported on this platform',
              platform: Platform.operatingSystem,
            );
          }
        }

        // Try fallback URL
        if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
          final fallbackUri = Uri.parse(fallbackUrl);
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri);
            return OpenDeepLinkResult(
              success: true,
              url: fallbackUrl,
              message: 'Opened fallback URL',
              fallback: true,
            );
          }
        }

        return OpenDeepLinkResult(
          success: false,
          url: url,
          error: 'URL scheme not supported: ${uri.scheme}',
          message: 'URL scheme not supported: ${uri.scheme}',
          platform: Platform.operatingSystem,
        );
      }
    } catch (e, stackTrace) {
      print('Stack trace: $stackTrace');
      return OpenDeepLinkResult(
        success: false,
        error: e.toString(),
        message: 'Failed to open deep link',
      );
    }
  }

  /// Register a deep link handler for custom URL schemes
  ///
  /// Parameters:
  /// - scheme: The URL scheme to register (e.g., 'myapp')
  /// - host: Optional host part of the URL
  ///
  /// Note: This only registers the handler configuration. Actual deep link
  /// registration requires platform-specific setup in Info.plist (iOS/macOS)
  /// or AndroidManifest.xml (Android).
  @override
  Future<RegisterDeepLinkHandlerResult> registerDeepLinkHandler(
    RegisterDeepLinkHandlerOptions? options,
  ) async {
    try {
      final scheme = options?.scheme;
      final host = options?.host;

      if (scheme == null || scheme.isEmpty) {
        return RegisterDeepLinkHandlerResult(
          success: false,
          scheme: '',
          host: host,
          message: 'URL scheme is required',
          error: 'URL scheme is required',
          platform: Platform.operatingSystem,
          note: _getPlatformSpecificNote(),
        );
      }

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

      return RegisterDeepLinkHandlerResult(
        success: true,
        scheme: scheme,
        host: host,
        message: 'Deep link handler registered (requires platform configuration)',
        platform: Platform.operatingSystem,
        note: _getPlatformSpecificNote(),
      );
    } catch (e, stackTrace) {
      print('Register deep link handler failed: $e');
      print('Stack trace: $stackTrace');
      return RegisterDeepLinkHandlerResult(
        success: false,
        scheme: '',
        host: null,
        message: 'Failed to register deep link handler',
        error: e.toString(),
        platform: Platform.operatingSystem,
        note: _getPlatformSpecificNote(),
      );
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
}
