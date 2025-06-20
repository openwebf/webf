/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/widget.dart';

void main() {
  group('ContentfulWidgetDetector', () {
    test('should detect text widgets as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(Text('Hello')), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(RichText(text: TextSpan(text: 'Hello'))), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(SelectableText('Hello')), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(DefaultTextStyle(
        style: TextStyle(),
        child: Text('Hello'),
      )), isTrue);
    });

    test('should detect image widgets as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(Image.asset('test.png')), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(RawImage(image: null)), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(Icon(Icons.star)), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(ImageIcon(AssetImage('test.png'))), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(FadeInImage.assetNetwork(
        placeholder: 'placeholder.png',
        image: 'https://example.com/image.png',
      )), isTrue);
    });

    test('should detect graphics widgets as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(CustomPaint()), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(CircleAvatar()), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(DrawerHeader(child: Text('Header'))), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(UserAccountsDrawerHeader(
        accountName: Text('Name'),
        accountEmail: Text('Email'),
      )), isTrue);
    });

    test('should detect decorated containers as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(DecoratedBox(
        decoration: BoxDecoration(color: Colors.red),
      )), isTrue);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(Container(
        color: Colors.blue,
      )), isTrue);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
        ),
      )), isTrue);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(ColoredBox(
        color: Colors.green,
      )), isTrue);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(PhysicalModel(
        color: Colors.black,
        child: SizedBox(),
      )), isTrue);
    });

    test('should detect progress indicators as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(CircularProgressIndicator()), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(LinearProgressIndicator()), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(RefreshProgressIndicator()), isTrue);
      expect(ContentfulWidgetDetector.isContentfulWidget(CupertinoActivityIndicator()), isTrue);
    });

    test('should not detect layout-only widgets as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(Row()), isFalse);
      expect(ContentfulWidgetDetector.isContentfulWidget(Column()), isFalse);
      expect(ContentfulWidgetDetector.isContentfulWidget(Stack()), isFalse);
      expect(ContentfulWidgetDetector.isContentfulWidget(Padding(padding: EdgeInsets.all(10))), isFalse);
      expect(ContentfulWidgetDetector.isContentfulWidget(Center()), isFalse);
      expect(ContentfulWidgetDetector.isContentfulWidget(SizedBox()), isFalse);
      expect(ContentfulWidgetDetector.isContentfulWidget(ConstrainedBox(constraints: BoxConstraints())), isFalse);
      expect(ContentfulWidgetDetector.isContentfulWidget(AspectRatio(aspectRatio: 1.0)), isFalse);
    });

    test('should not detect transparent containers as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(Container()), isFalse);
      expect(ContentfulWidgetDetector.isContentfulWidget(Container(
        color: Colors.transparent,
      )), isFalse);
      expect(ContentfulWidgetDetector.isContentfulWidget(ColoredBox(
        color: Colors.black.withOpacity(0),
      )), isFalse);
    });

    test('should not detect invisible widgets as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(Opacity(
        opacity: 0,
        child: Text('Hidden'),
      )), isFalse);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(Visibility(
        visible: false,
        child: Text('Hidden'),
      )), isFalse);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(Offstage(
        offstage: true,
        child: Text('Hidden'),
      )), isFalse);
    });

    test('should detect contentful children in layout widgets', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(Padding(
        padding: EdgeInsets.all(10),
        child: Text('Hello'),
      )), isTrue);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(Center(
        child: Icon(Icons.star),
      )), isTrue);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(Row(
        children: [
          SizedBox(),
          Text('Hello'),
        ],
      )), isTrue);
    });

    test('should detect partially visible opacity widgets as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(Opacity(
        opacity: 0.5,
        child: Text('Semi-transparent'),
      )), isTrue);
    });

    test('should detect visible Visibility widgets as contentful', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(Visibility(
        visible: true,
        child: Text('Visible'),
      )), isTrue);
    });

    test('should handle Card widgets correctly', () {
      expect(ContentfulWidgetDetector.isContentfulWidget(Card(
        color: Colors.white,
        child: Text('Card content'),
      )), isTrue);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(Card(
        color: Colors.transparent,
        child: SizedBox(),
      )), isFalse);
      
      expect(ContentfulWidgetDetector.isContentfulWidget(Card(
        child: Text('Card content'),
      )), isTrue);
    });

    test('hasContentfulChild should recursively check widget tree', () {
      final widget = Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(width: 10),
                Text('Found me!'),
              ],
            ),
          ),
        ],
      );
      
      expect(ContentfulWidgetDetector.hasContentfulChild(widget), isTrue);
    });

    test('hasContentfulChild should return false for empty widget tree', () {
      final widget = Column(
        children: [
          SizedBox(),
          Padding(padding: EdgeInsets.all(10)),
          Row(),
        ],
      );
      
      expect(ContentfulWidgetDetector.hasContentfulChild(widget), isFalse);
    });
  });
}