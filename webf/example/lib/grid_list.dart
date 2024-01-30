import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  debugRepaintRainbowEnabled = true;
  debugRepaintTextRainbowEnabled = true;
  WebF.defineCustomElement('grid-multiple-view', (context) => GridViewElement(context));
  runApp(const MyApp());
}

class GridViewElement extends WidgetElement {
  GridViewElement(super.context);

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return SingleChildScrollView(
        child: RepaintBoundary(
      child: StaggeredGrid.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(children.length, (index) {
          return children[index];
        }),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Grid List';

    WebF? webf;

    return MaterialApp(
      title: title,
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print(webf!.controller!.view.getRootRenderObject().toStringDeep());
          },
        ),
        appBar: AppBar(
          title: const Text(title),
        ),
        body: webf = WebF(
          bundle: WebFBundle.fromUrl('assets:///assets/bundle.html'),
        ),
      ),
    );
  }
}
