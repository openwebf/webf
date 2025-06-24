
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webf/bridge.dart';
import 'package:webf/module.dart';

class ShareModule extends WebFBaseModule {
  ShareModule(super.moduleManager);

  @override
  void dispose() {
  }

  @override
  invoke(String method, params) async {
    if (method == 'share') {
      return await handleShare(params);
    } else if (method == 'shareText') {
      return await handleShareText(params);
    } else if (method == 'save') {
      return await handleSaveScreenshot(params);
    } else if (method == 'saveForPreview') {
      return await handleSaveForPreview(params);
    }
    return 'method not found';
  }


  Future<bool> handleShare(List<dynamic> args) async {
    try {
      final snapshot = args[0] as NativeByteData;
      String text = args[1];
      String subject = args[2];

      print('snapshot length: ${snapshot.length}');
      final downloadDir = await getTemporaryDirectory();
      final now = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${downloadDir.path}/screenshot_$now.png';

      Uint8List bytes = snapshot.bytes;

      final file = File(filePath);
      await file.writeAsBytes(snapshot.bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text,
        subject: subject,
      );

      return true;
    } catch (e, stackTrace) {
      print('Share failed: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Handle text-only sharing
  Future<bool> handleShareText(List<dynamic> args) async {
    try {
      // Support both formats: 
      // 1. [title, text] - old format
      // 2. [{title, text, url}] - new format from DeepLinkPage
      String title = '';
      String text = '';
      String? url;
      
      if (args.isNotEmpty && args[0] is Map) {
        // New format from DeepLinkPage
        final params = args[0] as Map;
        title = params['title'] ?? '';
        text = params['text'] ?? '';
        url = params['url'];
        
        // Include URL in the text if provided
        if (url != null && url.isNotEmpty) {
          text = text.isEmpty ? url : '$text\n$url';
        }
      } else if (args.length >= 2) {
        // Old format
        title = args[0];
        text = args[1];
      }

      print('Sharing text: $text');
      
      await Share.share(
        text,
        subject: title,
      );

      return true;
    } catch (e, stackTrace) {
      print('Text share failed: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Save screenshot to device gallery/downloads
  Future<Map<String, String>> handleSaveScreenshot(List<dynamic> args) async {
    try {
      final snapshot = args[0] as NativeByteData;
      String filename = args.length > 1 ? args[1] : 'screenshot_${DateTime.now().millisecondsSinceEpoch}';

      print('Saving screenshot, length: ${snapshot.length}');
      
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

      print('Screenshot saved to: $filePath');
      
      return {
        'success': 'true',
        'filePath': filePath,
        'platformInfo': platformInfo,
        'message': 'Screenshot saved successfully to $platformInfo'
      };
    } catch (e, stackTrace) {
      print('Save screenshot failed: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': 'false',
        'error': e.toString(),
        'message': 'Failed to save screenshot: ${e.toString()}'
      };
    }
  }

  /// Save screenshot for preview display (temporary file)
  Future<Map<String, String>> handleSaveForPreview(List<dynamic> args) async {
    try {
      final snapshot = args[0] as NativeByteData;
      String filename = args.length > 1 ? args[1] : 'preview_${DateTime.now().millisecondsSinceEpoch}';

      print('Saving preview image, length: ${snapshot.length}');
      
      // Save to temporary directory for preview
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename.png';
      final file = File(filePath);
      await file.writeAsBytes(snapshot.bytes);

      print('Preview saved to: $filePath');
      
      // Return file path for display
      return {
        'success': 'true',
        'filePath': 'file://$filePath', // Use file:// protocol for local file access
        'message': 'Preview saved successfully'
      };
    } catch (e, stackTrace) {
      print('Save preview failed: $e');
      print('Stack trace: $stackTrace');
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
