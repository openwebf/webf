import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';
import 'custom_elements/bottom_sheet.dart';
import 'custom_elements/custom_listview_cupertino.dart';
import 'custom_elements/custom_listview_material.dart';
import 'custom_elements/form.dart';
import 'custom_elements/show_case_view.dart';
import 'custom_elements/slider.dart';
import 'custom_elements/svg_img.dart';
import 'custom_elements/switch.dart';
import 'modules/deeplink.dart';
import 'modules/share.dart';
import 'modules/test_array_buffer.dart';
import 'webf_screen.dart';
import 'custom_elements/button.dart';
import 'custom_elements/icon.dart';
import 'custom_elements/search.dart';
import 'custom_elements/select.dart';
import 'custom_elements/tab.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  installWebFCupertinoUI();

  // Initialize the WebF controller manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
    maxAliveInstances: 4,
    maxAttachedInstances: 2,
    onControllerDisposed: (String name, WebFController controller) {
      print('controller disposed: $name');
    },
    onControllerDetached: (String name, WebFController controller) {
      print('controller detached: $name');
    },
  ));

  WebF.defineCustomElement('flutter-tab', (context) => FlutterTab(context));
  WebF.defineCustomElement('flutter-tab-item', (context) => FlutterTabItem(context));
  WebF.defineCustomElement('flutter-icon', (context) => FlutterIcon(context));
  WebF.defineCustomElement('flutter-search', (context) => FlutterSearch(context));
  WebF.defineCustomElement('flutter-select', (context) => FlutterSelect(context));
  WebF.defineCustomElement('flutter-button', (context) => FlutterButton(context));
  WebF.defineCustomElement('flutter-bottom-sheet', (context) => FlutterBottomSheet(context));
  WebF.defineCustomElement('flutter-slider', (context) => SliderElement(context));
  WebF.defineCustomElement('flutter-switch', (context) => FlutterSwitch(context));
  WebF.defineCustomElement('flutter-svg-img', (context) => FlutterSVGImg(context));
  WebF.defineCustomElement('flutter-showcase-view', (context) => FlutterShowCaseView(context));
  WebF.defineCustomElement('flutter-showcase-item', (context) => FlutterShowCaseItem(context));
  WebF.defineCustomElement('flutter-showcase-description', (context) => FlutterShowCaseDescription(context));
  WebF.defineCustomElement('webf-listview-cupertino', (context) => CustomWebFListViewWithCupertinoRefreshIndicator(context));
  WebF.defineCustomElement('webf-listview-material', (context) => CustomWebFListViewWithMeterialRefreshIndicator(context));
  WebF.defineCustomElement('flutter-webf-form', (context) => FlutterWebFForm(context));
  WebF.defineCustomElement('flutter-webf-form-field', (context) => FlutterWebFFormField(context));

  WebF.defineModule((context) => TestModule(context));
  WebF.defineModule((context) => ShareModule(context));
  WebF.defineModule((context) => DeepLinkModule(context));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Playground App',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WebFScreen(),
    );
  }
}
