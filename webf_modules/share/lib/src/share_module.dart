import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webf/bridge.dart';
import 'package:webf/module.dart';

/// WebF module for sharing content, text, and images
/// 
/// This module provides functionality to share images, text, save screenshots,
/// and create preview images for display.
class ShareModule extends WebFBaseModule {
  ShareModule(super.moduleManager);

  @override
  void dispose() {
    // Clean up any temporary files if needed
  }

  @override
  invoke(String method, params) async {
    switch (method) {
      case 'share':
        return await handleShare(params);
      case 'shareText':
        return await handleShareText(params);
      case 'save':
        return await handleSaveScreenshot(params);
      case 'saveForPreview':
        return await handleSaveForPreview(params);
      default:
        return {'success': false, 'error': 'Method not found: $method'};
    }
  }

  /// Share an image with optional text and subject
  /// 
  /// Parameters:
  /// - args[0]: NativeByteData - The image data to share
  /// - args[1]: String - Text to include with the share
  /// - args[2]: String - Subject line for the share
  /// 
  /// Returns true if successful, false otherwise
  Future<bool> handleShare(List<dynamic> args) async {
    try {
      final snapshot = args[0] as NativeByteData;
      String text = args[1];
      String subject = args[2];

      final downloadDir = await getTemporaryDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${downloadDir.path}/screenshot_$now.png';

      final file = File(filePath);
      await file.writeAsBytes(snapshot.bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
        subject: subject,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Handle text-only sharing
  /// 
  /// Supports two formats:
  /// 1. [title, text] - legacy format
  /// 2. [{title, text, url}] - new format with URL support
  /// 
  /// Returns true if successful, false otherwise
  Future<bool> handleShareText(List<dynamic> args) async {
    try {
      String title = '';
      String text = '';
      String? url;
      
      if (args.isNotEmpty && args[0] is Map) {
        // New format with structured data
        final params = args[0] as Map;
        title = params['title'] ?? '';
        text = params['text'] ?? '';
        url = params['url'];
        
        // Include URL in the text if provided
        if (url != null && url.isNotEmpty) {
          text = text.isEmpty ? url : '$text\n$url';
        }
      } else if (args.length >= 2) {
        // Legacy format
        title = args[0];
        text = args[1];
      }
      
      await Share.share(
        text,
        subject: title,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save screenshot to device gallery/downloads
  /// 
  /// Parameters:
  /// - args[0]: NativeByteData - The image data to save
  /// - args[1]: String (optional) - Custom filename (without extension)
  /// 
  /// Returns a Map with success status and file information
  Future<Map<String, String>> handleSaveScreenshot(List<dynamic> args) async {
    try {
      final snapshot = args[0] as NativeByteData;
      String filename = args.length > 1 ? args[1] : 'screenshot_${DateTime.now().millisecondsSinceEpoch}';
      
      // Get appropriate directory for saving
      Directory? directory;
      String platformInfo = '';
      
      if (Platform.isAndroid) {
        // On Android, try to save to Downloads or Pictures
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
          platformInfo = 'External Storage';
        } else {
          platformInfo = 'Downloads';
        }
      } else if (Platform.isIOS) {
        // On iOS, save to app documents directory (accessible via Files app)
        directory = await getApplicationDocumentsDirectory();
        platformInfo = 'App Documents (accessible via Files app)';
      } else if (Platform.isMacOS) {
        // On macOS, save to Documents directory
        directory = await getApplicationDocumentsDirectory();
        platformInfo = 'Application Documents';
      } else {
        // Fallback to documents directory
        directory = await getApplicationDocumentsDirectory();
        platformInfo = 'Documents';
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      final filePath = '${directory.path}/$filename.png';
      final file = File(filePath);
      await file.writeAsBytes(snapshot.bytes);

      
      return {
        'success': 'true',
        'filePath': filePath,
        'platformInfo': platformInfo,
        'message': 'Screenshot saved successfully to $platformInfo'
      };
    } catch (e) {
      return {
        'success': 'false',
        'error': e.toString(),
        'message': 'Failed to save screenshot: ${e.toString()}'
      };
    }
  }

  /// Save screenshot for preview display (temporary file)
  /// 
  /// Parameters:
  /// - args[0]: NativeByteData - The image data to save
  /// - args[1]: String (optional) - Custom filename for preview
  /// 
  /// Returns a Map with file path for preview display
  Future<Map<String, String>> handleSaveForPreview(List<dynamic> args) async {
    try {
      final snapshot = args[0] as NativeByteData;
      String filename = args.length > 1 ? args[1] : 'preview_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save to temporary directory for preview
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename.png';
      final file = File(filePath);
      await file.writeAsBytes(snapshot.bytes);

      
      // Return file path for display
      return {
        'success': 'true',
        'filePath': 'file://$filePath', // Use file:// protocol for local file access
        'message': 'Preview saved successfully'
      };
    } catch (e) {
      return {
        'success': 'false',
        'error': e.toString(),
        'message': 'Failed to save preview'
      };
    }
  }

  @override
  String get name => 'Share';
}