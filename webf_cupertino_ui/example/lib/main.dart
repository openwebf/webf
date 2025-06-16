import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebF Cupertino UI Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebF Cupertino UI Examples'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildExampleButton(
            context,
            'Components Gallery',
            'View all Cupertino components',
            ComponentsGalleryPage(),
          ),
          SizedBox(height: 12),
          _buildExampleButton(
            context,
            'Form Example',
            'Cupertino form components demo',
            FormExamplePage(),
          ),
          SizedBox(height: 12),
          _buildExampleButton(
            context,
            'Dialog Examples',
            'Alerts, action sheets, and popups',
            DialogExamplesPage(),
          ),
          SizedBox(height: 12),
          _buildExampleButton(
            context,
            'Navigation Example',
            'Tab bars and navigation',
            NavigationExamplePage(),
          ),
          SizedBox(height: 12),
          _buildExampleButton(
            context,
            'Cupertino Gallery (Vue.js)',
            'Full-featured Vue.js example app',
            CupertinoGalleryPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleButton(
    BuildContext context,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}

class ComponentsGalleryPage extends StatelessWidget {
  const ComponentsGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Components Gallery'),
      ),
      body: WebF.fromControllerName(
        controllerName: 'components-gallery',
        bundle: WebFBundle.fromUrl('assets:///assets/components_gallery.html'),
      ),
    );
  }
}

class FormExamplePage extends StatelessWidget {
  const FormExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Example'),
      ),
      body: WebF.fromControllerName(
        controllerName: 'form-example',
        bundle: WebFBundle.fromUrl('assets:///assets/form_example.html'),
      ),
    );
  }
}

class DialogExamplesPage extends StatelessWidget {
  const DialogExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dialog Examples'),
      ),
      body: WebF.fromControllerName(
        controllerName: 'dialog-examples',
        bundle: WebFBundle.fromUrl('assets:///assets/dialog_examples.html'),
      ),
    );
  }
}

class NavigationExamplePage extends StatelessWidget {
  const NavigationExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation Example'),
      ),
      body: WebF.fromControllerName(
        controllerName: 'navigation-example',
        bundle: WebFBundle.fromUrl('assets:///assets/navigation_example.html'),
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
  // TODO: Replace with your actual Vercel deployment URL
  static const String vercelUrl = 'https://vue-cupertino-gallery.vercel.app/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cupertino Gallery (Vue.js)'),
      ),
      body: WebF.fromControllerName(
        controllerName: 'cupertino-gallery',
        bundle: WebFBundle.fromUrl(vercelUrl),
      ),
    );
  }
}
