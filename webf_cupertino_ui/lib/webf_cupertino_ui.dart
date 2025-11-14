import 'package:webf/webf.dart';

export 'src/alert.dart';
export 'src/button.dart';
export 'src/icon.dart';
export 'src/tab_bar.dart';
export 'src/tab_scaffold.dart';
export 'src/tab_view.dart';
import 'src/alert.dart';
import 'src/tab_scaffold.dart';
import 'src/button.dart';
import 'src/icon.dart';
import 'src/tab_bar.dart';
import 'src/tab_scaffold.dart';
import 'src/tab_view.dart';

/// Installs all Cupertino UI custom elements for WebF.
///
/// Call this function in your main() before running your WebF application
/// to register all available Cupertino-style custom elements.
///
/// Example:
/// ```dart
/// void main() {
///   installWebFCupertinoUI();
///   runApp(MyApp());
/// }
/// ```
void installWebFCupertinoUI() {
  WebF.defineCustomElement('flutter-cupertino-button', (context) => FlutterCupertinoButton(context));
  WebF.defineCustomElement('flutter-cupertino-alert', (context) => FlutterCupertinoAlert(context));
  WebF.defineCustomElement('flutter-cupertino-tab-scaffold', (context) => FlutterCupertinoTabScaffold(context));
  WebF.defineCustomElement('flutter-cupertino-tab-scaffold-tab', (context) => FlutterCupertinoTabScaffoldTab(context));
  WebF.defineCustomElement('flutter-cupertino-tab-bar', (context) => FlutterCupertinoTabBar(context));
  WebF.defineCustomElement('flutter-cupertino-tab-bar-item', (context) => FlutterCupertinoTabBarItem(context));
  WebF.defineCustomElement('flutter-cupertino-tab-view', (context) => FlutterCupertinoTabView(context));
  WebF.defineCustomElement('flutter-cupertino-icon', (context) => FlutterCupertinoIcon(context));


  // WebF.defineCustomElement('flutter-cupertino-input', (context) => FlutterCupertinoInput(context));
  // WebF.defineCustomElement('flutter-cupertino-segmented-tab', (context) => FlutterCupertinoSegmentedTab(context));
  // WebF.defineCustomElement(
  //     'flutter-cupertino-segmented-tab-item', (context) => FlutterCupertinoSegmentedTabItem(context));
  // WebF.defineCustomElement('flutter-cupertino-switch', (context) => FlutterCupertinoSwitch(context));
  // WebF.defineCustomElement('flutter-cupertino-picker', (context) => FlutterCupertinoPicker(context));
  // WebF.defineCustomElement('flutter-cupertino-picker-item', (context) => FlutterCupertinoPickerItem(context));
  // WebF.defineCustomElement('flutter-cupertino-date-picker', (context) => FlutterCupertinoDatePicker(context));
  // WebF.defineCustomElement('flutter-cupertino-modal-popup', (context) => FlutterCupertinoModalPopup(context));
  // WebF.defineCustomElement('flutter-cupertino-search-input', (context) => FlutterCupertinoSearchInput(context));
  // WebF.defineCustomElement('flutter-cupertino-alert', (context) => FlutterCupertinoAlert(context));
  // WebF.defineCustomElement('flutter-cupertino-toast', (context) => FlutterCupertinoToast(context));
  // WebF.defineCustomElement('flutter-cupertino-loading', (context) => FlutterCupertinoLoading(context));
  // WebF.defineCustomElement('flutter-cupertino-textarea', (context) => FlutterCupertinoTextArea(context));
  // WebF.defineCustomElement('flutter-cupertino-slider', (context) => FlutterCupertinoSlider(context));
  // WebF.defineCustomElement('flutter-cupertino-context-menu', (context) => FlutterCupertinoContextMenu(context));
  // WebF.defineCustomElement('flutter-cupertino-checkbox', (context) => FlutterCupertinoCheckbox(context));
  // WebF.defineCustomElement('flutter-cupertino-radio', (context) => FlutterCupertinoRadio(context));
  // WebF.defineCustomElement('flutter-cupertino-timer-picker', (context) => FlutterCupertinoTimerPicker(context));
  // WebF.defineCustomElement('flutter-cupertino-action-sheet', (context) => FlutterCupertinoActionSheet(context));
  // WebF.defineCustomElement('flutter-cupertino-form-row', (context) => FlutterCupertinoFormRow(context));
  // WebF.defineCustomElement('flutter-cupertino-form-row-prefix', (context) => FlutterCupertinoFormRowPrefix(context));
  // WebF.defineCustomElement('flutter-cupertino-form-row-helper', (context) => FlutterCupertinoFormRowHelper(context));
  // WebF.defineCustomElement('flutter-cupertino-form-row-error', (context) => FlutterCupertinoFormRowError(context));
  // WebF.defineCustomElement('flutter-cupertino-form-section', (context) => FlutterCupertinoFormSection(context));
  // WebF.defineCustomElement('flutter-cupertino-form-section-header', (context) => FlutterCupertinoFormSectionHeader(context));
  // WebF.defineCustomElement('flutter-cupertino-form-section-footer', (context) => FlutterCupertinoFormSectionFooter(context));
  // WebF.defineCustomElement('flutter-cupertino-input-prefix', (context) => FlutterCupertinoInputPrefix(context));
  // WebF.defineCustomElement('flutter-cupertino-input-suffix', (context) => FlutterCupertinoInputSuffix(context));
  // WebF.defineCustomElement('flutter-cupertino-list-section', (context) => FlutterCupertinoListSection(context));
  // WebF.defineCustomElement('flutter-cupertino-list-section-header', (context) => FlutterCupertinoListSectionHeader(context));
  // WebF.defineCustomElement('flutter-cupertino-list-section-footer', (context) => FlutterCupertinoListSectionFooter(context));
  // WebF.defineCustomElement('flutter-cupertino-list-tile', (context) => FlutterCupertinoListTile(context));
  // WebF.defineCustomElement('flutter-cupertino-list-tile-leading', (context) => FlutterCupertinoListTileLeading(context));
  // WebF.defineCustomElement('flutter-cupertino-list-tile-subtitle', (context) => FlutterCupertinoListTileSubtitle(context));
  // WebF.defineCustomElement('flutter-cupertino-list-tile-additional-info', (context) => FlutterCupertinoListTileAdditionalInfo(context));
  // WebF.defineCustomElement('flutter-cupertino-list-tile-trailing', (context) => FlutterCupertinoListTileTrailing(context));
}
