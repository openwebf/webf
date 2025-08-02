/// WebF UI Kit - A collection of Flutter UI components for WebF applications
/// 
/// This package provides a comprehensive set of UI components that can be used
/// as custom HTML elements in WebF applications.
/// 
/// Example usage:
/// ```dart
/// import 'package:webf_ui_kit/webf_ui_kit.dart';
/// 
/// void main() {
///   // Register all UI components
///   installWebFUIKit();
///   
///   runApp(MyApp());
/// }
/// ```
library webf_ui_kit;

import 'package:webf/webf.dart';

// Export all components
export 'src/button.dart';
export 'src/icon.dart';
export 'src/search.dart';
export 'src/select.dart';
export 'src/tab.dart';
export 'src/bottom_sheet.dart';
export 'src/slider.dart';
export 'src/switch.dart';
export 'src/svg_img.dart';
export 'src/showcase_view.dart';
export 'src/listview_cupertino.dart';
export 'src/listview_material.dart';

// Import components for registration
import 'src/button.dart';
import 'src/icon.dart';
import 'src/search.dart';
import 'src/select.dart';
import 'src/tab.dart';
import 'src/bottom_sheet.dart';
import 'src/slider.dart';
import 'src/switch.dart';
import 'src/svg_img.dart';
import 'src/showcase_view.dart';
import 'src/listview_cupertino.dart';
import 'src/listview_material.dart';

/// Installs all WebF UI Kit components.
/// 
/// This function registers all UI components as custom HTML elements
/// that can be used in WebF applications.
/// 
/// Call this function once during app initialization:
/// ```dart
/// void main() {
///   installWebFUIKit();
///   runApp(MyApp());
/// }
/// ```
void installWebFUIKit() {
  // Register button components
  WebF.defineCustomElement('flutter-button', (context) => FlutterButton(context));
  
  // Register icon component
  WebF.defineCustomElement('flutter-icon', (context) => FlutterIcon(context));
  
  // Register input components
  WebF.defineCustomElement('flutter-search', (context) => FlutterSearch(context));
  WebF.defineCustomElement('flutter-select', (context) => FlutterSelect(context));
  
  // Register navigation components
  WebF.defineCustomElement('flutter-tab', (context) => FlutterTab(context));
  WebF.defineCustomElement('flutter-tab-item', (context) => FlutterTabItem(context));
  WebF.defineCustomElement('flutter-bottom-sheet', (context) => FlutterBottomSheet(context));
  
  // Register control components
  WebF.defineCustomElement('flutter-slider', (context) => SliderElement(context));
  WebF.defineCustomElement('flutter-switch', (context) => FlutterSwitch(context));
  
  // Register media components
  WebF.defineCustomElement('flutter-svg-img', (context) => FlutterSVGImg(context));
  
  // Register showcase components
  WebF.defineCustomElement('flutter-showcase-view', (context) => FlutterShowCaseView(context));
  WebF.defineCustomElement('flutter-showcase-item', (context) => FlutterShowCaseItem(context));
  WebF.defineCustomElement('flutter-showcase-description', (context) => FlutterShowCaseDescription(context));
  
  // Register list view components
  WebF.defineCustomElement('webf-listview-cupertino', (context) => CustomWebFListViewWithCupertinoRefreshIndicator(context));
  WebF.defineCustomElement('webf-listview-material', (context) => CustomWebFListViewWithMeterialRefreshIndicator(context));
  
  print('WebF UI Kit components installed successfully');
}