import 'package:webf/webf.dart';

import 'flutter_form.dart';

export 'flutter_form.dart';

/// Register WebF custom elements provided by this package.
///
/// Call this once during app startup (before creating any WebF instances).
void installWebFForm() {
  WebF.defineCustomElement('flutter-form', (context) => FlutterForm(context));
  WebF.defineCustomElement(
      'flutter-form-field', (context) => FlutterFormField(context));
}
