/*
 * Copyright (C) 2024 The OpenWebF(Cayman) Company . All rights reserved.
 */

import 'package:webf/webf.dart';
import 'alert.dart';
import 'button.dart';
import 'context_menu.dart';
import 'date_picker.dart';
import 'icon.dart';
import 'input.dart';
import 'loading.dart';
import 'modal_popup.dart';
import 'picker.dart';
import 'search_input.dart';
import 'segmented_tab.dart';
import 'switch.dart';
import 'tab.dart';
import 'tab_bar.dart';
import 'textarea.dart';
import 'toast.dart';
import 'slider.dart';

void installWebFCupertino() {
  WebF.defineCustomElement('flutter-cupertino-button', (context) => FlutterCupertinoButton(context));
  WebF.defineCustomElement('flutter-cupertino-input', (context) => FlutterCupertinoInput(context));
  WebF.defineCustomElement('flutter-cupertino-tab', (context) => FlutterCupertinoTab(context));
  WebF.defineCustomElement('flutter-cupertino-tab-item', (context) => FlutterCupertinoTabItem(context));
  WebF.defineCustomElement('flutter-cupertino-segmented-tab', (context) => FlutterCupertinoSegmentedTab(context));
  WebF.defineCustomElement(
      'flutter-cupertino-segmented-tab-item', (context) => FlutterCupertinoSegmentedTabItem(context));
  WebF.defineCustomElement('flutter-cupertino-switch', (context) => FlutterCupertinoSwitch(context));
  WebF.defineCustomElement('flutter-cupertino-picker', (context) => FlutterCupertinoPicker(context));
  WebF.defineCustomElement('flutter-cupertino-picker-item', (context) => FlutterCupertinoPickerItem(context));
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
}
