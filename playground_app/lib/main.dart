import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';
import 'package:webf_deeplink/webf_deeplink.dart';
import 'package:webf_share/webf_share.dart';
import 'package:webf_ui_kit/webf_ui_kit.dart';
import 'router_config.dart';
import 'modules/test_array_buffer.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  installWebFCupertinoUI();
  installWebFUIKit();

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

  WebF.defineModule((context) => TestModule(context));
  WebF.defineModule((context) => ShareModule(context));
  WebF.defineModule((context) => DeepLinkModule(context));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Playground App',
      routerConfig: AppRouterConfig.router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
