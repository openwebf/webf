import 'package:webf/webf.dart';

export 'src/icon.dart';

import 'src/icon.dart';

/// Installs all Lucide Icons custom elements for WebF.
///
/// Call this function in your main() before running your WebF application
/// to register the Lucide icon custom element.
///
/// Example:
/// ```dart
/// void main() {
///   installWebFLucideIcons();
///   runApp(MyApp());
/// }
/// ```
void installWebFLucideIcons() {
  WebF.defineCustomElement('flutter-lucide-icon', (context) => FlutterLucideIcon(context));
}
