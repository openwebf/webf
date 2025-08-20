/// WebF Deep Link module for handling URL schemes and app navigation
/// 
/// This module provides functionality to:
/// - Open deep links in external applications
/// - Register deep link handlers
/// - Handle fallback URLs
/// 
/// Example usage:
/// ```dart
/// // Register module globally (in main function)
/// WebF.defineModule((context) => DeepLinkModule(context));
/// ```
/// 
/// JavaScript usage with npm package (Recommended):
/// ```bash
/// npm install @openwebf/webf-deeplink
/// ```
/// 
/// ```javascript
/// import { WebFDeepLink, DeepLinkHelpers } from '@openwebf/webf-deeplink';
/// 
/// // Open email
/// await DeepLinkHelpers.openEmail({
///   to: 'demo@example.com',
///   subject: 'Hello from WebF'
/// });
/// 
/// // Open deep link with fallback
/// const result = await WebFDeepLink.openDeepLink({
///   url: 'whatsapp://send?text=Hello',
///   fallbackUrl: 'https://wa.me/?text=Hello'
/// });
/// ```
/// 
/// Direct module invocation (Legacy):
/// ```javascript
/// const result = await webf.invokeModuleAsync('DeepLink', 'openDeepLink', {
///   url: 'whatsapp://send?text=Hello',
///   fallbackUrl: 'https://wa.me/?text=Hello'
/// });
/// ```
library webf_deeplink;

export 'src/deeplink_module.dart';