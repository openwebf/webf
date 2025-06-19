import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebF LCP Integration Test',
      home: Scaffold(
        appBar: AppBar(
          title: Text('WebF LCP Integration Test'),
        ),
        body: Center(
          child: Text('Integration tests are running...'),
        ),
      ),
    );
  }
}