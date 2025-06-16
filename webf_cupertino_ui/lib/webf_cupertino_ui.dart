library webf_cupertino_ui;

export 'src/action_sheet.dart';
export 'src/alert.dart';
export 'src/button.dart';
export 'src/checkbox.dart';
export 'src/context_menu.dart';
export 'src/date_picker.dart';
export 'src/form_row.dart';
export 'src/form_section.dart';
export 'src/icon.dart';
export 'src/input.dart';
export 'src/list_section.dart';
export 'src/list_tile.dart';
export 'src/loading.dart';
export 'src/modal_popup.dart';
export 'src/picker.dart';
export 'src/radio.dart';
export 'src/search_input.dart';
export 'src/segmented_tab.dart';
export 'src/slider.dart';
export 'src/switch.dart';
export 'src/tab.dart';
export 'src/tab_bar.dart';
export 'src/textarea.dart';
export 'src/timer_picker.dart';
export 'src/toast.dart';

import 'package:webf/webf.dart';
import 'src/action_sheet.dart';
import 'src/alert.dart';
import 'src/button.dart';
import 'src/checkbox.dart';
import 'src/context_menu.dart';
import 'src/date_picker.dart';
import 'src/form_row.dart';
import 'src/form_section.dart';
import 'src/icon.dart';
import 'src/input.dart';
import 'src/list_section.dart';
import 'src/list_tile.dart';
import 'src/loading.dart';
import 'src/modal_popup.dart';
import 'src/picker.dart';
import 'src/radio.dart';
import 'src/search_input.dart';
import 'src/segmented_tab.dart';
import 'src/slider.dart';
import 'src/switch.dart';
import 'src/tab.dart';
import 'src/tab_bar.dart';
import 'src/textarea.dart';
import 'src/timer_picker.dart';
import 'src/toast.dart';

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
  WebF.defineCustomElement('flutter-cupertino-input', (context) => FlutterCupertinoInput(context));
  WebF.defineCustomElement('flutter-cupertino-tab', (context) => FlutterCupertinoTab(context));
  WebF.defineCustomElement('flutter-cupertino-tab-item', (context) => FlutterCupertinoTabItem(context));
  WebF.defineCustomElement('flutter-cupertino-segmented-tab', (context) => FlutterCupertinoSegmentedTab(context));
  WebF.defineCustomElement(
      'flutter-cupertino-segmented-tab-item', (context) => FlutterCupertinoSegmentedTabItem(context));
  WebF.defineCustomElement('flutter-cupertino-switch', (context) => FlutterCupertinoSwitch(context));
  WebF.defineCustomElement('flutter-cupertino-picker', (context) => FlutterCupertinoPicker(context));
  WebF.defineCustomElement('flutter-cupertino-date-picker', (context) => FlutterCupertinoDatePicker(context));
  WebF.defineCustomElement('flutter-cupertino-modal-popup', (context) => FlutterCupertinoModalPopup(context));
  WebF.defineCustomElement('flutter-cupertino-icon', (context) => FlutterCupertinoIcon(context));
  WebF.defineCustomElement('flutter-cupertino-search-input', (context) => FlutterCupertinoSearchInput(context));
  WebF.defineCustomElement('flutter-cupertino-alert', (context) => FlutterCupertinoAlert(context));
  WebF.defineCustomElement('flutter-cupertino-toast', (context) => FlutterCupertinoToast(context));
  WebF.defineCustomElement('flutter-cupertino-loading', (context) => FlutterCupertinoLoading(context));
  WebF.defineCustomElement('flutter-cupertino-textarea', (context) => FlutterCupertinoTextArea(context));
  WebF.defineCustomElement('flutter-cupertino-tab-bar', (context) => FlutterTabBar(context));
  WebF.defineCustomElement('flutter-cupertino-tab-bar-item', (context) => FlutterCupertinoTabBarItem(context));
  WebF.defineCustomElement('flutter-cupertino-slider', (context) => FlutterCupertinoSlider(context));
  WebF.defineCustomElement('flutter-cupertino-context-menu', (context) => FlutterCupertinoContextMenu(context));
  WebF.defineCustomElement('flutter-cupertino-checkbox', (context) => FlutterCupertinoCheckbox(context));
  WebF.defineCustomElement('flutter-cupertino-radio', (context) => FlutterCupertinoRadio(context));
  WebF.defineCustomElement('flutter-cupertino-timer-picker', (context) => FlutterCupertinoTimerPicker(context));
  WebF.defineCustomElement('flutter-cupertino-action-sheet', (context) => FlutterCupertinoActionSheet(context));
  WebF.defineCustomElement('flutter-cupertino-form-row', (context) => FlutterCupertinoFormRow(context));
  WebF.defineCustomElement('flutter-cupertino-form-section', (context) => FlutterCupertinoFormSection(context));
  WebF.defineCustomElement('flutter-cupertino-list-section', (context) => FlutterCupertinoListSection(context));
  WebF.defineCustomElement('flutter-cupertino-list-tile', (context) => FlutterCupertinoListTile(context));
}