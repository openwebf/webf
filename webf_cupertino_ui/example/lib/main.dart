import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  // Initialize WebF Controller Manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
    maxAliveInstances: 2,
    maxAttachedInstances: 1,
  ));

  // Install all Cupertino UI components
  installWebFCupertinoUI();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? handleOnGenerateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      // Main page uses WebF widget
      return CupertinoPageRoute(
        settings: settings,
        builder: (context) => CupertinoGalleryPage(),
      );
    } else {
      // Sub-pages use WebFRouterView
      return CupertinoPageRoute(
        settings: settings,
        builder: (context) {
          return WebFRouterView.fromControllerName(
              controllerName: 'cupertino-gallery',
              path: settings.name!,
              builder: (context, controller) {
                return CupertinoGallerySubView(controller: controller, path: settings.name!);
              },
              loadingWidget: buildSplashScreen());
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebF Cupertino UI Gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      navigatorObservers: [routeObserver],
      onGenerateRoute: handleOnGenerateRoute,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }

  static Widget buildSplashScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.systemBackground,
            CupertinoColors.systemGrey6,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cupertino icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.cube_box_fill,
                size: 60,
                color: CupertinoColors.activeBlue,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'WebF Cupertino UI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Gallery',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            SizedBox(height: 40),
            CupertinoActivityIndicator(
              radius: 16,
            ),
            SizedBox(height: 16),
            Text(
              'Loading components...',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.tertiaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CupertinoGalleryPage extends StatefulWidget {
  const CupertinoGalleryPage({super.key});

  @override
  CupertinoGalleryPageState createState() => CupertinoGalleryPageState();
}

class CupertinoGalleryPageState extends State<CupertinoGalleryPage> {
  // Vue Cupertino Gallery hosted on Vercel
  static const String vercelUrl = 'https://vue-cupertino-gallery.openwebf.com/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cupertino Gallery (Vue.js)'),
      ),
      body: WebF.fromControllerName(
        controllerName: 'cupertino-gallery',
        bundle: WebFBundle.fromUrl(vercelUrl),
        loadingWidget: MyApp.buildSplashScreen(),
        createController: () => WebFController(
          routeObserver: routeObserver,
        ),
      ),
    );
  }
}

class CupertinoGallerySubView extends StatefulWidget {
  const CupertinoGallerySubView({super.key, required this.path, required this.controller});

  final WebFController controller;
  final String path;

  @override
  State<StatefulWidget> createState() {
    return CupertinoGallerySubViewState();
  }
}

class CupertinoGallerySubViewState extends State<CupertinoGallerySubView> {
  @override
  Widget build(BuildContext context) {
    WebFController controller = widget.controller;
    RouterLinkElement? routerLinkElement = controller.view.getHybridRouterView(widget.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(routerLinkElement?.getAttribute('title') ?? 'Cupertino Gallery'),
      ),
      body: WebFRouterView(controller: controller, path: widget.path),
    );
  }
}
