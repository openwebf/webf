/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// ignore_for_file: constant_identifier_names

import 'package:webf/webf.dart';
import 'package:flutter/material.dart';

const String SHIMMER_AVATAR = 'FLUTTER-SHIMMER-AVATAR';

class FlutterShimmerAvatarElement extends WidgetElement {
  FlutterShimmerAvatarElement(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterShimerAvatarElementState(this);
  }
}

class FlutterShimerAvatarElementState extends WebFWidgetElementState {
  FlutterShimerAvatarElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final width = widgetElement.renderStyle.width.value ?? 40.0;
    final height = widgetElement.renderStyle.height.value ?? 40.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

const String SHIMMER_TEXT = 'FLUTTER-SHIMMER-TEXT';

class FlutterShimmerTextElement extends WidgetElement {
  FlutterShimmerTextElement(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterShimmerTextElementState(this);
  }
}

class FlutterShimmerTextElementState extends WebFWidgetElementState {
  FlutterShimmerTextElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final height = widgetElement.renderStyle.height.value ?? 16.0;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

const String SHIMMER_BUTTON = 'FLUTTER-SHIMMER-BUTTON';

class FlutterShimmerButtonElement extends WidgetElement {
  FlutterShimmerButtonElement(super.context);

  @override
  WebFWidgetElementState createState() {
    return FlutterShimmerButtonElementState(this);
  }
}

class FlutterShimmerButtonElementState extends WebFWidgetElementState {
  FlutterShimmerButtonElementState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final width = widgetElement.renderStyle.width.value ??
        double.tryParse(widgetElement.attributes['width'] ?? '') ??
        80.0;

    final height = widgetElement.renderStyle.height.value ??
        double.tryParse(widgetElement.attributes['height'] ?? '') ??
        32.0;

    final borderRadius = double.tryParse(widgetElement.attributes['radius'] ?? '') ?? 4.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
