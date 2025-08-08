/// WebF Share module for sharing content, text, and images
/// 
/// This module provides functionality to:
/// - Share images with text and subject
/// - Share text content and URLs
/// - Save screenshots to device storage
/// - Create preview images for display
/// 
/// Example usage:
/// ```dart
/// // Register module globally (in main function)
/// WebF.defineModule((context) => ShareModule(context));
/// ```
/// 
/// JavaScript usage with npm package (Recommended):
/// ```bash
/// npm install @openwebf/webf-share
/// ```
/// 
/// ```javascript
/// import { WebFShare, ShareHelpers } from '@openwebf/webf-share';
/// 
/// // Share text
/// await WebFShare.shareText({
///   title: 'My App',
///   text: 'Check out this amazing content!',
///   url: 'https://example.com'
/// });
/// 
/// // Share image
/// const canvas = document.querySelector('canvas');
/// const imageData = await ShareHelpers.canvasToArrayBuffer(canvas);
/// await WebFShare.shareImage({
///   imageData,
///   text: 'Check this out!',
///   subject: 'Amazing Content'
/// });
/// 
/// // Save screenshot
/// const result = await WebFShare.saveScreenshot({
///   imageData,
///   filename: 'my_screenshot'
/// });
/// ```
/// 
/// Direct module invocation (Legacy):
/// ```javascript
/// await webf.invokeModuleAsync('Share', 'share', 
///   imageBytes, 'Check this out!', 'Amazing Content'
/// );
/// ```
library webf_share;

export 'src/share_module.dart';