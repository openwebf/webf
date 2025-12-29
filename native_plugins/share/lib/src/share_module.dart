import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webf/bridge.dart';
import 'package:webf/module.dart';
import 'share_module_bindings_generated.dart';

/// WebF module for sharing content, text, and images
///
/// This module provides functionality to share images, text, save screenshots,
/// and create preview images for display.
class ShareModule extends ShareModuleBindings {
  ShareModule(super.moduleManager);

  @override
  void dispose() {
    // Clean up any temporary files if needed
  }

  @override
  Future<bool> share(NativeByteData imageData, dynamic text, dynamic subject) {
    final textStr = (text ?? '').toString();
    final subjectStr = (subject ?? '').toString();
    return handleShare(imageData, textStr, subjectStr);
  }

  @override
  Future<bool> shareText(ShareTextOptions? options) {
    final title = options?.title ?? '';
    var text = options?.text ?? '';
    final url = options?.url;
    return handleShareText(title, text, url: url);
  }

  @override
  Future<ShareSaveResult> save(NativeByteData imageData, dynamic filename) async {
    final effectiveFilename = filename?.toString();
    return handleSaveScreenshot(
      imageData,
      effectiveFilename,
    );
  }

  @override
  Future<ShareSaveResult> saveForPreview(NativeByteData imageData, dynamic filename) async {
    final effectiveFilename = filename?.toString();
    return handleSaveForPreview(
      imageData,
      effectiveFilename,
    );
  }

  /// Share an image with optional text and subject.
  Future<bool> handleShare(
    NativeByteData snapshot,
    String text,
    String subject,
  ) async {
    try {
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
  Future<bool> handleShareText(
    String title,
    String text, {
    String? url,
  }) async {
    try {
      // Include URL in the text if provided
      if (url != null && url.isNotEmpty) {
        text = text.isEmpty ? url : '$text\n$url';
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
  /// Returns a typed ShareSaveResult with success status and file information.
  Future<ShareSaveResult> handleSaveScreenshot(
    NativeByteData snapshot, [
    String? filename,
  ]) async {
    try {
      filename ??= 'screenshot_${DateTime.now().millisecondsSinceEpoch}';

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

      return ShareSaveResult(
        success: 'true',
        filePath: filePath,
        platformInfo: platformInfo,
        message: 'Screenshot saved successfully to $platformInfo',
      );
    } catch (e) {
      return ShareSaveResult(
        success: 'false',
        message: 'Failed to save screenshot: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  /// Save screenshot for preview display (temporary file)
  ///
  /// Parameters:
  /// - args[0]: NativeByteData - The image data to save
  /// - args[1]: String (optional) - Custom filename for preview
  ///
  /// Returns a typed ShareSaveResult with file path for preview display.
  Future<ShareSaveResult> handleSaveForPreview(
    NativeByteData snapshot, [
    String? filename,
  ]) async {
    try {
      filename ??= 'preview_${DateTime.now().millisecondsSinceEpoch}';

      // Save to temporary directory for preview
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename.png';
      final file = File(filePath);
      await file.writeAsBytes(snapshot.bytes);

      // Return file path for display
      return ShareSaveResult(
        success: 'true',
        filePath: 'file://$filePath', // Use file:// protocol for local file access
        message: 'Preview saved successfully',
      );
    } catch (e) {
      return ShareSaveResult(
        success: 'false',
        message: 'Failed to save preview',
        error: e.toString(),
      );
    }
  }

}
